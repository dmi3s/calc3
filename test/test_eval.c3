module calc3::test::eval;
import calc3::ast;
import calc3::parser;
import std::collections::result;

fn int eval_ok(String src)
{
    Result{ast::ASTNode, parser::ParseError} r = parser::parse(src, tmem);
    test::@check(r.is_ok);
    Result{int, ast::EvalError} res = ast::eval(r.value, tmem);
    test::@check(res.is_ok);
    return res.value;
}

fn void eval_err(String src)
{
    Result{ast::ASTNode, parser::ParseError} r = parser::parse(src, tmem);
    test::@check(r.is_ok);
    Result{int, ast::EvalError} res = ast::eval(r.value, tmem);
    test::@check(!(res.is_ok));
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
