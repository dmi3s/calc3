module calc3::ast;
import calc3::token;
import calc3::symbol_table;
import std::core;
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
    fn void visit_if(ASTIf* node);
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
    symbol_table::Type ret_type;
    symbol_table::Param[16] params;
    usz param_count;
    ASTNode body;
}

fn void ASTFunDef.accept(&self, ASTVisitor visitor) @dynamic
{
    visitor.visit_fundef(self);
}

fn sz? ASTFunDef.to_format(&self, Formatter* f) @dynamic
{
    (void)f.printf("(fn %s(", self.name);
    for (sz i = 0; i < (sz)self.param_count; i++)
    {
        if (i > 0) (void)f.printf(",");
        (void)f.printf("%s", self.params[i].name);
    }
    return f.printf(") %s)", self.body);
}

struct ASTCall (ASTNode, Printable)
{
    token::Ref ref;
    String name;
    ASTNode[16] args;
    usz argc;
}

fn void ASTCall.accept(&self, ASTVisitor visitor) @dynamic
{
    visitor.visit_call(self);
}

fn sz? ASTCall.to_format(&self, Formatter* f) @dynamic
{
    (void)f.printf("(%s", self.name);
    for (sz i = 0; i < (sz)self.argc; i++)
    {
        (void)f.printf(" ");
        (void)f.printf("%s", self.args[i]);
    }
    return f.printf(")");
}

struct ASTIf (ASTNode, Printable)
{
    token::Ref ref;
    ASTNode cond;
    ASTNode then_branch;
    ASTNode else_branch;
}

fn void ASTIf.accept(&self, ASTVisitor visitor) @dynamic
{
    visitor.visit_if(self);
}

fn sz? ASTIf.to_format(&self, Formatter* f) @dynamic
{
    return f.printf("(if %s %s %s)", self.cond, self.then_branch, self.else_branch);
}

<*
 @require op == token::TokenKind.PLUS || op == token::TokenKind.MINUS || op == token::TokenKind.MUL || op == token::TokenKind.DIV || op == token::TokenKind.MOD || op == token::TokenKind.EQEQ || op == token::TokenKind.NEQ || op == token::TokenKind.LESS || op == token::TokenKind.GREATER || op == token::TokenKind.LEQ || op == token::TokenKind.GEQ : "Not a binary operator"
*>
fn String op_symbol(token::TokenKind op) {
    switch (op) {
        case PLUS: return "+";
        case MINUS: return "-";
        case MUL: return "*";
        case DIV: return "/";
        case MOD: return "%";
        case EQEQ: return "==";
        case NEQ: return "!=";
        case LESS: return "<";
        case GREATER: return ">";
        case LEQ: return "<=";
        case GEQ: return ">=";
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

fn ASTNode create_fundef(Allocator allocator, String name, symbol_table::Type ret_type, symbol_table::Param* params, usz param_count, ASTNode body, token::Ref ref)
{
    ASTFunDef* node = alloc::new(allocator, ASTFunDef, {
        .ref = ref, .name = name, .ret_type = ret_type, .param_count = param_count, .body = body
    });
    for (sz i = 0; i < (sz)param_count; i++) node.params[i] = params[i];
    return (ASTNode)node;
}

fn ASTNode create_call(Allocator allocator, String name, ASTNode* args, usz argc, token::Ref ref)
{
    ASTCall* node = alloc::new(allocator, ASTCall, {
        .ref = ref, .name = name, .argc = argc
    });
    for (sz i = 0; i < (sz)argc; i++) node.args[i] = args[i];
    return (ASTNode)node;
}

fn ASTNode create_if(Allocator allocator, ASTNode cond, ASTNode then_branch, ASTNode else_branch, token::Ref ref)
{
    ASTIf* node = alloc::new(allocator, ASTIf, {
        .ref = ref, .cond = cond, .then_branch = then_branch, .else_branch = else_branch
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
    io::printf("FunDef \"%s\":\n", node.name);
    node.body.accept(self);
}

fn void ASTestVisitor.visit_call(&self, ast::ASTCall* node) @dynamic
{
    io::printf("Call \"%s\":\n", node.name);
    foreach (a : node.args) a.accept(self);
}

fn void ASTestVisitor.visit_if(&self, ast::ASTIf* node) @dynamic
{
    io::printf("If:\n");
    io::printf("cond:\n");
    node.cond.accept(self);
    io::printf("then:\n");
    node.then_branch.accept(self);
    io::printf("else:\n");
    node.else_branch.accept(self);
}
