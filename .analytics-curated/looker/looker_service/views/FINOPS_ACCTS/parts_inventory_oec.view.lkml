view: parts_inventory_oec {
  derived_table: {
    sql: with oec as (
  select date_trunc(month,generateddate::date) month_group
, sum(totaloec) totaloec
from ES_WAREHOUSE.SCD.PULLING_INVENTORY_EVENTS
where month_group=generateddate::date
group by month_group
)
,inventory as (select period_start_date
, sum(amount) inventory
from
analytics.intacct_models.BALANCE_SHEET_BY_DEPARTMENT_V
where account_number =1301
               and entity_id='E1'
             group by period_start_date)
select month_group
, totaloec
, inventory
, inventory/totaloec
from oec
join inventory i
on oec.month_group=i.period_start_date ;;
  }

  dimension_group: month {
    type: time
    timeframes: [date, month]
    sql: ${TABLE}.month_group ;;
  }

  measure: oec {
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}.totaloec ;;
  }

  measure: inventory {
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}.inventory ;;
  }

  measure: inventory_oec_ratio {
    type: number
    value_format_name: percent_1
    sql: ${inventory}/${oec} ;;
  }
 }
