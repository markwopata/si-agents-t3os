connection: "es_warehouse"

include: "/views/warranty_status_report/warranty_detail.view.lkml"
include: "/views/warranty_status_report/warranty_work_orders.view.lkml"



explore: warranty_detail {
  view_name: warranty_detail
  group_label: "Service"
  label: "Warranty Detail"
  case_sensitive: no
  # persist_for: "20 minutes"
 sql_always_where: ${company_id_a} =  {{ _user_attributes['company_id'] }};;

join: warranty_work_orders {
  type:  inner
  relationship: many_to_many
  sql_on:  ${warranty_detail.asset_id_asl}=${warranty_work_orders.asset_id_asl} ;;


  }
}
