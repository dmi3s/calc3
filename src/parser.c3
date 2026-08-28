module calc3::parser;
import calc3::lexer;
import calc3::token;
import calc3::ast;
import calc3::symbol_table;
import std::io;
import std::core;
import std::core::string;
import std::collections::result;

struct ParseError (Printable)
{
    token::Ref ref;
    String msg;
}

fn sz? ParseError.to_format(&self, Formatter* f) @dynamic
{
    return f.printf("%s", token::format_ref_error("ParseError", self.ref, self.msg));
}

struct Parser
{
    Lexer lex;
    Allocator allocator;
    Token current;
    bool failed;
    ParseError error;
}

fn void Parser.init(&self, String src, Allocator allocator)
{
    self.lex.init(src);
    self.allocator = allocator;
    self.failed = false;
    self.advance();
}

fn void Parser.advance(&self)
{
    if (self.failed) return;
    Token? t = self.lex.next();
    if (catch err = t)
    {
        self.failed = true;
        self.error = {
            .ref = self.lex.ref,
            .msg = err == lexer::UNKNOWN_CHAR ? "Unexpected character" : "Integer overflow",
        };
        return;
    }
    self.current = t;
}

fn Result{ast::ASTNode, ParseError} Parser.expression(&self)
{
    return self.equality();
}

fn Result{ast::ASTNode, ParseError} Parser.equality(&self)
{
    if (self.failed) return result::err(self.error);
    ast::ASTNode node = self.relational().@or_else(;r) { return r; };
    while (self.current.kind == EQEQ || self.current.kind == NEQ)
    {
        token::Ref ref = self.current.ref;
        token::TokenKind op = self.current.kind;
        self.advance();
        if (self.failed) return result::err(self.error);
        ast::ASTNode right = self.relational().@or_else(;r) { return r; };
        node = ast::create_binary(self.allocator, op, node, right, ref);
    }
    return result::ok(node);
}

fn Result{ast::ASTNode, ParseError} Parser.relational(&self)
{
    if (self.failed) return result::err(self.error);
    ast::ASTNode node = self.additive().@or_else(;r) { return r; };
    while (self.current.kind == LESS || self.current.kind == GREATER || self.current.kind == LEQ || self.current.kind == GEQ)
    {
        token::Ref ref = self.current.ref;
        token::TokenKind op = self.current.kind;
        self.advance();
        if (self.failed) return result::err(self.error);
        ast::ASTNode right = self.additive().@or_else(;r) { return r; };
        node = ast::create_binary(self.allocator, op, node, right, ref);
    }
    return result::ok(node);
}

fn Result{ast::ASTNode, ParseError} Parser.additive(&self)
{
    if (self.failed) return result::err(self.error);
    ast::ASTNode node = self.term().@or_else(;r) { return r; };
    while (self.current.kind == PLUS || self.current.kind == MINUS)
    {
        token::Ref ref = self.current.ref;
        token::TokenKind op = self.current.kind;
        self.advance();
        if (self.failed) return result::err(self.error);
        ast::ASTNode right = self.term().@or_else(;r) { return r; };
        node = ast::create_binary(self.allocator, op, node, right, ref);
    }
    return result::ok(node);
}

fn Result{ast::ASTNode, ParseError} Parser.term(&self)
{
    if (self.failed) return result::err(self.error);
    ast::ASTNode node = self.factor().@or_else(;r) { return r; };
    while (self.current.kind == MUL || self.current.kind == DIV || self.current.kind == MOD)
    {
        token::Ref ref = self.current.ref;
        token::TokenKind op = self.current.kind;
        self.advance();
        if (self.failed) return result::err(self.error);
        ast::ASTNode right = self.factor().@or_else(;r) { return r; };
        node = ast::create_binary(self.allocator, op, node, right, ref);
    }
    return result::ok(node);
}

fn Result{ast::ASTNode, ParseError} Parser.factor(&self)
{
    if (self.failed) return result::err(self.error);
    if (self.current.kind == PLUS || self.current.kind == MINUS)
    {
        token::Ref ref = self.current.ref;
        token::TokenKind op = self.current.kind;
        self.advance();
        if (self.failed) return result::err(self.error);
        ast::ASTNode operand = self.factor().@or_else(;r) { return r; };
        return result::ok(ast::create_unary(self.allocator, op, operand, ref));
    }
    return self.primary();
}

