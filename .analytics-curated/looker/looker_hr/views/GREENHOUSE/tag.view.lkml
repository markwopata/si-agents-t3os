view: tag {
  sql_table_name: "GREENHOUSE"."TAG"
    ;;
  drill_fields: [id]

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ID"::INT ;;
  }

  dimension: _fivetran_deleted {
    type: yesno
    sql: ${TABLE}."_FIVETRAN_DELETED" ;;
  }

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

  dimension: tag {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension: sales_experience {
    type: string
    sql: CASE WHEN ${id}='910917' THEN 'Yes' ELSE 'No' END ;;
  }

  dimension: sales_experience_tag {
    type: string
    sql: CASE WHEN ${markets.name} = 'Corporate' THEN 'Corporate' ELSE ${sales_experience} END ;;
  }

  dimension: rental_experience {
    type: string
    sql: CASE WHEN ${id}='910924' THEN 'Yes' ELSE 'No' END ;;
  }

  dimension: rental_experience_tag {
    type: string
    sql: CASE WHEN ${markets.name} = 'Corporate' THEN 'Corporate' ELSE ${rental_experience} END ;;
  }

  measure: count {
    type: count
    drill_fields: [id, tag, candidate_tag.count]
  }
}
