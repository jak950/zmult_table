CLASS zcl_power DEFINITION PUBLIC INHERITING FROM zcl_mult_table
  FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    CLASS-METHODS:
      power
        IMPORTING iv_base TYPE i
                  iv_exp  TYPE i
        RETURNING VALUE(rv_result) TYPE i.
ENDCLASS.

CLASS zcl_power IMPLEMENTATION.

  METHOD power.
    rv_result = iv_base ** iv_exp.
  ENDMETHOD.

ENDCLASS.
