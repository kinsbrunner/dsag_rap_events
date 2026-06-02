CLASS lsc_zr_dmo_processbo DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.
    METHODS save_modified REDEFINITION.

ENDCLASS.


CLASS lsc_zr_dmo_processbo IMPLEMENTATION.
  METHOD save_modified.

    DATA event_proc_started     TYPE TABLE FOR EVENT ZR_DMO_ProcessBO~processStarted.
    DATA event_mat_created      TYPE TABLE FOR EVENT ZR_DMO_ProcessBO~materialCreated.
    DATA event_bom_created      TYPE TABLE FOR EVENT ZR_DMO_ProcessBO~bomCreated.
    DATA event_mat_create_error TYPE TABLE FOR EVENT ZR_DMO_ProcessBO~materialCreateError.

    LOOP AT create-processbo INTO DATA(process_created)
         WHERE %control-Status = if_abap_behv=>mk-on.

      IF process_created-Status = 'MAT_CRT'.

        APPEND INITIAL LINE TO event_proc_started ASSIGNING FIELD-SYMBOL(<proc_started>).
        <proc_started>-%key = process_created-%key.

      ENDIF.

    ENDLOOP.

    LOOP AT update-processbo INTO DATA(process_updated)
         WHERE %control-Status = if_abap_behv=>mk-on.

      IF process_updated-Status = 'MAT_CRT'.

        APPEND INITIAL LINE TO event_proc_started ASSIGNING <proc_started>.
        <proc_started>-%key = process_updated-%key.

      ELSEIF process_updated-Status = 'MAT_OK'.

        APPEND INITIAL LINE TO event_mat_created ASSIGNING FIELD-SYMBOL(<mat_created>).
        <mat_created>-%key = process_updated-%key.

      ELSEIF process_updated-Status = 'BOM_OK'.

        APPEND INITIAL LINE TO event_bom_created ASSIGNING FIELD-SYMBOL(<bom_created>).
        <bom_created>-%key = process_updated-%key.

      ELSEIF process_updated-Status = 'MAT_ERR'.

        APPEND INITIAL LINE TO event_mat_create_error ASSIGNING FIELD-SYMBOL(<mat_error>).
        <mat_error>-%key = process_updated-%key.

      ENDIF.

    ENDLOOP.

    IF event_proc_started IS NOT INITIAL.
      RAISE ENTITY EVENT ZR_DMO_ProcessBO~processStarted
            FROM event_proc_started.
    ENDIF.
    IF event_mat_created IS NOT INITIAL.
      RAISE ENTITY EVENT ZR_DMO_ProcessBO~materialCreated
            FROM event_mat_created.
    ENDIF.
    IF event_bom_created IS NOT INITIAL.
      RAISE ENTITY EVENT ZR_DMO_ProcessBO~bomCreated
            FROM event_bom_created.
    ENDIF.
    IF event_mat_create_error IS NOT INITIAL.
      RAISE ENTITY EVENT ZR_DMO_ProcessBO~materialCreateError
            FROM event_mat_create_error.
    ENDIF.

  ENDMETHOD.
ENDCLASS.


CLASS lhc_ProcessBO DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR ProcessBO RESULT result.

    METHODS createForSalesOrder FOR MODIFY
      IMPORTING keys FOR ACTION ProcessBO~createForSalesOrder.

    METHODS createSimple FOR MODIFY
      IMPORTING keys FOR ACTION ProcessBO~createSimple RESULT result.

    METHODS retry FOR MODIFY
      IMPORTING keys FOR ACTION ProcessBO~retry RESULT result.

    METHODS checkDesignTeam FOR VALIDATE ON SAVE
      IMPORTING keys FOR ProcessBO~checkDesignTeam.

ENDCLASS.


CLASS lhc_ProcessBO IMPLEMENTATION.
  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD createForSalesOrder.

    SELECT FROM zr_dmo_processbo
      FIELDS MAX( ProcessID )
      INTO @DATA(lv_max_processid).

    LOOP AT keys INTO DATA(key).
      lv_max_processid += 1.
      MODIFY ENTITIES OF zr_dmo_processbo IN LOCAL MODE
             ENTITY ProcessBO
             CREATE
             AUTO FILL CID
             SET FIELDS WITH VALUE #( ( %key-ProcessID = lv_max_processid
                                        Status         = 'MAT_CRT'
                                        DesignTeam     = 4712
                                        Salesorder     = key-%param-SalesOrderID ) )
             FAILED failed
             REPORTED reported.
    ENDLOOP.

  ENDMETHOD.

  METHOD createSimple.

    DATA process_update TYPE TABLE FOR UPDATE ZR_DMO_ProcessBO\\ProcessBO.

    DATA lv_material       TYPE zdmo_numc10.
    DATA lv_billofmaterial TYPE zdmo_numc10.

    READ ENTITIES OF ZR_DMO_ProcessBO IN LOCAL MODE
         ENTITY ProcessBO
         ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(process_read_result).

