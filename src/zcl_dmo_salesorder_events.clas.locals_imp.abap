CLASS leh_zr_dmo_salesorder DEFINITION INHERITING FROM cl_abap_behavior_event_handler.
  PRIVATE SECTION.
    METHODS handle_event_created FOR ENTITY EVENT importing_parameter FOR SalesOrder~salesordercreated.

ENDCLASS.


CLASS leh_zr_dmo_salesorder IMPLEMENTATION.
  METHOD handle_event_created.

    MODIFY ENTITIES OF ZR_DMO_ProcessBO
           ENTITY ProcessBO
           EXECUTE createForSalesOrder
           AUTO FILL CID
           WITH VALUE #( FOR row IN importing_parameter
                         ( %cid                = row-SalesOrderID
                           %param-SalesOrderID = row-SalesOrderID ) )
           FAILED DATA(failed).
    ASSERT failed IS INITIAL.

  ENDMETHOD.
ENDCLASS.
