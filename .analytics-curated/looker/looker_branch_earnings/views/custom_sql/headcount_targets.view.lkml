view: headcount_targets {
  derived_table: {
    sql:
      with tech_headcount as (
    select m.market_id, count(*) as tech_headcount
    from analytics.payroll.job_profiles_technicians jpt
    join analytics.payroll.stg_analytics_payroll__company_directory cd
      on jpt.employee_id = cd.employee_id
    join analytics.branch_earnings.market m
      on cd.market_id = m.child_market_id
    where cd.is_active_employee = 'true'
      and jpt.job_profile in ('7801 - Field Service Technician I',
        '7802 - Field Technician',
        '7803 - Field Technician I',
        '7804 - Field Technician II',
        '7805 - Field Technician III',
        '7806 - Field Technician IV',
        '7881 - Shop Technician',
        '7882 - Shop Technician I',
        '7883 - Shop Technician II',
        '7884 - Shop Technician III',
        '7885 - Shop Technician IV')
    group by m.market_id
),
tam_headcount as (
    select m.market_id, count(*) as tam_headcount
    from analytics.payroll.stg_analytics_payroll__company_directory cd
    join analytics.branch_earnings.market m
      on cd.market_id = m.child_market_id
    where cd.is_active_employee = 'true'
      and cd.employee_title = 'Territory Account Manager'
    group by m.market_id
),
driver_headcount as (
    select m.market_id, count(*) as driver_headcount
    from analytics.payroll.stg_analytics_payroll__company_directory cd
    join analytics.branch_earnings.market m
      on cd.market_id = m.child_market_id
    where cd.is_active_employee = 'true'
      and cd.employee_title ilike '%driver%'
    group by m.market_id
),
total_headcount as (
    select m.market_id, count(*) as total_headcount
    from analytics.payroll.stg_analytics_payroll__company_directory cd
    join analytics.branch_earnings.market m
      on cd.market_id = m.child_market_id
    where cd.is_active_employee = 'true'
    group by m.market_id
),
latest_hlf as (
    select
        hlf.market_id,
        hlf.market_name,
        hlf.oec,
        row_number() over (partition by hlf.market_id order by hlf.gl_date desc) as rn
    from analytics.branch_earnings.high_level_financials hlf
    qualify rn = 1
),
headcount_output as (
    select
        lhlf.market_id,
        lhlf.market_name,
        'Total' as headcount_type,
        coalesce(tc.total_headcount, 0) as headcount,
        null as target
    from latest_hlf lhlf
    left join total_headcount tc on lhlf.market_id = tc.market_id

    union all

    select
        lhlf.market_id,
        lhlf.market_name,
        'Technician' as headcount_type,
        coalesce(tech.tech_headcount, 0) as headcount,
        round(lhlf.oec / 3900000.00, 0) as target
    from latest_hlf lhlf
    left join tech_headcount tech on lhlf.market_id = tech.market_id

    union all

    select
        lhlf.market_id,
        lhlf.market_name,
        'Driver' as headcount_type,
        coalesce(dh.driver_headcount, 0) as headcount,
        round(lhlf.oec / 7520000.00, 0) as target
    from latest_hlf lhlf
    left join driver_headcount dh on lhlf.market_id = dh.market_id

    union all

    select
        lhlf.market_id,
        lhlf.market_name,
        'TAM' as headcount_type,
        coalesce(tam.tam_headcount, 0) as headcount,
        round(lhlf.oec / 9150000.00, 0) as target
    from latest_hlf lhlf
    left join tam_headcount tam on lhlf.market_id = tam.market_id
)
select
    ho.market_id,
    ho.market_name,
    m.region_name,
    m.district,
    m.market_type,
    ho.headcount_type,
    ho.headcount,
    ho.target
from headcount_output ho
join analytics.branch_earnings.market m
  on ho.market_id = m.child_market_id
order by ho.market_id, ho.headcount_type;;
  } dimension: region {
    label: "Region"
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension: district {
    label: "District"
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: market_id {
    label: "Market ID"
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    label: "Market Name"
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: market_type {
    label: "Market Type"
    type: string
    sql: ${TABLE}."MARKET_TYPE" ;;
  }

  dimension: headcount_type {
    label: "Job Group"
    type: string
    sql: ${TABLE}."HEADCOUNT_TYPE" ;;
  }

  measure: Headcount {
    label: "Headcount"
    type: sum
    sql: ${TABLE}."HEADCOUNT" ;;
  }

  measure: Target {
    label: "Target Headcount"
    type: sum
    sql: CASE
        WHEN ${headcount_type} = 'Total' THEN NULL
        ELSE ${TABLE}."TARGET"
      END ;;
  }

  }
