<!-- source-hash: sha256:b6f4a5dd1614d554a475efdffc75eb90429b9133bc8f98912374caabcdb2307d -->
[English](README.md) | [Русский](README.ru.md) | 中文

# Calc3 — 基于 C3 语言的入门计算器项目

<img src="resources/calc3_logo.png" alt="Calc3 logo" align="left"
     style="float:left; width:160px; height:auto; margin: 0 16px 12px 0;"/>
<div style="clear: both;"></div>
<b>正式目标</b>——定义文法、实现词法分析器（tokenizer）和语法分析器（parser），
构建抽象语法树（AST）并组织树的遍历。
一种情况——以输出逆波兰表达式（RPN）为目标；另一种情况——计算表达式的值。

---

**真正目标**——通过实践学习 C3 语言，练习使用 LLM（在线和离线），
以一个相对较新的编程语言为例，目前网上关于它的示例（相对）还很少。

# 构建项目

- 调试（Debug）版本
  ```bash
  $ c3c build calc3
  ```
- 发布（Release）版本
  ```bash
  $ c3c build calc3 -O2 -g0
  ```
- 运行测试
  ```bash
  $ c3c test calc3
  ```

# 输入输出示例

与程序的交互是逐行的：输入表达式，即可得到 AST、逆波兰表示法以及计算结果。
示例（涵盖了所有运算符类型——`+ - * / %`、一元负号和括号）：

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

## 计算器语法

```ebnf
expression = term, { ("+" | "-"), term } ;
term       = factor, { ("*" | "/" | "%"), factor } ;
factor     = { "+" | "-" }, primary ;
primary    = INTEGER | "(", expression, ")" ;

INTEGER    = digit, { digit } ;
digit      = "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" ;

```

## 结构说明

|    规则    |          负责          | 优先级 |                结合性                  |
| :--------: | :--------------------: | :----: | :------------------------------------: |
| expression |        二元 + 和 -     |   低   | 左结合（由 { op, term } 自然得出）     |
|    term    |        二元 *、/、%    |   中   |                  左                    |
|   factor   |        一元 + 和 -     |   高   |                  右                    |
|  primary   | 原子：数字和括号       |   最高 |                   —                    |

# 当前状态

项目已实现正式目标：词法分析器、语法分析器、AST 构建与树的遍历——既用于输出逆波兰表达式，
也用于计算表达式的值。

- **Token（记号）** — [src/token.c3](src/token.c3)：记号类型（数字、运算符、括号、输入结束）、
  记号的值及其在源码中的位置。
- **词法分析器（Lexer）** — [src/lexer.c3](src/lexer.c3)：把文本拆分为记号，跳过空白字符，
  跟踪位置（行/列），捕获整数溢出和未知字符。出错时，词法分析器会“读完”出问题的片段，
  并以“好像可以继续解析”的状态返回——不过，失败后的恢复目前尚未实现，也暂时没有计划。
- **AST** — [src/ast.c3](src/ast.c3)：抽象语法树，包含三种节点——数字、一元运算和二元运算。
  节点可以接受访问者（visitor），也可以被打印。
- **访问者（Visitor）** — 用于遍历树的访问者模式：
  - [src/ast.c3](src/ast.c3) — 打印节点的演示访问者；
  - [src/ast_tree.c3](src/ast_tree.c3) — `ast::to_tree()`：以树状形式输出 AST（eza -T 风格）；
  - [src/rpn_visitor.c3](src/rpn_visitor.c3) — `ast::to_rpn()`：输出逆波兰表达式（一元负号 — `NEG`，
    一元正号 — `POS`）；
  - [src/eval_visitor.c3](src/eval_visitor.c3) — `ast::eval()`：计算表达式的值。返回
    `Result{int, EvalError}`：除以/取模零、整数溢出（包括 `INT_MIN / -1` 和 `-INT_MIN`）
    会连同位置一起返回错误。
- **语法分析器（Parser）** — [src/parser.c3](src/parser.c3)：按照上面的文法进行递归下降，
  遵循优先级和结合性；构建 AST，支持一元运算符和括号。错误会连同描述和位置一起返回。
- **程序入口** — [src/main.c3](src/main.c3)：从 stdin 读取表达式，对每一行打印 RPN 和计算出的值
  （或错误信息）。输入 “?” 时输出数字 42。
