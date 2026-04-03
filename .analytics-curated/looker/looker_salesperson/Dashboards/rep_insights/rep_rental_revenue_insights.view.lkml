
view: rep_rental_revenue_insights {
  derived_table: {
    sql: with user_access as (
      select
      case
      when position(' ',coalesce(cd.nickname,cd.first_name)) = 0 then concat(coalesce(cd.nickname,cd.first_name), ' ', cd.last_name)
      else
      concat(coalesce(nickname,concat(cd.first_name, ' ',cd.last_name))) end as rep,
      employee_title,
      location as employee_location,
      u.user_id as employee_user_id,
      mn.manager_name,
      IFF(manager_email = IFF('{{ _user_attributes['email'] }}' = 'bobbi.malone@equipmentshare.com','jay.mitchell@equipmentshare.com','{{ _user_attributes['email'] }}'),TRUE,FALSE) as direct_report,
      mrx.district
      from
      analytics.payroll.pa_employee_access ca
      join analytics.payroll.company_directory cd on ca.employee_id = cd.employee_id
      join
      (
      select
        distinct EMPLOYEE_ID as manager_id,
          case when position(' ',coalesce(NICKNAME,FIRST_NAME)) = 0 then concat(coalesce(NICKNAME,FIRST_NAME), ' ', LAST_NAME)
               else concat(coalesce(NICKNAME,concat(FIRST_NAME, ' ',LAST_NAME))) end as manager_name,
          direct_manager_employee_id,
          work_email as manager_email
      from
        analytics.PAYROLL.COMPANY_DIRECTORY
      where
        employee_status not in ('Inactive', 'Never Started', 'Not In Payroll', 'Terminated')
      ) mn on mn.manager_id = cd.direct_manager_employee_id
      join es_warehouse.public.users u on lower(u.email_address) = lower(cd.work_email)
      -- LEFT JOIN (SELECT user_id, first_date_as_TAM FROM analytics.bi_ops.salesperson_info where record_ineffective_date IS NULL) si ON si.user_id = u.user_id
      left join analytics.public.market_region_xwalk mrx on mrx.market_id = cd.market_id
      where
      (
      employee_status not in ('Inactive', 'Never Started', 'Not In Payroll', 'Terminated') AND
      (
      (contains(ca.manager_access_emails,IFF('{{ _user_attributes['email'] }}' = 'bobbi.malone@equipmentshare.com','jay.mitchell@equipmentshare.com','{{ _user_attributes['email'] }}')))
      )
      AND employee_title = 'Territory Account Manager'
      )
      OR
      ({{ _user_attributes['job_role'] }} = 'developer')
      )
      , rep_month_duration as (
      --Determine months in TAM position
      select
      user_id,
      first_date_as_tam,
      ROUND(months_between(current_date, first_date_as_tam ), 0) as months_as_TAM
      from analytics.bi_ops.salesperson_info
      where record_ineffective_date IS NULL and employee_title_dated IN ('Territory Account Manager', 'Strategic Account Manager', 'Rental Territory Manager')
      )
      , current_rep_rev as (
      --Get previous month revenue where revenue is under 125K
      select
          sp_user_id as salesperson_user_id,
          sp_name,
          date_month,
          total_rev as current_ttl_rev
      from
          analytics.bi_ops.new_account_revenue_rankings
      where
          prev_month = '1'
          AND current_ttl_rev <= 125000
      )
      ,rep_rev as (
      --Get revenue for historical months where it is not current/previous month
      select
          narr.sp_user_id as salesperson_user_id,
          narr.sp_name,
          narr.date_month,
          narr.total_rev as ttl_rev
      from
          analytics.bi_ops.new_account_revenue_rankings narr
          left join rep_month_duration rmd ON rmd.user_id = narr.sp_user_id
      where
          narr.current_month = '0'
          AND narr.prev_month = '0'
          AND narr.total_rev <= 125000
          AND narr.date_month <> date_trunc('month', rmd.first_date_as_tam)
      )
      ,rev_date_comparsion AS (
      -- Anchor: start with previous month
      SELECT
          salesperson_user_id,
          date_month,
          current_ttl_rev as current_ttl_rental_rev,
          current_ttl_rev as ttl_rental_rev,
          date_month AS start_date
      FROM
          current_rep_rev
      where
          current_ttl_rev is not null
          AND salesperson_user_id is not null
      UNION ALL
      -- Recursive: check if the previous month value is bellow 125K threshold
      SELECT
          dv.salesperson_user_id,
          dv.date_month,
          rev.current_ttl_rental_rev,
          dv.ttl_rev as ttl_rental_rev,
          rev.start_date
      FROM
          rev_date_comparsion rev
          JOIN rep_rev dv ON dv.salesperson_user_id = rev.salesperson_user_id AND dv.date_month = rev.date_month - INTERVAL '1 month'
      WHERE
          dv.ttl_rev <= 125000
      )
      , rev_rep_summary as (
      --Determine how many months they haven't met 125K threshold
      SELECT
          salesperson_user_id,
          current_ttl_rental_rev,
          MAX(datediff('months',date_month,start_date) + 1) as total_months_down,
          MAX(ttl_rental_rev) as max_rental_rev_while_down
      FROM
          rev_date_comparsion
      GROUP BY
          salesperson_user_id,
          current_ttl_rental_rev
      )

      select
          rrs.salesperson_user_id,
          ua.rep,
          ua.employee_location,
          ua.district,
          ua.manager_name,
          rmd.months_as_TAM,
          rrs.total_months_down,
          rrs.current_ttl_rental_rev as previous_month_value,
          rrs.max_rental_rev_while_down
      from
          rev_rep_summary rrs
          join user_access ua on ua.employee_user_id = rrs.salesperson_user_id
          left join rep_month_duration rmd on rmd.user_id = rrs.salesperson_user_id
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: salesperson_user_id {
    type: number
    sql: ${TABLE}."SALESPERSON_USER_ID" ;;
  }

  dimension: rep {
    type: string
    sql: ${TABLE}."REP" ;;
  }

  dimension: employee_location {
    type: string
    sql: ${TABLE}."EMPLOYEE_LOCATION" ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: manager_name {
    type: string
    sql: ${TABLE}."MANAGER_NAME" ;;
  }

  dimension: months_as_tam {
    type: number
    sql: ${TABLE}."MONTHS_AS_TAM" ;;
  }

  dimension: total_months_down {
    type: number
    sql: ${TABLE}."TOTAL_MONTHS_DOWN" ;;
  }

  dimension: previous_month_value {
    type: number
    sql: ${TABLE}."PREVIOUS_MONTH_VALUE" ;;
  }

  dimension: max_rental_rev_while_down {
    type: number
    sql: ${TABLE}."MAX_RENTAL_REV_WHILE_DOWN" ;;
  }

  dimension: rep_home_market {
    type: string
    sql: concat(${rep},' - ',${employee_location}) ;;
  }

  dimension: salesperson {
    group_label: "Sales Person Info"
    label: "TAM"
    type: string
    sql: ${rep} ;;
    html:
    <font color="#0063f3 "><a href="https://equipmentshare.looker.com/dashboards/1409?Rep={{rep_home_market._filterable_value}}"target="_blank">
    {{rendered_value}} ➔</a>
    <br />
    <font style="color: #8C8C8C; text-align: right;">Home: {{employee_location._rendered_value }} </font>
    <br />
    <font style="color: #8C8C8C; text-align: right;">Months As TAM: {{total_months_as_tam._rendered_value }} </font>
    ;;
  }

  dimension: direct_manager_with_link {
    group_label: "Link to Sales Manager"
    label: "Direct Manager"
    sql: ${manager_name} ;;
    html: <font color="#0063f3 "><a href="https://equipmentshare.looker.com/dashboards/1472?Direct%20Manager={{ manager_name._filterable_value}}"target="_blank">{{rendered_value}} ➔</a> ;;
  }

  measure: previous_month_rental_revenue {
    group_label: "Previous Month Rental Revenue"
    label: "Previous Month Rental Revenue"
    type: max
    sql: ${previous_month_value} ;;
    value_format_name: usd_0
  }

  measure: total_months_down_new_accounts {
    group_label: "Previous Month Rental Revenue"
    label: "Months Below"
    type: max
    sql: ${total_months_down} ;;
    html: {{rendered_value}} ;;
  }

  measure: total_months_as_tam {
    group_label: "Sales Person Info"
    label: "Months As TAM"
    type: max
    sql: ${months_as_tam} ;;
    html: {{rendered_value}} ;;
  }

  set: detail {
    fields: [
    salesperson_user_id,
    rep,
    employee_location,
    district,
    manager_name,
    months_as_tam,
    total_months_down,
    previous_month_value
    ]
  }
}
