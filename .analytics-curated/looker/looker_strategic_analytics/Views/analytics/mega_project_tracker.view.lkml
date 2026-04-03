view: mega_project_tracker {
    sql_table_name: analytics.mega_projects.mega_project_tracker_gs;;


    measure: count {
      type: count
      drill_fields: [detail*]
    }

    dimension: project_id {
      type: string
      sql: ${TABLE}."PROJECT_ID" ;;
    }

    dimension: project_name {
      type: string
      sql: ${TABLE}."PROJECT_NAME" ;;
    }

    dimension: address {
      type: string
      sql: ${TABLE}."ADDRESS" ;;
    }

    dimension: status {
      type: string
      sql: ${TABLE}."STATUS" ;;
    }

    dimension: start_date {
      type: date
      sql: ${TABLE}."START_DATE" ;;
    }

    dimension: project_type {
      type: string
      sql: ${TABLE}."PROJECT_TYPE" ;;
    }

    dimension: onsite_type {
      type: string
      sql: ${TABLE}."ONSITE_TYPE" ;;
    }

    dimension: location {
      type: string
      sql: ${TABLE}."LOCATION" ;;
    }

    set: detail {
      fields: [
        project_id,
        project_name,
        address,
        status,
        start_date,
        project_type,
        onsite_type,
        location
      ]
    }
  }