fn Result{ast::ASTNode, ParseError} Parser.primary(&self)
{
    if (self.failed) return result::err(self.error);
    if (self.current.kind == IDENT && self.current.name.compare_to("if") == 0)
    {
        return self.if_expr();
    }
    switch (self.current.kind)
    {
        case NUMBER:
        {
            token::Ref ref = self.current.ref;
            int value = self.current.val.num;
            self.advance();
            if (self.failed) return result::err(self.error);
            return result::ok(ast::create_number(self.allocator, value, ref));
        }
        case IDENT:
        {
            String name = self.current.name;
            token::Ref ref = self.current.ref;
            self.advance();
            if (self.failed) return result::err(self.error);
            if (self.current.kind == LPAREN)
            {
                self.advance();
                if (self.failed) return result::err(self.error);
                ast::ASTNode[16] args;
                usz argc = 0;
                if (self.current.kind != RPAREN)
                {
                    while (true)
                    {
                        ast::ASTNode a = self.expression().@or_else(;r) { return r; };
                        if (argc >= 16) return result::err({ .ref = self.current.ref, .msg = "Too many arguments" });
                        args[argc] = a;
                        argc++;
                        if (self.current.kind == RPAREN) break;
                        if (self.current.kind != COMMA)
                        {
                            return result::err({ .ref = self.current.ref, .msg = "Expected ',' or ')'" });
                        }
                        self.advance();
                        if (self.failed) return result::err(self.error);
                    }
                }
                self.advance();
                if (self.failed) return result::err(self.error);
                return result::ok(ast::create_call(self.allocator, name, &args[0], argc, ref));
            }
            return result::ok(ast::create_ident(self.allocator, name, ref));
        }
        case LPAREN:
        {
            self.advance();
            if (self.failed) return result::err(self.error);
            ast::ASTNode inner = self.expression().@or_else(;r) { return r; };
            if (self.current.kind != RPAREN)
            {
                return result::err({ .ref = self.current.ref, .msg = "Expected ')'" });
            }
            self.advance();
            if (self.failed) return result::err(self.error);
            return result::ok(inner);
        }
        case EOF:
            return result::err({ .ref = self.current.ref, .msg = "Unexpected end of input" });
        default:
            return result::err({ .ref = self.current.ref, .msg = "Unexpected token" });
    }
}

fn Result{ast::ASTNode, ParseError} Parser.if_expr(&self)
{
    token::Ref ref = self.current.ref;
    // current == 'if'
    self.advance();
    if (self.failed) return result::err(self.error);
    if (self.current.kind != LPAREN)
    {
        return result::err({ .ref = self.current.ref, .msg = "Expected '(' after 'if'" });
    }
    self.advance();
    if (self.failed) return result::err(self.error);
    ast::ASTNode cond = self.expression().@or_else(;r) { return r; };
    if (self.failed) return result::err(self.error);
    if (self.current.kind != RPAREN)
    {
        return result::err({ .ref = self.current.ref, .msg = "Expected ')'" });
    }
    self.advance();
    if (self.failed) return result::err(self.error);
    if (self.current.kind != LBRACE)
    {
        return result::err({ .ref = self.current.ref, .msg = "Expected '{' after 'if' condition" });
    }
    self.advance();
    if (self.failed) return result::err(self.error);
    ast::ASTNode then_branch = self.expression().@or_else(;r) { return r; };
    if (self.failed) return result::err(self.error);
    if (self.current.kind != RBRACE)
    {
        return result::err({ .ref = self.current.ref, .msg = "Expected '}'" });
    }
    self.advance();
    if (self.failed) return result::err(self.error);
    if (self.current.kind != IDENT || self.current.name.compare_to("else") != 0)
    {
        return result::err({ .ref = self.current.ref, .msg = "Expected 'else'" });
    }
    self.advance();
    if (self.failed) return result::err(self.error);
    if (self.current.kind != LBRACE)
    {
        return result::err({ .ref = self.current.ref, .msg = "Expected '{' after 'else'" });
    }
    self.advance();
    if (self.failed) return result::err(self.error);
    ast::ASTNode else_branch = self.expression().@or_else(;r) { return r; };
    if (self.failed) return result::err(self.error);
    if (self.current.kind != RBRACE)
    {
        return result::err({ .ref = self.current.ref, .msg = "Expected '}'" });
    }
    self.advance();
    if (self.failed) return result::err(self.error);
    return result::ok(ast::create_if(self.allocator, cond, then_branch, else_branch, ref));
}

fn Result{ast::ASTNode, ParseError} Parser.let_stmt(&self)
{
    // current == 'let'
    self.advance();
    if (self.failed) return result::err(self.error);
    if (self.current.kind != IDENT)
    {
        return result::err({ .ref = self.current.ref, .msg = "Expected variable name after 'let'" });
    }
    String name = self.current.name;
    self.advance();
    if (self.failed) return result::err(self.error);
    if (self.current.kind != EQ)
    {
        return result::err({ .ref = self.current.ref, .msg = "Expected '='" });
    }
    self.advance();
    if (self.failed) return result::err(self.error);
    ast::ASTNode value = self.expression().@or_else(;r) { return r; };
    if (self.failed) return result::err(self.error);
    return result::ok(ast::create_let(self.allocator, name, value, self.current.ref));
}

