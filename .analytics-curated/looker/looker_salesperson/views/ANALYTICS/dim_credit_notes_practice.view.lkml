view: dim_credit_notes_practice {

    sql_table_name: analytics.intacct_models.dim_credit_notes  ;;


    measure: count {
      type: count
      drill_fields: [detail*]
    }

    dimension: credit_note_id {
      type: string
      sql: ${TABLE}."CREDIT_NOTE_ID" ;;
    }

    measure: credit_note_id_count {
      type: count_distinct
      sql: ${credit_note_id} ;;
      drill_fields: [credit_note_detail*]
    }

    measure: credit_note_count {
      type: count_distinct
      sql: ${credit_note_id} ;;
    }

    dimension: company_id {
      type: string
      sql: ${TABLE}."COMPANY_ID" ;;
    }

    dimension: originating_invoice_id {
      type: string
      sql: ${TABLE}."ORIGINATING_INVOICE_ID" ;;
    }

    dimension: market_id {
      type: string
      sql: ${TABLE}."MARKET_ID" ;;
    }

    dimension: credit_note_type_id {
      type: string
      sql: ${TABLE}."CREDIT_NOTE_TYPE_ID" ;;
    }

    dimension: credit_note_status_id {
      type: string
      sql: ${TABLE}."CREDIT_NOTE_STATUS_ID" ;;
    }

    dimension: credit_note_status_name {
      type: string
      sql: ${TABLE}."CREDIT_NOTE_STATUS_NAME" ;;
    }

    dimension: url_credit_note_admin {
      type: string
      sql: ${TABLE}."URL_CREDIT_NOTE_ADMIN" ;;
    }

    dimension: invoice_number {
      type: string
      sql: ${TABLE}."INVOICE_NUMBER" ;;
    }

    dimension: credit_note_number {
      type: string
      sql: ${TABLE}."CREDIT_NOTE_NUMBER" ;;
    }

    dimension: created_by_user_id {
      type: string
      sql: ${TABLE}."CREATED_BY_USER_ID" ;;
    }

    dimension: created_by {
      type: string
      sql: ${TABLE}."CREATED_BY" ;;
    }

    dimension_group: date_created {
      type: time
      sql: ${TABLE}."DATE_CREATED" ;;
    }

    set: credit_note_detail {
      fields: [
        credit_note_id,
        date_created_date,
        company_id,
        created_by,
        invoice_number
      ]
    }

    set: detail {
      fields: [
        credit_note_id,
        company_id,
        originating_invoice_id,
        market_id,
        credit_note_type_id,
        created_by_user_id,
        credit_note_status_id,
        credit_note_status_name,
        url_credit_note_admin,
        invoice_number,
        credit_note_number,
        created_by,
        date_created_time
      ]
    }
  }
