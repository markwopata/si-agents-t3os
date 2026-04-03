include: "/_base/people_analytics/docebo/certification.view.lkml"

view: +certification {

  ############### DIMENSIONS ###############
  dimension: id {
    value_format_name: id
    description: "Primary key for the dataset"
  }
  dimension: certification_id {
    value_format_name: id
    description: "ID associated with a specific certification"
  }
  dimension: user_id {
    value_format_name: id
    description: "ID associated with a specific user in Docebo"
  }
  dimension: awarded_from_id {
    value_format_name: id
    description: "ID associated with the course that gave the certification"
  }
  dimension: created_by_id {
    value_format_name: id
    description: "ID associated with the person in Docebo that created the certification for the user"
  }
  dimension: updated_by_id {
    value_format_name: id
    description: "ID associated with the person in Docebo that updated the certification for the user in the system"
  }

  ############### DATES ###############
  dimension_group: issued_at {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${issued_at};;
  }
  dimension_group: expiring_at {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${expiring_at} ;;
  }
  dimension_group: created_at {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${created_at} ;;
  }
  dimension_group: updated_at {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${updated_at} ;;
  }

  ############### MEASURES ###############
  measure: unique_certification_ids {
    type: count_distinct
    sql: ${certification_id} ;;
  }
  measure: unique_user_ids {
    type: count_distinct
    sql: ${user_id} ;;
  }
}
