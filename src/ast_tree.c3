module calc3::ast;
import calc3::token;
import std::core;

struct ASTreeContext
{
    Allocator allocator;
    DString out;
    bool[] ancestor_is_last;
    sz depth;
    bool is_last;
}

struct ASTreeVisitor (ASTVisitor)
{
    ASTreeContext* ctx;
}

fn ASTreeVisitor make_tree_visitor(Allocator allocator)
{
    ASTreeVisitor v;
    v.ctx = alloc::new(allocator, ASTreeContext, {});
    v.ctx.allocator = allocator;
    v.ctx.out.init(allocator);
    v.ctx.ancestor_is_last = alloc::new_array(allocator, bool, 16);
    v.ctx.depth = 0;
    v.ctx.is_last = false;
    return v;
}

fn void ASTreeVisitor.reserve_ancestors(&self)
{
    if (self.ctx.depth < self.ctx.ancestor_is_last.len) return;
    bool[] grown = alloc::realloc_array(self.ctx.allocator,
        self.ctx.ancestor_is_last.ptr, bool, self.ctx.ancestor_is_last.len * 2);
    self.ctx.ancestor_is_last = grown;
}

fn void ASTreeVisitor.append_line(&self, String label)
{
    if (self.ctx.depth == 0)
    {
        self.ctx.out.append_string(label);
        self.ctx.out.append_char('\n');
        return;
    }
    for (sz i = 0; i < self.ctx.depth - 1; i++)
    {
        self.ctx.out.append_string(self.ctx.ancestor_is_last[i] ? "    " : "│   ");
    }
    self.ctx.out.append_string(self.ctx.is_last ? "└── " : "├── ");
    self.ctx.out.append_string(label);
    self.ctx.out.append_char('\n');
}

fn void ASTreeVisitor.visit_number(&self, ASTNumber* node) @dynamic
{
    self.append_line(string::tformat("NUM(%d) (%d:%d)",
        node.value, node.ref.row, node.ref.col));
}

fn void ASTreeVisitor.visit_unary(&self, ASTUnary* node) @dynamic
{
    self.append_line(string::tformat("UNARY(%s) (%d:%d)",
        op_symbol(node.op), node.ref.row, node.ref.col));
    self.reserve_ancestors();
    if (self.ctx.depth >= 1) self.ctx.ancestor_is_last[self.ctx.depth - 1] = self.ctx.is_last;
    self.ctx.depth++;
    self.ctx.is_last = true;
    node.operand.accept(self);
    self.ctx.depth--;
}

fn void ASTreeVisitor.visit_binary(&self, ASTBinary* node) @dynamic
{
    self.append_line(string::tformat("BIN(%s) (%d:%d)",
        op_symbol(node.op), node.ref.row, node.ref.col));
    self.reserve_ancestors();
    if (self.ctx.depth >= 1) self.ctx.ancestor_is_last[self.ctx.depth - 1] = self.ctx.is_last;
    self.ctx.depth++;
    self.ctx.is_last = false;
    node.left.accept(self);
    self.ctx.is_last = true;
    node.right.accept(self);
    self.ctx.depth--;
}

fn String ASTreeVisitor.to_string(&self)
{
    return self.ctx.out.str_view();
}

fn String to_tree(ASTNode root, Allocator allocator)
{
    ASTreeVisitor v = make_tree_visitor(allocator);
    root.accept(&v);
    return v.to_string();
}