CLASS lsc_zr_dmo_salesorder DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

ENDCLASS.

CLASS lsc_zr_dmo_salesorder IMPLEMENTATION.

  METHOD save_modified.
    RAISE ENTITY EVENT zr_dmo_salesorder~SalesOrderCreated FROM VALUE #(
        FOR salesOrder IN create-salesorder ( SalesOrderID = salesOrder-salesorder ) ).
  ENDMETHOD.

ENDCLASS.

CLASS lhc_salesorder DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR SalesOrder
        RESULT result.
ENDCLASS.

CLASS lhc_salesorder IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.

ENDCLASS.
