view: equipment_classes {
    sql_table_name: "ES_WAREHOUSE"."PUBLIC"."EQUIPMENT_CLASSES"
      ;;


    dimension: equipment_class_id{
      primary_key: yes
      type: number
      sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
    }

    dimension: deleted {
      type: yesno
      sql: ${TABLE}."DELETED" ;;
    }

    dimension: name {
      type: string
      sql: ${TABLE}."NAME" ;;
    }

    dimension_group: _es_update_timestamp {
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
      sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
    }
 }
