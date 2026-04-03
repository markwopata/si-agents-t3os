connection: "es_warehouse"

include: "/views/*.view.lkml"                # include all views in the views/ folder in this project

explore: eld_pairing_report {
  group_label: "Fleet"
  label: "ELD Paired/Unpaired Drive Time Report"
  case_sensitive: no
  persist_for: "10 minutes"

  sql_always_where:
     ${eld_pairing_report.asset_id} in (select asset_id from table(assetlist({{ _user_attributes['user_id'] }}::numeric)))
     or ${eld_pairing_report.company_id} = {{ _user_attributes['company_id'] }}::numeric
  ;;

  join: organization_asset_xref {
    type: left_outer
    relationship: many_to_one
    sql_on: ${eld_pairing_report.asset_id} = ${organization_asset_xref.asset_id} ;;
  }

  join: organizations {
    type: left_outer
    relationship: one_to_one
    sql_on: ${organization_asset_xref.organization_id} = ${organizations.organization_id} ;;
  }

}
