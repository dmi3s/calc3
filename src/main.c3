module calc3::main;
import calc3::ast;
import calc3::parser;
import std::collections::result;
import std::io;

fn void process(String src)
{
    @pool()
    {
        Result{ast::ASTNode, parser::ParseError} r = parser::parse(src, tmem);
        if (r.is_ok)
        {
            io::print(ast::to_rpn(r.value, tmem));
            io::print("\n");
            Result{int, ast::EvalError} res = ast::eval(r.value, tmem);
            if (res.is_ok)
            {
                io::printf("%d\n", res.value);
            }
            else
            {
                io::printf("error: %s\n", res.error);
            }
        }
        else
        {
            io::printf("error: %s\n", r.error);
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
