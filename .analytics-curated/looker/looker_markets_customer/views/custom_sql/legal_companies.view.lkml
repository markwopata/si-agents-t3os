view: legal_companies {

    derived_table: {
      sql:  SELECT DISTINCT cp.company_id, PREFS:legal_audit as legal_audit
      FROM es_warehouse.public.billing_company_preferences cp
      join es_warehouse.public.companies c ON c.company_id = cp.company_id
      --WHERE PREFS:legal_audit = TRUE OR c.do_not_rent = TRUE
      ;;
    }

    measure: count {
      type: count
    }

    dimension: company_id {
      type: string
      sql: ${TABLE}."COMPANY_ID" ;;
    }

  dimension: legal_audit {
    type: yesno
    sql: ${TABLE}."LEGAL_AUDIT" ;;
  }

  }
