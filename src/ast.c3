module calc3::ast;
import calc3::token;
import std::io;

interface ASTVisitor
{
    fn void visit_number(ASTNumber* node);
    fn void visit_unary(ASTUnary* node);
    fn void visit_binary(ASTBinary* node);
}

interface ASTNode
{
    fn void accept(ASTVisitor visitor);
    fn sz? to_format(Formatter* f);
}

struct ASTNumber (ASTNode, Printable)
{
    token::Ref ref;
    int value;
}

fn void ASTNumber.accept(&self, ASTVisitor visitor) @dynamic
{
    visitor.visit_number(self);
}

fn sz? ASTNumber.to_format(&self, Formatter* f) @dynamic
{
    return f.printf("NUMBER(%d)", self.value);
}

struct ASTUnary (ASTNode, Printable)
{
    token::Ref ref;
    token::TokenKind op;
    ASTNode operand;
}

fn void ASTUnary.accept(&self, ASTVisitor visitor) @dynamic
{
    visitor.visit_unary(self);
}

fn sz? ASTUnary.to_format(&self, Formatter* f) @dynamic
{
    return f.printf("(%s %s)", op_symbol(self.op), self.operand);
}

struct ASTBinary (ASTNode, Printable)
{
    token::Ref ref;
    token::TokenKind op;
    ASTNode left;
    ASTNode right;
}

fn void ASTBinary.accept(&self, ASTVisitor visitor) @dynamic
{
    visitor.visit_binary(self);
}

fn sz? ASTBinary.to_format(&self, Formatter* f) @dynamic
{
    return f.printf("(%s %s %s)", self.left, op_symbol(self.op), self.right);
}

<*
 @require op == token::TokenKind.PLUS || op == token::TokenKind.MINUS || op == token::TokenKind.MUL || op == token::TokenKind.DIV || op == token::TokenKind.MOD : "Not a binary operator"
*>
fn String op_symbol(token::TokenKind op) {
    switch (op) {
        case PLUS: return "+";
        case MINUS: return "-";
        case MUL: return "*";
        case DIV: return "/";
        case MOD: return "%";
        default: return "?";
    }
}

fn ASTNode create_number(Allocator allocator, int value, token::Ref ref)
{
    ASTNumber* node = alloc::new(allocator, ASTNumber, { .ref = ref, .value = value });
    return (ASTNode)node;
}

fn ASTNode create_unary(Allocator allocator, token::TokenKind op, ASTNode operand, token::Ref ref)
{
    ASTUnary* node = alloc::new(allocator, ASTUnary, {
        .ref = ref, .op = op, .operand = operand
    });
    return (ASTNode)node;
}

fn ASTNode create_binary(Allocator allocator, token::TokenKind op, ASTNode left, ASTNode right, token::Ref ref)
{
    ASTBinary* node = alloc::new(allocator, ASTBinary, {
        .ref = ref, .op = op, .left = left, .right = right
    });
    return (ASTNode)node;
}
