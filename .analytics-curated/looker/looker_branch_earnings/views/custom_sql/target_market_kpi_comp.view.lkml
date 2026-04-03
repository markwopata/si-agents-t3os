view: target_market_kpi_comp {
    derived_table: {
      sql:
with max_published_month as(
select max(trunc::date) as max_published_month
 from analytics.gs.plexi_periods
 where period_published = 'published')

, target_date_param as(
select dateadd(month,-12, (select max_published_month from max_published_month)) as start_date
     , (select max_published_month from max_published_month) as end_date)

, time_entries as(
select m.market_id
     , date_trunc(month,tt.start_date::date) as gl_month
     , cd.employee_title
     , tt.work_order_id
     , tt.regular_hours
     , tt.overtime_hours
 from es_warehouse.time_tracking.time_entries tt
 join es_warehouse.public.users u on tt.user_id = u.user_id
 join analytics.payroll.stg_analytics_payroll__company_directory cd on u.employee_id = cd.employee_id::text
 left join analytics.public.MARKET_REGION_XWALK m on cd.market_id = m.market_id
 where tt.approval_status = 'Approved'
  and tt.event_type_id = 1
  and m.market_name is not null)

, work_hours as(
select market_id
     , gl_month
     , sum(case when (employee_title ilike any('%technician%','%mechanic%') and employee_title not ilike '%yard technician%' and work_order_id is not null) then regular_hours + overtime_hours end) as maint_tech_assigned_hours
     , sum(case when (employee_title ilike any('%technician%','%mechanic%') and employee_title not ilike '%yard technician%' and work_order_id is null) then regular_hours + overtime_hours end) as maint_tech_unassigned_hours
 from time_entries
 group by all)

, cs_target_market_kpis as(
select null as market_id
     , 'Comp Markets' as market_name
     , 'Core Solutions' as market_type
     , null as gl_month
     , null as month_year
     , sum(hlf.rental_revenue) as rental_revenue
     , sum(hlf.oec) as oec
     , sum(hlf.service_total_oec) as service_total_oec
     , sum(hlf.on_rent_oec) as on_rent_oec
     , sum(hlf.service_unavailable_oec) as service_unavailable_oec
     , sum(hlf.payroll_wage_expense - hlf.non_es_reg_wages - hlf.non_es_ot_wages) as payroll_expense
     , sum(hlf.payroll_overtime_expense) as payroll_overtime_expense
     , sum(hlf.payroll_compensation_expense) as payroll_compensation_expense
     , sum(wh.maint_tech_unassigned_hours) as maint_tech_unassigned_hours
     , sum(wh.maint_tech_assigned_hours + wh.maint_tech_unassigned_hours) as maint_total_hours
     , sum(hlf.nonintercompany_delivery_revenue) as nonintercompany_delivery_revenue
     , sum(hlf.delivery_expense) as delivery_expense
     , sum(hlf.rental_fleet_oec_daily_sum) as rental_fleet_oec_daily_sum
     , sum(hlf.oec_on_rent_daily_sum) as oec_on_rent_daily_sum
     , sum(hlf.unavailable_oec_daily_sum) as unavailable_oec_daily_sum
 from analytics.branch_earnings.high_level_financials hlf
 left join work_hours wh on hlf.market_id = wh.market_id and hlf.gl_date = wh.gl_month
 where hlf.market_id in(18702,63125,24007,24079,35789,15984,16835,40682)
  and hlf.gl_date between (select start_date from target_date_param) and (select end_date from target_date_param)
 group by all)

, as_target_market_kpis as(
select null as market_id
     , 'Comp Markets' as market_name
     , 'Advanced Solutions' as market_type
     , null as gl_month
     , null as month_year
     , sum(hlf.rental_revenue) as rental_revenue
     , sum(hlf.oec) as oec
     , sum(hlf.service_total_oec) as service_total_oec
     , sum(hlf.on_rent_oec) as on_rent_oec
     , sum(hlf.service_unavailable_oec) as service_unavailable_oec
     , sum(hlf.payroll_wage_expense - hlf.non_es_reg_wages - hlf.non_es_ot_wages) as payroll_expense
     , sum(hlf.payroll_overtime_expense) as payroll_overtime_expense
     , sum(hlf.payroll_compensation_expense) as payroll_compensation_expense
     , sum(wh.maint_tech_unassigned_hours) as maint_tech_unassigned_hours
     , sum(wh.maint_tech_assigned_hours + wh.maint_tech_unassigned_hours) as maint_total_hours
     , sum(hlf.nonintercompany_delivery_revenue) as nonintercompany_delivery_revenue
     , sum(hlf.delivery_expense) as delivery_expense
     , sum(hlf.rental_fleet_oec_daily_sum) as rental_fleet_oec_daily_sum
     , sum(hlf.oec_on_rent_daily_sum) as oec_on_rent_daily_sum
     , sum(hlf.unavailable_oec_daily_sum) as unavailable_oec_daily_sum
 from analytics.branch_earnings.high_level_financials hlf
 left join work_hours wh on hlf.market_id = wh.market_id and hlf.gl_date = wh.gl_month
 where hlf.market_id in(102247,109985,78665,95837)
  and hlf.gl_date between (select start_date from target_date_param) and (select end_date from target_date_param)
 group by all)

, market_kpis as(
select hlf.market_id
     , hlf.market_name
     , m.market_type
     , hlf.gl_date as gl_month
     , pp.display as month_year
     , hlf.rental_revenue
     , hlf.oec as oec
     , hlf.service_total_oec
     , hlf.on_rent_oec
     , hlf.service_unavailable_oec
     , (hlf.payroll_wage_expense - hlf.non_es_reg_wages - hlf.non_es_ot_wages) as payroll_expense
     , hlf.payroll_overtime_expense
     , hlf.payroll_compensation_expense
     , wh.maint_tech_unassigned_hours
     , (wh.maint_tech_assigned_hours + wh.maint_tech_unassigned_hours) as maint_total_hours
     , hlf.nonintercompany_delivery_revenue
     , hlf.delivery_expense
     , hlf.rental_fleet_oec_daily_sum
     , hlf.oec_on_rent_daily_sum
     , hlf.unavailable_oec_daily_sum
 from analytics.branch_earnings.high_level_financials hlf
 join analytics.branch_earnings.market m on hlf.market_id = m.child_market_id
 join analytics.gs.plexi_periods pp on hlf.gl_date::date = pp.trunc::date
 left join work_hours wh on hlf.market_id = wh.market_id and hlf.gl_date = wh.gl_month
 where hlf.region_name in('Southeast','Florida')
  and m.market_type in('Core Solutions','Advanced Solutions')
  and hlf.gl_date between dateadd('month',-14,date_trunc(month,current_date)) and date_trunc(month,current_date)
 group by all)

select *
 from cs_target_market_kpis
union all
select *
 from as_target_market_kpis
union all
select *
 from market_kpis
        ;;
    }

    dimension: market_id {
      label: "MarketID"
      type: string
      sql: ${TABLE}."MARKET_ID" ;;
    }

    dimension: market_name {
      label: "Market"
      type: string
      sql: ${TABLE}."MARKET_NAME" ;;
    }

    dimension: market_type {
      type: string
      sql: ${TABLE}."MARKET_TYPE" ;;
    }

    dimension: gl_month {
      label: "GL Month"
      type: date
      sql: ${TABLE}."GL_MONTH" ;;
    }

    dimension: month_year {
      label: "Month"
      type: string
      sql: ${TABLE}."MONTH_YEAR" ;;
    }

    measure: rental_revenue {
      type: sum
      sql: ${TABLE}."RENTAL_REVENUE" ;;
    }

    measure: service_total_oec {
      type: sum
      sql: ${TABLE}."SERVICE_TOTAL_OEC" ;;
    }

    measure: on_rent_oec {
      type: sum
      sql: ${TABLE}."ON_RENT_OEC" ;;
    }

    measure: service_unavailable_oec {
      type: sum
      sql: ${TABLE}."SERVICE_UNAVAILABLE_OEC" ;;
    }

    measure: payroll_expense {
      type: sum
      sql: ${TABLE}."PAYROLL_EXPENSE" ;;
    }

    measure: payroll_overtime_expense {
      type: sum
      sql: ${TABLE}."PAYROLL_OVERTIME_EXPENSE" ;;
    }

    measure: payroll_compensation_expense {
      type: sum
      sql: ${TABLE}."PAYROLL_COMPENSATION_EXPENSE" ;;
    }

    measure: maint_tech_unassigned_hours {
      type: sum
      sql: ${TABLE}."MAINT_TECH_UNASSIGNED_HOURS" ;;
    }

    measure: maint_total_hours {
      type: sum
      sql: ${TABLE}."MAINT_TOTAL_HOURS" ;;
    }

    measure: nonintercompany_delivery_revenue {
      type: sum
      sql: ${TABLE}."NONINTERCOMPANY_DELIVERY_REVENUE" ;;
    }

    measure: delivery_expense {
      type: sum
      sql: ${TABLE}."DELIVERY_EXPENSE" ;;
    }

    measure: rental_fleet_oec_daily_sum {
      type: sum
      sql: ${TABLE}."RENTAL_FLEET_OEC_DAILY_SUM" ;;
    }

    measure: oec_on_rent_daily_sum {
      type: sum
      sql: ${TABLE}."OEC_ON_RENT_DAILY_SUM" ;;
    }

  measure: unavailable_oec_daily_sum {
    type: sum
    sql: ${TABLE}."UNAVAILABLE_OEC_DAILY_SUM" ;;
  }

    measure: financial_utilization{
      type: number
      value_format_name: percent_2
      sql: (sum(${TABLE}."RENTAL_REVENUE")*365)/nullifzero(sum(${TABLE}."RENTAL_FLEET_OEC_DAILY_SUM")) ;;
    }

    measure: on_rent_oec_pct{
      label: "On Rent OEC"
      type: number
      value_format_name: percent_2
      sql: sum(${TABLE}."OEC_ON_RENT_DAILY_SUM")/nullifzero(sum(${TABLE}."RENTAL_FLEET_OEC_DAILY_SUM")) ;;
    }

    measure: unavailable_oec_pct{
      label: "Unavailable OEC"
      type: number
      value_format_name: percent_2
      sql: sum(${TABLE}."UNAVAILABLE_OEC_DAILY_SUM")/nullifzero(sum(${TABLE}."RENTAL_FLEET_OEC_DAILY_SUM"))  ;;
    }

    measure: payroll_rev{
      label: "Payroll:Rent Rev"
      type: number
      value_format_name: percent_2
      sql: sum(${TABLE}."PAYROLL_EXPENSE")/nullifzero(sum(${TABLE}."RENTAL_REVENUE")) ;;
    }

    measure: annualized_payroll_oec{
      label: "Annualized Payroll:OEC"
      type: number
      value_format_name: percent_2
      sql: (sum(${TABLE}."PAYROLL_EXPENSE")*12)/nullifzero(sum(${TABLE}."OEC")) ;;
    }

    measure: ot_total_wages{
      label: "OT:Total Wages"
      type: number
      value_format_name: percent_2
      sql: sum(${TABLE}."PAYROLL_OVERTIME_EXPENSE")/nullifzero(sum(${TABLE}."PAYROLL_COMPENSATION_EXPENSE")) ;;
    }

    measure: unassigned_tech_hours{
      label: "Unassigned Tech Hours"
      type: number
      value_format_name: percent_2
      sql: sum(${TABLE}."MAINT_TECH_UNASSIGNED_HOURS")/nullifzero(sum(${TABLE}."MAINT_TOTAL_HOURS")) ;;
    }

    measure: delivery_recovery{
      label: "Delivery Recovery"
      type: number
      value_format_name: percent_2
      sql: sum(${TABLE}."NONINTERCOMPANY_DELIVERY_REVENUE")/nullifzero(sum(${TABLE}."DELIVERY_EXPENSE")) ;;
    }
  }
