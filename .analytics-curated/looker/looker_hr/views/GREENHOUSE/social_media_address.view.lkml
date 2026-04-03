view: social_media_address {
  sql_table_name: "GREENHOUSE"."SOCIAL_MEDIA_ADDRESS"
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

  dimension: candidate_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."CANDIDATE_ID" ;;
  }

  dimension: index {
    type: number
    sql: ${TABLE}."INDEX" ;;
  }

  dimension: value {
    type: string
    sql: ${TABLE}."VALUE" ;;
  }

  measure: count {
    type: count
    drill_fields: [candidate.first_name, candidate.last_name, candidate.id]
  }
}
