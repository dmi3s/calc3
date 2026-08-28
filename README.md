<!-- source-hash: sha256:5bd25094a9db2e11ae31495b5b8cf8d11e08a3079723941b615cd13dc5bbba63 -->
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

## Example: defining and calling functions

Beyond arithmetic, the calculator supports user-defined functions and the built-in
`ask()`. Interaction is still line-by-line: one command per line.

```text
fn int add(int a, int b) { a + b }
add(2, 3)
fn int fact(int n) { if (n <= 1) { 1 } else { n * fact(n - 1) } }
fact(5)
fn int sq(int n) { n * n }
let x = sq(add(2, 3))
x
ask() + 1
```

Evaluation result (the `Result` field):

| Input | Result |
|-------|--------|
| `add(2, 3)` | `5` |
| `fact(5)` | `120` |
| `x` | `25` |
| `ask() + 1` | prints `? `, returns the entered integer `+ 1` |

Header syntax (prefix, like in C3):

```ebnf
function = "fn", Type, name, "(", [ Type, name, { ",", Type, name } ], ")", "{", expression, "}" ;
```

Parameters are listed explicitly and passed by value. Only the `int` type is supported
for now; a mismatched argument count yields `Argument count mismatch`, and an unknown
type yields `Unsupported type '...'`.

## Command-line usage

The program supports several run modes:

- `calc3` — interactive REPL: expressions are read one per line from stdin.
- `calc3 "<expression>"` — evaluate a single expression (prints AST, RPN and result).
- `calc3 -f <file>` or `calc3 --file <file>` — expressions from a file (one per line).
- `calc3 -h` / `calc3 --help` — show help.

To pass an expression that starts with `-` (e.g. a negative `-5`), use `--`:
`calc3 -- "-5 + 8"`.

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

- **Tokens** — [src/token.c3](src/token.c3): token kinds (number, operators, parentheses, end of input),
  the token's value and its position in the source.
- **Lexer** — [src/lexer.c3](src/lexer.c3): splits the text into tokens, skips whitespace, tracks the
  position (row/column), catches integer overflow and unknown characters. On an error the
  lexer "reads through" the offending fragment and returns in a state as if it is ready to
  continue parsing — however, recovery from failures is not implemented yet and is not even
  planned.
- **AST** — [src/ast.c3](src/ast.c3): an abstract syntax tree with three kinds of nodes —
  a number, a unary and a binary operation. Nodes can accept a visitor and be printed.
- **Visitors** — the Visitor pattern for tree traversal:
  - [src/ast.c3](src/ast.c3) — a demonstration visitor that prints nodes;
  - [src/ast_tree.c3](src/ast_tree.c3) — `ast::to_tree()`: renders the AST as a tree (eza -T style);
  - [src/rpn_visitor.c3](src/rpn_visitor.c3) — `ast::to_rpn()`: outputs reverse Polish notation
    (unary minus — `NEG`, unary plus — `POS`);
  - [src/eval_visitor.c3](src/eval_visitor.c3) — `ast::eval()`: evaluates the expression. Returns
    `Result{int, EvalError}`: division/modulo by zero, integer overflow
    (including `INT_MIN / -1` and `-INT_MIN`) produce an error with a position.
- **Parser** — [src/parser.c3](src/parser.c3): recursive descent over the grammar (see above) respecting
  precedence and associativity; builds the AST, supports unary operators, parentheses, `let`
  binding, and function definition/calls (`fn`). Errors are returned together with a description
  and position.
- **Symbol table** — [src/symbol_table.c3](src/symbol_table.c3): a single global namespace plus
  ephemeral call frames for parameters and recursion; stores variables (`let`) and function
  definitions (`fn`); the built-in `ask()` reads an `int` from stdin with the `? ` prompt.
- **Entry point** — [src/main.c3](src/main.c3): implements command-line argument parsing
  (`parse_args`), the interactive REPL (`run_repl`) and reading expressions from a file (`process_file`);
  for each expression it prints the AST, RPN and the evaluated value (or an error message). In response to "?" it prints 42.
