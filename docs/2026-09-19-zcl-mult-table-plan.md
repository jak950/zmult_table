# ZCL_MULT_TABLE через abapGit — план реализации

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Глобальный класс `zcl_mult_table` (таблица умножения) на SAP VM (NW 7.0x), установленный clone'ом из публичного GitHub-репозитория через abapGit standalone, с автоматической проверкой результата через SOAP RFC.

**Architecture:** Репозиторий в старом «однофайловом» формате abapGit (плоская раскладка, стартовая папка `/`) создаётся на хосте и публикуется на GitHub. Clone в SAP выполняет пользователь в GUI (один раз: прокси + New Online). Верификация — SOAP-отчёт, вызывающий методы класса, с выводом в `/tmp` внутри VM и забором файла vmrun'ом.

**Tech Stack:** ABAP 7.02-совместимый, формат файлов abapGit v1.0.0, git 2.54 (хост), GitHub REST API, `Виртуалка\tools\soap_rfc_run.py` (SOAP RFC `RFC_ABAP_INSTALL_AND_RUN`), vmrun (VMware Player).

## Global Constraints

- Синтаксис ABAP — строго 7.02: без inline-деклараций `DATA(...)`, без `VALUE #(...)`; string-шаблоны `|…|` и `string_table` разрешены.
- Класс — в однофайловом формате: `zcl_mult_table.clas.abap` (определение + реализация) + `zcl_mult_table.clas.xml`.
- Пакет в SAP — локальный `$ZMULT_TABLE` (создаёт abapGit при clone).
- Токен GitHub из Credential Manager не логировать в вывод команд (маскировать, выводить только префикс 4 символа и длину).
- Строки ABAP-файлов, исполняемых через `soap_rfc_run.py`, ≤ 72 символов; первая строка — `REPORT …`.
- Класс НЕ создавать на VM другими каналами до clone — иначе abapGit clone конфликтует.
- Рабочая папка хоста: `c:\Users\79215\Documents\Claude code\Виртуалка\zmult_table\` (это git-репозиторий); скрипты VM-канала лежат в `..\tools\` (не в репозитории).
- VMX: `C:\Personal_EWM_4 Retail_2\personalSAP_EWM.vmx`; vmrun из Git Bash — только с `MSYS_NO_PATHCONV=1`; гостевые креды ewmadm/personalSAP1.
- Каждый commit завершать строкой `Co-Authored-By: Claude Code <noreply@anthropic.com>`.

---

### Task 1: Файлы репозитория в формате abapGit

**Files:**
- Create: `.abapgit.xml`
- Create: `package.devc.xml`
- Create: `zcl_mult_table.clas.abap`
- Create: `zcl_mult_table.clas.xml`
- Create: `README.md`
- Create: `tools/verify_mult.abap`
- Commit: все перечисленное (дизайн-док уже в `docs/`)

**Interfaces:**
- Consumes: ничего (первая задача).
- Produces: рабочее дерево репозитория; класс `zcl_mult_table` c методами `get_product( iv_a TYPE i, iv_b TYPE i ) RETURNING VALUE(rv_product) TYPE i` и `build_table( iv_n TYPE i DEFAULT 10 ) RETURNING VALUE(rt_table) TYPE string_table`; скрипт верификации `tools/verify_mult.abap`, пишущий в `/tmp/zver.out` строки `get_product_7_8=…`, `lines=…`, `line62=…`, `line81=…` (задача 4 запускает его и сверяет).

- [x] **Step 1: Создать `.abapgit.xml`**

```xml
<?xml version="1.0" encoding="utf-8"?>
<asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">
 <asx:values>
  <SETTINGS>
   <MASTER_LANGUAGE>E</MASTER_LANGUAGE>
   <STARTING_FOLDER>/</STARTING_FOLDER>
  </SETTINGS>
 </asx:values>
</asx:abap>
```

- [x] **Step 2: Создать `package.devc.xml`**

```xml
<?xml version="1.0" encoding="utf-8"?>
<abapGit version="v1.0.0" serializer="LCL_OBJECT_DEVC" serializer_version="v1.0.0">
 <asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">
  <asx:values>
   <DATA>
    <CTEXT>Multiplication table demo (ZCL_MULT_TABLE)</CTEXT>
   </DATA>
  </asx:values>
 </asx:abap>
