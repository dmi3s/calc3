# Calc3 — учебный проект калькулятора на C3

<img src="resources/calc3-logo.png" alt="Calc3 logo" align="left"
     style="float:left; width:160px; height:auto; margin: 0 16px 12px 0;"/>
<div style="clear: both;"></div>
<b>Формальная цель</b> проекта - определить грамматику, реализовать токенизатор и парсер.
Построить AST и органиовать обход дерева.
В одном случае - с целью вывести обратную польскую нотацию, в другом - вычислить значение выражения.

---

**Настоящая цель** - изучить на практике язык C3, работу с LLMs (online и offline) на
примере использования относительно нового языка программирования, для которого еще
(относительно) мало примеров в сети.

## Синтаксис калькуляттора

```ebnf
expression = term, { ("+" | "-"), term } ;
term       = factor, { ("*" | "/" | "%"), factor } ;
factor     = { "+" | "-" }, primary ;
primary    = INTEGER | "(", expression, ")" ;

INTEGER    = digit, { digit } ;
digit      = "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" ;

```

## Пояснение структуры

|  Правило   |      Отвечает за      | Приоритет |               Ассоциативность                |
| :--------: | :-------------------: | :-------: | :------------------------------------------: |
| expression |    Бинарные + и -     |  Низкий   | Левая (естественно вытекает из { op, term }) |
|    term    |   Бинарные *, /, %    |  Средний  |                    Левая                     |
|   factor   |     Унарные + и -     |  Высокий  |                    Правая                    |
|  primary   | Атомы: числа и скобки |  Высший   |                      —                       |

# Сборка проекта

- Debug версия
  ```bash
  $ c3c build calc3
  ```
- Release версия
  ```bash
  $ c3c build calc3 -O2 -g0
  ```
- Запуск тестов
  ```bash
  $ c3c test calc3
  ```

# Структура проекта

```
calc3/
├── .github/workflows/
│   └── ci.yaml                 ── GitHub CI workflow
├── src/                        ── Исходный код
│   └── *.c3
├── test/                       ── Тесты
│   └── *.c3
├── project.json                ── Конфигурация проекта
...
```

# Ссылки для справки и изучения

- [https://c3-lang.org/](https://c3-lang.org/) - главная страница о C3. Там есть:
  - - [https://c3-lang.org/getting-started/introduction/](https://c3-lang.org/getting-started/introduction/) - документация.
  - [https://c3-lang.org/blog/](https://c3-lang.org/blog/) - блог.
- [https://github.com/c3lang/c3c](https://github.com/c3lang/c3c) - собственно, исходники c3c.
- [https://github.com/c3lang/c3c/tree/master/lib/std](https://github.com/c3lang/c3c/tree/master/lib/std) - исходники стандартной библиотеки.
- [https://deepwiki.com/c3lang/c3c/1-overview](https://deepwiki.com/c3lang/c3c/1-overview) - очень интересная wiki, есть много вещей, не вошедших в официальную документацию. **Самое главное** - там к поиску прикрутили (возможно, специально дообученную) **модель Devin**, и она очень хорошо отвечает на вопросы по языку и стандартной библиотеке C3. И deepseek, и chatgpt хорошие, но универсальные модели. Да и C3 знают так себе. А Devin на сайте все объясняет, при необходимости - прямо исходники показывает. Очень впечатлен.
- [https://github.com/c3lang/c3-showcase](https://github.com/c3lang/c3-showcase) - коллекция проектов на C3.

# Лицензия

Проект распространяется под лицензией MIT.
