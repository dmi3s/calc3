module calc3::ast;
import calc3::token;
import calc3::symbol_table;
import std::collections::result;
import std::core;
import std::core::string;
import std::io;
import std::math;

struct EvalError (Printable)
{
    token::Ref ref;
    String msg;
}

fn sz? EvalError.to_format(&self, Formatter* f) @dynamic
{
    return f.printf("%s", token::format_ref_error("EvalError", self.ref, self.msg));
}

struct EvalContext
{
    int result;
    bool failed;
    EvalError error;
}

struct EvalVisitor (ASTVisitor)
{
    EvalContext* ctx;
    symbol_table::SymbolTable* syms;
}

fn EvalVisitor make_eval_visitor(Allocator allocator, symbol_table::SymbolTable* syms)
{
    EvalVisitor v;
    v.ctx = alloc::new(allocator, EvalContext, {});
    v.syms = syms;
    return v;
}

fn void EvalVisitor.fail(&self, token::Ref ref, String msg)
{
    self.ctx.failed = true;
    self.ctx.error = { .ref = ref, .msg = msg };
}

fn void EvalVisitor.visit_number(&self, ASTNumber* node) @dynamic
{
    self.ctx.result = node.value;
}

fn void EvalVisitor.visit_unary(&self, ASTUnary* node) @dynamic
{
    node.operand.accept(self);
    if (self.ctx.failed) return;
    if (node.op == token::TokenKind.MINUS)
    {
        if (self.ctx.result == int::min)
        {
            self.fail(node.ref, "Integer overflow");
            return;
        }
        self.ctx.result = -self.ctx.result;
    }
}

fn bool EvalVisitor.apply_binary(&self, token::TokenKind op, int left, int right, token::Ref ref)
{
    switch (op)
    {
        case token::TokenKind.PLUS:
        {
            int? res = left.overflow_add(right);
            if (catch err = res)
            {
                self.fail(ref, "Integer overflow");
                return false;
            }
            self.ctx.result = res;
            return true;
        }
        case token::TokenKind.MINUS:
        {
            int? res = left.overflow_sub(right);
            if (catch err = res)
            {
                self.fail(ref, "Integer overflow");
                return false;
            }
            self.ctx.result = res;
            return true;
        }
        case token::TokenKind.MUL:
        {
            int? res = left.overflow_mul(right);
            if (catch err = res)
            {
                self.fail(ref, "Integer overflow");
                return false;
            }
            self.ctx.result = res;
            return true;
        }
        case token::TokenKind.DIV:
        case token::TokenKind.MOD:
            if (right == 0)
            {
                self.fail(ref, "Division by zero");
                return false;
            }
            if (left == int::min && right == -1)
            {
                self.fail(ref, "Integer overflow");
                return false;
            }
            self.ctx.result = op == token::TokenKind.DIV ? left / right : left % right;
            return true;
        default:
            self.fail(ref, "Unknown operator");
            return false;
    }
}

fn void EvalVisitor.visit_binary(&self, ASTBinary* node) @dynamic
{
    node.left.accept(self);
    if (self.ctx.failed) return;
    int left = self.ctx.result;
    node.right.accept(self);
    if (self.ctx.failed) return;
    int right = self.ctx.result;
    self.apply_binary(node.op, left, right, node.ref);
}

fn void EvalVisitor.visit_ident(&self, ASTIdent* node) @dynamic
{
    VarSymbol*? v = self.syms.lookup_var(node.name);
    if (catch err = v)
    {
        self.fail(node.ref, "Unknown variable");
        return;
    }
    VarSymbol* vs = v;
    self.ctx.result = vs.value;
}

fn void EvalVisitor.visit_let(&self, ASTLet* node) @dynamic
{
    node.value.accept(self);
    if (self.ctx.failed) return;
    int val = self.ctx.result;
    self.syms.bind_var(node.name, val);
    self.ctx.result = val;
}

fn void EvalVisitor.visit_fundef(&self, ASTFunDef* node) @dynamic
{
    self.syms.register_func(node.name, node.param, node.body);
    self.ctx.result = 0;
}

fn void EvalVisitor.visit_call(&self, ASTCall* node) @dynamic
{
    if (node.name.compare_to("ask") == 0)
    {
        io::printf("? ");
        String? line = io::treadline(io::stdin());
        if (catch err = line)
        {
            self.fail(node.ref, "Input read failed");
            return;
        }
        int? val = line.trim().to_int();
        if (catch err = val)
        {
            self.fail(node.ref, "Invalid integer input");
            return;
        }
        self.ctx.result = val;
        return;
    }
    FunctionDef*? f = self.syms.lookup_func(node.name);
    if (catch err = f)
    {
        self.fail(node.ref, "Unknown function");
        return;
    }
    FunctionDef* func = f;
    node.arg.accept(self);
    if (self.ctx.failed) return;
    int argval = self.ctx.result;
    self.syms.push_call_scope(func.param, argval);
    func.body.accept(self);
    self.syms.pop_call_scope();
}

<*
 @require root != null : "Root node must not be null"
*>
fn Result{int, EvalError} eval(ASTNode root, Allocator allocator, symbol_table::SymbolTable* syms)
{
    EvalVisitor v = make_eval_visitor(allocator, syms);
    root.accept(&v);
    if (v.ctx.failed) return result::err(v.ctx.error);
    return result::ok(v.ctx.result);
}
