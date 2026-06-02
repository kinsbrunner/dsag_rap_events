CLASS zbp_r_dmo_processbo DEFINITION PUBLIC ABSTRACT FINAL FOR BEHAVIOR OF zr_dmo_processbo.

  PUBLIC SECTION.
    TYPES tt_update TYPE TABLE FOR UPDATE ZR_DMO_ProcessBO\\ProcessBO.

    CLASS-METHODS raise_update_status
      IMPORTING it_update TYPE tt_update.

    CLASS-METHODS raise_new_status
      IMPORTING it_update TYPE tt_update.

ENDCLASS.


CLASS zbp_r_dmo_processbo IMPLEMENTATION.
  METHOD raise_update_status.

    DATA update_status_event TYPE TABLE FOR EVENT ZR_DMO_ProcessBO~updateStatus.

    LOOP AT it_update INTO DATA(ls_update).

      APPEND INITIAL LINE TO update_status_event ASSIGNING FIELD-SYMBOL(<event>).
      <event> = VALUE #( %key   = VALUE #( ProcessID = ls_update-ProcessID )
                         %param = VALUE #( material          = ls_update-Material
                                           billofmaterial    = ls_update-Billofmaterial
                                           status            = ls_update-Status
                                           error_description = ls_update-errorDescription ) ).

    ENDLOOP.

    RAISE ENTITY EVENT ZR_DMO_ProcessBO~updateStatus
          FROM update_status_event.

  ENDMETHOD.

  METHOD raise_new_status.

    DATA event_material_created TYPE TABLE FOR EVENT ZR_DMO_ProcessBO~materialCreated.
    DATA event_bom_created      TYPE TABLE FOR EVENT ZR_DMO_ProcessBO~bomCreated.
    DATA event_material_error   TYPE TABLE FOR EVENT ZR_DMO_ProcessBO~materialCreateError.

    LOOP AT it_update INTO DATA(ls_update).

      SELECT SINGLE FROM zdmo_procbo
        FIELDS *
        WHERE process_id = @ls_update-ProcessID
        INTO @DATA(ls_procbo).

      ls_procbo = CORRESPONDING #( BASE ( ls_procbo ) ls_update MAPPING FROM ENTITY USING CONTROL ).

      UPDATE zdmo_procbo FROM @ls_procbo.

      IF ls_update-Status = 'MAT_OK'.

        APPEND VALUE #( processid = ls_procbo-process_id ) TO event_material_created.

      ELSEIF ls_update-Status = 'MAT_ERR'.

        zcl_dmo_process_notification=>send_notification( iv_process_id = ls_update-ProcessID ).


      ELSEIF ls_update-status = 'BOM_OK'.

        APPEND VALUE #( processid = ls_procbo-process_id ) TO event_bom_created.

      ENDIF.

    ENDLOOP.

    IF event_material_created IS NOT INITIAL.
      RAISE ENTITY EVENT ZR_DMO_ProcessBO~materialCreated
            FROM event_material_created.
    ENDIF.

    IF event_bom_created IS NOT INITIAL.
      RAISE ENTITY EVENT ZR_DMO_ProcessBO~bomCreated
            FROM event_bom_created.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
