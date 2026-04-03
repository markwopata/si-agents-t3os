connection: "es_snowflake_analytics"

include: "/views/BUSINESS_INTELLIGENCE/*.view.lkml"
include: "/views/ANALYTICS/*.view.lkml"
include: "/Dashboards/Market_Operations_1378/salesperson_permissions/*.view.lkml"
include: "/views/ANALYTICS/market_region_xwalk.view.lkml"
include: "/views/ANALYTICS/company_directory.view.lkml"
include: "/views/ANALYTICS/fct_credit_notes.view.lkml"
include: "/views/ES_WAREHOUSE/rentals_solo.view.lkml"
include: "/views/ES_WAREHOUSE/orders.view.lkml"



datagroup: dim_credit_notes_update {
  sql_trigger: select max(date_created) from analytics.intacct_models.dim_credit_notes ;;
  max_cache_age: "8 hours"
  description: "Looking at analytics.intacct_models.dim_credit_notes for when a new credit notes comes in."
}

explore: dim_credit_notes {
  label: "Rental Salesperson - Credits Report"
  case_sensitive: no
  persist_with:  dim_credit_notes_update
  sql_always_where: ${dim_credit_notes.credit_note_status_id} = 2 AND
           (( {{ _user_attributes['job_role'] }} = 'tam' AND '{{ _user_attributes['email'] }}' = ${salesperson_permissions.employee_email})
        OR contains(${salesperson_permissions.manager_access_emails}, '{{ _user_attributes['email'] }}')
        OR {{ _user_attributes['job_role'] }} = 'developer'
        OR {{ _user_attributes['job_role'] }} = 'hrbp'
        OR {{ _user_attributes['job_role'] }} = 'leadership'
        OR {{ _user_attributes['job_role'] }} = 'legal'
        OR ('bobbi.malone@equipmentshare.com' = '{{ _user_attributes['email'] }}' )
        OR ('jay.mitchell@equipmentshare.com' = '{{ _user_attributes['email'] }}')
        OR ('kate.helmstetler@equipmentshare.com' = '{{ _user_attributes['email'] }}')
        OR ('mandy.peters@equipmentshare.com' = '{{ _user_attributes['email'] }}' AND (${salesperson_permissions.district_dated} IN ('5-8', '5-4') OR (${salesperson_permissions.region_name_dated} IN ('Southeast') and ${salesperson_permissions.business_segment} IN ('Advanced Solutions'))))
        OR ('victor.otalora@equipmentshare.com' = '{{ _user_attributes['email'] }}' AND (${salesperson_permissions.district_dated} IN ('2-3') OR (${salesperson_permissions.region_name_dated} IN ('Mountain West') and ${salesperson_permissions.business_segment} IN ('Advanced Solutions'))))
        OR ('mj.mason@equipmentshare.com' = '{{ _user_attributes['email'] }}' AND (${salesperson_permissions.district_dated} IN ('1-4') OR (${salesperson_permissions.region_name_dated} IN ('Pacific') and ${salesperson_permissions.business_segment} IN ('Advanced Solutions'))))
        OR ('mike.k.smith@equipmentshare.com' = '{{ _user_attributes['email'] }}' AND (${salesperson_permissions.district_dated} IN ('1-4') OR (${salesperson_permissions.region_name_dated} IN ('Pacific') and ${salesperson_permissions.business_segment} IN ('Advanced Solutions')))) -- requested by kyle stout in help looker
        OR ('kyle.stout@equipmentshare.com' = '{{ _user_attributes['email'] }}' AND (${salesperson_permissions.district_dated} IN ('1-4') OR (${salesperson_permissions.region_name_dated} IN ('Pacific') and ${salesperson_permissions.business_segment} IN ('Advanced Solutions'))))
        OR
          (case
            when 'laurenjo.stone@equipmentshare.com' = '{{ _user_attributes['email'] }}' then contains(${salesperson_permissions.manager_access_emails},'zach@equipmentshare.com')
            when 'josh.helmstetler@equipmentshare.com' = '{{ _user_attributes['email'] }}'  then contains(${salesperson_permissions.manager_access_emails},'josh.helmstetler@equipmentshare.com') OR contains(${salesperson_permissions.manager_access_emails},'karen.hubbard@equipmentshare.com')
            when 'web.bailey@equipmentshare.com' = '{{ _user_attributes['email'] }}'  then contains(${salesperson_permissions.manager_access_emails},'zach@equipmentshare.com')
            when 'kelly.adams@equipmentshare.com' = '{{ _user_attributes['email'] }}'  then contains(${salesperson_permissions.manager_access_emails},'zach@equipmentshare.com')
            when 'brian.kniffen@equipmentshare.com' = '{{ _user_attributes['email'] }}'  then contains(${salesperson_permissions.manager_access_emails},'justin.ingold@equipmentshare.com')
            when 'arianna.olson@equipmentshare.com' = '{{ _user_attributes['email'] }}' then contains(${salesperson_permissions.manager_access_emails}, 'brian.kniffen@equipmentshare.com') OR contains(${salesperson_permissions.manager_access_emails},'justin.ingold@equipmentshare.com')
            when 'mike.galvan@equipmentshare.com' = '{{ _user_attributes['email'] }}' and ${salesperson_permissions.region_name_dated} = 2 then contains(${salesperson_permissions.manager_access_emails},'justin.ingold@equipmentshare.com')
            when 'conner.bradley@equipmentshare.com' = '{{ _user_attributes['email'] }}' AND (${salesperson_permissions.employee_id} IN ('3102', '3654', '12795', '18434', '10321', '14194', '4275', '18691', '13644', '3644', '18880')) then contains(${salesperson_permissions.manager_access_emails},'toby.fischer@equipmentshare.com') OR contains(${salesperson_permissions.manager_access_emails},'kyle.stout@equipmentshare.com')
            END))
            AND NOT ('leann.thomas@equipmentshare.com' = '{{ _user_attributes['email'] }}' and ${salesperson_permissions.district_dated} IN ('8-4'))


    ;;

  join: credit_created_date {
    from: v_dim_dates_bi
    type: left_outer
    relationship: many_to_one
    sql_on: ${dim_credit_notes.date_created_date} = ${credit_created_date.date} ;;
  }

  join: dim_companies_bi {
    type: left_outer
    relationship: one_to_one
    sql_on: ${dim_credit_notes.company_id} = ${dim_companies_bi.company_id} ;;
  }

  join: credit_created_by {
    from: dim_users_bi
    type: left_outer
    relationship: many_to_one
    sql_on: ${dim_credit_notes.created_by_user_id} = ${credit_created_by.user_id} ;;
  }

  join: salesperson_permissions {
    type: inner
    relationship: many_to_one
    sql_on: ${dim_credit_notes.created_by_user_id} = ${salesperson_permissions.employee_user_id} ;;
  }

  join: dim_salesperson_enhanced_historical {
    from: dim_salesperson_enhanced
    view_label: "Historical Salesperson Info"
    type: left_outer
    relationship: many_to_one
    sql_on: ${dim_credit_notes.created_by_user_id} = ${dim_salesperson_enhanced_historical.user_id} AND
          ${credit_created_date.date} >=  ${dim_salesperson_enhanced_historical._valid_from_date} AND
          ${credit_created_date.date} < ${dim_salesperson_enhanced_historical._valid_to_date};;
  }

  join: salesperson_xwalk_historical {
    from: market_region_xwalk
    type: left_outer
    relationship: many_to_one
    sql_on:  ${dim_salesperson_enhanced_historical.market_id_hist} = ${salesperson_xwalk_historical.market_id} ;;
  }

  join: fct_credit_notes {
    view_label: "Credit Note Totals"
    type: left_outer
    relationship: one_to_one
    sql_on: ${dim_credit_notes.credit_note_id} = ${fct_credit_notes.credit_note_id} ;;
  }




}


