@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View for ZR_DMO_PROCESSBO'
@ObjectModel.semanticKey: [ 'ProcessID' ]
define root view entity ZC_DMO_ProcessBO
  provider contract transactional_query
  as projection on ZR_DMO_ProcessBO
  association to one ZC_DMO_SALESORDER as _SalesOrder on _SalesOrder.Salesorder = $projection.Salesorder
{
  key ProcessID,
      Status,
      errorDescription,
      DesignTeam,
      Salesorder,
      Material,
      Billofmaterial,
      LocalLastChangedAt,
      _SalesOrder
}
