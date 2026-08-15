module calc3::test::token;
import calc3::token;

fn void test_formatter() @test {
    Token eof = { .kind = EOF, .ref = {1, 1} };
    test::eq(string::tformat("%s",eof), "{ EOF, 1:1 }");
    Token num = { .kind = NUMBER, .val = {.num =37}, .ref = {12, 2} };
    test::eq(string::tformat("%s",num), "{ NUMBER(37), 12:2 }");
    Token lparen = { .kind = LPAREN, .val = {.c = '('}, .ref = {77, 91} };
    test::eq(string::tformat("%s",lparen), "{ LPAREN('('), 77:91 }" );
}
