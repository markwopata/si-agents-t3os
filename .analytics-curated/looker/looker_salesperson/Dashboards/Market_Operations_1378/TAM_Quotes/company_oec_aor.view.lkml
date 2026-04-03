
view: company_oec_aor {
  derived_table: {
    sql: select * from analytics.bi_ops.company_oec_aor_historical where date > dateadd(day, '-91', CURRENT_DATE)
      UNION
      select * from analytics.bi_ops.company_oec_aor_current ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension_group: date {
    type: time
    sql: ${TABLE}."DATE" ;;
  }

  dimension: company_id {
    type: string
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  dimension: assets_on_rent {
    type: number
    sql: ${TABLE}."ASSETS_ON_RENT" ;;
  }

  dimension: num_class_types {
    type: number
    sql: ${TABLE}."NUM_CLASS_TYPES" ;;
  }

  dimension: num_primary_salesreps {
    type: number
    sql: ${TABLE}."NUM_PRIMARY_SALESREPS" ;;
  }

  dimension: num_markets {
    type: number
    sql: ${TABLE}."NUM_MARKETS" ;;
  }

  dimension: oec_on_rent {
    type: number
    sql: ${TABLE}."OEC_ON_RENT" ;;
    value_format_name: usd_0
  }

  dimension: rr_assets_on_rent {
    type: number
    sql: ${TABLE}."RR_ASSETS_ON_RENT" ;;
  }

  dimension: num_rr_primary_salesreps {
    type: number
    sql: ${TABLE}."NUM_RR_PRIMARY_SALESREPS" ;;
  }

  dimension: num_rr_markets {
    type: number
    sql: ${TABLE}."NUM_RR_MARKETS" ;;
  }

  set: detail {
    fields: [
        date_date,
  company_id,
  company_name,
  assets_on_rent,
  num_class_types,
  num_primary_salesreps,
  num_markets,
  oec_on_rent,
  rr_assets_on_rent,
  num_rr_primary_salesreps,
  num_rr_markets
    ]
  }
}
