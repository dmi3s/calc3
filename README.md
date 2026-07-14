## Calc3 - A C3-based Calculator Learning Project.
The formal goal of the project is to write a grammar, implement a tokenizer
tokenizer and parser.
To build an Abstract Syntax Tree (AST) and organize its traversal.
In one case, with the aim of generating Reverse Polish Notation (RPN), and 
in another, to calculate the value of an expression.

The real goal is to practically learn the C3 language, as well as working w
with AI (online and offline), using a "new" programming language for which 
there are still relatively few examples available online.

## Language Grammar
```
ToDo.
```

## Project Build
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

