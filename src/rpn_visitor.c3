module calc3::ast;
import calc3::token;
import std::core;

struct RPNContext
{
    Allocator allocator;
    DString out;
}

struct RPNVisitor (ASTVisitor)
{
    RPNContext* ctx;
}

fn RPNVisitor make_rpn_visitor(Allocator allocator)
{
    RPNVisitor v;
    v.ctx = alloc::new(allocator, RPNContext, {});
    v.ctx.allocator = allocator;
    v.ctx.out.init(allocator);
    return v;
}

fn void RPNVisitor.append(&self, String tok)
{
    self.ctx.out.append_string(tok);
    self.ctx.out.append_char(' ');
}

fn void RPNVisitor.visit_number(&self, ASTNumber* node) @dynamic
{
    self.append(string::tformat("%d", node.value));
}

fn void RPNVisitor.visit_unary(&self, ASTUnary* node) @dynamic
{
    node.operand.accept(self);
    self.append(node.op == MINUS ? "NEG" : "POS");
}

fn void RPNVisitor.visit_binary(&self, ASTBinary* node) @dynamic
{
    node.left.accept(self);
    node.right.accept(self);
    self.append(op_symbol(node.op));
}

<*
 @require root != null : "Root node must not be null"
*>
fn String to_rpn(ASTNode root, Allocator allocator)
{
    RPNVisitor v = make_rpn_visitor(allocator);
    root.accept(&v);
    return v.ctx.out.str_view().trim_right(" ").copy(allocator);
}