</abapGit>
```

- [x] **Step 3: Создать `zcl_mult_table.clas.abap`** (синтаксис 7.02, произведение — через переменную, без арифметики внутри `{ }`)

```abap
CLASS zcl_mult_table DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    CLASS-METHODS:
      get_product
        IMPORTING iv_a TYPE i
                  iv_b TYPE i
        RETURNING VALUE(rv_product) TYPE i,
      build_table
        IMPORTING iv_n TYPE i DEFAULT 10
        RETURNING VALUE(rt_table) TYPE string_table.
ENDCLASS.

CLASS zcl_mult_table IMPLEMENTATION.

  METHOD get_product.
    rv_product = iv_a * iv_b.
  ENDMETHOD.

  METHOD build_table.
    DATA: lv_a TYPE i,
          lv_b TYPE i,
          lv_p TYPE i.
    DO iv_n TIMES.
      lv_a = sy-index.
      DO iv_n TIMES.
        lv_b = sy-index.
        lv_p = lv_a * lv_b.
        APPEND |{ lv_a } x { lv_b } = { lv_p }| TO rt_table.
      ENDDO.
    ENDDO.
  ENDMETHOD.

ENDCLASS.
```

- [x] **Step 4: Создать `zcl_mult_table.clas.xml`**

```xml
<?xml version="1.0" encoding="utf-8"?>
<abapGit version="v1.0.0" serializer="LCL_OBJECT_CLAS" serializer_version="v1.0.0">
 <asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">
  <asx:values>
   <VSEOCLASS>
    <CLSNAME>ZCL_MULT_TABLE</CLSNAME>
    <LANGU>E</LANGU>
    <DESCRIPT>Multiplication table</DESCRIPT>
    <STATE>1</STATE>
    <CLSCCINCL>X</CLSCCINCL>
    <FIXPT>X</FIXPT>
    <UNICODE>X</UNICODE>
   </VSEOCLASS>
   <DESCRIPTIONS>
    <SEOCOMPOTX>
     <CLSNAME>ZCL_MULT_TABLE</CLSNAME>
     <CMPNAME>GET_PRODUCT</CMPNAME>
     <LANGU>E</LANGU>
     <DESCRIPT>Product of two integers</DESCRIPT>
    </SEOCOMPOTX>
    <SEOCOMPOTX>
     <CLSNAME>ZCL_MULT_TABLE</CLSNAME>
     <CMPNAME>BUILD_TABLE</CMPNAME>
     <LANGU>E</LANGU>
     <DESCRIPT>N x N multiplication table lines</DESCRIPT>
    </SEOCOMPOTX>
   </DESCRIPTIONS>
  </asx:values>
 </asx:abap>
</abapGit>
```

- [x] **Step 5: Создать `README.md`**

````markdown
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
````

- [x] **Step 6: Создать `tools/verify_mult.abap`** (исполняется SOAP-каналом; все строки ≤72; итог — в `/tmp/zver.out`)

```abap
REPORT zver_mult.
DATA: lt_tab TYPE string_table,
      lt_out TYPE string_table,
      lv_p   TYPE i,
      lv_n   TYPE i,
      lv_s   TYPE string.
lv_p = zcl_mult_table=>get_product( iv_a = 7 iv_b = 8 ).
APPEND |get_product_7_8={ lv_p }| TO lt_out.
lt_tab = zcl_mult_table=>build_table( iv_n = 9 ).
lv_n = lines( lt_tab ).
APPEND |lines={ lv_n }| TO lt_out.
READ TABLE lt_tab INTO lv_s INDEX 62.
APPEND |line62={ lv_s }| TO lt_out.
READ TABLE lt_tab INTO lv_s INDEX 81.
APPEND |line81={ lv_s }| TO lt_out.
OPEN DATASET '/tmp/zver.out' FOR OUTPUT IN TEXT MODE.
LOOP AT lt_out INTO lv_s.
  TRANSFER lv_s TO '/tmp/zver.out'.
ENDLOOP.
CLOSE DATASET '/tmp/zver.out'.
```

- [x] **Step 7: Локальные проверки (тест задачи)**

```bash
cd "c:/Users/79215/Documents/Claude code/Виртуалка/zmult_table"
python - <<'EOF'
import xml.dom.minidom as m, sys
for f in ['.abapgit.xml','package.devc.xml','zcl_mult_table.clas.xml']:
    m.parse(f); print(f, 'XML OK')
