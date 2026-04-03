connection: "es_warehouse"

include: "/views/DBT_Triage_Tables/*.view.lkml"
include: "/views/*.view.lkml"

explore: stg_t3__asset_info {
 label: "Inventory Information"
 sql_always_where:
${asset_id} in (select asset_id from table(assetlist({{ _user_attributes['user_id'] }}::numeric)))
;;

 join: stg_t3__telematics_health {
   type: left_outer
   relationship: one_to_one
   sql_on: ${stg_t3__asset_info.asset_id} = ${stg_t3__telematics_health.asset_id} ;;
 }

  join: organization_asset_xref {
    type: left_outer
    relationship: many_to_one
    sql_on: ${stg_t3__asset_info.asset_id} = ${organization_asset_xref.asset_id} ;;
  }

  join: organizations {
    type: left_outer
    relationship: one_to_many
    sql_on: ${organization_asset_xref.organization_id} = ${organizations.organization_id}
      AND ${organizations.company_id} = {{ _user_attributes['company_id'] }}::numeric ;;
  }

  join: organizations_list_agg {
    type: left_outer
    relationship: one_to_many
    sql_on: ${stg_t3__asset_info.asset_id} = ${organizations_list_agg.asset_id}
      AND ${organizations_list_agg.company_id} = {{ _user_attributes['company_id'] }}::numeric ;;
  }

  join: asset_types {
    type: left_outer
    relationship: one_to_one
    sql_on: ${stg_t3__asset_info.asset_type} = ${asset_types.asset_type} ;;
  }

}
