view: cash_sources_uses_abl {
  derived_table: {
    sql: select 'Cash' as description ,sum(COMPOSITEBALANCECONVERTED)/1000000 as amount
from analytics.TREASURY.CASH_BALANCES_BY_ENTITY_HISTORY
where TIMESTAMP = (select max(TIMESTAMP) from analytics.TREASURY.CASH_BALANCES_BY_ENTITY_HISTORY)
and date::date = '2023-09-27' -- Use Most Recent Sunday
and bank_id is not null
union all
select 'Sources & Uses' as description, sum(amount)/1000000 as amount
from analytics.TREASURY.SOURCES_USES_FORECAST
where TIMESTAMP = (select max(TIMESTAMP) from analytics.TREASURY.SOURCES_USES_FORECAST)
and date::date >= '2023-09-28' -- Use Most Recent Monday
union all
select 'ABL' as description, sum(amount)/1000 as amount
from analytics.TREASURY.abl
--where TIMESTAMP = (select max(TIMESTAMP) from analytics.TREASURY.ABL)
where abl_type = '3Q23'
and date::date = '2023-09-30' -- Use Current End of Quarter
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
