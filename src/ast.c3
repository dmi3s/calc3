module calc3::ast;
import calc3::token;
import std::io;

interface ASTVisitor
{
    fn void visit_number(ASTNumber* node);
    fn void visit_unary(ASTUnary* node);
    fn void visit_binary(ASTBinary* node);
    fn void visit_ident(ASTIdent* node);
    fn void visit_let(ASTLet* node);
    fn void visit_fundef(ASTFunDef* node);
    fn void visit_call(ASTCall* node);
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

struct ASTIdent (ASTNode, Printable)
{
    token::Ref ref;
    String name;
}

fn void ASTIdent.accept(&self, ASTVisitor visitor) @dynamic
{
    visitor.visit_ident(self);
}

fn sz? ASTIdent.to_format(&self, Formatter* f) @dynamic
{
    return f.printf("IDENT(%s)", self.name);
}

struct ASTLet (ASTNode, Printable)
{
    token::Ref ref;
    String name;
    ASTNode value;
}

fn void ASTLet.accept(&self, ASTVisitor visitor) @dynamic
{
    visitor.visit_let(self);
}

fn sz? ASTLet.to_format(&self, Formatter* f) @dynamic
{
    return f.printf("(let %s %s)", self.name, self.value);
}

struct ASTFunDef (ASTNode, Printable)
{
    token::Ref ref;
    String name;
    String param;
    ASTNode body;
}

fn void ASTFunDef.accept(&self, ASTVisitor visitor) @dynamic
{
    visitor.visit_fundef(self);
}

fn sz? ASTFunDef.to_format(&self, Formatter* f) @dynamic
{
    return f.printf("(fn %s(%s) %s)", self.name, self.param, self.body);
}

struct ASTCall (ASTNode, Printable)
{
    token::Ref ref;
    String name;
    ASTNode arg;
}

fn void ASTCall.accept(&self, ASTVisitor visitor) @dynamic
{
    visitor.visit_call(self);
}

fn sz? ASTCall.to_format(&self, Formatter* f) @dynamic
{
    return f.printf("(%s %s)", self.name, self.arg);
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

fn ASTNode create_ident(Allocator allocator, String name, token::Ref ref)
{
    ASTIdent* node = alloc::new(allocator, ASTIdent, { .ref = ref, .name = name });
    return (ASTNode)node;
}

fn ASTNode create_let(Allocator allocator, String name, ASTNode value, token::Ref ref)
{
    ASTLet* node = alloc::new(allocator, ASTLet, {
        .ref = ref, .name = name, .value = value
    });
    return (ASTNode)node;
}

fn ASTNode create_fundef(Allocator allocator, String name, String param, ASTNode body, token::Ref ref)
{
    ASTFunDef* node = alloc::new(allocator, ASTFunDef, {
        .ref = ref, .name = name, .param = param, .body = body
    });
    return (ASTNode)node;
}

fn ASTNode create_call(Allocator allocator, String name, ASTNode arg, token::Ref ref)
{
    ASTCall* node = alloc::new(allocator, ASTCall, {
        .ref = ref, .name = name, .arg = arg
    });
    return (ASTNode)node;
}

struct ASTestVisitor (ast::ASTVisitor)
{
    void* dummy;
}

fn void ASTestVisitor.visit_number(&self, ast::ASTNumber* node) @dynamic
{
    io::printf("Number: %d\n", node.value);
}

fn void ASTestVisitor.visit_unary(&self, ast::ASTUnary* node) @dynamic
{
    io::printf("Unary \"%s\":\n", op_symbol(node.op));
    node.operand.accept(self);
}

fn void ASTestVisitor.visit_binary(&self, ast::ASTBinary* node) @dynamic
{
    io::printf("Binary \"%s\":\n", op_symbol(node.op));
    io::printf("left:\n");
    node.left.accept(self);
    io::printf("right:\n");
    node.right.accept(self);
}

fn void ASTestVisitor.visit_ident(&self, ast::ASTIdent* node) @dynamic
{
    io::printf("Ident: %s\n", node.name);
}

fn void ASTestVisitor.visit_let(&self, ast::ASTLet* node) @dynamic
{
    io::printf("Let \"%s\":\n", node.name);
    node.value.accept(self);
}

fn void ASTestVisitor.visit_fundef(&self, ast::ASTFunDef* node) @dynamic
{
    io::printf("FunDef \"%s(%s)\":\n", node.name, node.param);
    node.body.accept(self);
}

fn void ASTestVisitor.visit_call(&self, ast::ASTCall* node) @dynamic
{
    io::printf("Call \"%s\":\n", node.name);
    node.arg.accept(self);
}
