@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View for ZR_DMO_SALESORDER'
@ObjectModel.semanticKey: [ 'Salesorder' ]
define root view entity ZC_DMO_SALESORDER
  provider contract transactional_query
  as projection on ZR_DMO_SALESORDER
{
  key Salesorder,
  Customer,
  MaterialText,
  LocalLastChangedAt
  
}
