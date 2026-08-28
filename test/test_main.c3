module calc3::test::main;
import calc3::main;
import calc3::symbol_table;
import std::core::string;

fn void test_answer_question() @test {
    @pool()
    {
        symbol_table::SymbolTable syms;
        syms.init(tmem);
        test::eq(main::process_line("?", tmem, &syms), "42");
    };
}

fn void test_process_line_arithmetic() @test {
    @pool()
    {
        symbol_table::SymbolTable syms;
        syms.init(tmem);
        test::eq(main::process_line("1 + 2", tmem, &syms), "1 2 +\n3");
    };
}

fn void test_process_line_division_by_zero() @test {
    @pool()
    {
        symbol_table::SymbolTable syms;
        syms.init(tmem);
        test::eq(main::process_line("1 / 0", tmem, &syms), "1 0 /\nerror: EvalError(Division by zero at 1:3)");
    };
}

fn void test_process_line_parse_error() @test {
    @pool()
    {
        symbol_table::SymbolTable syms;
        syms.init(tmem);
        test::eq(main::process_line("1 @ 2", tmem, &syms), "error: ParseError(Unexpected character at 1:4)");
    };
}

fn void test_process_to_string_number() @test {
    @pool()
    {
        symbol_table::SymbolTable syms;
        syms.init(tmem);
        test::eq(main::process_to_string("42", tmem, &syms),
            "=== AST (Abstract syntax tree) ===\n"
            "NUM(42) (1:1)\n"
            "\n"
            "=== RPN (Reverse Polish notation) ===\n"
            "42\n"
            "\n"
            "=== Result (Eval) ===\n"
            "42\n");
    };
}

fn void test_parse_args_single_expr() @test {
    @pool()
    {
        String expr = "";
        bool has_expr = false;
        String file = "";
        bool has_file = false;
        bool cont = main::parse_args({ "calc3", "1 + 2" }, &expr, &has_expr, &file, &has_file);
        test::eq(cont, true);
        test::eq(has_expr, true);
        test::eq(expr, "1 + 2");
        test::eq(has_file, false);
    };
}

fn void test_parse_args_file_option() @test {
    @pool()
    {
        String expr = "";
        bool has_expr = false;
        String file = "";
        bool has_file = false;
        bool cont = main::parse_args({ "calc3", "-f", "input.txt" }, &expr, &has_expr, &file, &has_file);
        test::eq(cont, true);
        test::eq(has_file, true);
        test::eq(file, "input.txt");
        test::eq(has_expr, false);
    };
}

fn void test_parse_args_double_dash_expr() @test {
    @pool()
    {
        String expr = "";
        bool has_expr = false;
        String file = "";
        bool has_file = false;
        bool cont = main::parse_args({ "calc3", "--", "-5+8" }, &expr, &has_expr, &file, &has_file);
        test::eq(cont, true);
        test::eq(has_expr, true);
        test::eq(expr, "-5+8");
    };
}

fn void test_parse_args_unknown_option() @test {
    @pool()
    {
        String expr = "";
        bool has_expr = false;
        String file = "";
        bool has_file = false;
        bool cont = main::parse_args({ "calc3", "--bogus" }, &expr, &has_expr, &file, &has_file);
        test::eq(cont, false);
    };
}
