view: vip_companies {
    derived_table: {
      sql: SELECT
              *
              FROM T3_ANALYTICS.VW_VIP_COMPANIES ;;
    }

    measure: count {
      type: count
      drill_fields: [detail*]
    }

    dimension: company_id {
      label: "Comapny ID"
      type: string
      sql: ${TABLE}."COMPANY_ID" ;;
      description: "A Company selected as a VIP customer at any time."
    }

    dimension: company_name {
      label: "Company Name"
      type: string
      sql: ${TABLE}."COMPANY_NAME" ;;
    }

    dimension: owner_user_id {
      label: "Company Owner User ID"
      type: string
      sql: ${TABLE}."OWNER_USER_ID" ;;
    }

    dimension: timezone {
      label: "Company Timezone"
      type: string
      sql: ${TABLE}."TIMEZONE" ;;
    }

    dimension: current_vip {
      label: "Current VIP (yes/no)"
      type: yesno
      sql: ${TABLE}."CURRENT_VIP" ;;
      description: "Is the company a current VIP"
    }

    set: detail {
      fields: [
        company_id,
        company_name,
        owner_user_id,
        timezone,
        current_vip
      ]
    }
  }
