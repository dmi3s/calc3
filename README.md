## Calc3 - A C3-based Calculator Learning Project.

The formal goal of the project is to write a grammar, implement a tokenizer
and parser; to build an Abstract Syntax Tree (AST) and organize tree traversal;
in one case, with the aim of generating Reverse Polish Notation (RPN), and 
in another, to calculate the value of an expression.

The real goal is to learn C3 in practice, along with working with LLMs (online and offline), using a "new" programming language for which there are still relatively few examples available online.

## Language Grammar
### Brief EBNF Reference.

> `{ X }` - 0 or more repetitions of `X`.
>
> `[ X ]` - 0 or 1 repetition of `X`.
>
> `( X | Y )` - grouping of alternatives.
>
> `,` - sequence;
>
> `;` - end of rule.

### Calculator Syntax

```ebnf
expr = term , { ( "+" | "-" ) , term } ;
term = factor , { ( "*" | "/" ) , factor } ;
factor = integer | "(" , expr , ")" ;
(* The sign is allowed for "0": +0 == -0 == 0. It's not beautiful, but it's
correct. *)
integer = [ sign ] , ( non_zero_integer | "0" ) ;
non_zero_integer = non_zero_digit , { digit } ;
sign   = "+" | "-" ;
digit = "0" | digit_nz ;
non_zero_digit = "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" ;
```

## Building the Project
* Debug version:
  ```bash
  $ c3c build calc3
  ```
* Release version:
  ```bash
  $ c3c build calc3 -02 -g0
  ```
* Running tests:
  ```bash
  $ c3c test calc3
  ```

## Project Structure
```
calc3/
├── .github/workflows/
│   └── ci.yaml                 ── GitHub CI workflow
├── src/                        ── Source code
│   └── ...
├── tests/                      ── Tests
│   └── ...
├── project.json                ── Project configuration
```

## License
The project is distributed under the MIT license.
