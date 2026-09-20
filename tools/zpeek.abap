REPORT zpeek.
DATA: lr   TYPE REF TO data,
      lo   TYPE string_table,
      lv   TYPE string,
      lt_  TYPE string,
      lv_v TYPE string,
      lp   TYPE string,
      lx   TYPE string,
      lv_c TYPE i.
FIELD-SYMBOLS: <tab> TYPE STANDARD TABLE,
               <wa>  TYPE any,
               <f>   TYPE any.
CREATE DATA lr TYPE TABLE OF ('ZABAPGIT').
ASSIGN lr->* TO <tab>.
SELECT * FROM ('ZABAPGIT') INTO TABLE <tab> UP TO 100 ROWS.
lv_c = sy-dbcnt.
lv = |zabapgit_rows={ lv_c }|.
APPEND lv TO lo.
LOOP AT <tab> ASSIGNING <wa>.
  CLEAR: lt_, lv_v, lp.
  ASSIGN COMPONENT 'TYPE' OF STRUCTURE <wa> TO <f>.
  IF sy-subrc = 0.
    lt_ = <f>.
  ENDIF.
  IF lt_ CS 'REPO'.
    ASSIGN COMPONENT 'VALUE' OF STRUCTURE <wa> TO <f>.
    IF sy-subrc = 0.
      lv_v = <f>.
    ENDIF.
    ASSIGN COMPONENT 'DATA_STR' OF STRUCTURE <wa> TO <f>.
    IF sy-subrc = 0.
      lx = <f>.
      FIND REGEX '<PACKAGE>([^<]*)' IN lx SUBMATCHES lp.
    ENDIF.
    CONCATENATE 'repo_type=' lt_ 'value=' lv_v 'pkg=' lp
      INTO lv SEPARATED BY space.
    APPEND lv TO lo.
  ENDIF.
ENDLOOP.
OPEN DATASET '/tmp/zpeek.out' FOR OUTPUT IN TEXT MODE ENCODING UTF-8.
LOOP AT lo INTO lv.
  TRANSFER lv TO '/tmp/zpeek.out'.
ENDLOOP.
CLOSE DATASET '/tmp/zpeek.out'.
