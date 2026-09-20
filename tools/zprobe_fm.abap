REPORT zprobe_fm.
DATA: lt TYPE TABLE OF fupararef,
      ls TYPE fupararef,
      lo TYPE string_table,
      lv TYPE string,
      cnt TYPE i.
SELECT * FROM fupararef INTO TABLE lt
  WHERE funcname = 'SEO_CLASS_DELETE_COMPLETE'.
cnt = lines( lt ).
lv = |params={ cnt }|.
APPEND lv TO lo.
LOOP AT lt INTO ls.
  CONCATENATE 'P=' ls-parameter 'T=' ls-paramtype
    'S=' ls-structure INTO lv SEPARATED BY space.
  APPEND lv TO lo.
ENDLOOP.
OPEN DATASET '/tmp/zfm2.out' FOR OUTPUT IN TEXT MODE ENCODING UTF-8.
LOOP AT lo INTO lv.
  TRANSFER lv TO '/tmp/zfm2.out'.
ENDLOOP.
CLOSE DATASET '/tmp/zfm2.out'.
