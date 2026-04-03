view: dim_sub_renters {
  sql_table_name: "PLATFORM"."GOLD"."V_SUB_RENTERS" ;;

  # PRIMARY KEY
  dimension: sub_renter_key {
    primary_key: yes
    type: string
    sql: ${TABLE}."SUB_RENTER_KEY" ;;
    description: "Surrogate key for sub-renters dimension"
    hidden: yes
  }

  # NATURAL KEY
  dimension: sub_renter_id {
    type: number
    sql: ${TABLE}."SUB_RENTER_ID" ;;
    description: "Sub-renter ID (natural key)"
    value_format_name: id
  }

  # SUB-RENTER COMPANY INFORMATION
  dimension: sub_renter_company_id {
    type: number
    sql: ${TABLE}."SUB_RENTER_COMPANY_ID" ;;
    description: "Company ID of the sub-renter"
    value_format_name: id
  }

  dimension: sub_renter_company_name {
    type: string
    sql: ${TABLE}."SUB_RENTER_COMPANY_NAME" ;;
    description: "Company name of the sub-renter (sub-contractor)"
    label: "Sub-Renter Company"
  }

  # SUB-RENTER CONTACT INFORMATION
  dimension: sub_renter_ordered_by_id {
    type: number
    sql: ${TABLE}."SUB_RENTER_ORDERED_BY_ID" ;;
    description: "User ID who placed the order on behalf of sub-renter"
    value_format_name: id
  }

  dimension: sub_renter_ordered_by_name {
    type: string
    sql: ${TABLE}."SUB_RENTER_ORDERED_BY_NAME" ;;
    description: "Name of the person who ordered on behalf of sub-renter"
    label: "Sub-Renter Contact"
  }

  # SOURCE TRACKING
  dimension: sub_renter_source {
    type: string
    sql: ${TABLE}."SUB_RENTER_SOURCE" ;;
    description: "Source system for sub-renter record"
    hidden: yes
  }

  # AGGREGATED MEASURES
  measure: count {
    type: count
    description: "Number of sub-renters"
    drill_fields: [sub_renter_id, sub_renter_company_name, sub_renter_ordered_by_name]
  }

  measure: count_distinct_sub_renters {
    type: count_distinct
    sql: ${sub_renter_id} ;;
    description: "Number of distinct sub-renters"
  }

  measure: count_distinct_sub_renter_companies {
    type: count_distinct
    sql: ${sub_renter_company_id} ;;
    description: "Number of distinct sub-renter companies"
  }
}
