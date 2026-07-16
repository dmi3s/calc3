# Calc3 — A C3 Calculator Learning Project
<img src="resources/calc3-logo.png" alt="Calc3 logo" align="left"
     style="float:left; width:160px; height:auto; margin: 0 16px 12px 0;"/>
<div style="clear: both;"></div>

The <b>formal goal</b> of this project is to define a grammar, implement a tokenizer
and parser, build an Abstract Syntax Tree (AST), and organize tree traversal.
The AST will be used for two purposes:
generating Reverse Polish Notation (RPN) and evaluating expressions.

---

The <b>real purpose</b> is to gain practical experience with the C3 language and
working with LLMs (online and offline) using a relatively young programming language
for which there are still relatively few examples available online.

## Calculator Syntax

<!--💡 **A brief reminder about EBNF.**-->
> [!NOTE] **A brief reminder about EBNF.**
>
> `{ X }` - 0 or more repetitions of `X`.
>
> `[ X ]` - 0 or 1 repetition of `X`.
>
> `( X | Y )` - grouping of alternatives.
>
> `,` - sequence.
>
> `;` - end of rule.
>
> `(*...*)` - comment.


```ebnf
expr = term , { ( "+" | "-" ) , term } ;
term = factor , { ( "*" | "/" ) , factor } ;
(* 
*  Unary signs are allowed before factors.
*  Therefore +0 == -0 == -(-0) == ... == 0.
*)
factor = [ sign ] , ( integer | "(" , expr , ")" ) ;
integer = ( non_zero_integer | "0" ) ;
non_zero_integer = non_zero_digit , { digit } ;
sign   = "+" | "-" ;
digit = "0" | non_zero_digit ;
non_zero_digit = "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" ;

```

# Building the Project

* Debug version:
  ```bash
  $ c3c build calc3
  ```
* Release version:
  ```bash
  $ c3c build calc3 -O2 -g0
  ```
* Running tests:
  ```bash
  $ c3c test calc3
  ```

# Project Structure
```
calc3/
├── .github/workflows/
│  └── ci.yaml                  ── GitHub CI workflow
├── src/                        ── Source code
│   └── ...
├── test/                       ── Tests
│   └── ...
├── project.json                ── Project configuration
...
```

# References for Information and Learning

- [https://c3-lang.org/](https://c3-lang.org/) - The main page about C3. It includes:
  - [https://c3-lang.org/getting-started/introduction/](https://c3-lang.org/getting-started/introduction/) - Documentation.
  - [https://c3-lang.org/blog/](https://c3-lang.org/blog/) - Blog.
- [https://github.com/c3lang/c3c](https://github.com/c3lang/c3c) - The 
source code of c3c itself.
- [https://github.com/c3lang/c3c/tree/master/lib/std](https://github.com/c3lang/c3c/tree/master/lib/std) - The source code of the standard library.
- [https://deepwiki.com/c3lang/c3c/1-overview](https://deepwiki.com/c3lang/c3c/1-overview) - A very interesting wiki with many things not included in the official documentation.
**Most importantly**, it has a search feature powered by (likely, fine-tuned) the **Devin model**, which provides excellent answers to questions about the C3 language and standard library. 
Both DeepSeek and ChatGPT are good general models, but their knowledge of C3 is limited. The Devin model on this site explains everything clearly, and when needed, even shows the source code of the stdlib  directly. I'm very impressed.


# License
The project is distributed under the MIT license.
