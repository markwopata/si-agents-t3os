include: "/_standard/analytics/commission/equipment_sales_finalized_post_jake_finalized.layer.lkml"
include: "/_standard/analytics/asset_details/asset_physical.layer.lkml"
include: "/_standard/analytics/public/line_item_types.layer.lkml"
include: "/_standard/analytics/rate_achievement/commission_rate_tiers.layer.lkml"
include: "/_standard/es_warehouse/public/invoices.layer.lkml"
include: "/_standard/es_warehouse/public/line_items.layer.lkml"
include: "/_standard/analytics/payroll/pa_employee_access.layer.lkml"
include: "/_standard/analytics/payroll/pa_market_access.layer.lkml"
include: "/_standard/analytics/payroll/company_directory.layer.lkml"


explore: equipment_sales_finalized_post_jake_finalized {

  case_sensitive: no
  sql_always_where:
  CASE
    WHEN '{{ _user_attributes['email'] }}' IN ('logan.dunkin@equipmentshare.com', 'connor.obannon@equipmentshare.com')
      THEN ${equipment_sales_finalized_post_jake_finalized.line_item_type_id} IN (81, 111, 123)

    WHEN '{{ _user_attributes['email'] }}' NOT IN ('logan.dunkin@equipmentshare.com', 'connor.obannon@equipmentshare.com')
      AND (
        ('yes' = {{ _user_attributes['people_analytics_access'] }})

      OR CONTAINS(LOWER(${pa_employee_access.manager_access_emails}), LOWER('{{ _user_attributes['email'] }}'))

      OR CONTAINS(LOWER(${company_directory.work_email}), LOWER('{{ _user_attributes['email'] }}'))

      OR (CONTAINS(LOWER(${pa_market_access.market_access_emails}), LOWER('{{ _user_attributes['email'] }}'))
        AND {{ _user_attributes['job_role'] }} IN ('regional_ops', 'district_sales_manager'))

      OR {{ _user_attributes['job_role'] }} IN ('hrbp', 'leadership')
      )

      THEN TRUE

    ELSE FALSE
  END ;;

  join: company_directory {
    type: left_outer
    relationship: many_to_one
    sql_on: ${equipment_sales_finalized_post_jake_finalized.employee_id} = ${company_directory.employee_id} ;;
  }

  join: pa_employee_access {
    type: left_outer
    relationship: many_to_one
    sql_on: ${equipment_sales_finalized_post_jake_finalized.employee_id} = ${pa_employee_access.employee_id} ;;
  }

  join: pa_market_access {
    type: left_outer
    relationship: many_to_one
    sql_on: ${company_directory.market_id}::varchar = ${pa_market_access.market_id}::varchar ;;
  }

  join: invoices {
    relationship: one_to_many
    type: left_outer
    sql_on: ${equipment_sales_finalized_post_jake_finalized.invoice_id} = ${invoices.invoice_id} ;;
  }

  join: asset_physical {
    relationship: many_to_one
    type: left_outer
    sql_on: ${equipment_sales_finalized_post_jake_finalized.asset_id} = ${asset_physical.asset_id} ;;
  }

  join: line_item_types {
    relationship: many_to_one
    type: left_outer
    sql_on: ${equipment_sales_finalized_post_jake_finalized.line_item_type_id} = ${line_item_types.line_item_type_id} ;;
  }

  join: line_items {
    relationship: many_to_one
    type: left_outer
    sql_on: ${equipment_sales_finalized_post_jake_finalized.asset_id} = ${line_items.asset_id} ;;
  }


}



explore: commission_rate_tiers {
}
