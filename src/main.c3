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
        io::print(process_line(src, tmem));
        io::print("\n");
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