- **测试** — [test/](test/)：针对词法分析器、AST、语法分析器、eval 和程序入口的单元测试
  （67 个测试）。运行方式：`c3c test calc3`。

暂不规划：词法分析器/语法分析器在出错后的恢复。

# 项目结构

```
calc3/
├── .github/workflows/
│   └── ci.yaml                    ── CI：在推送/PR 到 main 时构建并运行测试
├── src/                           ── 源代码
│   ├── token.c3                   ── Token：类型、值及其在源码中的位置
│   ├── lexer.c3                   ── 词法分析器：源码文本 → 记号流
│   ├── ast.c3                     ── AST：树节点、接口与工厂函数
│   ├── ast_tree.c3                ── 访问者：AST → 树（eza -T 风格）
│   ├── rpn_visitor.c3             ── 访问者：AST → 逆波兰表达式
│   ├── eval_visitor.c3            ── 访问者：AST → 表达式值
│   ├── parser.c3                  ── 语法分析器：Token → AST（递归下降）
│   └── main.c3                    ── 程序入口：从 stdin 读取表达式
├── test/                          ── 测试
│   └── *.c3                       ── 针对 src/ 中每个模块的单元测试
├── resources/
│   └── calc3_logo*.png             ── 项目 Logo
├── project.json                   ── 构建配置与设置（c3c）
├── README.md                      ── 英文文档
├── README.ru.md                   ── 俄文文档
├── README.zh.md                   ── 中文文档
└── LICENSE                        ── MIT 许可证
```

# 参考与学习链接

- [https://c3-lang.org/](https://c3-lang.org/) - C3 的主页。其中包含：
  - - [https://c3-lang.org/getting-started/introduction/](https://c3-lang.org/getting-started/introduction/) - 文档。
  - [https://c3-lang.org/blog/](https://c3-lang.org/blog/) - 博客。
- [https://github.com/c3lang/c3c](https://github.com/c3lang/c3c) - 即 c3c 的源码。
- [https://github.com/c3lang/c3c/tree/master/lib/std](https://github.com/c3lang/c3c/tree/master/lib/std) - 标准库源码。
- [https://deepwiki.com/c3lang/c3c/1-overview](https://deepwiki.com/c3lang/c3c/1-overview) - 一个非常有意思的 wiki，包含很多官方文档没有的内容。**最重要的是**——那里给搜索接上了（可能是专门微调过的）**Devin 模型**，它对 C3 语言和标准库的问题回答得非常好。deepseek 和 chatgpt 都不错，但它们是通用模型，对 C3 的了解也就一般。而 Devin 在网站上解释一切，必要时还能直接展示源码。印象非常深刻。
- [https://github.com/c3lang/c3-showcase](https://github.com/c3lang/c3-showcase) - C3 项目集锦。
- [https://zed.dev/](https://zed.dev/) - 一款现代 IDE，自带多个 LLM——Free（或条件性 Free）模型，与 VS Code 相比显著更快。其整体理念与 VS Code 大致相似。

## 翻译同步

文档的源头是 `README.ru.md`。翻译文件 `README.md`（英文）和 `README.zh.md`
（中文）必须与其保持一致。为了追踪偏差，每个翻译文件在开头嵌入了一段隐藏的
HTML 注释，包含源文件的 sha256：

```text
<!-- source-hash: sha256:<64 hex> -->
```

脚本 `scripts/check_readme_sync` 会将 `README.ru.md` 的当前哈希值与翻译文件
中嵌入的哈希值进行比较。模式：
- （默认）— 不阻塞的提示，始终 `exit 0`；
- `--update` — 用当前哈希值重写翻译文件中的标记；
- `--strict` — 若翻译与源文件不一致则失败（`exit 1`，在 CI 中作为测试使用）。

编辑源文件时的工作流：
1. 编辑 `README.ru.md`。
2. `git commit` — `pre-commit` 钩子会提醒你（warning），但不会阻止提交。
3. 手动更新翻译文件 `README.md` 和 `README.zh.md`。
4. 运行 `scripts/check_readme_sync --update` 以刷新标记。
5. 校验：`scripts/check_readme_sync --strict`（应显示 `OK`）。
6. `git push` — CI 的 `--strict` 步骤会检查一致性。

注意：标记仅反映源文件是否改动，而不反映翻译质量；请务必在真正更新翻译
之后才运行 `--update`。

# 许可证

本项目基于 MIT 许可证发布。