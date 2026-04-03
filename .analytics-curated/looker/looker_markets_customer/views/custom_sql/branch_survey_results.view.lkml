view: branch_survey_results {

  derived_table: {
    sql: select bsr.*, mrx.REGION_NAME
from ANALYTICS.PUBLIC.BRANCH_SURVEY_RESULTS bsr
left join
    ANALYTICS.PUBLIC.MARKET_REGION_XWALK mrx
on bsr.BRANCH_ID = mrx.MARKET_ID
      ;;
  }

  dimension: branch_name {
    type: string
    sql: ${TABLE}.branch_name ;;
  }
  dimension: branch_id {
    type: number
    sql: ${TABLE}.branch_id ;;
  }
  dimension: category {
    type: string
    sql: ${TABLE}.category ;;
  }
  dimension: class {
    type: string
    sql: ${TABLE}.class ;;
  }
  dimension: avg_oec {
    type: number
    sql: ${TABLE}.avg_oec ;;
  }
  dimension: current_branch_oec_by_class {
    type: number
    sql: ${TABLE}.current_branch_oec_by_class ;;
  }
  dimension: current_branch_count_by_class {
    type: number
    sql: ${TABLE}.current_branch_count_by_class ;;
  }
  dimension: adjust_unit_count {
    type: number
    sql: ${TABLE}.adjust_unit_count ;;
  }
  dimension: new_branch_count_by_class {
    type: number
    sql: ${TABLE}.new_branch_count_by_class ;;
  }
  dimension: new_branch_oec_by_class {
    type: number
    sql: ${TABLE}.new_branch_oec_by_class ;;
  }
  dimension: class_comments {
    type: string
    sql: ${TABLE}.additional_comments ;;
  }
  dimension: respondent_email {
    type: string
    sql: ${TABLE}.respondent_email ;;
  }
  dimension: survey_timestamp {
    type: date_time
    sql: ${TABLE}.insert_timestamp ;;
  }
  dimension: region_name {
    type: string
    sql: ${TABLE}.REGION_NAME ;;
  }
}
