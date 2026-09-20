REPORT zrtti1.
DATA: od TYPE REF TO cl_abap_classdescr,
      oi TYPE REF TO cl_abap_intfdescr,
      lo TYPE string_table,
      lv TYPE string,
      ls TYPE string,
      lk TYPE string.
FIELD-SYMBOLS: <mt> TYPE ANY TABLE,
               <m>  TYPE any,
               <pt> TYPE ANY TABLE,
               <p>  TYPE any,
               <n1> TYPE any,
               <k1> TYPE any.
od ?= cl_abap_classdescr=>describe_by_name( 'CL_PACKAGE_FACTORY' ).
ASSIGN od->('METHODS') TO <mt>.
LOOP AT <mt> ASSIGNING <m>.
  CLEAR: ls, lk.
  ASSIGN COMPONENT 'NAME' OF STRUCTURE <m> TO <n1>.
  IF sy-subrc = 0.
    ls = <n1>.
  ENDIF.
  lv = |CLS_M={ ls }|.
  APPEND lv TO lo.
  IF ls = 'CREATE_NEW_PACKAGE'.
    ASSIGN COMPONENT 'PARAMETERS' OF STRUCTURE <m> TO <pt>.
    IF sy-subrc = 0.
      LOOP AT <pt> ASSIGNING <p>.
        CLEAR: ls, lk.
        ASSIGN COMPONENT 'NAME' OF STRUCTURE <p> TO <n1>.
        IF sy-subrc = 0.
          ls = <n1>.
        ENDIF.
        ASSIGN COMPONENT 'KIND' OF STRUCTURE <p> TO <k1>.
        IF sy-subrc = 0.
          lk = <k1>.
        ENDIF.
        CONCATENATE '  P=' ls 'KIND=' lk INTO lv SEPARATED BY space.
        APPEND lv TO lo.
      ENDLOOP.
    ENDIF.
  ENDIF.
ENDLOOP.
oi ?= cl_abap_typedescr=>describe_by_name( 'IF_PACKAGE' ).
ASSIGN oi->('METHODS') TO <mt>.
LOOP AT <mt> ASSIGNING <m>.
  CLEAR ls.
  ASSIGN COMPONENT 'NAME' OF STRUCTURE <m> TO <n1>.
  IF sy-subrc = 0.
    ls = <n1>.
  ENDIF.
  IF ls CS 'SHORT_TEXT' OR ls = 'SAVE'
     OR ls CS 'CHANGEABLE' OR ls CS 'RESPONSIBLE'.
    lv = |IF_M={ ls }|.
    APPEND lv TO lo.
    ASSIGN COMPONENT 'PARAMETERS' OF STRUCTURE <m> TO <pt>.
    IF sy-subrc = 0.
      LOOP AT <pt> ASSIGNING <p>.
        CLEAR: ls, lk.
        ASSIGN COMPONENT 'NAME' OF STRUCTURE <p> TO <n1>.
        IF sy-subrc = 0.
          ls = <n1>.
        ENDIF.
        ASSIGN COMPONENT 'KIND' OF STRUCTURE <p> TO <k1>.
        IF sy-subrc = 0.
          lk = <k1>.
        ENDIF.
        CONCATENATE '  P=' ls 'KIND=' lk INTO lv SEPARATED BY space.
        APPEND lv TO lo.
      ENDLOOP.
    ENDIF.
  ENDIF.
ENDLOOP.
OPEN DATASET '/tmp/zrtti.out' FOR OUTPUT IN TEXT MODE ENCODING UTF-8.
LOOP AT lo INTO lv.
  TRANSFER lv TO '/tmp/zrtti.out'.
ENDLOOP.
CLOSE DATASET '/tmp/zrtti.out'.
