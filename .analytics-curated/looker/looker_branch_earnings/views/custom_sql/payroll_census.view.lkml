view: payroll_census {
  derived_table: {
    sql:
      with company_directory as (
        select
            cdv.first_name,
            cdv.last_name,
            coalesce(cdv.nickname, cdv.full_name) as full_name,
            cdv.employee_id,
            cdv.market_id::int market_id,
            cdv.employee_title,
            cdv.employee_status,
            date_trunc(month, cdv._es_update_timestamp) period_date,
            default_cost_centers_full_path cost_center
        from analytics.payroll.stg_analytics_payroll__company_directory_vault as cdv
        where cdv._ES_UPDATE_TIMESTAMP < dateadd(month, 1, (select trunc::date from ANALYTICS.GS.PLEXI_PERIODS
                                                                    where DISPLAY = {% parameter report_period %}))
        qualify row_number() over (partition by employee_id order by _es_update_timestamp desc) = 1
    ),
    cost_center as (
        select
            ccv.COST_CENTER_PATH,
            ccv.MARKET_ID
        from analytics.payroll.cost_center_vault as ccv
        qualify row_number() over (partition by COST_CENTER_PATH order by _es_update_timestamp desc) = 1
    )

        select
            cd.full_name ||
            case
                when cd.cost_center ilike '%telematics installation%' then ' (Not on P&L)'
                else ''
            end                                                                                as employee_name,
            cd.employee_title                                                                  as job_title,
            cd.employee_id                                                                     as employee_id,
            coalesce(cc.market_id,cd.market_id)                                                as market_id,
            coalesce(mrx_c.market_name, d.title)                                               as home_market,
            cd.employee_status,
            cd.period_date                                                                     as period_date
        from company_directory cd
        left join cost_center as cc
            on cd.cost_center = cc.COST_CENTER_PATH
        left join analytics.public.MARKET_REGION_XWALK mrx_c
            on cd.market_id = mrx_c.market_id
        left join analytics.intacct.department d
                   on cd.market_id::text = d.DEPARTMENTID
        where 1 = 1
            and (cd.employee_status not in ('Terminated', 'Never Started', 'Not In Payroll', 'Inactive'))
        order by home_market, employee_name;;
  }

  parameter:  report_period {
    label: "Period"
    type: string
    full_suggestions: yes
    suggest_explore: plexi_periods
    suggest_dimension: plexi_periods.display
  }

  dimension: market_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.market_id ;;
  }

  dimension: employee_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.employee_id ;;
  }

  dimension: employee_status {
    type: string
    sql:${TABLE}.employee_status ;;
  }

  dimension: employee_name {
    type: string
    sql: ${TABLE}.employee_name ;;
    html: {% if value contains 'Not on P&L' %}
     <font color="purple">{{value}}</font>
      {% else %}
      {{value}}
      {% endif %}
    ;;
  }

  dimension: job_title {
    type: string
    sql: ${TABLE}.job_title ;;
  }

  dimension: home_market {
    type: string
    sql: ${TABLE}.home_market ;;
  }

  dimension: period_date {
    type: date
    sql: ${TABLE}.period_date ;;
  }
}
