connection: "es_snowflake_c_analytics"

include: "/views/BUSINESS_INTELLIGENCE/*.view.lkml"
include: "/views/PLATFORM/*.view.lkml"
include: "/views/ANALYTICS/*.view.lkml"
include: "/views/PLATFORM/*.view.lkml"
include: "/Dashboards/Market_Operations_1378/salesperson_permissions/*.view.lkml"
include: "/views/PLATFORM/invoice_summary_by_order.view.lkml"
include: "/views/BUSINESS_INTELLIGENCE/dim_quotes.view.lkml"
include: "/views/PLATFORM/dim_orders.view.lkml"



explore: int_revenue {
  label: "Concrete Reporting"
  case_sensitive: no
  persist_for: "3 hours"
  description: "Explore to be used for reporting on reps working in Concrete Sales. Revenue reported is net of credits, billing approved, and excluding intercompany revenue. "
  sql_always_where: not ${int_revenue.is_intercompany} AND

          ${salesperson_permissions.manager_title} ilike '%concrete%' and


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

            WHEN 'matt.dunn_c@equipmentshare.com' = '{{ _user_attributes['email'] }}' then contains(${salesperson_permissions.manager_access_emails},'brett.claycamp@equipmentshare.com')

            when 'josh.helmstetler@equipmentshare.com' = '{{ _user_attributes['email'] }}'  then contains(${salesperson_permissions.manager_access_emails},'josh.helmstetler@equipmentshare.com') OR contains(${salesperson_permissions.manager_access_emails},'karen.hubbard@equipmentshare.com')
            when 'web.bailey@equipmentshare.com' = '{{ _user_attributes['email'] }}'  then contains(${salesperson_permissions.manager_access_emails},'zach@equipmentshare.com')
            when 'kelly.adams@equipmentshare.com' = '{{ _user_attributes['email'] }}'  then contains(${salesperson_permissions.manager_access_emails},'zach@equipmentshare.com')
            when 'brian.kniffen@equipmentshare.com' = '{{ _user_attributes['email'] }}'  then contains(${salesperson_permissions.manager_access_emails},'justin.ingold@equipmentshare.com')
            when 'arianna.olson@equipmentshare.com' = '{{ _user_attributes['email'] }}' then contains(${salesperson_permissions.manager_access_emails}, 'brian.kniffen@equipmentshare.com') OR contains(${salesperson_permissions.manager_access_emails},'justin.ingold@equipmentshare.com')
            when 'mike.galvan@equipmentshare.com' = '{{ _user_attributes['email'] }}' and ${salesperson_permissions.region} = 2 then contains(${salesperson_permissions.manager_access_emails},'justin.ingold@equipmentshare.com')
            when 'conner.bradley@equipmentshare.com' = '{{ _user_attributes['email'] }}' AND (${salesperson_permissions.employee_id} IN ('3102', '3654', '12795', '18434', '10321', '14194', '4275', '18691', '13644', '3644', '18880')) then contains(${salesperson_permissions.manager_access_emails},'toby.fischer@equipmentshare.com') OR contains(${salesperson_permissions.manager_access_emails},'kyle.stout@equipmentshare.com')
            END))
            AND NOT ('leann.thomas@equipmentshare.com' = '{{ _user_attributes['email'] }}' and ${salesperson_permissions.district_dated} IN ('8-4'));;

  join: int_revenue_xwalk {
    from: market_region_xwalk
    type: left_outer
    relationship: many_to_one
    sql_on: ${int_revenue.market_id} = ${int_revenue_xwalk.market_id} ;;
  }

  join: invoice_date {
    from: v_dim_dates_bi
    type: left_outer
    relationship: many_to_one
    sql_on: ${int_revenue.billing_approved_date_date} = ${invoice_date.date} ;;
  }

  join: dim_companies_bi {
    type: left_outer
    relationship: one_to_one
    sql_on: ${int_revenue.company_id} = ${dim_companies_bi.company_id} ;;
  }

  join: dim_users_bi {
    type: left_outer
    relationship: many_to_one
    sql_on: ${int_revenue.primary_salesperson_id} = ${dim_users_bi.user_id};;
  }

  join: salesperson_permissions {
    type: inner
    relationship: many_to_one
    sql_on: ${int_revenue.primary_salesperson_id}  = ${salesperson_permissions.employee_user_id} ;;
  }

  join: secondary_salesperson_info {
  from: salesperson_permissions
    type: left_outer
    relationship: many_to_one
    sql_on: ${int_revenue.secondary_salesperson_id_one}  = ${secondary_salesperson_info.employee_user_id} ;;
  }

  join: bridge_quote_salesperson {
    type: inner
    relationship: many_to_one
    sql_on: ${dim_users_bi.user_key} = ${bridge_quote_salesperson.salesperson_user_key} ;;
  }

  join: v_fact_quotes {
    type: inner
    relationship: many_to_one
    sql_on: ${v_fact_quotes.quote_key} = ${bridge_quote_salesperson.quote_key} ;;
  }

  join: quote_created_date {
    from: v_dim_dates_bi
    type: inner
    relationship: one_to_one
    sql_on: ${v_fact_quotes.created_date_key} = ${quote_created_date.date_key} ;;
  }

  join: dim_quotes {
    type: inner
    relationship: one_to_one
    sql_on: ${v_fact_quotes.quote_key} = ${dim_quotes.quote_key} ;;
  }

}

