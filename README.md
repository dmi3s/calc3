## Calc3 - A C3 Calculator Learning Project.

The formal goal of the project is to write a grammar, implement a tokenizer
and parser.
To build an Abstract Syntax Tree (AST) and organize tree traversal.
In one case, with the aim of generating Reverse Polish Notation (RPN), and 
in another, to calculate the value of an expression.

The real purpose is to gain practical experience with the C3 language and
working with LLMs (online and offline) using a "new" programming language
for which there are still relatively few examples available online.

### Calculator Syntax

<!--💡 **A brief reminder about EBNF.**-->
> [!NOTE] **A brief reminder about EBNF.**
> * `{ X }` - 0 or more repetitions of `X`.
> * `[ X ]` - 0 or 1 repetition of `X`.
> * `( X | Y )` - grouping of alternatives.
> * `,` - sequence.
> * `;` - end of rule.
> * `(*...*)` - comment.


```ebnf
expr = term , { ( "+" | "-" ) , term } ;
term = factor , { ( "*" | "/" ) , factor } ;
factor = integer | "(" , expr , ")" ;
(* A sign is allowed before "0": +0 == -0 == 0.  It's not pretty, but it's 
correct.*)
integer = [ sign ] , ( non_zero_integer | "0" ) ;
non_zero_integer = non_zero_digit , { digit } ;
sign   = "+" | "-" ;
digit = "0" | non_zero_digit ;
non_zero_digit = "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" ;

```

## Building the Project
* Debug version:
  ```bash
  $ c3c build calc3
  ```
* Release version:
  ```bash
  $ c3c build calc3 -01 -g0
  ```
* Running tests:
  ```bash
  $ c3c test calc3
  ```

## Project Structure
```
calc3/
├── .github/workflows/
│  └── ci.yaml                 ── GitHub CI workflow
├── src/                        ── Source code
│   └── ...
├── tests/                      ── Tests
│   └── ...
├── project.json                ── Project configuration
...
```

## References for Information and Learning

- [https://c3-lang.org/](https://c3-lang.org/) - The main page about C3. It includes:
  - [https://c3-lang.org/getting-started/introduction/](https://c3-lang.org[https://c3-lang.org/getting-started/introduction/](https://c3-lang.org/getting-started/introduction/) - Documentation.
  - [https://c3-lang.org/blog/](https://c3-lang.org/blog/) - Blog.
- [https://github.com/c3lang/c3c](https://github.com/c3lang/c3c) - The sour
source code of c3c itself.
- [https://github.com/c3lang/c3c/tree/master/lib/std](https://github.com/c3[https://github.com/c3lang/c3c/tree/master/lib/std](https://github.com/c3lang/c3c/tree/master/lib/std) - Source code of the standard library.
- [https://deepwiki.com/c3lang/c3c/1-overview](https://deepwiki.com/c3lang/[https://deepwiki.com/c3lang/c3c/1-overview](https://deepwiki.com/c3lang/c3c/1-overview) - A very interesting wiki with many things not included in 
the official documentation.

## License
The project is distributed under the MIT license.
