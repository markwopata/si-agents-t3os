view: rateachievement_bookrate {
  sql_table_name: "PUBLIC"."RATEACHIEVEMENT_BOOKRATE"
    ;;

  dimension: day_book {
    type: number
    sql: ${TABLE}."DAY_BOOK" ;;
  }

  dimension: divison {
    type: string
    sql: ${TABLE}."DIVISON" ;;
  }

  dimension: equipment_category {
    type: string
    sql: ${TABLE}."EQUIPMENT_CATEGORY" ;;
  }

  dimension: equipment_class {
    type: string
    sql: ${TABLE}."EQUIPMENT_CLASS" ;;
  }

  dimension: equipment_class_id {
    type: string
    sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }

  dimension: month_book {
    type: number
    sql: coalesce(${TABLE}."MONTH_BOOK",0) ;;
  }

  dimension: region {
    type: string
    sql: ${TABLE}."REGION" ;;
  }

  dimension: region_index {
    type: number
    sql: ${TABLE}."REGION_INDEX" ;;
  }

  dimension: week_book {
    type: number
    sql: ${TABLE}."WEEK_BOOK" ;;
  }

  dimension: year_quarter {
    type: string
    sql: ${TABLE}."YEAR_QUARTER" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }

  dimension: create_rental_quote {
    html: <font color="blue "><u><a href = "https://docs.google.com/spreadsheets/u/0/?ftv=1&folder=0ADbXhLKRJ-iEUk9PVA&tgif=d" target="_blank">Create Rental Quote</a></font></u> ;;
    sql: ${equipment_class_id}
      ;;
  }
}
