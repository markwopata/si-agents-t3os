view: trovata_liquidity {
  derived_table: {
    sql: select 'Cash' as description ,sum(COMPOSITEBALANCECONVERTED)/1000000 as amount
from analytics.TREASURY.CASH_BALANCES_BY_ENTITY_HISTORY
where TIMESTAMP = (select max(TIMESTAMP) from analytics.TREASURY.CASH_BALANCES_BY_ENTITY_HISTORY)
and date::date = current_date - 1
and bank_id is not null
and bank_name not in  ('Restricted','Insurance')
union all
select item as description, amount
from analytics.treasury.cash_forecast_inputs
where item = 'ABL Current Balance'
          ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}.DESCRIPTION ;;
  }

  measure: amount {
    type: sum
    sql: ${TABLE}.AMOUNT ;;
  }
}