EOF
awk 'length > 72 {print FILENAME": "FNR" len="length}' tools/verify_mult.abap
grep -c 'ENDCLASS' zcl_mult_table.clas.abap
grep -c 'METHOD ' zcl_mult_table.clas.abap
```

Expected: три строки `XML OK`; awk — пусто (нет строк длиннее 72); `grep -c ENDCLASS` = 2; `grep -c 'METHOD '` = 2.

- [x] **Step 8: Commit**

```bash
git add -A
git commit -m "feat: файлы abapGit для ZCL_MULT_TABLE (пакет \$ZMULT_TABLE)

Co-Authored-By: Claude Code <noreply@anthropic.com>"
```

---

### Task 2: Публикация на GitHub

**Files:**
- Modify: ничего в дереве (remote добавляется в `.git/config`)

**Interfaces:**
- Consumes: коммиты из Task 1 (ветка `main`).
- Produces: публичный репозиторий `https://github.com/<login>/zmult_table` с веткой `main`, доступный анонимному чтению (Task 3 даёт этот URL пользователю).

**Внимание:** Step 1–2 — ОДИН составной вызов bash (переменные окружения не переживают отдельные вызовы).

- [x] **Step 1: Токен → логин → создать репозиторий → push → анонимная проверка** (токен не выводить, маскировать)

```bash
cd "c:/Users/79215/Documents/Claude code/Виртуалка/zmult_table" || exit 1
CRED=$(printf 'protocol=https\nhost=github.com\n\n' | \
  GCM_INTERACTIVE=never GIT_TERMINAL_PROMPT=0 git credential fill 2>/dev/null)
TOKEN=$(printf '%s\n' "$CRED" | sed -n 's/^password=//p')
GHUSER=$(printf '%s\n' "$CRED" | sed -n 's/^username=//p')
[ -n "$TOKEN" ] || { echo 'NO_TOKEN'; exit 1; }
LOGIN=$(curl -s -H "Authorization: Bearer $TOKEN" https://api.github.com/user | \
  python -c "import sys,json; print(json.load(sys.stdin).get('login',''))")
[ -n "$LOGIN" ] || { echo 'NO_LOGIN'; exit 1; }
echo "user=$GHUSER login=$LOGIN token=${TOKEN:0:4}*** len=${#TOKEN}"
code=$(curl -s -o /tmp/ghrepo.json -w '%{http_code}' -X POST \
  -H "Authorization: Bearer $TOKEN" -H "Accept: application/vnd.github+json" \
  https://api.github.com/user/repos \
  -d '{"name":"zmult_table","description":"ABAP multiplication table ZCL_MULT_TABLE (abapGit)","private":false,"has_issues":false,"has_wiki":false,"has_projects":false}')
echo "create_http=$code"
if [ "$code" = "422" ]; then
  n=$(git ls-remote "https://github.com/$LOGIN/zmult_table.git" | wc -l)
  [ "$n" = "0" ] && echo "repo exists, empty -> reuse" || { echo "REPO_CONFLICT"; exit 1; }
fi
git remote remove origin 2>/dev/null
git remote add origin "https://github.com/$LOGIN/zmult_table.git"
git push "https://x-access-token:${TOKEN}@github.com/${LOGIN}/zmult_table.git" main:main 2>&1 \
  | sed "s/${TOKEN}/***/g"
git ls-remote "https://github.com/$LOGIN/zmult_table.git" refs/heads/main
curl -s "https://api.github.com/repos/$LOGIN/zmult_table/contents/zcl_mult_table.clas.abap" | \
  python -c "import sys,json; print('content:', json.load(sys.stdin).get('name','MISSING'))"
echo "REPO_URL=https://github.com/$LOGIN/zmult_table"
```

Expected, по порядку: `user=… login=<ваш-логин> token=XXXX*** len=…`; `create_http=201` (или `422` + `repo exists, empty -> reuse`); push без ошибок; анонимный `ls-remote` печатает `<sha>\trefs/heads/main`; `content: zcl_mult_table.clas.abap`; последняя строка — готовый `REPO_URL`. Сбои: `NO_TOKEN` → остановиться и спросить у пользователя PAT (fallback из спеки); `REPO_CONFLICT` → репозиторий с чужим контентом, спросить пользователя.

