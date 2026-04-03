view: customer_rebates {
  sql_table_name:  "ANALYTICS"."RATE_ACHIEVEMENT"."CUSTOMER_REBATE_AGREEMENTS"
   ;;

  # # changed to derived table with liquid filters to improve query performance - 2023.03.01 BES
  # derived_table: {
  #   sql:
  #     with customer_rebates_v as (
  #     SELECT
  #         c.COMPANY_ID as customer_id,
  #         co.NAME as customer_name,
  #         CAST(a.REBATE_PERIOD_BEGIN AS DATE) as rebate_start_period,
  #         CAST(a.REBATE_PERIOD_END AS DATE) as rebate_end_period,
  #         t.GROSS_RENT_PAYMENTS_MIN as revenue_lower_bound,
  #         t.GROSS_RENT_PAYMENTS_MAX as revenue_upper_bound,
  #         t.REBATE_PERCENTAGE as rebate_percent,
  #         (a.PAYMENT_TERMS + 3) as paid_in_days,
  #         'no' as rebate_paid,
  #         0 as rebate_paid_amount,
  #         case when a.CUSTOM_RENTAL_RATES = TRUE then 'yes'
  #             else 'no' end as customer_specific_rates
  #     FROM SWORKS.CUSTOMER_REBATES.REBATE_AGREEMENT_COMPANIES c
  #     LEFT JOIN ES_WAREHOUSE.PUBLIC.COMPANIES co on co.COMPANY_ID = c.COMPANY_ID
  #     LEFT JOIN SWORKS.CUSTOMER_REBATES.REBATE_AGREEMENTS a on a.REBATE_AGREEMENT_ID = c.REBATE_AGREEMENT_ID
  #     LEFT JOIN SWORKS.CUSTOMER_REBATES.REBATE_TIERS t on t.REBATE_AGREEMENT_ID = c.REBATE_AGREEMENT_ID
  #     and c.ACTIVE = TRUE
  #     and a.ACTIVE = TRUE
  # )

  #     SELECT
  #       *,
  #       ROW_NUMBER() OVER (PARTITION BY CUSTOMER_ID, REBATE_END_PERIOD ORDER BY REVENUE_LOWER_BOUND) AS TIER_NUMBER
  #     FROM
  #       customer_rebates_v
  #     WHERE
  #       {% condition customer_name %} customer_rebates_v.customer_name {% endcondition %} AND
  #       {% condition rebate_end_period_date %} customer_rebates_v.rebate_end_period::DATE {% endcondition %}
  #   ;;
  # }

  # dimension_group: _fivetran_synced {
  #   type: time
  #   timeframes: [
  #     raw,
  #     time,
  #     date,
  #     week,
  #     month,
  #     quarter,
  #     year
  #   ]
  #   sql: CAST(${TABLE}."_FIVETRAN_SYNCED" AS TIMESTAMP_NTZ) ;;
  # }

  # dimension: _row {
  #   type: number
  #   sql: ${TABLE}."_ROW" ;;
  # }

  dimension: customer_id {
    type: number
    value_format: "0"
    sql: ${TABLE}."CUSTOMER_ID" ;;
  }

  dimension: customer_name {
    type: string
    suggest_persist_for: "30 minutes"
    sql: ${TABLE}."CUSTOMER_NAME" ;;
  }

  dimension: paid_in_days {
    type: number
    sql: ${TABLE}.days_to_pay_with_grace_period ;;
  }

  dimension: rebate_percent {
    type: number
    sql: ${TABLE}."REBATE_PERCENT" ;;
  }
  dimension: date_created {


    type: date
    sql: ${TABLE}."DATE_CREATED" ;;


  }

  dimension: is_retroactive {

    type: yesno
    sql: ${TABLE}."IS_RETROACTIVE" ;;

  }
  dimension_group: rebate_start_period {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."REBATE_START_PERIOD" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: rebate_end_period {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."REBATE_END_PERIOD" AS TIMESTAMP_NTZ) ;;
  }

  dimension: current_rebates {
    type: yesno
    sql: ${rebate_end_period_date}>=current_timestamp()::date ;;
  }

  dimension: revenue_lower_bound {
    type: number
    sql: ${TABLE}."REVENUE_LOWER_BOUND" ;;
  }

  dimension: revenue_upper_bound {
    type: number
    sql: ${TABLE}."REVENUE_UPPER_BOUND" ;;
  }

  # dimension: rebate_paid {
  #   type: string
  #   sql: ${TABLE}."REBATE_PAID" ;;
  # }

  # dimension: rebate_paid_amount {
  #   type: number
  #   sql: ${TABLE}."REBATE_PAID_AMOUNT" ;;
  # }

  dimension: customer_specific_rates {
    type: string
    sql: ${TABLE}."CUSTOMER_SPECIFIC_RATES" ;;
  }

  dimension: tier_number {
    type: number
    sql: ${TABLE}."TIER_NUMBER" ;;
  }

  measure: count {
    type: count
    drill_fields: [customer_name, rebate_end_period_raw]
  }
}
