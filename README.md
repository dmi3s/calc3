English | [Русский](README.ru.md) | [中文](README.zh.md)

# Calc3 — a learning calculator project in C3

<img src="resources/calc3-logo.png" alt="Calc3 logo" align="left"
     style="float:left; width:160px; height:auto; margin: 0 16px 12px 0;"/>
<div style="clear: both;"></div>
The <b>formal goal</b> of the project is to define a grammar, implement a tokenizer and a parser.
Build an AST and organize a tree traversal.
In one case — to output reverse Polish notation, in the other — to evaluate the expression.

---

**The real goal** is to learn the C3 language in practice, to work with LLMs (online and offline)
using a relatively new programming language as an example, for which there are still
(relatively) few examples on the Internet.

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

# Project structure

```
calc3/
├── .github/workflows/
│   └── ci.yaml                 ── GitHub CI workflow
├── src/                        ── Source code
│   └── *.c3
├── test/                       ── Tests
│   └── *.c3
├── project.json                ── Project configuration
...
```

# Reference and learning links

- [https://c3-lang.org/](https://c3-lang.org/) - the main C3 page. It contains:
  - - [https://c3-lang.org/getting-started/introduction/](https://c3-lang.org/getting-started/introduction/) - documentation.
  - [https://c3-lang.org/blog/](https://c3-lang.org/blog/) - blog.
- [https://github.com/c3lang/c3c](https://github.com/c3lang/c3c) - the c3c sources themselves.
- [https://github.com/c3lang/c3c/tree/master/lib/std](https://github.com/c3lang/c3c/tree/master/lib/std) - standard library sources.
- [https://deepwiki.com/c3lang/c3c/1-overview](https://deepwiki.com/c3lang/c3c/1-overview) - a very interesting wiki, it has many things not included in the official documentation. **The most important thing** - a (possibly specially fine-tuned) **Devin model** has been attached to the search there, and it answers questions about the C3 language and standard library very well. Both deepseek and chatgpt are good, but generic models. And they know C3 only so-so. But Devin explains everything on the site, and if necessary, shows the sources directly. Very impressed.
- [https://github.com/c3lang/c3-showcase](https://github.com/c3lang/c3-showcase) - a collection of projects in C3.

# License

The project is distributed under the MIT license.
