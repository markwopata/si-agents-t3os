view: budget_live_be {
  derived_table: {
    sql:
select
    MARKET_ID,
    MONTHS,
    sum(REVENUE_GOALS) as GOAL,
    to_varchar(MONTHS, 'mmmm yyyy') AS PERIOD,
    MARKET_ID||'-'||MONTHS::Date AS MKT_MONTHS,
'Rental Revenues' as TYPE
from analytics.PUBLIC.MARKET_GOALS

where (START_DATE is null or START_DATE <= MONTHS)
    and END_DATE is null
group by MARKET_ID, MONTHS,PERIOD,MKT_MONTHS, TYPE

union all

select
    mkt_id AS MARKET_ID,
    add_months(date_trunc(month,beds.GL_DATE::date),-2) AS MONTHS,
    sum(amt) AS GOAL,
    to_varchar(MONTHS, 'mmmm yyyy') AS PERIOD,
    MARKET_ID||'-'||MONTHS::date || '-' || BEDS.TYPE AS MKT_MONTHS,
    BEDS.TYPE as TYPE
from analytics.public.BRANCH_EARNINGS_DDS_SNAP beds

where ACCTNO::varchar::varchar <> '5000'
    and beds.dept <> 'sale'
    and months >= '2022-05-01'
group by MARKET_ID, months,period,mkt_months, TYPE
;;
  }

  dimension: mkt_months {
    type: string
    primary_key: yes
    sql: ${TABLE}."MKT_MONTHS" ;;
  }

 dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

 dimension: months {
    type: date
    sql: ${TABLE}."MONTHS" ;;
  }

  dimension: period {
    type: string
    sql: ${TABLE}."PERIOD" ;;
  }

  measure: goal {
    type: sum
    sql: ${TABLE}."GOAL" ;;
  }



  dimension: type {
    type: string
    sql: ${TABLE}."TYPE" ;;
  }

  }
