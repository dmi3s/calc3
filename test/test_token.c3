module calc3::test::token;
import calc3::token;

fn void test_new_token() @test {
    Token token = token::new_token(TOKEN_MULTIPLY, 12u, 1023u);
    test::eq(token.type, TokenType.TOKEN_MULTIPLY);
    test::eq(token.line, 12u);
    test::eq(token.column, 1023u);
}

fn void test_new_token_with_data() @test {
    Token token_int = token::new_token_with_data(TOKEN_INTEGER, { .integer_value = -103  }, 37u, 42u);
    test::eq(token_int.type, TokenType.TOKEN_INTEGER);
    test::eq(token_int.data.integer_value, -103);
    test::eq(token_int.line, 37u);
    test::eq(token_int.column, 42u);
}

fn void test_token_format() @test {
    Token token = token::new_token(TOKEN_MULTIPLY, 37u, 42u);
    test::eq(string::tformat("%s", token),  "{ type: TOKEN_MULTIPLY, 37:42 }");
}

fn void test_token_with_data_format() @test {
    Token token = token::new_token_with_data(TOKEN_INTEGER, {.integer_value = -42}, 37u, 42u);
    test::eq(string::tformat("%s", token),  "{ type: TOKEN_INTEGER, data: -42, 37:42 }");
}
