view: market_region_salesperson {
  sql_table_name: "ANALYTICS"."PUBLIC"."MARKET_REGION_SALESPERSON"
    ;;

  dimension: amount {
    type: number
    sql: ${TABLE}."AMOUNT" ;;
  }

  dimension: district {
    type: number
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: first_name {
    type: string
    sql: ${TABLE}."FIRST_NAME" ;;
  }

  dimension: last_name {
    type: string
    sql: ${TABLE}."LAST_NAME" ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: region {
    type: number
    sql: ${TABLE}."REGION" ;;
  }

  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension: salesperson_user_id {
    type: number
    sql: ${TABLE}."SALESPERSON_USER_ID" ;;
  }

  dimension: primary_key {
    primary_key: yes
    type: string
    sql: CONCAT(${TABLE}.salesperson_user_id,${TABLE}.market_id) ;;
  }

  dimension: Full_Name_with_ID{
    type:  string
    sql: concat(${first_name},' ',${last_name},' - ',${salesperson_user_id}) ;;
  }

  dimension: Salesperson_District_Region_Market_Access {
    type: yesno
    sql:
    ${market_region_salesperson.district} in ({{ _user_attributes['district'] }}) OR ${market_region_salesperson.region_name} in ({{ _user_attributes['region'] }}) OR ${market_region_salesperson.market_id} in ({{ _user_attributes['market_id'] }}) ;;
    }

  measure: count {
    type: count
    drill_fields: [region_name, last_name, first_name]
  }
}
