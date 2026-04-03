include: "/_base/analytics/public/asset_financing_snapshots.view.lkml"


view: +asset_financing_snapshots {

  ############### DIMENSIONS ###############

  dimension: asset_id {
    value_format_name: id
    description: "Unique ID used for an asset."
  }
  dimension: company_id {
    value_format_name: id
    description: "Unique ID used for a company."
  }
  dimension: financial_schedule_id {
    value_format_name: id
    description: "Id for the monday board. This will match what's in the url."
  }
  dimension: market_id {
    value_format_name: id
    description: "Unique ID used for a market."
  }
  dimension: phoenix_id {
    value_format_name: id
  }

  ################ DATES ################

  dimension_group: first_rental {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${first_rental} ;;
  }
  dimension_group: commencement {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${commencement} ;;
  }
  dimension_group: purchase {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${purchase} ;;
  }
  dimension_group: created {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${created} ;;
  }
  dimension_group: date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${date} ;;
  }
  dimension_group: snapshot {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${snapshot} ;;
  }

  ############### MEASURES ###############

  measure: sum_of_oec {
    type: sum
    sql: ${oec} ;;
  }
}
