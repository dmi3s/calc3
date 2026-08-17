module calc3::token;
import std::core::string;
import std::io;

enum TokenKind : uint {
    NUMBER,
    LPAREN, RPAREN,
    MUL, DIV, MOD,
    PLUS, MINUS,
    EOF,
}

struct Ref {
    int row;
    int col;
}

fn bool Ref.equals(&self, Ref other) @operator(==) {
    return self.row == other.row && self.col == other.col;
}

alias ValueInt = int;
alias ValueChar = char;

union Value {
    ValueInt num;
    ValueChar c;
}

struct Token (Printable) {
    TokenKind kind;
    Value val;
    Ref ref;
}

fn bool Token.equals(&self, Token other) @operator(==) {
    if ( self.kind != other.kind || self.ref != other.ref ) {
        return false;
    }
    if (self.kind == NUMBER) {
        return self.val.num == other.val.num;
    }
    return self.val.c == other.val.c;
}

fn sz? Token.to_format(&self, Formatter* f) @dynamic {
    switch (self.kind) {
        case EOF:
            return f.printf("{ %s, %d:%d }",
                self.kind.description, self.ref.row, self.ref.col);
        case NUMBER:
            return f.printf("{ %s(%d), %d:%d }",
                self.kind.description, self.val.num, self.ref.row, self.ref.col);
        default:
            return f.printf("{ %s('%c'), %d:%d }",
                self.kind.description, self.val.c, self.ref.row, self.ref.col);
    }
}