Анонимный `ls-remote` — это ровно то, чем будет пользоваться abapGit при clone.

- [x] **Step 2: Сохранить URL для следующих задач**

Запомнить последнюю строку вывода: `REPO_URL=https://github.com/<login>/zmult_table`.

---

### Task 3: Clone на VM (пользователь в SAP GUI)

**Files:**
- Create: ничего на хосте (шаг ожидания пользователя)

**Interfaces:**
- Consumes: `REPO_URL` из Task 2.
- Produces: на VM — пакет `$ZMULT_TABLE` и активный класс `zcl_mult_table` (их проверяет Task 4).

- [ ] **Step 1: Преком-проверки хоста и VM**

```bash
echo "sap: $(curl -s -o /dev/null -w '%{http_code}' http://192.168.7.102:8081/sap/public/ping)"
echo "proxy: $(curl -s -o /dev/null -w '%{http_code}' -x http://192.168.7.1:3128 https://github.com/)"
```

Expected: `sap: 200`, `proxy: 200`. Если proxy не 200 — запустить мини-прокси фоновым процессом (run_in_background, окно живёт, пока идёт работа) и повторить проверку:

```bash
cd "c:/Users/79215/Documents/Claude code/Виртуалка" && python tools/guest-proxy.py
```

- [ ] **Step 2: Дать пользователю инструкцию (текст ниже) и ждать подтверждения**

> 1. SAP GUI → клиент 002, ZAIDEVELOPER → SE38 (или SA38) → программа `ZABAPGIT_STANDALONE` → F8.
> 2. В abapGit: кнопка **Settings** на стартовом экране → закладка **Global** → поля proxy: host `192.168.7.1`, port `3128` → Save → Back.
> 3. Кнопка **New Online**: **Git Repository URL** = `<REPO_URL>`, **Package** = `$ZMULT_TABLE` → Enter/Continue.
> 4. Если спросит «package does not exist, create?» — подтвердить; родительский пакет указать `$TMP`.
> 5. Дождаться окончания clone: в списке репозиториев появится `zmult_table`, объекты `PACKAGE` и `CLASS` без красных статусов (активация входит в clone).

Возможные расхождения надписей (старый standalone) — «Settings» может называться «Global Settings», «New Online» — «Clone». Пользователь сообщает «готово» или присылает текст ошибки.

Сбой clone по сети/TLS (ICM 407, connection failed и т.п.) → прогон диагноста и разбор по его выводу (fallback из спеки):

```bash
cd "c:/Users/79215/Documents/Claude code/Виртуалка" && python tools/soap_rfc_run.py tools/zdiag_wrap.abap
```

- [ ] **Step 3: (после подтверждения) быстрый контроль с хоста**

Скрипт принимает путь к файлу, не stdin — сначала записать файл:

```bash
cat > "c:/Users/79215/Documents/Claude code/Виртуалка/zmult_table/tools/zchk_pkg.abap" <<'EOF'
REPORT zchk_pkg.
DATA: lv_cnt TYPE i,
      lv_s   TYPE string.
SELECT COUNT(*) INTO lv_cnt FROM tadir
  WHERE pgmid = 'R3TR' AND object = 'CLAS'
  AND obj_name = 'ZCL_MULT_TABLE' AND devclass = '$ZMULT_TABLE'.
lv_s = |tadir_cnt={ lv_cnt }|.
OPEN DATASET '/tmp/zchk.out' FOR OUTPUT IN TEXT MODE.
TRANSFER lv_s TO '/tmp/zchk.out'.
CLOSE DATASET '/tmp/zchk.out'.
EOF
cd "c:/Users/79215/Documents/Claude code/Виртуалка" && \
  python tools/soap_rfc_run.py zmult_table/tools/zchk_pkg.abap
MSYS_NO_PATHCONV=1 "/c/Program Files (x86)/VMware/VMware Player/vmrun.exe" -T player \
  -gu ewmadm -gp personalSAP1 copyFileFromGuestToHost \
  "C:\Personal_EWM_4 Retail_2\personalSAP_EWM.vmx" /tmp/zchk.out \
  "c:/Users/79215/Documents/Claude code/Виртуалка/zmult_table/tools/zchk.out"
cat "c:/Users/79215/Documents/Claude code/Виртуалка/zmult_table/tools/zchk.out"
```

