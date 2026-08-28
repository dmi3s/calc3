module calc3::symbol_table;
import calc3::ast;
import std::collections::map;
import std::core;
import std::core::string;

const sz MAX_CALL_DEPTH = 256;

struct VarSymbol
{
    int value;
}

struct FunctionDef
{
    String param;
    ast::ASTNode body;
}

struct Scope
{
    HashMap { String, VarSymbol } vars;
    HashMap { String, FunctionDef } funcs;
}

struct SymbolTable
{
    Scope global;
    Scope[MAX_CALL_DEPTH] frames;
    sz frame_count;
    Allocator allocator;
}

fn void SymbolTable.init(&self, Allocator allocator)
{
    self.allocator = allocator;
    self.frame_count = 0;
    self.global.vars.init(allocator);
    self.global.funcs.init(allocator);
}

fn VarSymbol*? SymbolTable.lookup_var(&self, String name)
{
    for (sz i = self.frame_count; i > 0; i--)
    {
        VarSymbol*? found = self.frames[i - 1].vars.get_ref(name);
        if (catch err = found) continue;
        return found;
    }
    return self.global.vars.get_ref(name);
}

fn FunctionDef*? SymbolTable.lookup_func(&self, String name)
{
    return self.global.funcs.get_ref(name);
}

fn void SymbolTable.bind_var(&self, String name, int value)
{
    Scope* cur = self.frame_count ? &self.frames[self.frame_count - 1] : &self.global;
    cur.vars.set(name, { .value = value });
}

fn void SymbolTable.register_func(&self, String name, String param, ast::ASTNode body)
{
    self.global.funcs.set(name, { .param = param, .body = body });
}

fn void SymbolTable.push_call_scope(&self, String param, int value)
{
    if (self.frame_count >= MAX_CALL_DEPTH)
    {
        return;
    }
    Scope frame;
    frame.vars.init(self.allocator);
    frame.funcs.init(self.allocator);
    frame.vars.set(param, { .value = value });
    self.frames[self.frame_count] = frame;
    self.frame_count++;
}

fn void SymbolTable.pop_call_scope(&self)
{
    if (self.frame_count) self.frame_count--;
}
