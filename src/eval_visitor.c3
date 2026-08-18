module calc3::ast;
import calc3::token;
import std::collections::result;
import std::core;
import std::io;

struct EvalError (Printable)
{
    token::Ref ref;
    String msg;
}

fn sz? EvalError.to_format(&self, Formatter* f) @dynamic
{
    return f.printf("EvalError(%s at %d:%d)", self.msg, self.ref.row, self.ref.col);
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
}

fn EvalVisitor make_eval_visitor(Allocator allocator)
{
    EvalVisitor v;
    v.ctx = alloc::new(allocator, EvalContext, {});
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
        self.ctx.result = -self.ctx.result;
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
    switch (node.op)
    {
        case token::TokenKind.PLUS:
            self.ctx.result = left + right;
        case token::TokenKind.MINUS:
            self.ctx.result = left - right;
        case token::TokenKind.MUL:
            self.ctx.result = left * right;
        case token::TokenKind.DIV:
            if (right == 0)
            {
                self.fail(node.ref, "Division by zero");
                return;
            }
            self.ctx.result = left / right;
        case token::TokenKind.MOD:
            if (right == 0)
            {
                self.fail(node.ref, "Division by zero");
                return;
            }
            self.ctx.result = left % right;
        default:
            self.fail(node.ref, "Unknown operator");
    }
}

fn Result{int, EvalError} eval(ASTNode root, Allocator allocator)
{
    EvalVisitor v = make_eval_visitor(allocator);
    root.accept(&v);
    if (v.ctx.failed) return result::err(v.ctx.error);
    return result::ok(v.ctx.result);
}
