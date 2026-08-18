module calc3::lexer;
import std::core::string;
import std::core::ascii;
import std::math;
import calc3::token;

faultdef UNKNOWN_CHAR, OVERFLOW;

struct Lexer {
    String input;
    Ref ref;
    sz pos;
}

fn void Lexer.init(&self, String input) {
    self.input = input;
    self.ref = {1, 1};
    self.pos = 0;
}

<*
 @require !self.@is_eof() : "peek: Can't peek at eof"
*>
fn char Lexer.peek(&self) {
    return self.input[self.pos];
}

<*
 @require !self.@is_eof() : "eat: Can't eat at eof"
*>
fn char Lexer.eat(&self) {
    if (self.input[self.pos] == '\n') {
        self.ref.row += 1;
        self.ref.col = 1;
    } else if (self.input[self.pos] == '\t') {
        self.ref.col += 4;
    } else {
        self.ref.col += 1;
    }
    return self.input[self.pos++];
}

macro bool Lexer.@is_eof(&self) {
    return self.pos >= self.input.len;
}

fn void Lexer.skip_ws(&self) @inline {
    while (!self.@is_eof() && ascii::@is_space(self.peek())) {
        self.eat();
    }
}

fn int? Lexer.eat_int(&self) {
    int num = 0;
    while (!self.@is_eof() && ascii::@is_digit(self.peek())) {
        int digit = self.eat() - '0';
        int? next = num.overflow_mul(10).overflow_add(digit);
        if (catch err = next) {
            while (!self.@is_eof() && ascii::@is_digit(self.peek())) {
                self.eat();
            }
            return OVERFLOW~;
        }
        num = next;
    }
    return num;
}

macro Token @mk_token(token::TokenKind kind, token::Value val, Ref ref) @private{
    return { .kind = kind, .val = val, .ref = ref };
}

fn Token? Lexer.next(&self) {
    self.skip_ws();

    if (self.@is_eof()) {
        return @mk_token(EOF, {}, self.ref);
    }
    Ref start = self.ref;

    switch (char ch = self.peek()) {
        case '(':
            return @mk_token(LPAREN, {self.eat()}, start);
        case ')':
            return @mk_token(RPAREN, {self.eat()}, start);
        case '+':
            return @mk_token(PLUS, {self.eat()}, start);
        case '-':
            return @mk_token(MINUS, {self.eat()}, start);
        case '*':
            return @mk_token(MUL, {self.eat()}, start);
        case '/':
            return @mk_token(DIV, {self.eat()}, start);
        case '%':
            return @mk_token(MOD, {self.eat()}, start);
        default:
            if (ascii::@is_digit(ch)) {
                int? num = self.eat_int();
                if (catch err = num) return err~;
                return @mk_token(NUMBER, {num}, start);
            }
            self.eat(); // Ready to continue
            return UNKNOWN_CHAR~;
    }
}
