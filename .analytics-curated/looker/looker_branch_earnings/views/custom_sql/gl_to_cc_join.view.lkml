view: gl_to_cc_join {
  derived_table: {
    sql:
      with gl_agg as (
        select
          ACCOUNT_NUMBER,
          ACCOUNT_NAME,
          split_part(ENTRY_DESCRIPTION, ';', 3) as transaction_id,
          sum(AMOUNT) as amt
        from ANALYTICS.INTACCT_MODELS.GL_DETAIL gl
        where ENTRY_DESCRIPTION ilike '%citi;%'
        group by all
      )

      select
      gl.ACCOUNT_NUMBER,
      gl.ACCOUNT_NAME,
      ccf.TRANSACTION_DATE::date as transaction_date,
      ccf.MERCHANT_NAME,
      cdt.LEGAL_CORPORATION_NAME,
      gl.transaction_id,
      gl.amt as gl_amount,
      sum(ccf.TRANSACTION_AMOUNT) as cc_transaction_amount
      from gl_agg gl
      left join analytics.PUBLIC.CC_AND_FUEL_SPEND_ALL ccf
      on gl.transaction_id = ccf.TRANSACTION_ID
      left join analytics.CREDIT_CARD.CITI_DAILY_TRANSACTIONS cdt
      on ccf.TRANSACTION_ID = cdt.TRANSACTION_ID
      group by all
      order by ccf.TRANSACTION_DATE::date, gl.ACCOUNT_NAME ;;
  }

  dimension: account_number {
    type: string
    sql: ${TABLE}.ACCOUNT_NUMBER ;;
  }

  dimension: account_name {
    type: string
    sql: ${TABLE}.ACCOUNT_NAME ;;
  }

  dimension: transaction_id {
    type: string
    sql: ${TABLE}.TRANSACTION_ID ;;
  }

  dimension_group: transaction_date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}.TRANSACTION_DATE ;;
  }

  dimension: merchant_name {
    type: string
    sql: ${TABLE}.MERCHANT_NAME ;;
  }

  dimension: legal_corporation_name {
    type: string
    sql: ${TABLE}.LEGAL_CORPORATION_NAME ;;
  }

  measure: row_count {
    type: count
    drill_fields: [
      account_number,
      account_name,
      transaction_id,
      merchant_name,
      legal_corporation_name,
      transaction_date_date
    ]
  }

  measure: total_gl_amount {
    type: sum
    sql: ${TABLE}.GL_AMOUNT ;;
    value_format_name: usd
  }

  measure: total_cc_transaction_amount {
    type: sum
    sql: ${TABLE}.CC_TRANSACTION_AMOUNT ;;
    value_format_name: usd
  }

  measure: avg_cc_transaction_amount {
    type: average
    sql: ${TABLE}.CC_TRANSACTION_AMOUNT ;;
    value_format_name: usd
  }

  measure: matched_transaction_count {
    type: count_distinct
    sql: ${transaction_id} ;;
  }
}
