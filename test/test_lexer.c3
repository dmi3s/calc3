module calc3::test::lexer;
import calc3::lexer;
import calc3::token;


fn void test_empty() @test {
    Lexer lex;
    String test_string = "";
    Token [*] expected_tokens = {
        { .kind = EOF, .ref = {1, 1} }
    };
    lex.init(test_string);
    foreach(Token* &tok : expected_tokens) {
        Token? res = lex.next();
        test::eq(res!!, *tok);
    }
}

fn void test_empty_with_whitespaces() @test {
    Lexer lex;
    String test_string = "  \t\t\n ";
    Token [*] expected_tokens = {
        { .kind = EOF, .ref = {2, 2} }
    };
    lex.init(test_string);
    foreach(Token* &tok : expected_tokens) {
        Token? res = lex.next();
        test::eq(res!!, *tok);
    }
}

fn void test_number() @test {
    Lexer lex;
    String test_string = "12";
    Token [*] expected_tokens = {
        { .kind = NUMBER, .val = {12}, .ref = {1,1} },
        { .kind = EOF, .ref = {1,3} }
    };
    lex.init(test_string);
    foreach(Token* &tok : expected_tokens) {
        Token? res = lex.next();
        test::eq(res!!, *tok);
    }
}

fn void test_simple() @test {
    Lexer lex;

    String test_string = "12 + 18 * 22 / 7 + 16 %3";
    Token [*] expected_tokens = {
        { .kind = NUMBER, .val = {12}, .ref = {1,1} },
        { .kind = PLUS, .val = {'+'}, .ref = {1,4} },
        { .kind = NUMBER, .val = {18}, .ref = {1,6} },
        { .kind = MUL, .val = {'*'}, .ref = {1,9} },
        { .kind = NUMBER, .val = {22}, .ref = {1,11} },
        { .kind = DIV, .val = {'/'}, .ref = {1,14} },
        { .kind = NUMBER, .val = {7}, .ref = {1,16} },
        { .kind = PLUS, .val = {'+'}, .ref = {1,18} },
        { .kind = NUMBER, .val = {16}, .ref = {1,20} },
        { .kind = MOD, .val = {'%'}, .ref = {1,23} },
        { .kind = NUMBER, .val = {3}, .ref = {1,24} },
        { .kind = EOF, .ref = {1,25} }
    };
    lex.init(test_string);
    foreach(Token* &tok : expected_tokens) {
        Token? res = lex.next();
        test::eq(res!!, *tok);
    }
}

fn void test_complex() @test {
    Lexer lex;

    String test_string = "-18*22/(7+\n16 % 3)\n\t";
    Token [*] expected_tokens = {
        { .kind = MINUS, .val = {'-'}, .ref = {1,1} },
        { .kind = NUMBER, .val = {18}, .ref = {1,2} },
        { .kind = MUL, .val = {'*'}, .ref = {1,4} },
        { .kind = NUMBER, .val = {22}, .ref = {1,5} },
        { .kind = DIV, .val = {'/'}, .ref = {1,7} },
        { .kind = LPAREN, .val = {'('}, .ref = {1,8} },
        { .kind = NUMBER, .val = {7}, .ref = {1,9} },
        { .kind = PLUS, .val = {'+'}, .ref = {1,10} },   // '\n'
        { .kind = NUMBER, .val = {16}, .ref = {2,1} },
        { .kind = MOD, .val = {'%'}, .ref = {2,4} },
        { .kind = NUMBER, .val = {3}, .ref = {2,6} },
        { .kind = RPAREN, .val = {')'}, .ref = {2,7} },
        { .kind = EOF, .ref = {3,5} }
    };
    lex.init(test_string);
    foreach(Token* &tok : expected_tokens) {
        Token? res = lex.next();
        test::eq(res!!, *tok);
    }
}

fn void test_unknown() @test {
    Lexer lex;
    lex.init("@");
    Token? res = lex.next();
    test::@error(lex.next(), lexer::UNKNOWN_CHAR);
}

fn void test_overflow() @test {
    Lexer lex;
    lex.init("2147483648");
    test::@error(lex.next(), lexer::OVERFLOW);
}

fn void test_overflow_consumes_digits() @test {
    Lexer lex;
    lex.init("2147483648+1");
    test::@error(lex.next(), lexer::OVERFLOW);
    Token [*] expected_tokens = {
        { .kind = PLUS, .val = {'+'}, .ref = {1, 11} },
        { .kind = NUMBER, .val = {1}, .ref = {1, 12} },
        { .kind = EOF, .ref = {1, 13} }
    };
    foreach(Token* &tok : expected_tokens) {
        test::eq(lex.next()!!, *tok);
    }
}
