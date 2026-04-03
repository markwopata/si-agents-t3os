view: oec_detail {
  sql_table_name: analytics.branch_earnings.int_branch_earnings_oec_detail_looker ;;

  filter: Period {
    suggest_dimension: plexi_periods.period_for_suggest
    suggest_explore: plexi_periods
  }

  measure: count {
    type: count
    label: "Total Units"
    drill_fields: [detail*]
  }

  measure: sum {
    label: "OEC"
    type: sum
    value_format: "#,##0;(#,##0);-"
    sql: ${amount} ;;
    drill_fields: [detail*]
  }

  dimension: market_id {
    type: string
    label: "Market Id"
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: pk {
    type: number
    primary_key: yes
    hidden: yes
    sql: ${TABLE}."PK" ;;
  }

  dimension: gl_date {
    type: date
    convert_tz: no
    sql: ${TABLE}."GL_DATE" ;;
  }

  dimension: amount {
    type: number
    value_format: "#,##0;(#,##0);-"
    sql: ${TABLE}."AMOUNT" ;;
  }

  dimension: equipment_charge {
    type: number
    value_format: "#,##0;(#,##0);-"
    sql: ${TABLE}."EQUIPMENT_CHARGE" ;;
  }

  dimension: asset_id {
    type: string
    sql: ${TABLE}."ASSET_ID";;
    html:
    <font color="blue"><u><a href = "@{db_oec_asset_detail}?Asset%20ID={{ asset_id._filterable_value | url_encode }}" target="_blank">{{ asset_id._filterable_value }}</a></font></u>;;
  }

  dimension: make {
    type: string
    sql:  ${TABLE}."MAKE" ;;
  }

  dimension: model {
    type: string
    sql:  ${TABLE}."MODEL" ;;
  }

  dimension: year {
    type: string
    sql:  ${TABLE}."YEAR" ;;
  }

  dimension: asset_class {
    type: string
    sql:  ${TABLE}."ASSET_CLASS" ;;
  }

  dimension: asset_type {
    type: string
    sql:  ${TABLE}."ASSET_TYPE" ;;
  }

  dimension: inventory_status {
    type: string
    sql:${TABLE}."INVENTORY_STATUS" ;;
  }

  dimension: company_id {
    type: number
    value_format_name: id
    sql:  ${TABLE}."COMPANY_ID" ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  dimension: is_new_asset {
    type: yesno
    sql: ${TABLE}."IS_NEW_ASSET" ;;
  }

  dimension: current_flag {
    type: yesno
    sql: ${TABLE}."IS_CURRENT_ASSET" ;;
  }

  dimension: url_admin {
    type: string
    sql: ${TABLE}."URL_ADMIN" ;;
  }

  dimension: url_track {
    type: string
    sql: ${TABLE}."URL_TRACK" ;;
  }

  dimension: link_agg {
    label: "Links"
    sql: 'a' ;;
    html:
    {% if oec_detail.url_admin._value != null %}
    <a href = "{{ oec_detail.url_admin._value }}" target="_blank">
    <img src="https://assets-global.website-files.com/60cb2013a506c737cfeddf74/615b728bc86ddc3555605abc_EquipmentShare-Favicon.png" width="16" height="16"> Admin</a>
    &nbsp;
    {% endif %}
    {% if oec_detail.url_track._value != null %}
    <a href = "{{ oec_detail.url_track._value }}" target="_blank">
    <img src="https://unav.equipmentshare.com/fleet.svg" width="16" height="16"> T3</a>
    &nbsp;
    {% endif %}
    ;;
  }

  dimension: rental_market_id {
    type: string
    sql:  ${TABLE}."RENTAL_MARKET_ID";;
  }

  dimension: rental_market_name {
    type: string
    sql:  ${TABLE}."RENTAL_MARKET";;
  }

  dimension: rental_market {
    type: string
    sql: ${rental_market_id} || ' - ' || ${rental_market_name} ;;
  }

  dimension: inventory_market_id {
    type: string
    sql:  ${TABLE}."INVENTORY_MARKET_ID";;
  }

  dimension: inventory_market_name {
    type: string
    sql:  ${TABLE}."INVENTORY_MARKET";;
  }

  dimension: inventory_market {
    type: string
    sql: ${inventory_market_id} || ' - ' || ${inventory_market_name} ;;
  }

  dimension: service_market_id {
    type: string
    sql:  ${TABLE}."SERVICE_MARKET_ID";;
  }

  dimension: service_market_name {
    type: string
    sql:  ${TABLE}."SERVICE_MARKET";;
  }

  dimension: service_market {
    type: string
    sql: ${service_market_id} || ' - ' || ${service_market_name} ;;
  }

  dimension: problem_note {
    type: string
    sql:  ${TABLE}."PROBLEM_NOTE" ;;
  }

  set: detail {
    fields: [
      market_id,
      gl_date,
      amount,
      asset_id,
      make,
      model,
      year,
      asset_class,
      asset_type,
      company_id,
      company_name
    ]
  }
}