fn Result{symbol_table::Type, ParseError} Parser.parse_type(&self)
{
    if (self.current.name.compare_to("int") == 0) return result::ok(symbol_table::Type.INT);
    return result::err({ .ref = self.current.ref, .msg = string::tformat("Unsupported type '%s'", self.current.name) });
}

fn Result{usz, ParseError} Parser.parse_params(&self, symbol_table::Param* out_params)
{
    usz count = 0;
    if (self.current.kind == RPAREN) return result::ok(0);
    while (true)
    {
        if (self.current.kind != IDENT)
        {
            return result::err({ .ref = self.current.ref, .msg = "Expected parameter type" });
        }
        Type type = self.parse_type().@or_else(;it) { return result::err(it.error); };
        self.advance();
        if (self.failed) return result::err(self.error);
        if (self.current.kind != IDENT)
        {
            return result::err({ .ref = self.current.ref, .msg = "Expected parameter name" });
        }
        if (count >= 16) return result::err({ .ref = self.current.ref, .msg = "Too many parameters" });
        String pname = self.current.name;
        self.advance();
        if (self.failed) return result::err(self.error);
        out_params[count] = { .type = type, .name = pname };
        count++;
        if (self.current.kind == RPAREN) break;
        if (self.current.kind != COMMA)
        {
            return result::err({ .ref = self.current.ref, .msg = "Expected ',' or ')'" });
        }
        self.advance();
        if (self.failed) return result::err(self.error);
    }
    return result::ok(count);
}

fn Result{ast::ASTNode, ParseError} Parser.fn_stmt(&self)
{
    // current == 'fn'
    self.advance();
    if (self.failed) return result::err(self.error);
    // return type
    if (self.current.kind != IDENT)
    {
        return result::err({ .ref = self.current.ref, .msg = "Expected return type" });
    }
    Type ret_type = self.parse_type().@or_else(;it) { return result::err(it.error); };
    self.advance();
    if (self.failed) return result::err(self.error);
    if (self.current.kind != IDENT)
    {
        return result::err({ .ref = self.current.ref, .msg = "Expected function name" });
    }
    String name = self.current.name;
    self.advance();
    if (self.failed) return result::err(self.error);
    if (self.current.kind != LPAREN)
    {
        return result::err({ .ref = self.current.ref, .msg = "Expected '('" });
    }
    self.advance();
    if (self.failed) return result::err(self.error);
    symbol_table::Param[16] params;
    usz param_count = self.parse_params(&params[0]).@or_else(;r) { return result::err(r.error); };
    if (self.current.kind != RPAREN)
    {
        return result::err({ .ref = self.current.ref, .msg = "Expected ')'" });
    }
    self.advance();
    if (self.failed) return result::err(self.error);
    if (self.current.kind != LBRACE)
    {
        return result::err({ .ref = self.current.ref, .msg = "Expected '{'" });
    }
    self.advance();
    if (self.failed) return result::err(self.error);
    ast::ASTNode body = self.expression().@or_else(;r) { return r; };
    if (self.failed) return result::err(self.error);
    if (self.current.kind != RBRACE)
    {
        return result::err({ .ref = self.current.ref, .msg = "Expected '}'" });
    }
    self.advance();
    if (self.failed) return result::err(self.error);
    return result::ok(ast::create_fundef(self.allocator, name, ret_type, &params[0], param_count, body, self.current.ref));
}

fn Result{ast::ASTNode, ParseError} Parser.program(&self)
{
    if (self.failed) return result::err(self.error);
    if (self.current.kind == IDENT)
    {
        if (self.current.name.compare_to("let") == 0) return self.let_stmt();
        if (self.current.name.compare_to("fn") == 0) return self.fn_stmt();
    }
    return self.expression();
}

fn Result{ast::ASTNode, ParseError} parse(String src, Allocator allocator)
{
    Parser p;
    p.init(src, allocator);
    if (p.failed) return result::err(p.error);
    if (p.current.kind == EOF)
    {
        return result::ok(ast::create_number(allocator, 0, p.current.ref));
    }
    ast::ASTNode node = p.program().@or_else(;r) { return r; };
    if (p.failed) return result::err(p.error);
    if (p.current.kind != EOF)
    {
        return result::err({ .ref = p.current.ref, .msg = "Unexpected trailing token" });
    }
    return result::ok(node);
}
