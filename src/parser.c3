module calc3::parser;
import calc3::lexer;
import calc3::token;
import calc3::ast;
import std::io;
import std::core;
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

fn Result{ast::ASTNode, ParseError} parse(String src, Allocator allocator)
{
    Parser p;
    p.init(src, allocator);
    if (p.failed) return result::err(p.error);
    if (p.current.kind == EOF)
    {
        return result::ok(ast::create_number(allocator, 0, p.current.ref));
    }
    ast::ASTNode node = p.expression().@or_else(;r) { return r; };
    if (p.failed) return result::err(p.error);
    if (p.current.kind != EOF)
    {
        return result::err({ .ref = p.current.ref, .msg = "Unexpected trailing token" });
    }
    return result::ok(node);
}
