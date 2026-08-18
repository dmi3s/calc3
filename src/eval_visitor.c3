module calc3::ast;
import calc3::token;
import std::collections::result;
import std::core;
import std::io;
import std::math;

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

fn Result{int, EvalError} eval(ASTNode root, Allocator allocator)
{
    EvalVisitor v = make_eval_visitor(allocator);
    root.accept(&v);
    if (v.ctx.failed) return result::err(v.ctx.error);
    return result::ok(v.ctx.result);
}
