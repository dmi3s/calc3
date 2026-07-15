module calc3::main;
import calc3::token;


fn void main() {
    Token token_mul = token::new_token(TOKEN_MULTIPLY, 37u, 42u);
    Token token_int = token::new_token_with_data(TOKEN_INTEGER, { .integer_value =42  }, 37u, 42u);
    log::info("Token mul: %s", token_mul);
    log::info("Token int: %s", token_int);
}
