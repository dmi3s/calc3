[English](README.md) | [Русский](README.ru.md) | 中文

# Calc3 — 基于 C3 语言的入门计算器项目

<img src="resources/calc3-logo.png" alt="Calc3 logo" align="left"
     style="float:left; width:160px; height:auto; margin: 0 16px 12px 0;"/>
<div style="clear: both;"></div>
<b>正式目标</b>——定义文法、实现词法分析器（tokenizer）和语法分析器（parser），
构建抽象语法树（AST）并组织树的遍历。
一种情况——以输出逆波兰表达式（RPN）为目标；另一种情况——计算表达式的值。

---

**真正目标**——通过实践学习 C3 语言，练习使用 LLM（在线和离线），
以一个相对较新的编程语言为例，目前网上关于它的示例（相对）还很少。

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

# 项目结构

```
calc3/
├── .github/workflows/
│   └── ci.yaml                 ── GitHub CI workflow
├── src/                        ── 源代码
│   └── *.c3
├── test/                       ── 测试
│   └── *.c3
├── project.json                ── 项目配置
...
```

# 参考与学习链接

- [https://c3-lang.org/](https://c3-lang.org/) - C3 的主页。其中包含：
  - - [https://c3-lang.org/getting-started/introduction/](https://c3-lang.org/getting-started/introduction/) - 文档。
  - [https://c3-lang.org/blog/](https://c3-lang.org/blog/) - 博客。
- [https://github.com/c3lang/c3c](https://github.com/c3lang/c3c) - 即 c3c 的源码。
- [https://github.com/c3lang/c3c/tree/master/lib/std](https://github.com/c3lang/c3c/tree/master/lib/std) - 标准库源码。
- [https://deepwiki.com/c3lang/c3c/1-overview](https://deepwiki.com/c3lang/c3c/1-overview) - 一个非常有意思的 wiki，包含很多官方文档没有的内容。**最重要的是**——那里给搜索接上了（可能是专门微调过的）**Devin 模型**，它对 C3 语言和标准库的问题回答得非常好。deepseek 和 chatgpt 都不错，但它们是通用模型，对 C3 的了解也就一般。而 Devin 在网站上解释一切，必要时还能直接展示源码。印象非常深刻。
- [https://github.com/c3lang/c3-showcase](https://github.com/c3lang/c3-showcase) - C3 项目集锦。

# 许可证

本项目基于 MIT 许可证发布。