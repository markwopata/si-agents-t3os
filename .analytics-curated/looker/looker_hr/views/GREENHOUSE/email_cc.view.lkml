view: email_cc {
  sql_table_name: "GREENHOUSE"."EMAIL_CC"
    ;;

  dimension_group: _fivetran_synced {
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
    sql: CAST(${TABLE}."_FIVETRAN_SYNCED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: cc_email {
    type: string
    sql: ${TABLE}."CC_EMAIL" ;;
  }

  dimension: email_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."EMAIL_ID" ;;
  }

  measure: count {
    type: count
    drill_fields: [email.id]
  }
}
