module calc3::test::eval;
import calc3::ast;
import calc3::parser;
import calc3::symbol_table;
import std::collections::result;

fn int eval_ok_with(String src, symbol_table::SymbolTable* syms)
{
    Result{ast::ASTNode, parser::ParseError} r = parser::parse(src, tmem);
    test::@check(r.is_ok);
    Result{int, ast::EvalError} res = ast::eval(r.value, tmem, syms);
    test::@check(res.is_ok);
    return res.value;
}

fn void eval_err_with(String src, symbol_table::SymbolTable* syms)
{
    Result{ast::ASTNode, parser::ParseError} r = parser::parse(src, tmem);
    test::@check(r.is_ok);
    Result{int, ast::EvalError} res = ast::eval(r.value, tmem, syms);
    test::@check(!(res.is_ok));
}

fn int eval_ok(String src)
{
    symbol_table::SymbolTable syms;
    syms.init(tmem);
    return eval_ok_with(src, &syms);
}

fn void eval_err(String src)
{
    symbol_table::SymbolTable syms;
    syms.init(tmem);
    eval_err_with(src, &syms);
}

fn void test_eval_number() @test {
    @pool()
    {
        test::eq(eval_ok("42"), 42);
    };
}

fn void test_eval_empty() @test {
    @pool()
    {
        test::eq(eval_ok(""), 0);
    };
}

fn void test_eval_zero() @test {
    @pool()
    {
        test::eq(eval_ok("0"), 0);
    };
}

fn void test_eval_simple_binop() @test {
    @pool()
    {
        test::eq(eval_ok("1 + 2"), 3);
        test::eq(eval_ok("7 - 2"), 5);
        test::eq(eval_ok("6 * 7"), 42);
    };
}

fn void test_eval_division() @test {
    @pool()
    {
        test::eq(eval_ok("7 / 2"), 3);
    };
}

fn void test_eval_modulo() @test {
    @pool()
    {
        test::eq(eval_ok("10 % 3"), 1);
    };
}

fn void test_eval_precedence() @test {
    @pool()
    {
        test::eq(eval_ok("1 + 2 * 3"), 7);
        test::eq(eval_ok("2 + 3 * 4 - 1"), 13);
        test::eq(eval_ok("10 - 2 * 3 % 4"), 8);
    };
}

fn void test_eval_parens() @test {
    @pool()
    {
        test::eq(eval_ok("(1 + 2) * 3"), 9);
        test::eq(eval_ok("(2 + 3) * (4 - 1)"), 15);
    };
}

fn void test_eval_unary_minus() @test {
    @pool()
    {
        test::eq(eval_ok("-5"), -5);
        test::eq(eval_ok("--5"), 5);
    };
}

fn void test_eval_unary_plus() @test {
    @pool()
    {
        test::eq(eval_ok("+5"), 5);
        test::eq(eval_ok("-+5"), -5);
    };
}

fn void test_eval_unary_nested() @test {
    @pool()
    {
        test::eq(eval_ok("-(1 + 2)"), -3);
        test::eq(eval_ok("--(1 + 2)"), 3);
    };
}

fn void test_eval_negative_result() @test {
    @pool()
    {
        test::eq(eval_ok("2 - 7"), -5);
        test::eq(eval_ok("1 - 2 - 3"), -4);
    };
}

fn void test_eval_negative_modulo() @test {
    @pool()
    {
        test::eq(eval_ok("-7 % 3"), -1);
    };
}

fn void test_eval_division_by_zero() @test {
    @pool()
    {
        eval_err("1 / 0");
    };
}

fn void test_eval_modulo_by_zero() @test {
    @pool()
    {
        eval_err("1 % 0");
    };
}

fn void test_eval_division_by_zero_nested() @test {
    @pool()
    {
        eval_err("1 + 2 / 0");
        eval_err("(1 + 2) / (3 - 3)");
    };
}

fn void test_eval_overflow_add() @test {
    @pool()
    {
        eval_err("2147483647 + 1");
    };
}

fn void test_eval_overflow_sub() @test {
    @pool()
    {
        eval_err("2147483647 - -1");
    };
}

