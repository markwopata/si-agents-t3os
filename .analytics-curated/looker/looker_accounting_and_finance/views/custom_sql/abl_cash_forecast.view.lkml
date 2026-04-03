view: abl_cash_forecast {
  derived_table: {
    sql: with main_cte as (select 'Cash' as description,date ,sum(COMPOSITEBALANCECONVERTED)/1000 as amount
from analytics.treasury.cash_balances_by_entity_history
where timestamp = (select max(timestamp) from analytics.treasury.cash_balances_by_entity_history)
and bank_name <> 'Restricted'
and bank_id is not null
group by date
union all
select 'ABL' as description,date ,sum(amount) as amount
from analytics.TREASURY.abl
where abl_type = 'Weekly'
group by date)
select date,sum(amount) as amount
from main_cte
group by date
          ;;
  }


  dimension: description {
    type: string
    sql: ${TABLE}.DESCRIPTION ;;
  }

  dimension: date {
    type: date
    sql: ${TABLE}.DATE ;;
  }


  measure: amount {
    type: sum
    sql: ${TABLE}.AMOUNT;;
  }



}
