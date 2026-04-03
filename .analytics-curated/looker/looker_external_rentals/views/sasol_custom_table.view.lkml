
view: sasol_custom_table {
  derived_table: {
    sql: WITH rental_locations AS (
select
    DISTINCT r.rental_id, l.nickname as jobsite
from
    es_warehouse.public.rentals r
left join es_warehouse.public.orders o on r.order_id = o.order_id
left join es_warehouse.public.users u on u.user_id = o.user_id
left join es_warehouse.public.companies c on u.company_id = c.company_id
left join es_warehouse.public.rental_location_assignments rla on rla.rental_id = r.rental_id
left join es_warehouse.public.locations l on l.location_id = rla.location_id
where
    --company filter
    1=1 -- no filter on 'on_off_rent_with_spend.company_filter'
QUALIFY ROW_NUMBER() OVER(PARTITION BY r.rental_id ORDER BY l.date_updated desc) = 1
),

phases_and_jobs as (
select
    r.rental_id
  , j.name as phase_job_name
  , jp.name as job_name
from
    es_warehouse.public.orders o
left join es_warehouse.public.rentals r on (r.order_id = o.order_id)
join es_warehouse.public.jobs j on (j.job_id = o.job_id) and j.parent_job_id is not null
left join es_warehouse.public.jobs jp on (j.parent_job_id = jp.job_id)
where
    r.deleted = false
    and o.deleted = false

union

select
    r.rental_id
    , NULL as phase_job_name
    , j.name as job_name
from
    es_warehouse.public.orders o
left join es_warehouse.public.rentals r on (r.order_id = o.order_id)
join es_warehouse.public.jobs j on (j.job_id = o.job_id) and j.parent_job_id is null
where
    r.deleted = false
    and o.deleted = false
),

current_assets AS (
SELECT
    rental_id,
    asset_id as current_asset_id
FROM ES_WAREHOUSE.PUBLIC.EQUIPMENT_ASSIGNMENTS
QUALIFY ROW_NUMBER() OVER(PARTITION BY rental_id ORDER BY start_date desc) = 1
),


all_rentals AS(
select
    r.rental_id,
    o.order_id,
    o.sub_renter_id,
    r.asset_id as rental_asset_id,
    coalesce(a.asset_class,pt.description,' ') as asset_class,
    po.name as purchase_order_name,
    r.start_date::date as rental_start_date,
    r.end_date::date as rental_end_date,
    ac.next_cycle_inv_date::date::date as next_cycle_date,
    ac.total_days_on_rent,
    ac.days_left as billing_days_left,
    'On Rent' as rental_status,
    c.company_id,
    c.name as company_name,
    r.price_per_day,
    r.price_per_week,
    r.price_per_month,
    coalesce(r.quantity,1) as quantity,
    --l.nickname as jobsite
    l.jobsite,
    concat(u.first_name,' ',u.last_name,' (',u.phone_number,')') as order_by_with_phone_number,
    m.name as order_branch_location
from
    es_warehouse.public.rentals r
    left join es_warehouse.public.assets a on a.asset_id = r.asset_id
    left join es_warehouse.public.admin_cycle ac on ac.rental_id = r.rental_id and ac.asset_id = r.asset_id
    left join es_warehouse.public.orders o on r.order_id = o.order_id
    left join es_warehouse.public.purchase_orders po on po.purchase_order_id = o.purchase_order_id
    left join es_warehouse.public.companies poc on o.company_id = poc.company_id
    left join es_warehouse.public.users u on u.user_id = o.user_id
    join es_warehouse.public.companies c on c.company_id = u.company_id
    left join es_warehouse.public.remaining_rental_cost rrc on rrc.rental_id = r.rental_id and o.purchase_order_id = po.purchase_order_id
    left join rental_locations l on l.rental_id = r.rental_id
    left join es_warehouse.public.rental_part_assignments rpa on rpa.rental_id = r.rental_id
    left join es_warehouse.inventory.parts p on p.part_id = rpa.part_id
    left join es_warehouse.inventory.part_types pt on pt.part_type_id = p.part_type_id
    left join es_warehouse.public.markets m on m.market_id = o.market_id
where
  --match on purchase order table
      1=1 -- no filter on 'on_off_rent_with_spend.company_filter'
  AND
  --match on companies table
      --company filter on companies table
      1=1 -- no filter on 'on_off_rent_with_spend.company_filter'
  AND r.rental_status_id = 5

---------------
UNION
---------------

select
    r.rental_id,
    o.order_id,
    o.sub_renter_id,
    r.asset_id,
    coalesce(a.asset_class,pt.description,' ') as asset_class,
    po.name as purchase_order_name,
    r.start_date::date as rental_start_date,
    r.end_date::date as rental_end_date,
    NULL,
    NULL,
    NULL,
    'Off Rent',
    c.company_id,
    c.name,
    r.price_per_day,
    r.price_per_week,
    r.price_per_month,
    coalesce(r.quantity,1) as quantity,
    --l.nickname as jobsite
    l.jobsite,
    concat(u.first_name,' ',u.last_name,' (',u.phone_number,')') as order_by_with_phone_number,
    m.name as order_branch_location
from
    es_warehouse.public.rentals r
    left join es_warehouse.public.orders o on r.order_id = o.order_id
    left join es_warehouse.public.users u on u.user_id = o.user_id
    join es_warehouse.public.companies c on c.company_id = u.company_id
    left join es_warehouse.public.assets a on r.asset_id = a.asset_id
    left join es_warehouse.public.purchase_orders po on po.purchase_order_id = o.purchase_order_id
    left join es_warehouse.public.companies poc on o.company_id = poc.company_id
    left join es_warehouse.public.rental_part_assignments rpa on rpa.rental_id = r.rental_id
    left join es_warehouse.inventory.parts p on p.part_id = rpa.part_id
    left join es_warehouse.inventory.part_types pt on pt.part_type_id = p.part_type_id
    left join rental_locations l on l.rental_id = r.rental_id
    left join es_warehouse.public.markets m on m.market_id = o.market_id
where
      '2021-01-01'::date <= r.end_date::date
  and r.start_date::date <= current_date
  AND
  --match on purchase order table
      1=1 -- no filter on 'on_off_rent_with_spend.company_filter'
  AND
  --match on companies table
      --company filter on companies table
      1=1 -- no filter on 'on_off_rent_with_spend.company_filter'
  and r.rental_status_id IN (6, 7, 9)
),

PRE_FINAL_DATA AS(
SELECT
    r.*,
    a.current_asset_id,
    pj.phase_job_name,
    pj.job_name,
    c.name sub_renting_company,
    concat(u.first_name, ' ', u.last_name) as sub_renting_contact
FROM
    all_rentals r
LEFT JOIN current_assets a ON r.rental_id = a.rental_id
LEFT JOIN phases_and_jobs pj ON r.rental_id = pj.rental_id
left join es_warehouse.public.sub_renters sr on sr.sub_renter_id = r.sub_renter_id
left join es_warehouse.public.users u on sr.sub_renter_ordered_by_id = u.user_id
left join es_warehouse.public.companies c on sr.sub_renter_company_id = c.company_id
),

PART_NUMBERS AS (
    SELECT
        DISTINCT RENTAL_ID, PART_NUMBER
    FROM es_warehouse.public.rental_part_assignments r
    INNER JOIN es_warehouse.inventory.parts p USING (PART_ID)
    QUALIFY ROW_NUMBER() OVER (PARTITION BY r.rental_id ORDER BY p.date_updated DESC NULLS LAST) = 1
)


SELECT
    COALESCE(p.RENTAL_ASSET_ID::VARCHAR, p2.PART_NUMBER::VARCHAR) AS PRODUCT,
    p.ASSET_CLASS AS EQUIPMENT_CLASS,
    p.QUANTITY,
    p.PURCHASE_ORDER_NAME,
    p.RENTAL_STATUS,
    p.ORDER_ID,
    p.JOBSITE AS LOCATION_NAME,
    p.JOB_NAME AS JOB,
    p.PHASE_JOB_NAME AS PHASE,
    p.RENTAL_START_DATE AS START_DATE,
    p.RENTAL_END_DATE AS END_DATE,
    p.PRICE_PER_DAY,
    p.PRICE_PER_WEEK,
    p.PRICE_PER_MONTH,
    COALESCE(
    CASE
        WHEN p.RENTAL_START_DATE >= CURRENT_DATE-7 THEN SUM(u.RUN_TIME_CST) / NULLIF((DATEDIFF('seconds', p.RENTAL_START_DATE, CURRENT_DATE) / 3), 0)
        WHEN p.RENTAL_END_DATE <= CURRENT_DATE THEN SUM(u.RUN_TIME_CST) / NULLIF((DATEDIFF('seconds', CURRENT_DATE - 7, p.RENTAL_END_DATE) / 3), 0)
        ELSE SUM(u.RUN_TIME_CST)/(604800/3) -- 7 eight hour days
    END
    , 0)
    AS LAST_SEVEN_DAY_UTILIZATION
FROM
PRE_FINAL_DATA p
LEFT JOIN BUSINESS_INTELLIGENCE.TRIAGE.STG_T3__BY_DAY_UTILIZATION u
    ON p.rental_asset_id = u.asset_id
    AND u.date BETWEEN CURRENT_DATE-8 AND CURRENT_DATE -- UTILIZATION IN L7D
LEFT JOIN PART_NUMBERS p2 ON p.rental_id = p2.rental_id
WHERE
    p.COMPANY_ID = 55742 --SASOL
    AND p.RENTAL_END_DATE >= CURRENT_DATE-7 -- last 7D
GROUP BY ALL;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: product {
    type: string
    sql: ${TABLE}."PRODUCT" ;;
  }

  dimension: equipment_class {
    type: string
    sql: ${TABLE}."EQUIPMENT_CLASS" ;;
  }

  dimension: quantity {
    type: number
    sql: ${TABLE}."QUANTITY" ;;
  }

  dimension: purchase_order_name {
    type: string
    sql: ${TABLE}."PURCHASE_ORDER_NAME" ;;
  }

  dimension: rental_status {
    type: string
    sql: ${TABLE}."RENTAL_STATUS" ;;
  }

  dimension: order_id {
    type: string
    sql: ${TABLE}."ORDER_ID" ;;
  }

  dimension: location_name {
    type: string
    sql: ${TABLE}."LOCATION_NAME" ;;
  }

  dimension: job {
    type: string
    sql: ${TABLE}."JOB" ;;
  }

  dimension: phase {
    type: string
    sql: ${TABLE}."PHASE" ;;
  }

  dimension: start_date {
    type: date
    sql: ${TABLE}."START_DATE" ;;
  }

  dimension: end_date {
    type: date
    sql: ${TABLE}."END_DATE" ;;
  }

  dimension: price_per_day {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}."PRICE_PER_DAY" ;;
  }

  dimension: price_per_week {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}."PRICE_PER_WEEK" ;;
  }

  dimension: price_per_month {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}."PRICE_PER_MONTH" ;;
  }

  dimension: last_seven_day_utilization {
    type: number
    value_format_name: percent_2
    sql: ${TABLE}."LAST_SEVEN_DAY_UTILIZATION" ;;
  }


  set: detail {
    fields: [
      product,
      equipment_class,
      quantity,
      purchase_order_name,
      rental_status,
      order_id,
      location_name,
      job,
      phase,
      start_date,
      end_date,
      price_per_day,
      price_per_week,
      price_per_month,
      last_seven_day_utilization
    ]
  }

}
