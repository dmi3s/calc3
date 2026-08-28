module calc3::test::lexer;
import calc3::lexer;
import calc3::token;


macro Lexer @make_lexer(String init_str) @local {
    Lexer lex;
    lex.init(init_str);
    return lex;
}

macro void @verify_tokens(#lex, #tokens) @local {
    Token[*] expected_tokens = #tokens;
    foreach(Token* &tok : expected_tokens) {
        test::eq(#lex.next()!!, *tok);
    }
}


fn void test_empty() @test {
    Lexer lex = @make_lexer("");
    @verify_tokens(lex, {
        { .kind = EOF, .ref = {1, 1} }
    });
}

fn void test_empty_with_whitespaces() @test {
    Lexer lex = @make_lexer("  \t\t\n ");
    @verify_tokens(lex, {
        { .kind = EOF, .ref = {2, 2} }
    });
}

fn void test_number() @test {
    Lexer lex = @make_lexer("12");
    @verify_tokens(lex, {
        { .kind = NUMBER, .val = {12}, .ref = {1,1} },
        { .kind = EOF, .ref = {1,3} }
    });
}

fn void test_simple() @test {
    Lexer lex = @make_lexer("12 + 18 * 22 / 7 + 16 %3");
    @verify_tokens(lex, {
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
    });
}

fn void test_complex() @test {
    Lexer lex = @make_lexer("-18*22/(7+\n16 % 3)\n\t");
    @verify_tokens(lex, {
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
    });
}

fn void test_unknown() @test {
    Lexer lex = @make_lexer("@");
    test::@error(lex.next(), lexer::UNKNOWN_CHAR);
    @verify_tokens(lex, {
        { .kind = EOF, .ref = {1, 2} }
    });
}

fn void test_unknown_continues() @test {
    Lexer lex = @make_lexer("1@2");
    @verify_tokens(lex, { { .kind = NUMBER, .val = {1}, .ref = {1, 1} } });
    test::@error(lex.next(), lexer::UNKNOWN_CHAR);
    @verify_tokens(lex, {
        { .kind = NUMBER, .val = {2}, .ref = {1, 3} },
        { .kind = EOF, .ref = {1, 4} }
    });
}

fn void test_overflow() @test {
    Lexer lex = @make_lexer("2147483648");
    test::@error(lex.next(), lexer::OVERFLOW);
}

fn void test_overflow_consumes_digits() @test {
    Lexer lex = @make_lexer("2147483648+1");
    test::@error(lex.next(), lexer::OVERFLOW);
    @verify_tokens(lex, {
        { .kind = PLUS, .val = {'+'}, .ref = {1, 11} },
        { .kind = NUMBER, .val = {1}, .ref = {1, 12} },
        { .kind = EOF, .ref = {1, 13} }
    });
}

fn void test_identifier() @test {
    Lexer lex = @make_lexer("let x");
    @verify_tokens(lex, {
        { .kind = IDENT, .name = "let", .ref = {1, 1} },
        { .kind = IDENT, .name = "x", .ref = {1, 5} },
        { .kind = EOF, .ref = {1, 6} }
    });
}

fn void test_keyword_and_symbol_tokens() @test {
    Lexer lex = @make_lexer("fn int sq(int n) { n = 5 }");
    @verify_tokens(lex, {
        { .kind = IDENT, .name = "fn", .ref = {1, 1} },
        { .kind = IDENT, .name = "int", .ref = {1, 4} },
        { .kind = IDENT, .name = "sq", .ref = {1, 8} },
        { .kind = LPAREN, .val = {'('}, .ref = {1, 10} },
        { .kind = IDENT, .name = "int", .ref = {1, 11} },
        { .kind = IDENT, .name = "n", .ref = {1, 15} },
        { .kind = RPAREN, .val = {')'}, .ref = {1, 16} },
        { .kind = LBRACE, .val = {'{'}, .ref = {1, 18} },
        { .kind = IDENT, .name = "n", .ref = {1, 20} },
        { .kind = EQ, .val = {'='}, .ref = {1, 22} },
        { .kind = NUMBER, .val = {5}, .ref = {1, 24} },
        { .kind = RBRACE, .val = {'}'}, .ref = {1, 26} },
        { .kind = EOF, .ref = {1, 27} }
    });
}
