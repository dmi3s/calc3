module calc3::test::main;
import calc3::main;
import std::core::string;

fn void test_answer_question() @test {
    @pool()
    {
        test::eq(main::process_line("?", tmem), "42");
    };
}

fn void test_process_line_arithmetic() @test {
    @pool()
    {
        test::eq(main::process_line("1 + 2", tmem), "1 2 +\n3");
    };
}

fn void test_process_line_division_by_zero() @test {
    @pool()
    {
        test::eq(main::process_line("1 / 0", tmem), "1 0 /\nerror: EvalError(Division by zero at 1:3)");
    };
}

fn void test_process_line_parse_error() @test {
    @pool()
    {
        test::eq(main::process_line("1 @ 2", tmem), "error: ParseError(Unexpected character at 1:4)");
    };
}

fn void test_process_to_string_number() @test {
    @pool()
    {
        test::eq(main::process_to_string("42", tmem),
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
