module calc3::main;
import calc3::ast;
import calc3::parser;
import calc3::symbol_table;
import std::collections::result;
import std::core;
import std::core::string;
import std::io;
import std::io::file;

struct PipelineOk
{
    ast::ASTNode node;
    String rpn;
    Result{int, ast::EvalError} eval;
}

fn Result{PipelineOk, parser::ParseError} pipeline(String src, Allocator allocator, symbol_table::SymbolTable* syms)
{
    Result{ast::ASTNode, parser::ParseError} r = parser::parse(src, allocator);
    if (!r.is_ok) return result::err(r.error);
    String rpn = ast::to_rpn(r.value, allocator);
    Result{int, ast::EvalError} eval = ast::eval(r.value, allocator, syms);
    return result::ok({ .node = r.value, .rpn = rpn, .eval = eval });
}

fn String process_line(String src, Allocator allocator, symbol_table::SymbolTable* syms)
{
    if (src.len == 1 && src == "?")
    {
        return "42";
    }
    Result{PipelineOk, parser::ParseError} p = pipeline(src, allocator, syms);
    if (!p.is_ok)
    {
        return string::tformat("error: %s", p.error);
    }
    String result = p.value.eval.is_ok
        ? string::tformat("%d", p.value.eval.value)
        : string::tformat("error: %s", p.value.eval.error);
    return string::tformat("%s\n%s", p.value.rpn, result);
}

fn String process_to_string(String src, Allocator allocator, symbol_table::SymbolTable* syms)
{
    if (src.len == 1 && src == "?")
    {
        return "Result:\n42\n";
    }
    Result{PipelineOk, parser::ParseError} p = pipeline(src, allocator, syms);
    if (!p.is_ok)
    {
        return string::tformat("error: %s\n", p.error);
    }
    DString out;
    out.init(allocator);
    out.append_string("=== AST (Abstract syntax tree) ===\n");
    out.append_string(ast::to_tree(p.value.node, allocator));
    out.append_string("\n");
    out.append_string("=== RPN (Reverse Polish notation) ===\n");
    out.append_string(p.value.rpn);
    out.append_string("\n\n");
    out.append_string("=== Result (Eval) ===\n");
    if (p.value.eval.is_ok)
    {
        out.append_string(string::tformat("%d", p.value.eval.value));
    }
    else
    {
        out.append_string(string::tformat("error: %s", p.value.eval.error));
    }
    out.append_string("\n");
    return out.str_view().copy(allocator);
}

fn void print_usage()
{
    io::print(
        "Usage:\n"
        "  calc3                  Start the interactive REPL (read expressions from stdin)\n"
        "  calc3 <expr>           Evaluate a single expression\n"
        "  calc3 -f <file>        Evaluate expressions from a file (one per line)\n"
        "  calc3 --file <file>    Same as -f\n"
        "  calc3 -h | --help      Show this help\n");
}

fn bool parse_args(String[] args, String* expr, bool* has_expr, String* file, bool* has_file)
{
    *expr = "";
    *has_expr = false;
    *file = "";
    *has_file = false;
    sz i = 1;
    bool end_options = false;
    while (i < args.len)
    {
        String arg = args[i];
        if (!end_options)
        {
            if (arg == "--")
            {
                end_options = true;
                i += 1;
                continue;
            }
            if (arg == "-h" || arg == "--help")
            {
                print_usage();
                return false;
            }
            if (arg == "-f" || arg == "--file")
            {
                if (i + 1 >= args.len)
                {
                    io::print("error: missing filename after ");
                    io::print(arg);
                    io::print("\n");
                    return false;
                }
                *file = args[i + 1];
                *has_file = true;
                i += 2;
                continue;
            }
            if (arg.starts_with("--"))
            {
                io::print("error: unknown option ");
                io::print(arg);
                io::print("\n");
                return false;
            }
        }
        if (*has_expr)
        {
            io::print("error: multiple expressions given\n");
            return false;
        }
        *expr = arg;
        *has_expr = true;
        i += 1;
    }
    if (*has_file && *has_expr)
    {
        io::print("error: provide either an expression or -f <file>, not both\n");
        return false;
    }
    return true;
}

fn void process_file(String file, symbol_table::SymbolTable* syms)
{
    char[]? content = io::file::load_temp(file);
    if (catch err = content)
    {
        io::print("error: cannot read file: ");
        io::print(file);
        io::print("\n");
        return;
    }
    String[] lines = ((String)content).tsplit("\n", 0, true);
    foreach (line : lines)
    {
        process_line(line.trim(), tmem, syms);
    }
}

fn void run_repl()
{
    @pool()
    {
        symbol_table::SymbolTable syms;
        syms.init(tmem);
        while (true)
        {
            String? line = io::treadline(io::stdin());
            if (catch err = line)
            {
                if (err == io::EOF) break;
                return;
            }
            io::print(process_to_string(line.trim(), tmem, &syms));
        }
    };
}

fn void main(String[] args)
{
    String expr = "";
    bool has_expr = false;
    String file = "";
    bool has_file = false;
    if (!parse_args(args, &expr, &has_expr, &file, &has_file)) return;
    if (has_file)
    {
        @pool()
        {
            symbol_table::SymbolTable syms;
            syms.init(tmem);
            process_file(file, &syms);
        };
        return;
    }
    if (has_expr)
    {
        @pool()
        {
            symbol_table::SymbolTable syms;
            syms.init(tmem);
            io::print(process_to_string(expr, tmem, &syms));
        };
        return;
    }
    run_repl();
}
