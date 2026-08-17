module calc3::test::ast;
import calc3::ast;
import calc3::parser;
import calc3::token;
import std::collections::result;
import std::core::string;

fn void test_ast_number() @test {
    @pool()
    {
        ast::ASTNode n = ast::create_number(tmem, 42, {1, 1});
        test::eq(string::tformat("%s", n), "NUMBER(42)");
    };
}

fn void test_ast_unary() @test {
    @pool()
    {
        ast::ASTNode operand = ast::create_number(tmem, 5, {1, 2});
        ast::ASTNode n = ast::create_unary(tmem, token::TokenKind.MINUS, operand, {1, 1});
        test::eq(string::tformat("%s", n), "(- NUMBER(5))");
    };
}

fn void test_ast_binary() @test {
    @pool()
    {
        ast::ASTNode left = ast::create_number(tmem, 1, {1, 1});
        ast::ASTNode right = ast::create_number(tmem, 2, {1, 3});
        ast::ASTNode n = ast::create_binary(tmem, token::TokenKind.PLUS, left, right, {1, 2});
        test::eq(string::tformat("%s", n), "(NUMBER(1) + NUMBER(2))");
    };
}

fn void test_ast_nested() @test {
    @pool()
    {
        ast::ASTNode one = ast::create_number(tmem, 1, {1, 1});
        ast::ASTNode two = ast::create_number(tmem, 2, {1, 3});
        ast::ASTNode three = ast::create_number(tmem, 3, {1, 5});
        ast::ASTNode inner = ast::create_binary(tmem, token::TokenKind.PLUS, one, two, {1, 2});
        ast::ASTNode n = ast::create_binary(tmem, token::TokenKind.MUL, inner, three, {1, 4});
        test::eq(string::tformat("%s", n), "((NUMBER(1) + NUMBER(2)) * NUMBER(3))");
    };
}

fn void test_to_tree_number() @test {
    @pool()
    {
        ast::ASTNode n = ast::create_number(tmem, 42, {3, 2});
        test::eq(ast::to_tree(n, tmem), "NUM(42) (3:2)\n");
    };
}

fn void test_to_tree_unary() @test {
    @pool()
    {
        ast::ASTNode operand = ast::create_number(tmem, 5, {1, 2});
        ast::ASTNode n = ast::create_unary(tmem, token::TokenKind.MINUS, operand, {1, 1});
        test::eq(ast::to_tree(n, tmem), "UNARY(-) (1:1)\n└── NUM(5) (1:2)\n");
    };
}

fn void test_to_tree_binary() @test {
    @pool()
    {
        ast::ASTNode left = ast::create_number(tmem, 1, {1, 1});
        ast::ASTNode right = ast::create_number(tmem, 2, {1, 3});
        ast::ASTNode n = ast::create_binary(tmem, token::TokenKind.PLUS, left, right, {1, 2});
        test::eq(ast::to_tree(n, tmem), "BIN(+) (1:2)\n├── NUM(1) (1:1)\n└── NUM(2) (1:3)\n");
    };
}

fn void test_to_tree_nested() @test {
    @pool()
    {
        ast::ASTNode one = ast::create_number(tmem, 1, {1, 1});
        ast::ASTNode two = ast::create_number(tmem, 2, {1, 3});
        ast::ASTNode three = ast::create_number(tmem, 3, {1, 7});
        ast::ASTNode inner = ast::create_binary(tmem, token::TokenKind.PLUS, one, two, {1, 2});
        ast::ASTNode n = ast::create_binary(tmem, token::TokenKind.MUL, inner, three, {1, 4});
        test::eq(ast::to_tree(n, tmem),
            "BIN(*) (1:4)\n├── BIN(+) (1:2)\n│   ├── NUM(1) (1:1)\n│   └── NUM(2) (1:3)\n└── NUM(3) (1:7)\n");
    };
}

fn void test_to_rpn_number() @test {
    @pool()
    {
        ast::ASTNode n = ast::create_number(tmem, 42, {3, 2});
        test::eq(ast::to_rpn(n, tmem), "42");
    };
}

fn void test_to_rpn_unary_minus() @test {
    @pool()
    {
        ast::ASTNode operand = ast::create_number(tmem, 5, {1, 2});
        ast::ASTNode n = ast::create_unary(tmem, token::TokenKind.MINUS, operand, {1, 1});
        test::eq(ast::to_rpn(n, tmem), "5 NEG");
    };
}

fn void test_to_rpn_unary_plus() @test {
    @pool()
    {
        ast::ASTNode operand = ast::create_number(tmem, 5, {1, 2});
        ast::ASTNode n = ast::create_unary(tmem, token::TokenKind.PLUS, operand, {1, 1});
        test::eq(ast::to_rpn(n, tmem), "5 POS");
    };
}

fn void test_to_rpn_binary() @test {
    @pool()
    {
        ast::ASTNode left = ast::create_number(tmem, 1, {1, 1});
        ast::ASTNode right = ast::create_number(tmem, 2, {1, 3});
        ast::ASTNode n = ast::create_binary(tmem, token::TokenKind.PLUS, left, right, {1, 2});
        test::eq(ast::to_rpn(n, tmem), "1 2 +");
    };
}

fn void test_to_rpn_nested() @test {
    @pool()
    {
        ast::ASTNode one = ast::create_number(tmem, 1, {1, 1});
        ast::ASTNode two = ast::create_number(tmem, 2, {1, 3});
        ast::ASTNode three = ast::create_number(tmem, 3, {1, 7});
        ast::ASTNode inner = ast::create_binary(tmem, token::TokenKind.PLUS, one, two, {1, 2});
        ast::ASTNode n = ast::create_binary(tmem, token::TokenKind.MUL, inner, three, {1, 4});
        test::eq(ast::to_rpn(n, tmem), "1 2 + 3 *");
    };
}

fn void test_to_rpn_unary_nested() @test {
    @pool()
    {
        ast::ASTNode one = ast::create_number(tmem, 1, {1, 1});
        ast::ASTNode two = ast::create_number(tmem, 2, {1, 3});
        ast::ASTNode inner = ast::create_binary(tmem, token::TokenKind.PLUS, one, two, {1, 2});
        ast::ASTNode n = ast::create_unary(tmem, token::TokenKind.MINUS, inner, {1, 1});
        test::eq(ast::to_rpn(n, tmem), "1 2 + NEG");
    };
}

fn void test_rpn_empty() @test {
    @pool()
    {
        Result{ast::ASTNode, parser::ParseError} res = parser::parse("", tmem);
        test::@check(res.is_ok);
        test::eq(ast::to_rpn(res.value, tmem), "0");
    };
}

fn void test_rpn_single() @test {
    @pool()
    {
        ast::ASTNode n = ast::create_number(tmem, 7, {1, 1});
        test::eq(ast::to_rpn(n, tmem), "7");
    };
}

fn void test_rpn_simple_binop() @test {
    @pool()
    {
        ast::ASTNode left = ast::create_number(tmem, 1, {1, 1});
        ast::ASTNode right = ast::create_number(tmem, 2, {1, 3});
        ast::ASTNode n = ast::create_binary(tmem, token::TokenKind.PLUS, left, right, {1, 2});
        test::eq(ast::to_rpn(n, tmem), "1 2 +");
    };
}
