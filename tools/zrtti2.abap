REPORT zrtti2.
DATA: od TYPE REF TO cl_abap_classdescr,
      ot TYPE REF TO cl_abap_typedescr,
      os TYPE REF TO cl_abap_structdescr,
      lo TYPE string_table,
      lv TYPE string,
      ls TYPE string.
FIELD-SYMBOLS: <mt> TYPE ANY TABLE,
               <m>  TYPE any,
               <pt> TYPE ANY TABLE,
               <p>  TYPE any,
               <ct> TYPE ANY TABLE,
               <c>  TYPE any,
               <n1> TYPE any,
               <t1> TYPE any.
od ?= cl_abap_classdescr=>describe_by_name( 'CL_PACKAGE_FACTORY' ).
ASSIGN od->('METHODS') TO <mt>.
LOOP AT <mt> ASSIGNING <m>.
  CLEAR ls.
  ASSIGN COMPONENT 'NAME' OF STRUCTURE <m> TO <n1>.
  IF sy-subrc = 0.
    ls = <n1>.
  ENDIF.
  IF ls = 'CREATE_NEW_PACKAGE'.
    ASSIGN COMPONENT 'PARAMETERS' OF STRUCTURE <m> TO <pt>.
    LOOP AT <pt> ASSIGNING <p>.
      CLEAR ls.
      ASSIGN COMPONENT 'NAME' OF STRUCTURE <p> TO <n1>.
      IF sy-subrc = 0.
        ls = <n1>.
      ENDIF.
      IF ls = 'C_PACKAGE_DATA'.
        ASSIGN COMPONENT 'TYPE' OF STRUCTURE <p> TO <t1>.
        IF sy-subrc <> 0.
          ASSIGN COMPONENT 'DECL_TYPE' OF STRUCTURE <p> TO <t1>.
        ENDIF.
        IF sy-subrc <> 0.
          APPEND 'NO_TYPE_COMPONENT' TO lo.
        ELSE.
          APPEND 'TYPE_COMPONENT_FOUND' TO lo.
          ot ?= <t1>.
          os ?= ot.
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
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDLOOP.
OPEN DATASET '/tmp/zrtti2.out' FOR OUTPUT IN TEXT MODE ENCODING UTF-8.
LOOP AT lo INTO lv.
  TRANSFER lv TO '/tmp/zrtti2.out'.
ENDLOOP.
CLOSE DATASET '/tmp/zrtti2.out'.
