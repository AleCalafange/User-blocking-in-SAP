*&---------------------------------------------------------------------*
*& Report ZBASIS_BLOCK_USER
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZBASIS_BLOCK_USER.

** Tabelas e tipos
TYPES: BEGIN OF ty_usr02,
       bname TYPE bname,
       trdat TYPE d,
     END OF ty_usr02.

TYPES: BEGIN OF ty_usuario_bloqueio,
       bname TYPE bname,
     END OF ty_usuario_bloqueio.

TYPES: tt_usuarios_bloqueio TYPE TABLE OF ty_usuario_bloqueio.

TYPES: BEGIN OF ty_usuarios_nao_bloquear,
         bname TYPE bname,
       END OF ty_usuarios_nao_bloquear.

TYPES: tt_usuarios_nao_bloquear TYPE TABLE OF ty_usuarios_nao_bloquear.

DATA: gt_usr02 TYPE TABLE OF ty_usr02,
      gs_usr02 TYPE ty_usr02.

** Variável para armazenar os dias de inatividade da TVARVC
DATA: lv_dias_inativo_tvarvc TYPE i.
DATA: lv_low_char TYPE string.

** Variável para armazenar os usuários que não podem ser bloqueados
DATA: gt_usuarios_nao_bloquear TYPE tt_usuarios_nao_bloquear,
      gs_usuarios_nao_bloquear TYPE ty_usuarios_nao_bloquear.
DATA: lv_usuarios_nao_bloquear TYPE string.

** Lê o valor da variável Z_DIAS_INATIVO da TVARVC
SELECT SINGLE low
  FROM tvarvc
  INTO lv_low_char
  WHERE name = 'Z_DIAS_INATIVO'.

** Verifica se o valor foi encontrado na TVARVC
IF sy-subrc <> 0.
  WRITE: / 'Variável Z_DIAS_INATIVO não encontrada na TVARVC. Verifique a configuração.'.
  EXIT.
ELSE.
  TRY.
      lv_dias_inativo_tvarvc = lv_low_char.
    CATCH cx_sy_conversion_error.
      WRITE: / 'Erro de conversão: Valor inválido para Z_DIAS_INATIVO na TVARVC.'.
      EXIT.
  ENDTRY.

  WRITE: / 'Dias de inatividade (TVARVC):', lv_dias_inativo_tvarvc.
ENDIF.

** Lê o valor da variável Z_USERS_NOT_BLOCKED da TVARVC
SELECT SINGLE low
  FROM tvarvc
  INTO lv_usuarios_nao_bloquear
  WHERE name = 'Z_USERS_NOT_BLOCKED'.

** Verifica se o valor foi encontrado na TVARVC
IF sy-subrc = 0 AND lv_usuarios_nao_bloquear IS NOT INITIAL.
  SPLIT lv_usuarios_nao_bloquear AT ',' INTO TABLE gt_usuarios_nao_bloquear.
  LOOP AT gt_usuarios_nao_bloquear INTO gs_usuarios_nao_bloquear.
    CONDENSE gs_usuarios_nao_bloquear-bname.
  ENDLOOP.
ENDIF.

** Seleciona usuários da USR02
SELECT bname trdat
  FROM usr02
  INTO TABLE gt_usr02
  WHERE ustyp = 'A' AND uflag <> 64.

** Tabela para armazenar usuários a serem bloqueados
DATA: gt_usuarios_bloqueio TYPE tt_usuarios_bloqueio,
      gs_usuario_bloqueio TYPE ty_usuario_bloqueio.

** Loop na tabela de usuários
LOOP AT gt_usr02 INTO gs_usr02.

** Calcula a diferença em dias entre a data do último logon e a data atual
  DATA: lv_dias_inativo TYPE i.
  lv_dias_inativo = sy-datum - gs_usr02-trdat.

** Verifica se o usuário está inativo por mais dias do que o definido na TVARVC
  IF lv_dias_inativo > lv_dias_inativo_tvarvc.

** Verifica se o usuário está na lista de não bloqueados
    READ TABLE gt_usuarios_nao_bloquear WITH KEY bname = gs_usr02-bname TRANSPORTING NO FIELDS.
    IF sy-subrc <> 0.
      gs_usuario_bloqueio-bname = gs_usr02-bname.
      APPEND gs_usuario_bloqueio TO gt_usuarios_bloqueio.
    ENDIF.
  ENDIF.

ENDLOOP.

** Verifica se há usuários para bloquear
IF gt_usuarios_bloqueio IS NOT INITIAL.



** Atualiza o campo GLTGB e UFLAG na USR02 para usuários bloqueados
  LOOP AT gt_usuarios_bloqueio INTO gs_usuario_bloqueio.
    UPDATE usr02
    SET gltgb = @sy-datum,  " Atualiza a data de bloqueio
        uflag = 64           " Atualiza o status de bloqueio (UFLAG = 64)
  WHERE bname = @gs_usuario_bloqueio-bname.

    IF sy-subrc = 0.
      WRITE: / 'Usuário bloqueado e GLTGB atualizado:', gs_usuario_bloqueio.
    ELSE.
      WRITE: / 'Erro ao atualizar GLTGB para usuário:', gs_usuario_bloqueio.
    ENDIF.
  ENDLOOP.

ELSE.
  WRITE: / 'Nenhum usuário inativo encontrado para bloqueio.'.
ENDIF.

** Mensagem de conclusão
WRITE: / 'Processo de bloqueio de usuários inativos via SU10 concluído.'.