Expected: `tadir_cnt=1` (запись TADIR создана в пакете `$ZMULT_TABLE`). `tadir_cnt=0` → класс не создан: вернуть пользователю текст ошибки из GUI. Если soap-прогон упал (ERRORMESSAGE) — разбирать по памяти `sap-vm-old-kernel-dev-tricks`. Удалить `tools/zchk.out` и `tools/zchk_pkg.abap` после проверки (временные файлы).

---

### Task 4: Верификация класса через SOAP RFC

**Files:**
- Create (временный): `tools/zver.out` — результат, забранный из VM (удалить после сверки)

**Interfaces:**
- Consumes: `tools/verify_mult.abap` (Task 1); активный класс `zcl_mult_table` на VM (Task 3); `..\tools\soap_rfc_run.py`.
- Produces: подтверждённые значения `get_product(7,8)=56`, `lines=81`, `line62=7 x 8 = 56`, `line81=9 x 9 = 81`.

- [ ] **Step 1: Прогнать верификационный отчёт**

```bash
cd "c:/Users/79215/Documents/Claude code/Виртуалка" && \
  python tools/soap_rfc_run.py zmult_table/tools/verify_mult.abap
```

Expected: запуск без ERRORMESSAGE (скрипт печатает результат вызова RFC).

- [ ] **Step 2: Забрать и прочитать /tmp/zver.out**

```bash
MSYS_NO_PATHCONV=1 "/c/Program Files (x86)/VMware/VMware Player/vmrun.exe" -T player \
  -gu ewmadm -gp personalSAP1 copyFileFromGuestToHost \
  "C:\Personal_EWM_4 Retail_2\personalSAP_EWM.vmx" /tmp/zver.out \
  "c:/Users/79215/Documents/Claude code/Виртуалка/zmult_table/tools/zver.out"
cat "c:/Users/79215/Documents/Claude code/Виртуалка/zmult_table/tools/zver.out"
```

- [ ] **Step 3: Сверка (тест задачи)**

Expected — ровно:

```
get_product_7_8=56
lines=81
line62=7 x 8 = 56
line81=9 x 9 = 81
```

Несовпадение `56`/`81`/строк → баг логики класса: править `zcl_mult_table.clas.abap` на хосте, commit, push (как в Task 2 Step 3), попросить пользователя сделать **Pull** в abapGit, повторить Steps 1–3. Файл не появился → класс неактивен/не создан: разбирать лог активации abapGit в GUI.

- [ ] **Step 4: Удалить временный файл**

```bash
rm "c:/Users/79215/Documents/Claude code/Виртуалка/zmult_table/tools/zver.out"
```

---

### Task 5: Финализация — память и статус-док

**Files:**
- Modify: `C:\Users\79215\.claude\projects\c--Users-79215-Documents-Claude-code----------\memory\sap-vm-mcp-setup.md` (обновить abapGit-абзац)
- Modify: `..\abapgit-https-resolution.md` (пометить «оставшийся шаг» выполненным)
- Commit: только изменения внутри `zmult_table/` (если правки README не понадобилось — коммита нет)

**Interfaces:**
- Consumes: успех Task 4 (значения сошлись), `LOGIN` из Task 2.
- Produces: обновлённая память (см. ниже) — для будущих сессий.

- [ ] **Step 1: Обновить память** — в `sap-vm-mcp-setup.md` заменить в abapGit-абзаце фразу про «единственный оставшийся шаг» (в статус-доке) и дополнить фактами: прокси настроен в глобальных настройках abapGit; публичный репозиторий `https://github.com/<LOGIN>/zmult_table`; класс `zcl_mult_table` в пакете `$ZMULT_TABLE` установлен clone'ом 2026-09-19, верифицирован SOAP (56/81/`7 x 8 = 56`).

- [ ] **Step 2: Обновить статус-док** — в `..\abapgit-https-resolution.md`, раздел «Оставшиеся хвосты»: пункт про настройку прокси пометить выполненным (дата, «clone zmult_table прошёл»).

- [ ] **Step 3: Сообщить результат пользователю**: URL репозитория, имя пакета/класса, итог верификации, как повторить pull (abapGit → репозиторий → Pull).
