view: asset_rpp {
   derived_table: {
    sql:
    SELECT  distinct a.*
    FROM ANALYTICS.DEBT.ASSET_NBV_ALL_OWNERS a
     left join ES_WAREHOUSE.public.rentals r
      on a.asset_id=r.asset_id
    left join ES_WAREHOUSE.public.orders o
      on o.order_id = r.order_id
    left join ES_WAREHOUSE.public.markets m
      on a.market_id=m.market_id
        where (m.company_id = 1854 or m.company_id =1855)
        and a.asset_type_id != 2
        order by a.asset_id
    ;;
  }


  dimension: equipment_class {
    type: string
    sql: ${TABLE}."ASSET_CLASS" ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: asset_invoice_url {
    type: string
    sql: ${TABLE}."ASSET_INVOICE_URL" ;;
  }

  dimension: asset_type {
    type: string
    sql: ${TABLE}."ASSET_TYPE" ;;
  }

  dimension: asset_type_id {
    type: number
    sql: ${TABLE}."ASSET_TYPE_ID" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  dimension: curr_bal {
    type: number
    sql: ${TABLE}."CURR_BAL" ;;
  }

  dimension_group: date_created {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_CREATED" ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension: finance_status {
    type: string
    sql: ${TABLE}."FINANCE_STATUS" ;;
  }

  dimension: financing_facility_type {
    type: string
    sql: ${TABLE}."FINANCING_FACILITY_TYPE" ;;
  }

  dimension_group: first_rental {
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
    sql: CAST(${TABLE}."FIRST_RENTAL" AS TIMESTAMP_NTZ) ;;
  }

  dimension: greensill_ind {
    type: string
    sql: ${TABLE}."GREENSILL_IND" ;;
  }

  dimension: hours {
    type: number
    sql: ${TABLE}."HOURS" ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}."MAKE" ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension: nbv {
    type: number
    sql: ${TABLE}."NBV" ;;
  }

  dimension: oec {
    type: number
    sql: ${TABLE}."OEC" ;;
  }

  dimension: orig_bal {
    type: number
    sql: ${TABLE}."ORIG_BAL" ;;
  }

  dimension: paid_in_cash_ind {
    type: number
    sql: ${TABLE}."PAID_IN_CASH_IND" ;;
  }

  dimension: payoff_amount {
    type: number
    sql: ${TABLE}."PAYOFF_AMT" ;;
  }

  dimension: pending_schedule {
    type: string
    sql: ${TABLE}."PENDING_SCHEDULE" ;;
  }

  dimension_group: purchase {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."PURCHASE_DATE" ;;
  }

  dimension: rental_status {
    type: string
    sql: ${TABLE}."RENTAL_STATUS" ;;
  }

  dimension: schedule {
    type: string
    sql: ${TABLE}."SCHEDULE" ;;
  }

  dimension: serial_number {
    type: string
    sql: ${TABLE}."SERIAL_NUMBER" ;;
  }

  dimension: vin {
    type: string
    sql: ${TABLE}."VIN" ;;
  }

  dimension: serial_vin {
    type: string
    sql: coalesce(${serial_number},${vin}) ;;
  }

  dimension: year {
    type: number
    sql: ${TABLE}."YEAR" ;;
  }


  measure: asset_replacement_value {
    type: sum
    sql: CASE WHEN ${paid_in_cash_ind}=1 THEN (${nbv} * 1.26)
              WHEN ${payoff_amount} IS NULL THEN (${nbv} * 1.26)
              WHEN ${nbv} >= ${payoff_amount} THEN (${nbv} * 1.26)
              WHEN ${nbv} < ${payoff_amount} THEN (${payoff_amount} * 1.26)
              ELSE 0 END ;;
  }

  measure: price_floor {
    type: sum
    sql: CASE WHEN ${paid_in_cash_ind}=1 THEN (${nbv} * 0.08) + ${nbv}
              WHEN ${payoff_amount} IS NULL THEN (${nbv} * 0.08) + ${nbv}
              WHEN ${nbv} >= ${payoff_amount} THEN (${nbv} * 0.08) + ${TABLE}.nbv
              WHEN ${nbv} < ${payoff_amount} THEN (${payoff_amount} * 0.08) + ${payoff_amount}
              ELSE 0 END ;;
  }

  measure: asset_replacement_value_sales_reps {
    type: sum
    sql: CASE WHEN ${greensill_ind} = 'greensill' THEN (${nbv} * 1.22)
              WHEN TRIM(UPPER(${make})) LIKE '%SANY%' AND TRIM(UPPER(${model})) LIKE '%SY500%' THEN (${nbv} * 1.30)
              WHEN TRIM(UPPER(${make})) LIKE '%SANY%' AND TRIM(UPPER(${model})) LIKE '%SY50%' THEN (${nbv} * 1.40)
              WHEN TRIM(UPPER(${make})) LIKE '%SANY%' AND TRIM(UPPER(${model})) LIKE '%SY35%' THEN (${nbv} * 1.40)
              WHEN TRIM(UPPER(${make})) LIKE '%SANY%' AND TRIM(UPPER(${model})) LIKE '%SY135%' THEN (${nbv} * 1.30)
              WHEN TRIM(UPPER(${make})) LIKE '%SANY%' AND TRIM(UPPER(${model})) LIKE '%SY95%' THEN (${nbv} * 1.30)
              WHEN TRIM(UPPER(${make})) LIKE '%SANY%' AND TRIM(UPPER(${model})) LIKE '%SY215%' THEN (${nbv} * 1.25)
              WHEN TRIM(UPPER(${equipment_class})) LIKE '%Telescopic Boom Lift, 120%' THEN (${nbv} * 1.30)
              WHEN TRIM(UPPER(${equipment_class})) LIKE '%Telescopic Boom Lift, 100%' THEN (${nbv} * 1.30)
              WHEN TRIM(UPPER(${equipment_class})) LIKE '%Telescopic Boom Lift, 125%' THEN (${nbv} * 1.30)
              WHEN TRIM(UPPER(${equipment_class})) LIKE '%Telescopic Boom Lift, 150%' THEN (${nbv} * 1.30)
              WHEN TRIM(UPPER(${equipment_class})) LIKE '%Telescopic Boom Lift, 135%' THEN (${nbv} * 1.30)
              WHEN TRIM(UPPER(${equipment_class})) LIKE '%Telescopic Boom Lift, 180%' THEN (${nbv} * 1.30)
              WHEN ${paid_in_cash_ind} = 1 THEN (${nbv} * 1.22)
              WHEN ${payoff_amount} IS NULL THEN (${nbv} * 1.22)
              WHEN ${nbv} >= ${payoff_amount} THEN (${nbv} * 1.22)
              WHEN ${nbv} < ${payoff_amount} THEN (${payoff_amount} * 1.22)
              ELSE 0 END ;;
    value_format_name: decimal_0
  }

  measure: count {
    type: count
    drill_fields: [company_name, market_name]
  }
}
