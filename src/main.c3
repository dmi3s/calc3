module calc3::main;
import calc3::token;
import calc3::lexer;
import calc3::parser;


fn void main() {
    String src = "( 42 % 2 )\t\t-324";
    log::info("\"%s\"", src);
    Lexer lex;
    lex.init(src);
    Token t;
    do {
        t = lex.next()!!;
        log::info("%s", t);
    } while (t.kind != EOF);
}
