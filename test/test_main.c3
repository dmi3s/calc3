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
