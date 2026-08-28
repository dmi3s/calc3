module calc3::test::parser;
import calc3::parser;
import calc3::ast;
import calc3::token;
import std::collections::result;
import std::core::string;

fn void test_parse_number() @test {
    @pool()
    {
        Result{ast::ASTNode, parser::ParseError} res = parser::parse("42", tmem);
        test::@check(res.is_ok);
        test::eq(string::tformat("%s", res.value), "NUMBER(42)");
    };
}

fn void test_parse_simple() @test {
    @pool()
    {
        Result{ast::ASTNode, parser::ParseError} res = parser::parse("1 + 2", tmem);
        test::@check(res.is_ok);
        test::eq(string::tformat("%s", res.value), "(NUMBER(1) + NUMBER(2))");
    };
}

fn void test_parse_precedence() @test {
    @pool()
    {
        Result{ast::ASTNode, parser::ParseError} res = parser::parse("1 + 2 * 3", tmem);
        test::@check(res.is_ok);
        test::eq(string::tformat("%s", res.value), "(NUMBER(1) + (NUMBER(2) * NUMBER(3)))");
    };
}

fn void test_parse_parens() @test {
    @pool()
    {
        Result{ast::ASTNode, parser::ParseError} res = parser::parse("(1 + 2) * 3", tmem);
        test::@check(res.is_ok);
        test::eq(string::tformat("%s", res.value), "((NUMBER(1) + NUMBER(2)) * NUMBER(3))");
    };
}

fn void test_parse_unary() @test {
    @pool()
    {
        Result{ast::ASTNode, parser::ParseError} res = parser::parse("-42", tmem);
        test::@check(res.is_ok);
        test::eq(string::tformat("%s", res.value), "(- NUMBER(42))");
    };
}

fn void test_parse_unary_nested() @test {
    @pool()
    {
        Result{ast::ASTNode, parser::ParseError} res = parser::parse("--5", tmem);
        test::@check(res.is_ok);
        test::eq(string::tformat("%s", res.value), "(- (- NUMBER(5)))");
    };
}

fn void test_parse_modulo() @test {
    @pool()
    {
        Result{ast::ASTNode, parser::ParseError} res = parser::parse("10 % 3", tmem);
        test::@check(res.is_ok);
        test::eq(string::tformat("%s", res.value), "(NUMBER(10) % NUMBER(3))");
    };
}

fn void test_parse_error_unclosed_paren() @test {
    @pool()
    {
        Result{ast::ASTNode, parser::ParseError} res = parser::parse("(1 + 2", tmem);
        test::@check(!(res.is_ok));
        test::eq(res.error.msg, "Expected ')'");
    };
}

fn void test_parse_error_unknown_char() @test {
    @pool()
    {
        Result{ast::ASTNode, parser::ParseError} res = parser::parse("1 @ 2", tmem);
        test::@check(!(res.is_ok));
        test::eq(res.error.msg, "Unexpected character");
    };
}

fn void test_parse_error_overflow() @test {
    @pool()
    {
        Result{ast::ASTNode, parser::ParseError} res = parser::parse("2147483648", tmem);
        test::@check(!(res.is_ok));
        test::eq(res.error.msg, "Integer overflow");
    };
}

fn void test_parse_error_trailing() @test {
    @pool()
    {
        Result{ast::ASTNode, parser::ParseError} res = parser::parse("1 2", tmem);
        test::@check(!(res.is_ok));
        test::eq(res.error.msg, "Unexpected trailing token");
    };
}

fn void test_parse_empty() @test {
    @pool()
    {
        Result{ast::ASTNode, parser::ParseError} res = parser::parse("", tmem);
        test::@check(res.is_ok);
        test::eq(string::tformat("%s", res.value), "NUMBER(0)");
    };
}

fn void test_parse_error_unexpected_token() @test {
    @pool()
    {
        Result{ast::ASTNode, parser::ParseError} res = parser::parse("+", tmem);
        test::@check(!(res.is_ok));
        test::eq(res.error.msg, "Unexpected end of input");
    };
}

fn void test_parse_let() @test {
    @pool()
    {
        Result{ast::ASTNode, parser::ParseError} res = parser::parse("let x = 5", tmem);
        test::@check(res.is_ok);
        test::eq(string::tformat("%s", res.value), "(let x NUMBER(5))");
    };
}

fn void test_parse_function_def() @test {
    @pool()
    {
        Result{ast::ASTNode, parser::ParseError} res = parser::parse("fn int sq(int n) { n * n }", tmem);
        test::@check(res.is_ok);
        test::eq(string::tformat("%s", res.value), "(fn sq(n) (IDENT(n) * IDENT(n)))");
    };
}

fn void test_parse_call() @test {
    @pool()
    {
        Result{ast::ASTNode, parser::ParseError} res = parser::parse("sq(5)", tmem);
        test::@check(res.is_ok);
        test::eq(string::tformat("%s", res.value), "(sq NUMBER(5))");
    };
}

fn void test_parse_call_no_args() @test {
    @pool()
    {
        Result{ast::ASTNode, parser::ParseError} res = parser::parse("ask()", tmem);
        test::@check(res.is_ok);
        test::eq(string::tformat("%s", res.value), "(ask NUMBER(0))");
    };
}