explore: concrete_quotes {
  from: v_fact_quotes
  label: "Concrete Quoted Amount"
  case_sensitive: no
  persist_for: "3 hours"
  description: "Explore to be used for reporting on quotes owned by reps working in Concrete Sales."
  sql_always_where: ${salesperson_permissions.manager_title} ilike '%concrete%' and

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

    WHEN 'matt.dunn_c@equipmentshare.com' = '{{ _user_attributes['email'] }}' then contains(${salesperson_permissions.manager_access_emails},'brett.claycamp@equipmentshare.com')

    when 'josh.helmstetler@equipmentshare.com' = '{{ _user_attributes['email'] }}'  then contains(${salesperson_permissions.manager_access_emails},'josh.helmstetler@equipmentshare.com') OR contains(${salesperson_permissions.manager_access_emails},'karen.hubbard@equipmentshare.com')
    when 'web.bailey@equipmentshare.com' = '{{ _user_attributes['email'] }}'  then contains(${salesperson_permissions.manager_access_emails},'zach@equipmentshare.com')
    when 'kelly.adams@equipmentshare.com' = '{{ _user_attributes['email'] }}'  then contains(${salesperson_permissions.manager_access_emails},'zach@equipmentshare.com')
    when 'brian.kniffen@equipmentshare.com' = '{{ _user_attributes['email'] }}'  then contains(${salesperson_permissions.manager_access_emails},'justin.ingold@equipmentshare.com')
    when 'arianna.olson@equipmentshare.com' = '{{ _user_attributes['email'] }}' then contains(${salesperson_permissions.manager_access_emails}, 'brian.kniffen@equipmentshare.com') OR contains(${salesperson_permissions.manager_access_emails},'justin.ingold@equipmentshare.com')
    when 'mike.galvan@equipmentshare.com' = '{{ _user_attributes['email'] }}' and ${salesperson_permissions.region_name_dated} = 2 then contains(${salesperson_permissions.manager_access_emails},'justin.ingold@equipmentshare.com')
    when 'conner.bradley@equipmentshare.com' = '{{ _user_attributes['email'] }}' AND (${salesperson_permissions.employee_id} IN ('3102', '3654', '12795', '18434', '10321', '14194', '4275', '18691', '13644', '3644', '18880')) then contains(${salesperson_permissions.manager_access_emails},'toby.fischer@equipmentshare.com') OR contains(${salesperson_permissions.manager_access_emails},'kyle.stout@equipmentshare.com')
    END))
    AND NOT ('leann.thomas@equipmentshare.com' = '{{ _user_attributes['email'] }}' and ${salesperson_permissions.district_dated} IN ('8-4'));;

  join: dim_quotes {
    type: inner
    relationship: one_to_one
    sql_on: ${concrete_quotes.quote_key} = ${dim_quotes.quote_key} ;;
  }

  join: bridge_quote_salesperson {
    type: inner
    relationship: one_to_one
    sql_on: ${concrete_quotes.quote_key} = ${bridge_quote_salesperson.quote_key}
      AND ${bridge_quote_salesperson.salesperson_type} = 'Primary' ;;
  }

  join: salesperson_permissions {
    type: inner
    relationship: many_to_one
    sql_on: ${bridge_quote_salesperson.salesperson_user_key} = ${salesperson_permissions.user_key} ;;
  }

  join: quote_created_date {
    from: v_dim_dates_bi
    type: left_outer
    relationship: many_to_one
    sql_on: ${concrete_quotes.created_date_key} = ${quote_created_date.date_key} ;;
  }

  join: dim_orders {
    type: left_outer
    relationship: many_to_one
    sql_on: ${concrete_quotes.order_key} = ${dim_orders.order_key} ;;
  }

  join: invoice_summary_by_order {
    type: left_outer
    relationship: many_to_one
    sql_on: ${concrete_quotes.order_key} = ${invoice_summary_by_order.order_key} ;;
  }

  join: invoice_date {
    from: v_dim_dates_bi
    type: left_outer
    relationship: many_to_one
    sql_on: ${invoice_summary_by_order.gl_billing_approved_date_key} = ${invoice_date.date_key} ;;
  }


}
