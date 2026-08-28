module calc3::main;
import calc3::ast;
import calc3::parser;
import std::collections::result;
import std::core;
import std::core::string;
import std::io;

fn String process_line(String src, Allocator allocator)
{
    if (src.len == 1 && src == "?")
    {
        return "42";
    }
    Result{ast::ASTNode, parser::ParseError} r = parser::parse(src, allocator);
    if (r.is_ok)
    {
        String rpn = ast::to_rpn(r.value, allocator);
        Result{int, ast::EvalError} res = ast::eval(r.value, allocator);
        if (res.is_ok)
        {
            return string::tformat("%s\n%d", rpn, res.value);
        }
        return string::tformat("%s\nerror: %s", rpn, res.error);
    }
    return string::tformat("error: %s", r.error);
}

fn void process(String src)
{
    @pool()
    {
        if (src.len == 1 && src == "?")
        {
            io::print("Result:\n42\n");
            return;
        }
        Result{ast::ASTNode, parser::ParseError} r = parser::parse(src, tmem);
        if (r.is_ok)
        {
            io::print("=== AST (Abstract syntax tree) ===\n");
            io::print(ast::to_tree(r.value, tmem));
            io::print("\n");

            String rpn = ast::to_rpn(r.value, tmem);
            io::print("=== RPN (Reverse Polish notation) ===\n");
            io::print(rpn);
            io::print("\n\n");

            Result{int, ast::EvalError} res = ast::eval(r.value, tmem);
            io::print("=== Result (Eval) ===\n");
            if (res.is_ok)
            {
                io::print(string::tformat("%d", res.value));
            }
            else
            {
                io::print(string::tformat("error: %s", res.error));
            }
            io::print("\n");
        }
        else
        {
            io::print(string::tformat("error: %s", r.error));
            io::print("\n");
        }
    };
}

fn void main() {
    while (true)
    {
        String? line = io::treadline(io::stdin());
        if (catch err = line)
        {
            if (err == io::EOF) break;
            return;
        }
        process(line);
    }
}
