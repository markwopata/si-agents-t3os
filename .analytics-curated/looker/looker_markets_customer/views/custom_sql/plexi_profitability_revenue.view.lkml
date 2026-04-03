view: plexi_profitability_revenue {
  derived_table: {
    sql: select
    iff(JE.DEPARTMENT = '15967', '33163', JE.DEPARTMENT)::int as mkt_id,
    M.MARKET_NAME ,
    datediff(month, RO.MARKET_START_MONTH, JE.ENTRY_DATE::date) as market_age,
    M.REGION_NAME as rgn_name,
    date_trunc(month, JE.ENTRY_DATE) as gl_date,
    round((JE.TRX_AMOUNT::float * JE.TR_TYPE::float * -1),2) as amount,
    JE.ACCOUNTNO
from ANALYTICS.INTACCT.GLENTRY                                    JE
    join ANALYTICS.GS.PLEXI_BUCKET_MAPPING                       B
        on JE.ACCOUNTNO = B.SAGE_GL
    join ANALYTICS.GS.REVMODEL_MARKET_ROLLOUT_CONSERVATIVE       RO
        on iff(JE.DEPARTMENT = '15967', '33163', JE.DEPARTMENT) = RO.MARKET_ID::varchar
    left join ANALYTICS.PUBLIC.MARKET_REGION_XWALK               M
        on iff(JE.DEPARTMENT = '15967', '33163', JE.DEPARTMENT) = M.MARKET_ID::varchar
where JE.LOCATION = 'E1'
    and JE.STATE = 'Posted'
    and B."GROUP" is not null
    and JE.DEPARTMENT regexp '^[0-9]+$'
    --and JE.ACCOUNTNO = 'FAAA'
   and (market_age = 12
    or (market_age > 12 and gl_date::date = date_trunc(month,current_timestamp::date) - interval '1 month'))
--group by mkt_id, mkt_name, rgn_name, market_age, gl_date
order by amount desc

       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MKT_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: market_age {
    type: number
    sql: ${TABLE}."MARKET_AGE" ;;
  }

  dimension: rgn_name {
    type: string
    sql: ${TABLE}."RGN_NAME" ;;
  }

  dimension: gl_date {
    type: date
    sql: ${TABLE}."GL_DATE" ;;
  }

  dimension: account {
    type: string
    sql: ${TABLE}."ACCOUNTNO" ;;
  }

  dimension: amount {
    type: number
    sql: ${TABLE}."AMOUNT" ;;
  }

  dimension: rent_revenue {
    type: yesno
    sql: trim(${account}) in ('FAAA') ;;
  }

  dimension: market_age_12_mo {
    type: yesno
    sql: ${market_age} = 12 ;;
  }

  dimension: market_age_older_than_12_mo {
    type: yesno
    sql: ${market_age} > 12 ;;
  }

  dimension: last_month_entry {
    type: yesno
    sql:  ${gl_date}::DATE = date_trunc(month,current_timestamp::DATE) - interval '1 month';;
  }

  measure: last_month_profitability {
    type: sum
    sql: ${amount} ;;
    filters: [market_age_older_than_12_mo: "Yes",
      last_month_entry: "Yes"]
  }

  measure: rent_revenue_at_12_months {
    type: sum
    sql: ${amount} ;;
    filters: [market_age_12_mo: "Yes",
      rent_revenue: "Yes"]
  }

  set: detail {
    fields: [
      market_id,
      market_name,
      market_age,
      rgn_name,
      gl_date,
      amount
    ]
  }
}
