view: work_codes_xref {
    derived_table: {
      sql: select * from ES_WAREHOUSE.TIME_TRACKING.TIME_ENTRY_WORK_CODE_XREF ;;
    }

    measure: count {
      type: count
      drill_fields: [detail*]
    }

    dimension: time_entry_id {
      type: number
      sql: ${TABLE}."TIME_ENTRY_ID" ;;
    }

    dimension: work_code_id {
      type: number
      sql: ${TABLE}."WORK_CODE_ID" ;;
    }

    dimension_group: _es_update_timestamp {
      type: time
      sql: ${TABLE}."_ES_UPDATE_TIMESTAMP" ;;
    }

    set: detail {
      fields: [
        time_entry_id,
        work_code_id,
        _es_update_timestamp_time
      ]
    }
  }
