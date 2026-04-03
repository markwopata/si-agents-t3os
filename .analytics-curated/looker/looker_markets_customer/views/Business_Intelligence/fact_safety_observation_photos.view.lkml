view: fact_safety_observation_photos {
  sql_table_name: "BUSINESS_INTELLIGENCE"."GOLD"."V_FACT_SAFETY_OBSERVATION_PHOTOS" ;;

  dimension: safety_observation_key {
    type:  string
    sql: ${TABLE}."SAFETY_OBSERVATION_KEY" ;;
    suggest_persist_for: "1 minute"
  }

  dimension: safety_observation_photo_key {
    type:  string
    hidden: yes
    sql: ${TABLE}."SAFETY_OBSERVATION_PHOTO_KEY" ;;
  }

  dimension: photo {
    type: string
    sql: ${TABLE}."PHOTO" ;;
    suggest_persist_for: "1 minute"
  }

  dimension_group: _created_recordtimestamp {
    type: time
    hidden: yes
    timeframes: [raw, time, date, week, month, year]
    sql: ${TABLE}."_CREATED_RECORDTIMESTAMP" ;;
  }

  dimension_group: _updated_recordtimestamp {
    type: time
    hidden: yes
    timeframes: [raw, time, date, week, month, year]
    sql: ${TABLE}."_UPDATED_RECORDTIMESTAMP" ;;
  }

}
