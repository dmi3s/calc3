module calc3::token;
import std::core::string;


enum TokenType : int {
    TOKEN_EOF,
    TOKEN_NUMBER,
    TOKEN_PLUS,
    TOKEN_MINUS,
    TOKEN_MULTIPLY,
    TOKEN_DIVIDE,
    TOKEN_LPAREN,
    TOKEN_RPAREN,
}

struct Token {
    TokenType type;
    String value; // ToDo: Посмотреть в сторону Any
    String text; // оригинальный текст (для отладки). ToDo: Так ли он нужен?
    uint line; // номер строки
    uint column; // номер столбца
}

macro Token new_token(TokenType type, String value,
                   String text, uint line, uint column) {
    return (Token) {
        .type = type,
        .value = value,
        .text = text,
        .line = line,
        .column = column,
    };
}

macro String token_type_to_string(TokenType type) => type.description;

<*
 This macro will create a temporary string description of a struct.

 @param token : "The token to create a description of"
*>
macro String ttoken_to_string(Token token) => string::tfrom_struct(token);


<*
 This macro will create a string description of a struct.

 @param [&inout] allocator : "The allocator to use"
 @param token : "The token to create a description of"
*>
macro String token_to_string(Allocator allocator, Token token) =>
    string::from_struct(allocator, token);
