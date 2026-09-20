# zmult_table

Глобальный класс ABAP `zcl_mult_table` — таблица умножения. Минимальный пример
репозитория для abapGit (однофайловый формат класса, плоская раскладка).

## Установка (abapGit)

1. SE38 → `ZABAPGIT_STANDALONE` (или любой abapGit).
2. New Online → URL этого репозитория (скопируйте из браузера).
3. Пакет: `$ZMULT_TABLE` (abapGit предложит создать, родитель `$TMP`).

## API

```abap
DATA lv TYPE i.
lv = zcl_mult_table=>get_product( iv_a = 7 iv_b = 8 ).  " 56

DATA lt TYPE string_table.
lt = zcl_mult_table=>build_table( iv_n = 9 ).  " 81 строка вида "3 x 4 = 12"
```

Синтаксис совместим с NW 7.02.
