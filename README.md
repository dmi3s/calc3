English | [Русский](README.ru.md) | [中文](README.zh.md)

# Calc3 — a learning calculator project in C3

<img src="resources/calc3_logo.png" alt="Calc3 logo" align="left"
     style="float:left; width:160px; height:auto; margin: 0 16px 12px 0;"/>
<div style="clear: both;"></div>
The <b>formal goal</b> of the project is to define a grammar, implement a tokenizer and a parser.
Build an AST and organize a tree traversal.
In one case — to output reverse Polish notation, in the other — to evaluate the expression.

---

**The real goal** is to learn the C3 language in practice, to work with LLMs (online and offline)
using a relatively new programming language as an example, for which there are still
(relatively) few examples on the Internet.

# Building the project

- Debug version
  ```bash
  $ c3c build calc3
  ```
- Release version
  ```bash
  $ c3c build calc3 -O2 -g0
  ```
- Running tests
  ```bash
  $ c3c test calc3
  ```

# Input and output example

Interaction with the program is line-by-line: you type an expression and get the AST,
reverse Polish notation and the computed value. Example (all operator kinds are used —
`+ - * / %`, unary minus and parentheses):

```text
$ ./build/calc3
-(2 + 3) * 4 - 6 / 2 % 3
=== AST (Abstract syntax tree) ===
BIN(-) (1:14)
├── BIN(*) (1:10)
│   ├── UNARY(-) (1:1)
│   │   └── BIN(+) (1:5)
│   │       ├── NUM(2) (1:3)
│   │       └── NUM(3) (1:7)
│   └── NUM(4) (1:12)
└── BIN(%) (1:22)
    ├── BIN(/) (1:18)
    │   ├── NUM(6) (1:16)
    │   └── NUM(2) (1:20)
    └── NUM(3) (1:24)

=== RPN (Reverse Polish notation) ===
2 3 + NEG 4 * 6 2 / 3 % -

=== Result (Eval) ===
-20
```

## Calculator Syntax

```ebnf
expression = term, { ("+" | "-"), term } ;
term       = factor, { ("*" | "/" | "%"), factor } ;
factor     = { "+" | "-" }, primary ;
primary    = INTEGER | "(", expression, ")" ;

INTEGER    = digit, { digit } ;
digit      = "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" ;

```

## Structure explanation

|    Rule    |            Handles             | Precedence |               Associativity                |
| :--------: | :----------------------------: | :--------: | :----------------------------------------: |
| expression |         Binary + and -         |    Low     | Left (naturally follows from { op, term }) |
|    term    |         Binary *, /, %         |   Medium   |                    Left                    |
|   factor   |         Unary + and -          |    High    |                   Right                    |
|  primary   | Atoms: numbers and parentheses |  Highest   |                     —                      |

# Current state

The project implements the formal goal: tokenizer, parser, AST construction and tree
traversal — both to output reverse Polish notation and to evaluate expressions.

- **Tokens** — `src/token.c3`: token kinds (number, operators, parentheses, end of input),
  the token's value and its position in the source.
- **Lexer** — `src/lexer.c3`: splits the text into tokens, skips whitespace, tracks the
  position (row/column), catches integer overflow and unknown characters. On an error the
  lexer "reads through" the offending fragment and returns in a state as if it is ready to
  continue parsing — however, recovery from failures is not implemented yet and is not even
  planned.
- **AST** — `src/ast.c3`: an abstract syntax tree with three kinds of nodes —
  a number, a unary and a binary operation. Nodes can accept a visitor and be printed.
- **Visitors** — the Visitor pattern for tree traversal:
  - `src/ast.c3` — a demonstration visitor that prints nodes;
  - `src/ast_tree.c3` — `ast::to_tree()`: renders the AST as a tree (eza -T style);
  - `src/rpn_visitor.c3` — `ast::to_rpn()`: outputs reverse Polish notation
    (unary minus — `NEG`, unary plus — `POS`);
  - `src/eval_visitor.c3` — `ast::eval()`: evaluates the expression. Returns
    `Result{int, EvalError}`: division/modulo by zero, integer overflow
    (including `INT_MIN / -1` and `-INT_MIN`) produce an error with a position.
- **Parser** — `src/parser.c3`: recursive descent over the grammar (see above) respecting
  precedence and associativity; builds the AST, supports unary operators and parentheses.
  Errors are returned together with a description and position.
- **Entry point** — `src/main.c3`: reads expressions from stdin and prints, for each line,
  the RPN and the evaluated value (or an error message). In response to "?" it prints 42.
- **Tests** — `test/`: unit tests for the lexer, AST, parser, eval and the entry point
  (67 tests). Run with `c3c test calc3`.

Not planned: recovery of the lexer/parser after errors.

# Project structure

```
calc3/
├── .github/workflows/
│   └── ci.yaml                    ── CI: build and test on push/PR to main
├── src/                           ── Source code
│   ├── token.c3                   ── Tokens: kinds, value and position in the source
│   ├── lexer.c3                   ── Lexer: source text → stream of tokens
│   ├── ast.c3                     ── AST: tree nodes, interfaces and factories
│   ├── ast_tree.c3                ── Visitor: AST → tree (eza -T style)
│   ├── rpn_visitor.c3             ── Visitor: AST → reverse Polish notation
│   ├── eval_visitor.c3            ── Visitor: AST → expression value
│   ├── parser.c3                  ── Parser: tokens → AST (recursive descent)
│   └── main.c3                    ── Entry point: reads expressions from stdin
├── test/                          ── Tests
│   └── *.c3                       ── Unit tests for each module in src/
├── resources/
│   └── calc3_logo*.png             ── Project logo
├── project.json                   ── Build configuration and settings (c3c)
├── README.md                      ── Documentation in English
├── README.ru.md                   ── Documentation in Russian
├── README.zh.md                   ── Documentation in Chinese
└── LICENSE                        ── MIT license
```

# Reference and learning links

- [https://c3-lang.org/](https://c3-lang.org/) - the main C3 page. It contains:
  - - [https://c3-lang.org/getting-started/introduction/](https://c3-lang.org/getting-started/introduction/) - documentation.
  - [https://c3-lang.org/blog/](https://c3-lang.org/blog/) - blog.
- [https://github.com/c3lang/c3c](https://github.com/c3lang/c3c) - the c3c sources themselves.
- [https://github.com/c3lang/c3c/tree/master/lib/std](https://github.com/c3lang/c3c/tree/master/lib/std) - standard library sources.
- [https://deepwiki.com/c3lang/c3c/1-overview](https://deepwiki.com/c3lang/c3c/1-overview) - a very interesting wiki, it has many things not included in the official documentation. **The most important thing** - a (possibly specially fine-tuned) **Devin model** has been attached to the search there, and it answers questions about the C3 language and standard library very well. Both deepseek and chatgpt are good, but generic models. And they know C3 only so-so. But Devin explains everything on the site, and if necessary, shows the sources directly. Very impressed.
- [https://github.com/c3lang/c3-showcase](https://github.com/c3lang/c3-showcase) - a collection of projects in C3.
- [https://zed.dev/](https://zed.dev/) - a modern IDE that ships with several LLM - Free (or conditionally Free) models, and stands out from VS Code with its greatly increased speed. Its overall concept is more or less similar to VS Code.

# License

The project is distributed under the MIT license.