*    LOOP AT process_read_result INTO DATA(ls_read).
*
*
*      CALL FUNCTION 'Z_DMO_BAPI_MAT' DESTINATION 'NONE'
**      CALL FUNCTION 'Z_DMO_BAPI_MAT'
*        EXPORTING
*          iv_text     = CONV zdmo_char50( |Mat-Text { sy-datum } / { sy-uzeit }| )
*          iv_baseunit = 'PCS'
*        IMPORTING
*          ev_material = lv_material.
*
*      CALL FUNCTION 'Z_DMO_BAPI_BOM' DESTINATION 'NONE'
**      CALL FUNCTION 'Z_DMO_BAPI_BOM'
*        EXPORTING
*          iv_material       = lv_material
*          iv_description    = CONV zdmo_char50( |Bom-Text { sy-datum } / { sy-uzeit }| )
*        IMPORTING
*          ev_billofmaterial = lv_billofmaterial
*        EXCEPTIONS
*          material_unknown  = 1
*          OTHERS            = 2.
*      IF sy-subrc <> 0.
*        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO DATA(dummy) ##NEEDED.
*      ENDIF.
*
*      APPEND INITIAL LINE TO process_update ASSIGNING FIELD-SYMBOL(<update>).
*      <update> = VALUE #( %tky           = ls_read-%tky
*                          Material       = lv_material
*                          BillOfMaterial = lv_billofmaterial
*                          %control       = VALUE #( Material       = if_abap_behv=>mk-on
*                                                    BillOfMaterial = if_abap_behv=>mk-on ) ).
*
*      CLEAR lv_material.
*      CLEAR lv_billofmaterial.
*
*    ENDLOOP.
*
*    MODIFY ENTITIES OF ZR_DMO_ProcessBO IN LOCAL MODE
*           ENTITY ProcessBO
*           UPDATE
*           FROM process_update.
*
*    READ ENTITIES OF ZR_DMO_ProcessBO IN LOCAL MODE
*         ENTITY ProcessBO
*         ALL FIELDS WITH CORRESPONDING #( keys )
*         RESULT process_read_result.
*
*    LOOP AT process_read_result INTO ls_read.
*
*      APPEND INITIAL LINE TO result ASSIGNING FIELD-SYMBOL(<result>).
*      <result> = VALUE #( %tky   = ls_read-%tky
*                          %param = CORRESPONDING #( ls_read ) ).
*
*    ENDLOOP.

  ENDMETHOD.

  METHOD retry.

    DATA process_update TYPE TABLE FOR UPDATE ZR_DMO_ProcessBO\\ProcessBO.

    READ ENTITIES OF ZR_DMO_ProcessBO IN LOCAL MODE
         ENTITY ProcessBO
         ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(process_read_result).

    LOOP AT process_read_result INTO DATA(process_read).
      " WHERE Status = 'MAT_ERR'.

      APPEND INITIAL LINE TO process_update ASSIGNING FIELD-SYMBOL(<proc_update>).
      <proc_update> = VALUE #( %tky            = process_read-%tky
                               status          = 'MAT_CRT'
                               %control-Status = if_abap_behv=>mk-on ).

    ENDLOOP.

    MODIFY ENTITIES OF ZR_DMO_ProcessBO IN LOCAL MODE
           ENTITY ProcessBO
           UPDATE
           FROM process_update.

    READ ENTITIES OF ZR_DMO_ProcessBO IN LOCAL MODE
         ENTITY ProcessBO
         ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT process_read_result.

    LOOP AT process_read_result INTO process_read.

      APPEND INITIAL LINE TO result ASSIGNING FIELD-SYMBOL(<result>).
      <result> = VALUE #( %tky   = process_read-%tky
                          %param = CORRESPONDING #( process_read ) ).

    ENDLOOP.

  ENDMETHOD.

  METHOD checkDesignTeam.

    READ ENTITIES OF zr_dmo_processbo IN LOCAL MODE
         ENTITY ProcessBO
         ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(process_read_result).

    LOOP AT process_read_result INTO DATA(ls_read)
         WHERE DesignTeam IS INITIAL.

      APPEND INITIAL LINE TO failed-processbo ASSIGNING FIELD-SYMBOL(<failed>).
      <failed> = VALUE #( %tky = ls_read-%tky ).

      APPEND INITIAL LINE TO reported-processbo ASSIGNING FIELD-SYMBOL(<reported>).
      <reported> = VALUE #( %tky = ls_read-%tky
                            %msg = new_message_with_text( text = 'No Design-Team maintained!' ) ).

    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
