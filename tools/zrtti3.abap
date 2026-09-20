REPORT zrtti3.
DATA: os TYPE REF TO cl_abap_structdescr,
      lo TYPE string_table,
      lv TYPE string,
      ls TYPE string.
FIELD-SYMBOLS: <ct> TYPE ANY TABLE,
               <c>  TYPE any,
               <n1> TYPE any.
os ?= cl_abap_typedescr=>describe_by_name( 'FUPARAREF' ).
ASSIGN os->('COMPONENTS') TO <ct>.
LOOP AT <ct> ASSIGNING <c>.
  CLEAR ls.
  ASSIGN COMPONENT 'NAME' OF STRUCTURE <c> TO <n1>.
  IF sy-subrc = 0.
    ls = <n1>.
  ENDIF.
  CONCATENATE 'FLD=' ls INTO lv.
  APPEND lv TO lo.
ENDLOOP.
OPEN DATASET '/tmp/zrtti3.out' FOR OUTPUT IN TEXT MODE ENCODING UTF-8.
LOOP AT lo INTO lv.
  TRANSFER lv TO '/tmp/zrtti3.out'.
ENDLOOP.
CLOSE DATASET '/tmp/zrtti3.out'.
