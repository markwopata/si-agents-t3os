view: gpm_by_district_eq_class {

  derived_table: {

    sql:

  with line_items as (


select distinct li.branch_id,
b.equipment_class_id,
case when b.amount <= 1 then null else gross_profit_margin end as gross_profit_margin,
case when b.amount <= 1 then null else gross_profit_margin_pct end as gross_profit_margin_pct
from analytics.rate_achievement.breakeven_rates_line_item_details as b
left join es_warehouse.public.line_items as li
on li.line_item_id = b.line_item_id
where b.billing_approved_date between dateadd(day, -90, current_date()) and current_date()



)

select
li.equipment_class_id::varchar as equipment_class_id,
rr.district as district,

case when avg(li.gross_profit_margin_pct) < -1 then -1
    when avg(li.gross_profit_margin_pct) > 1 then 1 else avg(li.gross_profit_margin_pct) end as gross_profit_margin_pct
from line_items as li
join analytics.rate_achievement.rate_regions as rr
on rr.market_id = li.branch_id
group by 1,2




    ;;
  }

  dimension: equipment_class_district_pk {
    primary_key: yes
    type: string
    sql: CONCAT(
        CAST(${equipment_class_id} AS STRING),
        '_',
        ${district}
      ) ;;
  }

  dimension: equipment_class_id {

    type: string
    sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
    value_format_name: id

  }
  dimension: district {

    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: avg_gross_profit_margin_pct_90d {

    type: number
    sql: ${TABLE}."GROSS_PROFIT_MARGIN_PCT" ;;
   value_format_name: percent_2


  }

}
