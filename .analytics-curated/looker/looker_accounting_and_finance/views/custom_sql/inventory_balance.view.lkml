view: inventory_balance {
derived_table: {
  sql:
        select
        IBS.TIMESTAMP,
        DAY(IBS.TIMESTAMP) as DAY,
        iff(DAY = 1,TO_CHAR(DATEADD(day,-1,IBS.TIMESTAMP),'MMMM'),TO_CHAR(IBS.TIMESTAMP,'MMMM')) as MONTH,
        YEAR(IBS.TIMESTAMP) as YEAR,
        IBS.BRANCH_ID,
        M.NAME as MARKET_NAME,
        IBS.STORE_ID,
        IBS.STORE_NAME,
        IBS.PROVIDER_NAME,
        IBS.PART_NUMBER,
        IBS.DESCRIPTION,
        IBS.MIN,
        IBS.MAX,
        IBS.QUANTITY,
        IBS.TOTAL,
        IBS.COST,
        IBS.TOTAL_VALUE,
        IBS.STORE_PART_ID,
        IBS.PART_ID,
        IBS.PARENT_ID
        from ANALYTICS.PUBLIC.INVENTORY_BALANCES_SNAPSHOT as IBS
        left join ES_WAREHOUSE.PUBLIC.MARKETS as m
            on IBS.BRANCH_ID = M.MARKET_ID
        where TIMESTAMP ilike '%06:0%'
      ;;
}

  dimension: TIMESTAMP {
    type: date_time
    sql: ${TABLE}."TIMESTAMP";;
    }
  dimension: YEAR {
    type: number
    sql: ${TABLE}."YEAR";;
  }
  dimension: MONTH {
    type: string
    sql: ${TABLE}."MONTH";;
  }
  dimension: DAY {
    type: number
    sql: ${TABLE}."DAY";;
  }
  dimension: BRANCH_ID {
    type: number
    value_format_name: id
    sql: ${TABLE}."BRANCH_ID";;
  }
  dimension: MARKET_NAME {
    type: string
    sql: ${TABLE}."MARKET_NAME";;
  }
  dimension: STORE_ID {
    type: number
    value_format_name: id
    sql: ${TABLE}."STORE_ID";;
  }
  dimension: STORE_NAME {
    type: string
    sql: ${TABLE}."STORE_NAME";;
  }
  dimension: PROVIDER_NAME {
    type: string
    sql: ${TABLE}."PROVIDER_NAME";;
  }
  dimension: PART_NUMBER {
    type: number
    value_format_name: id
    sql: ${TABLE}."PART_NUMBER";;
  }
  dimension: DESCRIPTION {
    type: string
    sql: ${TABLE}."DESCRIPTION";;
  }
  dimension: MIN {
    type: number
    sql: ${TABLE}."MIN";;
  }
  dimension: MAX {
    type: number
    sql: ${TABLE}."MAX";;
  }
  dimension: QUANTITY {
    type: number
    sql: ${TABLE}."QUANTITY";;
  }
  dimension: TOTAL {
    type: number
    sql: ${TABLE}."TOTAL";;
  }
  dimension: COST {
    type: number
    sql: ${TABLE}."COST";;
  }
  dimension: TOTAL_VALUE {
    type: number
    sql: ${TABLE}."TOTAL_VALUE";;
  }
  dimension: STORE_PART_ID {
    type: number
    value_format_name: id
    sql: ${TABLE}."STORE_PART_ID";;
  }
  dimension: PART_ID {
    type: number
    value_format_name: id
    sql: ${TABLE}."PART_ID";;
  }
  dimension: PARENT_ID {
    type: number
    value_format_name: id
    sql: ${TABLE}."PARENT_ID";;
  }
}
