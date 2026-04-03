view: tam_hiring_dashboard {
  derived_table: {
    sql:
--HEADCOUNT
with headcount as (
select
mrx.region,
mrx.district,
mrx.market_id,
mrx.market_name,
mrx.market_type,
date_trunc('month',_es_update_timestamp) as date_month,
sum(CASE
           WHEN cd.employee_title ILIKE '%Territory Account Manager%' THEN cd.headcount
           ELSE 0
       END) AS headcount
from ANALYTICS.PUBLIC.MARKET_REGION_XWALK mrx
left outer join ANALYTICS.PAYROLL.EE_COMPANY_DIRECTORY_12_MONTH cd on mrx.market_id = cd.market_id
where cd.employee_status in ('Active','External Payroll','Leave with Pay','Leave without Pay','On Leave', 'Seasonal (Fixed Term)(Seasonal)','Work Comp Leave')
group by 1,2,3,4,5,6
order by mrx.district, date_month desc),

--TERMINATIONS
terminations as (
select
mrx.region,
mrx.district,
mrx.market_id,
mrx.market_name,
mrx.market_type,
date_trunc('month',_es_update_timestamp) as date_month,
sum(CASE
WHEN cd.employee_title like '%Territory Account Manager%' THEN cd.terminations
ELSE 0 END) as terminations
from ANALYTICS.PUBLIC.MARKET_REGION_XWALK mrx
left join ANALYTICS.PAYROLL.EE_COMPANY_DIRECTORY_12_MONTH cd on mrx.market_id = cd.market_id
where employee_status in ('Active','External Payroll','Leave with Pay','Leave without Pay','On Leave', 'Seasonal (Fixed Term)(Seasonal)','Work Comp Leave','Terminated')
group by 1,2,3,4,5,6
order by district, date_month desc
),

--AVERAGE TENURE HERE AND % UNDER 90
tenure as (
select
mrx.region,
mrx.district,
mrx.market_id,
mrx.market_name,
mrx.market_type,
date_trunc('month',_es_update_timestamp) as date_month,
CASE
WHEN cd.employee_title like '%Territory Account Manager%' THEN SUM(
      CASE
        WHEN date_terminated IS NULL THEN DATEDIFF('days', COALESCE(date_rehired, date_hired), CURRENT_DATE)
        WHEN date_rehired IS NOT NULL AND date_rehired >= date_terminated THEN DATEDIFF('days', date_rehired, CURRENT_DATE)
        ELSE DATEDIFF('days', COALESCE(date_rehired, date_hired), date_terminated)
      END
    )
ELSE null END as tenure_days,

CASE
WHEN cd.employee_title like '%Territory Account Manager%' THEN SUM(
      CASE
        WHEN date_terminated IS NULL THEN DATEDIFF('years', COALESCE(date_rehired, date_hired), CURRENT_DATE)
        WHEN date_rehired IS NOT NULL AND date_rehired >= date_terminated THEN DATEDIFF('years', date_rehired, CURRENT_DATE)
        ELSE DATEDIFF('years', COALESCE(date_rehired, date_hired), date_terminated)
      END
    )
ELSE null END as tenure_years,

CASE
WHEN cd.employee_title like '%Territory Account Manager%' THEN SUM(
      CASE
        WHEN
          CASE
            WHEN date_terminated IS NULL THEN DATEDIFF('days', COALESCE(date_rehired, date_hired), CURRENT_DATE)
            WHEN date_rehired IS NOT NULL AND date_rehired >= date_terminated THEN DATEDIFF('days', date_rehired, CURRENT_DATE)
            ELSE DATEDIFF('days', COALESCE(date_rehired, date_hired), date_terminated)
          END < 90
        THEN 1 ELSE 0
      END
    )
ELSE null END AS tenure_under_90
from ANALYTICS.PAYROLL.EE_COMPANY_DIRECTORY_12_MONTH cd
left join ANALYTICS.PUBLIC.MARKET_REGION_XWALK mrx on cd.market_id = mrx.market_id
where employee_status in ('Active','External Payroll','Leave with Pay','Leave without Pay','On Leave', 'Seasonal (Fixed Term)(Seasonal)','Work Comp Leave') and employee_title = 'Territory Account Manager'
group by 1,2,3,4,5,6, cd.employee_title
order by market_name desc),

--TOTAL INVOICES AND COMPANY IDs BY MARKET (TAM Market Attribution)
company_ids AS (
WITH second_snapshots AS (
SELECT employee_id, market_id, DATE(_es_update_timestamp) AS snapshot_date
FROM (
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY employee_id, DATE(_es_update_timestamp)
ORDER BY _es_update_timestamp DESC
) AS row_num
FROM ANALYTICS.PAYROLL.COMPANY_DIRECTORY_VAULT
WHERE employee_title ILIKE '%territory account manager'
AND _es_update_timestamp >= '2023-04-01'
AND _es_update_timestamp < DATE_TRUNC('month', CURRENT_DATE())
AND (employee_status LIKE 'Active' OR employee_status LIKE '%eave%')
AND REGEXP_LIKE(employee_id, '^[0-9]+$')
) t
WHERE row_num = 1
),

clean_users AS (
SELECT *
FROM ES_WAREHOUSE.PUBLIC.USERS
WHERE REGEXP_LIKE(employee_id, '^[0-9]+$')
)

  SELECT
    s.market_id,
    DATE_TRUNC('month', i.billing_approved_date) AS date_month,
    COUNT(DISTINCT i.company_id) AS total_company_ids,
    COUNT(DISTINCT i.invoice_id) AS total_invoices
  FROM ES_WAREHOUSE.PUBLIC.INVOICES i
  JOIN ES_WAREHOUSE.PUBLIC.ORDERS o ON i.order_id = o.order_id
  JOIN ES_WAREHOUSE.PUBLIC.MARKETS m ON m.market_id = o.market_id
  JOIN clean_users u ON i.salesperson_user_id = u.user_id
  JOIN second_snapshots s
    ON to_varchar(u.employee_id) = to_varchar(s.employee_id)
    AND DATE(i.billing_approved_date) = s.snapshot_date
  WHERE m.company_id = 1854
    AND i.billing_approved_date >= '2023-04-01'
    AND i.billing_approved_date < DATE_TRUNC('month', CURRENT_DATE())
    AND i.invoice_id NOT IN (
      SELECT originating_invoice_id
      FROM ES_WAREHOUSE.PUBLIC.CREDIT_NOTES
      WHERE originating_invoice_id IS NOT NULL
    )
  GROUP BY
    s.market_id,
    DATE_TRUNC('month', i.billing_approved_date)
),

--OEC by District
oec as (
select date_trunc('MONTH',date(date)) as date_month,
mrx.region,
mrx.district,
mrx.market_id,
mrx.market_name,
mrx.market_type,
sum(afs.oec) as total_oec
from ANALYTICS.PUBLIC.ASSET_FINANCING_SNAPSHOTS afs
left join ANALYTICS.PUBLIC.MARKET_REGION_XWALK mrx on afs.market_id = mrx.market_id
where date >= '2023-04-01' and
oec is not null and
category in ('Owned Rental OEC','Operating Lease OEC','Owned Rolling Stock OEC','Contractor Owned OEC','Payout Program Enrolled OEC','Payout Program Unpaid OEC')
group by 1,2,3,4,5,6
order by district, date_month desc),

--TOTAL POPULATION
population as(
select
mrx.region,
mrx.district,
mrx.market_id,
mrx.market_name,
mrx.market_type,
sum(mpd.population_2024_est) as total_population
from PEOPLE_ANALYTICS.LOOKER.MARKET_POPULATION_DATA mpd
left join ANALYTICS.PUBLIC.MARKET_REGION_XWALK mrx on mpd.market_id = mrx.market_id
group by 1,2,3,4,5
order by 1),

--OPEN REQS
open_reqs as (
select
split_part(o.office_region_name,' ',2) as region,
split_part(o.office_district_name,' ',2) as district,
case when TRIM(o.office_external_id) != '' AND REGEXP_LIKE(o.office_external_id, '^[0-9]+$') then o.office_external_id
else null end as market_id,
o.office_name as market_name,
r.requisition_custom_market_type as market_type,
count(distinct(r.requisition_id)) as open_reqs,
count(distinct case when r.requisition_custom_hire_type = 'Backfill' then r.requisition_id end) as backfill_open_reqs,
count(distinct case when r.requisition_custom_hire_type = 'New Headcount' then r.requisition_id end) as new_headcount_open_reqs
from PEOPLE_ANALYTICS.GREENHOUSE.V_FACT_APPLICATION_REQUISITION_OFFER f
inner join PEOPLE_ANALYTICS.GREENHOUSE.V_DIM_REQUISITION r on f.application_requisition_offer_requisition_key = r.requisition_key
inner join PEOPLE_ANALYTICS.GREENHOUSE.V_BRIDGE_DIM_OFFICE bdo on f.application_requisition_offer_key = bdo.bridge_dim_office_application_requisition_offer_key
inner join PEOPLE_ANALYTICS.GREENHOUSE.V_DIM_OFFICE o on bdo.bridge_dim_office_key = o.office_key
where r.requisition_name like '%Territory Account Manager%' and r.requisition_custom_type = 'Active Requisition' and r.requisition_status = 'open' and r.requisition_custom_market_type = 'Core Solutions'
group by 1,2,3,4,5
order by 1,2),

--MARKET MONTHS OPEN
market_open_dates as (
select
market_id,
market_name,
datediff(month,branch_earnings_start_month,current_date) as months_open
from ANALYTICS.BRANCH_EARNINGS.MARKET
)


select case when h.date_month is null
then date_trunc('month',dateadd(month,-1,current_date))
else h.date_month
end as month_date,
mrx.region,
mrx.district,
mrx.market_id,
mrx.market_name,
mrx.market_type,
mo.months_open as market_months_open,
term.terminations as terminations,
ten.tenure_days as total_tenure_days,
ten.tenure_years as total_tenure_years,
ten.tenure_under_90 as total_headcount_under_90_days,
ci.total_invoices as total_invoices,
ci.total_company_ids as total_company_ids,
population.total_population as total_population,
oec.total_oec as total_oec,
h.headcount as headcount,
open_reqs.open_reqs as open_reqs,
open_reqs.backfill_open_reqs as backfill_open_reqs,
open_reqs.new_headcount_open_reqs as new_headcount_open_reqs
from ANALYTICS.PUBLIC.MARKET_REGION_XWALK mrx
left join market_open_dates mo on mrx.market_id = mo.market_id
left join population on mrx.market_id = population.market_id
left join open_reqs on
open_reqs.market_id is not null
AND TO_VARCHAR(mrx.market_id) = TO_VARCHAR(open_reqs.market_id)
left join headcount h on mrx.market_id = h.market_id
left join terminations term on mrx.market_id = term.market_id and case when h.date_month is null
then date_trunc('month',dateadd(month,-1,current_date))
else h.date_month end = term.date_month
left join tenure ten on mrx.market_id = ten.market_id and case when h.date_month is null
then date_trunc('month',dateadd(month,-1,current_date))
else h.date_month end = ten.date_month
left join company_ids ci on mrx.market_id = ci.market_id and case when h.date_month is null
then date_trunc('month',dateadd(month,-1,current_date))
else h.date_month end = ci.date_month
left join oec on mrx.market_id = oec.market_id and case when h.date_month is null
then date_trunc('month',dateadd(month,-1,current_date))
else h.date_month end = oec.date_month
left join ANALYTICS.BRANCH_EARNINGS.MARKET m on mrx.market_id = m.market_id
where mrx.current_months_open > 0
group by month_date,
mrx.region,
mrx.district,
mrx.market_id,
mrx.market_name,
mrx.market_type,
mo.months_open,
term.terminations,
ten.tenure_days,
ten.tenure_years,
ten.tenure_under_90,
ci.total_invoices,
ci.total_company_ids,
population.total_population,
oec.total_oec,
h.headcount,
open_reqs.open_reqs,
open_reqs.backfill_open_reqs,
open_reqs.new_headcount_open_reqs
order by month_date desc, mrx.district, mrx.market_name;;
  }


  dimension: date_month {
    type: date_raw
    sql: ${TABLE}."MONTH_DATE" ;;
  }

  dimension: region {
    type: string
    sql: ${TABLE}."REGION" ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
    primary_key: yes
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: market_type {
    type: string
    sql: ${TABLE}."MARKET_TYPE" ;;
  }

  dimension: market_months_open {
    type: number
    sql: ${TABLE}."MARKET_MONTHS_OPEN" ;;
  }

  dimension: terminations {
    type: number
    sql: ${TABLE}."TERMINATIONS" ;;
    value_format_name: decimal_0
  }

  dimension: total_tenure_days {
    type: number
    sql: ${TABLE}."TOTAL_TENURE_DAYS" ;;
    value_format_name: decimal_0
  }

  dimension: total_tenure_years {
    type: number
    sql: ${TABLE}."TOTAL_TENURE_YEARS" ;;
    value_format_name: decimal_2
  }

  dimension: total_headcount_under_90_days {
    type: number
    sql: ${TABLE}."TOTAL_HEADCOUNT_UNDER_90_DAYS" ;;
    value_format_name: decimal_0
  }

  dimension: total_company_ids {
    type: number
    sql: ${TABLE}."TOTAL_COMPANY_IDS" ;;
  }

  dimension: total_invoices {
    type: number
    sql: ${TABLE}."TOTAL_INVOICES" ;;
  }

  dimension: total_population {
    type: number
    sql: ${TABLE}."TOTAL_POPULATION" ;;
  }

  dimension: total_oec {
    type: number
    sql: ${TABLE}."TOTAL_OEC" ;;
    value_format_name: usd
  }

  dimension: headcount {
    type: number
    sql: ${TABLE}."HEADCOUNT" ;;
  }

  dimension: open_reqs {
    type: number
    sql: ${TABLE}."OPEN_REQS" ;;
  }

  dimension: backfill_open_reqs {
    type: number
    sql: ${TABLE}."BACKFILL_OPEN_REQS" ;;
  }

  dimension: new_headcount_open_reqs {
    type: number
    sql: ${TABLE}."NEW_HEADCOUNT_OPEN_REQS" ;;
  }
}
