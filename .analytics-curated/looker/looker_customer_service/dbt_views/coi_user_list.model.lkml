connection: "es_snowflake_analytics"

include: "/dbt_views/*.view.lkml"
include: "/views/*.view.lkml"
#
explore: stg_t3__coi_user_list {
  join: billing_company_preferences {
    relationship: one_to_one
    sql_on: ${billing_company_preferences.company_id} = ${stg_t3__coi_user_list.supplier_id} ;;
  }
  join: companies {
    relationship: one_to_one
    sql_on: ${companies.company_id} = ${stg_t3__coi_user_list.supplier_id} ;;
  }
  join: company_documents {
    relationship: one_to_one
    sql_on: ${company_documents.company_id} = ${stg_t3__coi_user_list.supplier_id} and ${company_documents.voided} = 'FALSE';;
  }
  join: int_revenue {
    relationship: one_to_one
    sql_on: ${int_revenue.company_id} = ${stg_t3__coi_user_list.supplier_id} ;;
  }
  join: credit_applications {
    relationship: one_to_many
    sql_on: ${credit_applications.company_id} = ${stg_t3__coi_user_list.supplier_id} ;;
  }
  join: invoices {
    relationship: one_to_many
    sql_on: ${invoices.company_id} = ${stg_t3__coi_user_list.supplier_id} ;;
  }
  join: market_region_xwalk {
    relationship: one_to_many
    sql_on: ${market_region_xwalk.market_id} = ${invoices.branch_id} ;;
  }
  join: stg_t3__national_account_assignments {
    relationship: one_to_one
    sql_on: ${stg_t3__coi_user_list.supplier_id} = ${stg_t3__national_account_assignments.company_id} ;;
  }
  join: users {
    view_label: "National Account / Salesperson Users"
    relationship: one_to_many
    sql_on: ${users.user_id} = ${stg_t3__national_account_assignments.user_id} or ${users.user_id} = ${invoices.salesperson_user_id};;
  }
}
