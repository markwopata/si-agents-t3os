view: non_es_wages {
 derived_table: {
  sql:
      with cdv_dedup as (select employee_id, _es_update_timestamp, default_cost_centers_full_path
                   from analytics.payroll.company_directory_vault -- stg_analytics_payroll__company_directory_vault
                   qualify row_number() over (
                       partition by employee_id,
                           date_trunc(day, _es_update_timestamp)
                       order by _es_update_timestamp desc -- grab employee's title at time of work order
                       ) = 1),

    wages as (select m.market_id,
       pp.display,
       'IBAB' as account_number,
       date_trunc(month, te.start_date) as gl_month,
       coalesce(sum(te.regular_hours) * 64.4, 0)     as reg_wages,
       coalesce(sum(te.overtime_hours) * 96.6,0)    as ot_wages
from es_warehouse.time_tracking.time_entries te
         join analytics.assets.int_asset_historical_ownership ho
              on te.asset_id = ho.asset_id
                  and date_trunc(day, te.start_date) =
                      date_trunc(day, ho.daily_timestamp)
         left join analytics.public.es_companies ec
                   on ho.asset_company_id = ec.company_id
         join es_warehouse.public.users u
              on te.user_id = u.user_id
         join cdv_dedup cdv
              on to_varchar(u.employee_id) = to_varchar(cdv.employee_id)
                  and date_trunc(day, te.start_date) =
                      date_trunc(day, cdv._es_update_timestamp)
         join analytics.branch_earnings.market m
              on te.branch_id = m.child_market_id
         join analytics.gs.plexi_periods pp
              on month(te.start_date) = pp.month_num
                  and year(te.start_date) = pp.year
where te.branch_id is not null
  and cdv.default_cost_centers_full_path not like '%Tele%'
  and cdv._es_update_timestamp is not null
  and te.approval_status = 'Approved'
  and ec.company_id is null
  and ho.rental_branch_id is null
  and te.asset_id is not null
  and te.work_order_id is not null
group by all),

    payroll_wages as (
  select MARKET_ID, market_name, MARKET_TYPE, region_name, FILTER_MONTH, gl_month, district, MARKET_GREATER_THAN_12_MONTHS, sum(original_equipment_cost) as original_equipment_cost,
    CASE
      WHEN SUM(ORIGINAL_EQUIPMENT_COST) = 0 THEN 0
      ELSE
        SUM(
          CASE
            WHEN ACCOUNT_NAME ILIKE '%overtime%'
              OR ACCOUNT_NAME ILIKE '%payroll%'
            THEN AMOUNT
            ELSE 0
          END
        ) * -1
    END AS payroll_wage_expense
  from analytics.BRANCH_EARNINGS.INT_LIVE_BRANCH_EARNINGS_LOOKER_AGGREGATION agg
  GROUP BY MARKET_ID, market_name, MARKET_TYPE, region_name, FILTER_MONTH, district, MARKET_GREATER_THAN_12_MONTHS, gl_month
)

select m.market_id, m.market_name, pw.market_type, pw.region_name, pw.filter_month, pw.district, pw.market_greater_than_12_months, pw.original_equipment_cost, pw.payroll_wage_expense, coalesce(round(new.ot_wages, 2), 0) as ot_wages, coalesce(round(new.reg_wages, 2), 0) as reg_wages, (pw.payroll_wage_expense - coalesce(ot_wages,0) - coalesce(reg_wages, 0)) as adj_wages, coalesce(hlf.RENTAL_REVENUE, 0) as rental_revenue
from payroll_wages pw
left join wages new
on new.MARKET_ID = pw.MARKET_ID
and new.DISPLAY = pw.FILTER_MONTH
join analytics.branch_earnings.market m
on pw.market_id = m.child_market_id
left join analytics.BRANCH_EARNINGS.HIGH_LEVEL_FINANCIALS hlf
on m.market_id = hlf.market_id
and date_trunc(month, hlf.gl_date) = date_trunc(month, pw.gl_month)
where original_equipment_cost is not null

    ;;
}

dimension: market_id {
  label: "Market ID"
  type: number
  sql: ${TABLE}."MARKET_ID" ;;
}

dimension: period_month {
  label: "Period"
  type: string
  sql: ${TABLE}."DISPLAY" ;;
}

  measure: payroll_wages {
    label: "Payroll Wages"
    type: sum
    sql: ${TABLE}."PAYROLL_WAGE_EXPENSE" ;;
  }

measure: reg_wages {
  label: "Reg Wages"
  type: sum
  sql: ${TABLE}."REG_WAGES" ;;
}

measure: ot_wages {
  label: "OT Wages"
  type: sum
  sql: ${TABLE}."OT_WAGES" ;;
}

dimension: market_type {
  type: string
  sql: ${TABLE}."MARKET_TYPE" ;;
  }
dimension: region_name {
  type: string
  sql: ${TABLE}."REGION_NAME" ;;
  }

dimension: market_name {
  type: string
  sql: ${TABLE}."MARKET_NAME" ;;
  }

dimension: filter_month {
  type: string
  sql: ${TABLE}."FILTER_MONTH" ;;
  order_by_field: gl_month
  }
dimension: district {
  type: string
  sql: ${TABLE}."DISTRICT" ;;
  }

dimension: market_greater_than_12_months {
  type: yesno
  sql: ${TABLE}."MARKET_GREATER_THAN_12_MONTHS" ;;
  }
dimension: gl_month {
  type: string
  sql: ${TABLE}."GL_MONTH" ;;
  }

measure: annualized_payroll_to_oec {
  type: number
  label: "Annualized Payroll to OEC"
  value_format: "#,##0.0%;-#,##0.0%;-"
  sql: case when ${payroll_wages} != 0
        and ${original_equipment_cost} != 0
            then (12 * ${payroll_wages}) / ${original_equipment_cost}
            else 0 end;;
}

measure: rental_revenue {
  type: sum
  label: "Rental Revenue"
  sql: ${TABLE}.RENTAL_REVENUE ;;
}

measure: payroll_to_rent_revenue {
  type: number
  label: "Payroll to Rent Revenue"
  value_format: "#,##0.0%;-#,##0.0%;-"
  sql: case when ${payroll_wages} != 0
        and ${rental_revenue} != 0
            then ${payroll_wages} / ${rental_revenue}
            else 0 end;;
}

measure: original_equipment_cost {
  label: "Original Equipment Cost"
  type: sum
  sql: ${TABLE}."ORIGINAL_EQUIPMENT_COST" ;;
  }
}
