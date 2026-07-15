module calc3::token;
import std::core::string;
import std::io;

enum TokenType : int {
    TOKEN_EOF,
    TOKEN_INTEGER,
    TOKEN_PLUS,
    TOKEN_MINUS,
    TOKEN_MULTIPLY,
    TOKEN_DIVIDE,
    TOKEN_LPAREN,
    TOKEN_RPAREN,
}

union TokenData {
    int integer_value;
}


struct Token (Printable) {
    TokenType type;
    TokenData data;
    uint line; // номер строки
    uint column; // номер столбца
}

<*
@require type != TOKEN_INTEGER
*>
fn Token new_token(TokenType type, uint line, uint column) {
    return (Token) {
        .type = type,
        .line = line,
        .column = column,
    };
}

<*
@require type == TOKEN_INTEGER
*>
fn Token new_token_with_data(TokenType type, TokenData data,
    uint line, uint column) {
    return (Token) {
        .type = type,
        .data = data,
        .line = line,
        .column = column,
    };
}

fn sz? Token.to_format(&self, Formatter* f) @dynamic {
    switch(self.type) {
        case TOKEN_INTEGER :
            return f.printf("{ type: TOKEN_INTEGER, data: %d, %d:%d }",
                self.data.integer_value, self.line, self.column);
        default:
            return f.printf("{ type: %s, %d:%d }",
                self.type.description, self.line, self.column);
    }
}