datagroup: int_admin_credit_notes_update {
  sql_trigger: select max(date_created) from analytics.intacct_models.int_admin_credit_note_line_detail ;;
  max_cache_age: "8 hours"
  description: "Looking at analytics.intacct_models.int_admin_credit_note_line_detail for when a new credit notes comes in."
}

explore: int_admin_credit_note_line_detail {
  label: "Rental Salesperson - Credits Report 2"
  case_sensitive: no
  persist_with:  int_admin_credit_notes_update
  sql_always_where: ${int_admin_credit_note_line_detail.credit_note_status_id} = 2 AND not ${int_admin_credit_note_line_detail.is_intercompany} and
           (( {{ _user_attributes['job_role'] }} = 'tam' AND '{{ _user_attributes['email'] }}' = ${salesperson_permissions.employee_email})
        OR contains(${salesperson_permissions.manager_access_emails}, '{{ _user_attributes['email'] }}')
        OR {{ _user_attributes['job_role'] }} = 'developer'
        OR {{ _user_attributes['job_role'] }} = 'hrbp'
        OR {{ _user_attributes['job_role'] }} = 'leadership'
        OR {{ _user_attributes['job_role'] }} = 'legal'
        OR ('bobbi.malone@equipmentshare.com' = '{{ _user_attributes['email'] }}' )
        OR ('jay.mitchell@equipmentshare.com' = '{{ _user_attributes['email'] }}')
        OR ('kate.helmstetler@equipmentshare.com' = '{{ _user_attributes['email'] }}')
        OR ('mandy.peters@equipmentshare.com' = '{{ _user_attributes['email'] }}' AND (${salesperson_permissions.district_dated} IN ('5-8', '5-4') OR (${salesperson_permissions.region_name_dated} IN ('Southeast') and ${salesperson_permissions.business_segment} IN ('Advanced Solutions'))))
        OR ('victor.otalora@equipmentshare.com' = '{{ _user_attributes['email'] }}' AND (${salesperson_permissions.district_dated} IN ('2-3') OR (${salesperson_permissions.region_name_dated} IN ('Mountain West') and ${salesperson_permissions.business_segment} IN ('Advanced Solutions'))))
        OR ('mj.mason@equipmentshare.com' = '{{ _user_attributes['email'] }}' AND (${salesperson_permissions.district_dated} IN ('1-4') OR (${salesperson_permissions.region_name_dated} IN ('Pacific') and ${salesperson_permissions.business_segment} IN ('Advanced Solutions'))))
        OR ('mike.k.smith@equipmentshare.com' = '{{ _user_attributes['email'] }}' AND (${salesperson_permissions.district_dated} IN ('1-4') OR (${salesperson_permissions.region_name_dated} IN ('Pacific') and ${salesperson_permissions.business_segment} IN ('Advanced Solutions')))) -- requested by kyle stout in help looker
        OR ('kyle.stout@equipmentshare.com' = '{{ _user_attributes['email'] }}' AND (${salesperson_permissions.district_dated} IN ('1-4') OR (${salesperson_permissions.region_name_dated} IN ('Pacific') and ${salesperson_permissions.business_segment} IN ('Advanced Solutions'))))
        OR
          (case
            when 'laurenjo.stone@equipmentshare.com' = '{{ _user_attributes['email'] }}' then contains(${salesperson_permissions.manager_access_emails},'zach@equipmentshare.com')
            when 'josh.helmstetler@equipmentshare.com' = '{{ _user_attributes['email'] }}'  then contains(${salesperson_permissions.manager_access_emails},'josh.helmstetler@equipmentshare.com') OR contains(${salesperson_permissions.manager_access_emails},'karen.hubbard@equipmentshare.com')
            when 'web.bailey@equipmentshare.com' = '{{ _user_attributes['email'] }}'  then contains(${salesperson_permissions.manager_access_emails},'zach@equipmentshare.com')
            when 'kelly.adams@equipmentshare.com' = '{{ _user_attributes['email'] }}'  then contains(${salesperson_permissions.manager_access_emails},'zach@equipmentshare.com')
            when 'brian.kniffen@equipmentshare.com' = '{{ _user_attributes['email'] }}'  then contains(${salesperson_permissions.manager_access_emails},'justin.ingold@equipmentshare.com')
            when 'arianna.olson@equipmentshare.com' = '{{ _user_attributes['email'] }}' then contains(${salesperson_permissions.manager_access_emails}, 'brian.kniffen@equipmentshare.com') OR contains(${salesperson_permissions.manager_access_emails},'justin.ingold@equipmentshare.com')
            when 'mike.galvan@equipmentshare.com' = '{{ _user_attributes['email'] }}' and ${salesperson_permissions.region_name_dated} = 2 then contains(${salesperson_permissions.manager_access_emails},'justin.ingold@equipmentshare.com')
            when 'conner.bradley@equipmentshare.com' = '{{ _user_attributes['email'] }}' AND (${salesperson_permissions.employee_id} IN ('3102', '3654', '12795', '18434', '10321', '14194', '4275', '18691', '13644', '3644', '18880')) then contains(${salesperson_permissions.manager_access_emails},'toby.fischer@equipmentshare.com') OR contains(${salesperson_permissions.manager_access_emails},'kyle.stout@equipmentshare.com')
            END))
            AND NOT ('leann.thomas@equipmentshare.com' = '{{ _user_attributes['email'] }}' and ${salesperson_permissions.district_dated} IN ('8-4'));;

  join: base_es_warehouse_public__approved_invoice_salespersons {
    type: left_outer
    relationship: many_to_one
    sql_on: ${base_es_warehouse_public__approved_invoice_salespersons.invoice_id} = ${int_admin_credit_note_line_detail.originating_invoice_id} ;;
  }

  join: v_dim_dates_bi {
    type: left_outer
    relationship: many_to_one
    sql_on: ${int_admin_credit_note_line_detail.credit_note_date_date} = ${v_dim_dates_bi.date} ;;
  }

  join: dim_companies_bi {
    type: left_outer
    relationship: one_to_one
    sql_on: ${int_admin_credit_note_line_detail.company_id} = ${dim_companies_bi.company_id} ;;
  }

  join: dim_users_bi {
    type: left_outer
    relationship: many_to_one
    sql_on: COALESCE(${int_admin_credit_note_line_detail.primary_salesperson_id},${base_es_warehouse_public__approved_invoice_salespersons.primary_salesperson_id})  = ${dim_users_bi.user_id};;
  }

  join: salesperson_permissions {
    type: inner
    relationship: many_to_one
    sql_on: COALESCE(${int_admin_credit_note_line_detail.primary_salesperson_id},${base_es_warehouse_public__approved_invoice_salespersons.primary_salesperson_id}) = ${salesperson_permissions.employee_user_id} ;;
  }

  join: dim_salesperson_enhanced_historical {
    from: dim_salesperson_enhanced
    view_label: "Historical Salesperson Info"
    type: left_outer
    relationship: many_to_one
    sql_on: COALESCE(${int_admin_credit_note_line_detail.primary_salesperson_id},${base_es_warehouse_public__approved_invoice_salespersons.primary_salesperson_id}) = ${dim_salesperson_enhanced_historical.user_id} AND
          ${v_dim_dates_bi.date} >=  ${dim_salesperson_enhanced_historical._valid_from_date} AND
          ${v_dim_dates_bi.date} < ${dim_salesperson_enhanced_historical._valid_to_date};;
  }

  join: salesperson_xwalk_historical {
    from: market_region_xwalk
    type: left_outer
    relationship: many_to_one
    sql_on: ${dim_salesperson_enhanced_historical.market_id_hist} = ${salesperson_xwalk_historical.market_id} ;;
  }

}
