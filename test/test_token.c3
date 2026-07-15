module calc3::test::token;
import calc3::token;

fn void test_token_type_to_string() @test {
    TokenType type = TOKEN_DIVIDE;
    String str = token::token_type_to_string(type);
    assert(str == "TOKEN_DIVIDE");
}

fn void test_new_token() @test {
    Token token = token::new_token(TOKEN_MULTIPLY, "*", "3*4", 37, 42);
    assert(token.type == TOKEN_MULTIPLY);
    assert(token.value == "*");
    assert(token.text == "3*4");
    assert(token.line == 37);
    assert(token.column == 42);
}

fn void test_ttoken_to_string() @test {
    @pool() {
        Token token = token::new_token(TOKEN_DIVIDE, "/", "/", 1, 1);
        String str = token::ttoken_to_string(token);
        assert(str == "{ type: TOKEN_DIVIDE, value: /, text: /, line: 1, column: 1 }");
    };
}

fn void test_token_to_string() @test {
    @stack_mem(128; Allocator mem){
        Token token = token::new_token(TOKEN_DIVIDE, "/", "/", 1, 1);
        String str = token::token_to_string(tmem, token);
        assert(str == "{ type: TOKEN_DIVIDE, value: /, text: /, line: 1, column: 1 }");
    };
}