fn void test_eval_overflow_mul() @test {
    @pool()
    {
        eval_err("1000000 * 1000000");
    };
}

fn void test_eval_overflow_unary() @test {
    @pool()
    {
        eval_err("-(-2147483647 - 1)");
    };
}

fn void test_eval_overflow_div() @test {
    @pool()
    {
        eval_err("(-2147483647 - 1) / -1");
    };
}

fn void test_eval_overflow_mod() @test {
    @pool()
    {
        eval_err("(-2147483647 - 1) % -1");
    };
}

fn void test_eval_int_min() @test {
    @pool()
    {
        test::eq(eval_ok("-2147483647 - 1"), -2147483647 - 1);
    };
}

fn void test_eval_overflow_boundaries() @test {
    @pool()
    {
        test::eq(eval_ok("2147483647 * -1"), -2147483647);
        test::eq(eval_ok("-2147483647 / -1"), 2147483647);
        test::eq(eval_ok("1000 * 1000"), 1000000);
    };
}

fn void test_eval_let() @test {
    @pool()
    {
        symbol_table::SymbolTable syms;
        syms.init(tmem);
        test::eq(eval_ok_with("let x = 5", &syms), 5);
        test::eq(eval_ok_with("x * 2", &syms), 10);
        test::eq(eval_ok_with("x + 1", &syms), 6);
    };
}

fn void test_eval_let_rebind() @test {
    @pool()
    {
        symbol_table::SymbolTable syms;
        syms.init(tmem);
        test::eq(eval_ok_with("let x = 5", &syms), 5);
        test::eq(eval_ok_with("let x = 10", &syms), 10);
        test::eq(eval_ok_with("x", &syms), 10);
    };
}

fn void test_eval_unknown_variable() @test {
    @pool()
    {
        symbol_table::SymbolTable syms;
        syms.init(tmem);
        eval_err_with("y + 1", &syms);
    };
}

fn void test_eval_function_call() @test {
    @pool()
    {
        symbol_table::SymbolTable syms;
        syms.init(tmem);
        test::eq(eval_ok_with("fn int sq(int n) { n * n }", &syms), 0);
        test::eq(eval_ok_with("sq(5)", &syms), 25);
        test::eq(eval_ok_with("sq(3)", &syms), 9);
    };
}

fn void test_eval_function_global_var() @test {
    @pool()
    {
        symbol_table::SymbolTable syms;
        syms.init(tmem);
        test::eq(eval_ok_with("let x = 100", &syms), 100);
        test::eq(eval_ok_with("fn int g(int n) { n + x }", &syms), 0);
        test::eq(eval_ok_with("g(7)", &syms), 107);
        test::eq(eval_ok_with("x", &syms), 100);
    };
}

fn void test_eval_function_composition() @test {
    @pool()
    {
        symbol_table::SymbolTable syms;
        syms.init(tmem);
        test::eq(eval_ok_with("fn int add1(int n) { n + 1 }", &syms), 0);
        test::eq(eval_ok_with("fn int add2(int n) { add1(n) + 1 }", &syms), 0);
        test::eq(eval_ok_with("add2(5)", &syms), 7);
        test::eq(eval_ok_with("let y = add2(3)", &syms), 5);
    };
}

fn void test_eval_unknown_function() @test {
    @pool()
    {
        symbol_table::SymbolTable syms;
        syms.init(tmem);
        eval_err_with("foo(1)", &syms);
    };
}

fn void test_eval_function_multi_arg() @test {
    @pool()
    {
        symbol_table::SymbolTable syms;
        syms.init(tmem);
        test::eq(eval_ok_with("fn int add(int a, int b) { a + b }", &syms), 0);
        test::eq(eval_ok_with("add(2, 3)", &syms), 5);
        test::eq(eval_ok_with("add(10, add(1, 1))", &syms), 12);
    };
}

fn void test_eval_function_arity_mismatch() @test {
    @pool()
    {
        symbol_table::SymbolTable syms;
        syms.init(tmem);
        test::eq(eval_ok_with("fn int add(int a, int b) { a + b }", &syms), 0);
        eval_err_with("add(2)", &syms);
        eval_err_with("add(1, 2, 3)", &syms);
    };
}
