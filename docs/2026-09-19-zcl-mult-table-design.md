# Дизайн: глобальный класс ZCL_MULT_TABLE через abapGit

Дата: 2026-09-19. Утверждён пользователем в сессии Claude Code.

## Цель

Создать на локальной SAP VM (personalSAP EWM, NW 7.0x, ядро 7.22) глобальный класс
таблицы умножения `zcl_mult_table` **средствами abapGit** — как финальную проверку
починенной цепочки abapGit → прокси → GitHub (см. `../abapgit-https-resolution.md`).

## Решения

| Вопрос | Решение |
|---|---|
| Хостинг репозитория | GitHub, **публичный** (clone в abapGit анонимный, без пароля в SAP) |
| Push с хоста | токен из Windows Credential Manager (проверка тихая, без GUI-промптов) |
| Clone на VM | вручную в SAP GUI (~5 кликов: настройка прокси + New Online); остальное автоматизировано |
| Пакет | локальный `$ZMULT_TABLE` (без транспортов), создаётся abapGit при clone |
| Формат файлов | старый «однофайловый» формат класса (`.clas.abap` = определение + реализация) — понятен и старому standalone, и новым abapGit |
| Тест-класс в репо | нет — лишний риск сериализации на старом standalone; проверка отдельным SOAP-прогоном |

## Структура репозитория `zmult_table`

```
zmult_table/
├── .abapgit.xml                  # настройки репо (минимальные)
├── package.devc.xml              # пакет $ZMULT_TABLE
├── zcl_mult_table.clas.abap      # определение + реализация класса
├── zcl_mult_table.clas.xml       # метаданные класса (VSEOCLASS)
├── README.md
└── docs/2026-09-19-zcl-mult-table-design.md   # этот документ
```

## API класса

`zcl_mult_table` — глобальный, `PUBLIC CREATE`, `FINAL`, только статические методы:

```abap
CLASS zcl_mult_table DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    CLASS-METHODS get_product
      IMPORTING iv_a TYPE i
                iv_b TYPE i
      RETURNING VALUE(rv_product) TYPE i.
    CLASS-METHODS build_table
      IMPORTING iv_n          TYPE i DEFAULT 10
      RETURNING VALUE(rt_table) TYPE string_table.
ENDCLASS.
```

- `get_product( 7, 8 )` → `56`.
- `build_table( n )` → строки вида `3 x 4 = 12` для всех пар 1..N × 1..N
  (порядок: внешний цикл a = 1..N, внутренний b = 1..N; для N = 10 — 100 строк).

**Синтаксис — строго 7.02**: без inline-деклараций `DATA(...)`, без конструкторных
выражений `VALUE #(...)`; string-шаблоны `|...|` и `string_table` — можно.

## Поток установки

1. **Хост**: создать файлы репозитория → `git init` + commit.
2. **Хост**: взять токен GitHub из Credential Manager (`git credential fill`,
   без интерактивных промптов) → создать публичный репозиторий через GitHub API → push.
3. **VM, SAP GUI (пользователь, один раз)**:
   - SE38/SA38 → `ZABAPGIT_STANDALONE` → Settings → прокси `192.168.7.1:3128`;
   - New Online → URL репозитория, пакет `$ZMULT_TABLE` → clone
     (создаёт пакет + класс, активирует).
4. **Хост**: автопроверка через SOAP RFC (`tools/soap_rfc_run.py`) — отчёт вызывает
   `get_product( 7, 8 )` и `build_table( 9 )`, пишет результат в `/tmp`, файл забирается
   vmrun'ом; ожидания: `56`, 81 строка, строка `9 x 9 = 81` присутствует.

## Обработка ошибок

| Сбой | Реакция |
|---|---|
| Токен из Credential Manager не найден/нет права создания репо | попросить PAT у пользователя, либо пользователь создаёт пустой репозиторий сам и пушит по инструкции |
| Clone падает по TLS/сети | повторный прогон `tools/zdiag_wrap.abap`, диагностика по его выводу |
| Ошибки активации класса в abapGit | правка файлов на хосте → новый push → повторный pull в GUI |

## Вне объёма

- Тест-классы ABAP Unit в репозитории.
- Установка полной (пакетной) версии abapGit на VM.
- Изменения в SAP-системе помимо объектов, создаваемых самим abapGit clone
  (прокси в настройках abapGit — единственное ручное изменение, оно хранится в БД SAP).
