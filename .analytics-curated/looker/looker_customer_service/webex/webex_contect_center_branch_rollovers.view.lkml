view: webex_contect_center_branch_rollovers {
  sql_table_name: business_intelligence.webex.stg_webex_contact_center_calls ;;


    measure: count {
      type: count
      drill_fields: [detail*]
    }

    dimension: created_at {
      type: date
      sql: ${TABLE}."CREATED_AT" ;;
    }

    dimension: ended_at {
      type: date
      sql: ${TABLE}."ENDED_AT" ;;
    }

    dimension: termination_type {
      type: string
      sql: ${TABLE}."TERMINATION_TYPE" ;;
    }

    dimension: terminating_end {
      type: string
      sql: ${TABLE}."TERMINATING_END" ;;
    }

    dimension: matched_skill_name {
      type: string
      sql: ${TABLE}."MATCHED_SKILL_NAME" ;;
    }

    dimension: total_duration {
      type: number
      sql: ${TABLE}."TOTAL_DURATION" ;;
    }

    dimension: calls {
      type: number
      sql: ${TABLE}."CALLS" ;;
    }

    dimension: is_branch_call {
      type: yesno
      sql: ${TABLE}."IS_BRANCH_CALL" ;;
    }

    set: detail {
      fields: [
        created_at,
        ended_at,
        termination_type,
        terminating_end,
        matched_skill_name,
        total_duration,
        calls,
        is_branch_call
      ]
    }
  }
