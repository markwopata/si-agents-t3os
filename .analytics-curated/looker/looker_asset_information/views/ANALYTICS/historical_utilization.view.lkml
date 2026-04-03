view: historical_utilization {
  sql_table_name: "PUBLIC"."HISTORICAL_UTILIZATION"
    ;;

  dimension: age {
    type: number
    sql: ${TABLE}."AGE" ;;
  }

  dimension: aged_out_of_fleet {
    type: yesno
    sql: ${TABLE}."AGED_OUT_OF_FLEET" ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension_group: dte {
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
    sql: ${TABLE}."DTE" ;;
  }

  dimension: asset_dte {
    primary_key: yes
    type: string
    sql: concat(${asset_id},' ',${dte_date}) ;;
  }

  dimension: as_of_31_days_ago {
    type: yesno
    sql: ${dte_date} = current_timestamp::DATE - interval '31 days';;
  }

  measure: on_rent_oec_31_days_ago {
    type: sum
    filters: {
      field: as_of_31_days_ago
      value: "yes"
    }
    # sql: CASE WHEN coalesce(${asset_statuses.asset_inventory_status},${asset_statuses.asset_rental_status}) IN ('On Rent') then ${latest_purchase_price} ELSE 0 END ;;
    sql: CASE WHEN ${asset_status_key_values.value} IN ('On Rent') then ${purchase_price} ELSE 0 END ;;
  }


  dimension_group: first_rental {
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
    sql: ${TABLE}."FIRST_RENTAL" ;;
  }

  dimension: in_rental_fleet {
    type: yesno
    sql: ${TABLE}."IN_RENTAL_FLEET" ;;
  }

  dimension_group: last_rental {
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
    sql: ${TABLE}."LAST_RENTAL" ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: on_rent {
    type: yesno
    sql: ${TABLE}."ON_RENT" ;;
  }

  dimension: purchase_price {
    type: number
    sql: ${TABLE}."PURCHASE_PRICE" ;;
  }

  dimension: rerent_indicator {
    type: yesno
    sql: ${TABLE}."RERENT_INDICATOR" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
