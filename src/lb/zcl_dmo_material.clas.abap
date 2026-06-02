CLASS zcl_dmo_material DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    CLASS-METHODS create_for_process
      IMPORTING iv_process_id TYPE zr_dmo_processbo-processid.


    CLASS-METHODS create_material_via_template
      IMPORTING iv_process_id      TYPE zr_dmo_processbo-processid
      RETURNING VALUE(rv_material) TYPE zr_dmo_processbo-material
      RAISING   zcx_dmo_error.

ENDCLASS.


CLASS zcl_dmo_material IMPLEMENTATION.
  METHOD create_for_process.

    DATA process_update TYPE TABLE FOR UPDATE ZR_DMO_ProcessBO\\ProcessBO.
    DATA new_status     TYPE zdmo_status.

    READ ENTITIES OF ZR_DMO_ProcessBO
         ENTITY ProcessBO
         ALL FIELDS WITH VALUE #( ( %key = VALUE #( ProcessID = iv_process_id ) ) )
         RESULT DATA(process_read_result).

    LOOP AT process_read_result INTO DATA(read_result).

      APPEND INITIAL LINE TO process_update ASSIGNING FIELD-SYMBOL(<process_update>).

      TRY.
          DATA(lv_material) = create_material_via_template( iv_process_id = read_result-ProcessID ).

          new_status = 'MAT_OK'.
          <process_update> = VALUE #( %tky     = read_result-%tky
                                      Material = lv_material
                                      Status   = new_status
                                      %control = VALUE #( status   = if_abap_behv=>mk-on
                                                          material = if_abap_behv=>mk-on ) ).

        CATCH zcx_dmo_error INTO DATA(lx_error).

          new_status = 'MAT_ERR'.
          <process_update> = VALUE #( %tky             = read_result-%tky
                                      Status           = new_status
                                      errorDescription = lx_error->get_text( )
                                      %control         = VALUE #( errorDescription = if_abap_behv=>mk-on
                                                                  status           = if_abap_behv=>mk-on ) ).

      ENDTRY.

    ENDLOOP.

    IF zif_dmo_control=>c_cloud = abap_false.
      MODIFY ENTITIES OF ZR_DMO_ProcessBO
             ENTITY ProcessBO
             UPDATE FROM process_update.
    ELSEIF zif_dmo_control=>c_optimized = abap_true.
      zbp_r_dmo_processbo=>raise_new_status( it_update = process_update ).
    ELSE.
      zbp_r_dmo_processbo=>raise_update_status( it_update = process_update ).
    ENDIF.

  ENDMETHOD.

  METHOD create_material_via_template.

    IF zif_dmo_control=>c_template_exists = ABAP_true.

      CALL FUNCTION 'Z_DMO_BAPI_MAT'
        EXPORTING
          iv_text     = CONV zdmo_char50( |Mat-Text { iv_process_id }| )
          iv_baseunit = 'PCS'
        IMPORTING
          ev_material = rv_material.
    ELSE.
      RAISE EXCEPTION TYPE zcx_dmo_error
            MESSAGE e001.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
