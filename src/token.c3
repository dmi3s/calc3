module calc3::token;
import std::core::string;
import std::io;

enum TokenKind : uint {
    NUMBER,
    IDENT,
    LPAREN, RPAREN,
    LBRACE, RBRACE,
    COMMA,
    EQ,
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

fn String format_ref_error(String kind, Ref ref, String msg) {
    return string::tformat("%s(%s at %d:%d)", kind, msg, ref.row, ref.col);
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
    String name;
}

fn bool Token.equals(&self, Token other) @operator(==) {
    if ( self.kind != other.kind || self.ref != other.ref ) {
        return false;
    }
    if (self.kind == NUMBER) {
        return self.val.num == other.val.num;
    }
    if (self.kind == IDENT) {
        return self.name.compare_to(other.name) == 0;
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
        case IDENT:
            return f.printf("{ %s(%s), %d:%d }",
                self.kind.description, self.name, self.ref.row, self.ref.col);
        default:
            return f.printf("{ %s('%c'), %d:%d }",
                self.kind.description, self.val.c, self.ref.row, self.ref.col);
    }
}