- **Tests** — [test/](test/): unit tests for the lexer, AST, parser, eval and the entry point
  (92 tests). Run with `c3c test calc3`.

Not planned: recovery of the lexer/parser after errors.

# Documentation

<p align="center">
  <img src="resources/calc3_pipeline.svg" alt="Calc3 pipeline: text → lexer → tokens → parser → AST → RPN / Eval" width="760"/>
</p>

- Pipeline diagram — [source (D2)](docs/pipeline.d2)
- Architecture — [PDF](docs/architecture.pdf) · [source (Typst)](docs/architecture.typ)

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
│   └── main.c3                    ── Entry point: argument parsing, REPL and file input
├── test/                          ── Tests
│   └── *.c3                       ── Unit tests for each module in src/
├── resources/
│   └── calc3_logo*.png             ── Project logo
├── docs/                          ── Diagrams and documentation sources
│   ├── architecture.*             ── Architecture: Typst (.ru/.zh — translations), D2, SVG, PDF
│   ├── parser_ast.*               ── Tokenization and parsing into AST (D2 → SVG)
│   └── pipeline.*                 ── Pipeline text → lexer → … → RPN/Eval (D2 → SVG, in README)
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

## Syncing translations

The documentation source is `README.ru.md`. The translations `README.md`
(English) and `README.zh.md` (Chinese) must correspond to it. To track drift,
each translation embeds a hidden HTML comment with the sha256 of the source
at the top:

```text
<!-- source-hash: sha256:<64 hex> -->
```

The script `scripts/check_readme_sync` compares the current hash of
`README.ru.md` with the one embedded in the translations. Modes:
- (default) — non-blocking hint, always `exit 0`;
- `--update` — rewrites the markers in the translations with the current hash;
- `--strict` — fails (`exit 1`) if the translations do not correspond to the
  source (used in CI as a test).

Workflow when editing the source:
1. Edit `README.ru.md`.
2. `git commit` — the `pre-commit` hook reminds you (warning) but does not
   block the commit.
3. Manually update the translations `README.md` and `README.zh.md`.
4. Run `scripts/check_readme_sync --update` to refresh the markers.
5. Verify: `scripts/check_readme_sync --strict` (should print `OK`).
6. `git push` — the CI `--strict` step checks correspondence.

Note: the marker only reflects that the source changed, not translation
quality; run `--update` only after actually updating the translations.

## A note from the author

It started as a neat little exercise, but in practice grew into a compiler's
"undergrown child" :) As it stands, the language has only `let` and function
definitions. Functions are not first-class yet, but I'm strongly leaning that way.
This is a very experimental project — please don't judge it too harshly.

# License

The project is distributed under the MIT license.

# Project state: an outside view

> A brief summary for a random visitor, compiled from analysis of the codebase.

**Goals.**
- *Formal:* define a grammar, write a tokenizer and a recursive-descent parser,
  build an AST and implement two kinds of traversal — output reverse Polish
  notation and evaluate the expression's value.
- *Real:* hands-on learning of the C3 language and working with LLMs using a
  lesser-known language for which there are few examples online.

**Achievements.**
The formal pipeline `text → tokens → AST → RPN/value` is fully implemented.
There are 8 source modules covered by 92 unit tests. Three run modes are
available (REPL, file, single expression) plus a CLI with argument parsing.
Documentation is translated into three languages, and the architecture is
documented with diagrams and a PDF.

**General understanding for a random visitor.**
Calc3 is not a "product" but a learning sandbox: a minimal yet complete
calculator in C3 where each stage (lexer, parser, AST, visitors) is factored
into its own module and covered by tests. It is a good starting point for
understanding how an expression interpreter is built, while also getting to
know C3. There is no explicit roadmap yet — the author considers the formal
goal achieved.
