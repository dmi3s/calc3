module calc3::main;
import calc3::ast;
import calc3::parser;
import std::collections::result;
import std::core;
import std::io;

fn void main() {
    String src = "( 42 % 2 )\t\t-324";
    log::info("\"%s\"", src);
    Result{ast::ASTNode, parser::ParseError} r = parser::parse(src, tmem);
    if (r.is_ok)
    {
        io::print(ast::to_tree(r.value, tmem));
        io::print("\n");
        io::print(ast::to_rpn(r.value, tmem));
        io::print("\n");
    }
    else
    {
        log::error("%s", r.error);
    }
}
