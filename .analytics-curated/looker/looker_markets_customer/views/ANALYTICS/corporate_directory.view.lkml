view: corporate_directory {
  sql_table_name: "MARKET_DATA"."CORPORATE_DIRECTORY"
    ;;

  dimension: contact {
    type: string
    sql: ${TABLE}."CONTACT" ;;
  }

  dimension: contact_type {
    type: string
    sql: case when ${TABLE}."CONTACT_TYPE" = 1 THEN 'Primary' ELSE 'Secondary' end;;
  }

  dimension: email {
    type: string
    sql: ${TABLE}."EMAIL" ;;
  }

  dimension: phone {
    type: string
    sql: ${TABLE}."PHONE" ;;
  }

  dimension: slack {
    type: string
    sql: ${TABLE}."SLACK" ;;
  }

  dimension: topic {
    type: string
    sql: ${TABLE}."TOPIC" ;;
  }

  dimension: category {
    type: string
    sql: ${TABLE}."CATEGORY" ;;
  }

  dimension: topic_cat {
    type: number
    sql: ${TABLE}."TOPIC_CAT" ;;
    hidden: yes
  }

  measure: topic_cat_measure {
    type: average
    sql: ${topic_cat} ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
