view: int_claims__road_union {
  derived_table: {
    sql: select *,date_trunc(month,date_of_loss)::date as month_of_claim
         from analytics.claims.int_claims__road_union
        where month_of_claim between dateadd(month, -11, (select trunc::date from analytics.gs.plexi_periods where {% condition period_name %} display {% endcondition %}))
      and (select trunc::date from analytics.gs.plexi_periods where {% condition period_name %} display {% endcondition %}) ;;
  }

  filter: period_name {
    type: string
    suggest_explore: plexi_periods
    suggest_dimension: plexi_periods.display
  }

  dimension: date_of_loss {
    type: date
    sql: ${TABLE}."DATE_OF_LOSS" ;;
  }

  dimension: month_of_claim {
    type: date
    sql: ${TABLE}."MONTH_OF_CLAIM" ;;
  }

  dimension: asset_number {
    type: string
    label: "asset id"
    sql: ${TABLE}."ASSET_NUMBER" ;;
  }

  dimension: asset_year {
    type: number
    sql: ${TABLE}."ASSET_YEAR" ;;
  }

  dimension: asset_make {
    type: string
    sql: ${TABLE}."ASSET_MAKE" ;;
  }

  dimension: asset_model {
    type: string
    sql: ${TABLE}."ASSET_MODEL" ;;
  }

  dimension: serial {
    type: string
    sql: ${TABLE}."SERIAL" ;;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: location {
    type: string
    label: "Market Name"
    sql: ${TABLE}."LOCATION" ;;
  }

  dimension: at_fault_payer {
    type: string
    sql: ${TABLE}."AT_FAULT_PAYER" ;;
  }

  dimension: is_material_loss {
    type: yesno
    sql: ${TABLE}."IS_MATERIAL_LOSS" ;;
  }

  dimension: driver_name {
    type: string
    sql: ${TABLE}."DRIVER_NAME" ;;
  }

  dimension: driver_employee_id {
    type: number
    sql: ${TABLE}."DRIVER_EMPLOYEE_ID" ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
  }

}
