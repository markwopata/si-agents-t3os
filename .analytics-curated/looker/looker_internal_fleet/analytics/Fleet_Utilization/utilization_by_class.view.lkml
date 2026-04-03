view: utilization_by_class {
  derived_table: {
    sql: select * from analytics.bi_ops.class_and_sub_cat_utilization_benchmarking ;;
  }

    measure: count {
      type: count
      drill_fields: [detail*]
    }

    dimension: run_date {
      type: date
      sql: ${TABLE}."RUN_DATE" ;;
    }

    dimension_group: run_date_group {
      type: time
      sql: ${TABLE}."RUN_DATE" ;;
    }

    dimension: asset_id {
      type: string
      sql: ${TABLE}."ASSET_ID" ;;
    }

    dimension: custom_name {
      type: string
      sql: ${TABLE}."CUSTOM_NAME" ;;
    }

    dimension: on_time {
      type: number
      sql: ${TABLE}."ON_TIME" ;;
    }

    measure: on_time_sum {
      label: "On Time Seconds"
      group_label: "Individual Assets"
      type: sum
      sql: ${on_time} ;;
    }

    measure: on_time_sum_hours {
      label: "On Time (Hours)"
      group_label: "Individual Assets"
      type: sum
      sql: ${on_time} / 60 / 60;;
    }

    dimension: idle_time {
      type: number
      sql: ${TABLE}."IDLE_TIME" ;;
    }

  measure: idle_time_sum {
    label: "Idle Time Seconds"
    group_label: "Individual Assets"
    type: sum
    sql: ${idle_time} ;;
  }

  measure: idle_time_sum_hours {
    label: "Idle Time (Hours)"
    group_label: "Individual Assets"
    type: sum
    sql: ${idle_time} / 60 / 60;;
  }

    dimension: run_time {
      type: number
      sql: ${TABLE}."RUN_TIME" ;;
    }

  measure: run_time_sum {
    label: "Run Time Seconds"
    group_label: "Individual Assets"
    type: sum
    sql: ${run_time} ;;
  }

  measure: run_time_sum_hours {
    label: "Run Time (Hours)"
    group_label: "Individual Assets"
    type: sum
    sql: ${run_time} / 60 / 60;;
  }

  dimension: potential_utilization {
    type: number
    sql: ${TABLE}."POTENTIAL_UTILIZATION" ;;
  }

  measure: potential_utilization_sum {
    label: "Potential Utilization Seconds"
    group_label: "Individual Assets"
    type: sum
    sql: ${potential_utilization} ;;
  }

  measure: potential_utilization_sum_hours {
    label: "Potential Utilization Time (Hours)"
    group_label: "Individual Assets"
    type: sum
    sql: ${potential_utilization} / 60 / 60;;
  }

  measure: utilization_percent {
    label: "Utilization Percent"
    group_label: "Individual Assets"
    type: number
    sql: div0null(${run_time_sum}, ${potential_utilization_sum} ) ;;
  }

  dimension: individual_run_time_past_7 {
    type: number
    sql: ${TABLE}."INDIVIDUAL_RUN_TIME_PAST_7" ;;
  }

  measure: individual_run_time_sum_hours_past_7 {
    label: "Individual Run Time Past 7 (Hours)"
    group_label: "Individual Assets"
    type: sum
    sql: ${individual_run_time_past_7} / 60 / 60;;
  }

  dimension: individual_run_time_past_30 {
    type: number
    sql: ${TABLE}."INDIVIDUAL_RUN_TIME_PAST_30" ;;
  }

  measure: individual_run_time_sum_hours_past_30 {
    label: "Individual Run Time Past 30 (Hours)"
    group_label: "Individual Assets"
    type: sum
    sql: ${individual_run_time_past_30} / 60 / 60;;
  }

  dimension: individual_run_time_past_60 {
    type: number
    sql: ${TABLE}."INDIVIDUAL_RUN_TIME_PAST_60" ;;
  }

  measure: individual_run_time_sum_hours_past_60 {
    label: "Individual Run Time Past 60 (Hours)"
    group_label: "Individual Assets"
    type: sum
    sql: ${individual_run_time_past_60} / 60 / 60;;
  }

  dimension: individual_run_time_past_90 {
    type: number
    sql: ${TABLE}."INDIVIDUAL_RUN_TIME_PAST_90" ;;
  }

  measure: individual_run_time_sum_hours_past_90 {
    label: "Individual Run Time Past 90 (Hours)"
    group_label: "Individual Assets"
    type: sum
    sql: ${individual_run_time_past_90} / 60 / 60;;
  }

  dimension: individual_potential_utilization_past_7 {
    type: number
    sql: ${TABLE}."INDIVIDUAL_POTENTIAL_UTILIZATION_PAST_7" ;;
  }

  measure: individual_potential_utilization_sum_hours_past_7 {
    label: "Individual Potential Utilization Past 7 (Hours)"
    group_label: "Individual Assets"
    type: sum
    sql: ${individual_potential_utilization_past_7} / 60 / 60;;
  }

  dimension: individual_potential_utilization_past_30 {
    type: number
    sql: ${TABLE}."INDIVIDUAL_POTENTIAL_UTILIZATION_PAST_30" ;;
  }

  measure: individual_potential_utilization_sum_hours_past_30 {
    label: "Individual Potential Utilization Past 30 (Hours)"
    group_label: "Individual Assets"
    type: sum
    sql: ${individual_potential_utilization_past_30} / 60 / 60;;
  }

  dimension: individual_potential_utilization_past_60 {
    type: number
    sql: ${TABLE}."INDIVIDUAL_POTENTIAL_UTILIZATION_PAST_60" ;;
  }

  measure: individual_potential_utilization_sum_hours_past_60 {
    label: "Individual Potential Utilization Past 60 (Hours)"
    group_label: "Individual Assets"
    type: sum
    sql: ${individual_potential_utilization_past_60} / 60 / 60;;
  }

  dimension: individual_potential_utilization_past_90 {
    type: number
    sql: ${TABLE}."INDIVIDUAL_POTENTIAL_UTILIZATION_PAST_90" ;;
  }

  measure: individual_potential_utilization_sum_hours_past_90 {
    label: "Individual Potential Utilization Past 90 (Hours)"
    group_label: "Individual Assets"
    type: sum
    sql: ${individual_potential_utilization_past_90} / 60 / 60;;
  }

  measure: individual_utilization_percent_7_day {
    label: "7 Day Utilization Percent"
    group_label: "Individual Assets"
    value_format_name: percent_2
    type: number
    sql: div0null(${individual_run_time_sum_hours_past_7}, ${individual_potential_utilization_sum_hours_past_7} ) ;;
  }

  measure: individual_utilization_percent_30_day {
    label: "30 Day Utilization Percent"
    group_label: "Individual Assets"
    value_format_name: percent_2
    type: number
    sql: div0null(${individual_run_time_sum_hours_past_30}, ${individual_potential_utilization_sum_hours_past_30} ) ;;
  }

  measure: individual_utilization_percent_60_day {
    label: "60 Day Utilization Percent"
    group_label: "Individual Assets"
    value_format_name: percent_2
    type: number
    sql: div0null(${individual_run_time_sum_hours_past_60}, ${individual_potential_utilization_sum_hours_past_60} ) ;;
  }

  measure: individual_utilization_percent_90_day {
    label: "90 Day Utilization Percent"
    group_label: "Individual Assets"
    value_format_name: percent_2
    type: number
    sql: div0null(${individual_run_time_sum_hours_past_90}, ${individual_potential_utilization_sum_hours_past_90} ) ;;
  }

    dimension: sub_cat_name {
      label: "Sub Category"
      type: string
      sql: ${TABLE}."SUB_CAT_NAME" ;;
    }

  dimension: tracker_type {
    label: "Tracker Type"
    type: string
    sql: ${TABLE}."TRACKER_TYPE" ;;
  }

    dimension: renting_company {
      type: string
      sql: ${TABLE}."RENTING_COMPANY" ;;
    }

  dimension: renting_company_id {
    type: string
    sql: ${TABLE}."RENTING_COMPANY_ID" ;;
  }

  dimension: owning_company {
    type: string
    sql: ${TABLE}."OWNING_COMPANY" ;;
  }

  dimension: owning_company_id {
    type: string
    sql: ${TABLE}."OWNING_COMPANY_ID" ;;
  }

    dimension: class_run_date {
      type: date
      sql: ${TABLE}."CLASS_RUN_DATE" ;;
    }

    dimension: sub_category_name {
      type: string
      sql: ${TABLE}."SUB_CATEGORY_NAME" ;;
    }

    dimension: sub_category_distinct_assets {
      type: number
      sql: ${TABLE}."SUB_CATEGORY_DISTINCT_ASSETS" ;;
    }

    dimension: sub_category_on_time {
      type: number
      sql: ${TABLE}."SUB_CATEGORY_ON_TIME" ;;
    }

    dimension: sub_category_idle_time {
      type: number
      sql: ${TABLE}."SUB_CATEGORY_IDLE_TIME" ;;
    }

    dimension: sub_category_run_time {
      type: number
      sql: ${TABLE}."SUB_CATEGORY_RUN_TIME" ;;
    }

    dimension: sub_category_potential_utilization {
      type: number
      sql: ${TABLE}."SUB_CATEGORY_POTENTIAL_UTILIZATION" ;;
    }

    dimension: past_7_day_flag {
      type: number
      sql: ${TABLE}."PAST_7_DAY_FLAG" ;;
    }

    dimension: past_30_day_flag {
      type: number
      sql: ${TABLE}."PAST_30_DAY_FLAG" ;;
    }

    dimension: past_60_day_flag {
      type: number
      sql: ${TABLE}."PAST_60_DAY_FLAG" ;;
    }

    dimension: past_90_day_flag {
      type: number
      sql: ${TABLE}."PAST_90_DAY_FLAG" ;;
    }

    dimension: class_on_time_past_7 {
      type: number
      sql: ${TABLE}."CLASS_ON_TIME_PAST_7" ;;
    }

    dimension: class_on_time_past_30 {
      type: number
      sql: ${TABLE}."CLASS_ON_TIME_PAST_30" ;;
    }

    dimension: class_on_time_past_60 {
      type: number
      sql: ${TABLE}."CLASS_ON_TIME_PAST_60" ;;
    }

    dimension: class_on_time_past_90 {
      type: number
      sql: ${TABLE}."CLASS_ON_TIME_PAST_90" ;;
    }

    dimension: class_idle_time_past_7 {
      type: number
      sql: ${TABLE}."CLASS_IDLE_TIME_PAST_7" ;;
    }

    dimension: class_idle_time_past_30 {
      type: number
      sql: ${TABLE}."CLASS_IDLE_TIME_PAST_30" ;;
    }

    dimension: class_idle_time_past_60 {
      type: number
      sql: ${TABLE}."CLASS_IDLE_TIME_PAST_60" ;;
    }

    dimension: class_idle_time_past_90 {
      type: number
      sql: ${TABLE}."CLASS_IDLE_TIME_PAST_90" ;;
    }

    dimension: class_run_time_past_7 {
      type: number
      sql: ${TABLE}."CLASS_RUN_TIME_PAST_7" ;;
    }

  measure: class_run_time_past_7_sum_hours {
    label: "Class Run Time - Last 7 (Hours)"
    group_label: "Class Assets"
    type: sum
    sql: ${class_run_time_past_7} / 60 / 60;;
  }

    dimension: class_run_time_past_30 {
      type: number
      sql: ${TABLE}."CLASS_RUN_TIME_PAST_30" ;;
    }

  measure: class_run_time_past_30_sum_hours {
    label: "Class Run Time - Last 30 (Hours)"
    group_label: "Class Assets"
    type: sum
    sql: ${class_run_time_past_30} / 60 / 60;;
  }

    dimension: class_run_time_past_60 {
      type: number
      sql: ${TABLE}."CLASS_RUN_TIME_PAST_60" ;;
    }

  measure: class_run_time_past_60_sum_hours {
    label: "Class Run Time - Last 60 (Hours)"
    group_label: "Class Assets"
    type: sum
    sql: ${class_run_time_past_60} / 60 / 60;;
  }

    dimension: class_run_time_past_90 {
      type: number
      sql: ${TABLE}."CLASS_RUN_TIME_PAST_90" ;;
    }

  measure: class_run_time_past_90_sum_hours {
    label: "Class Run Time - Last 90 (Hours)"
    group_label: "Class Assets"
    type: sum
    sql: ${class_run_time_past_90} / 60 / 60;;
  }

    dimension: class_potential_utilization_past_7 {
      type: number
      sql: ${TABLE}."CLASS_POTENTIAL_UTILIZATION_PAST_7" ;;
    }

  measure: class_potential_utilization_past_7_sum_hours {
    label: "Class Potential Utilization - Last 7 (Hours)"
    group_label: "Class Assets"
    type: sum
    sql: ${class_potential_utilization_past_7} / 60 / 60;;
  }

    dimension: class_potential_utilization_past_30 {
      type: number
      sql: ${TABLE}."CLASS_POTENTIAL_UTILIZATION_PAST_30" ;;
    }

  measure: class_potential_utilization_past_30_sum_hours {
    label: "Class Potential Utilization - Last 30 (Hours)"
    group_label: "Class Assets"
    type: sum
    sql: ${class_potential_utilization_past_30} / 60 / 60;;
  }

    dimension: class_potential_utilization_past_60 {
      type: number
      sql: ${TABLE}."CLASS_POTENTIAL_UTILIZATION_PAST_60" ;;
    }

  measure: class_potential_utilization_past_60_sum_hours {
    label: "Class Potential Utilization - Last 60 (Hours)"
    group_label: "Class Assets"
    type: sum
    sql: ${class_potential_utilization_past_60} / 60 / 60;;
  }

    dimension: class_potential_utilization_past_90 {
      type: number
      sql: ${TABLE}."CLASS_POTENTIAL_UTILIZATION_PAST_90" ;;
    }

  measure: class_potential_utilization_past_90_sum_hours {
    label: "Class Potential Utilization - Last 90 (Hours)"
    group_label: "Class Assets"
    type: sum
    sql: ${class_potential_utilization_past_90} / 60 / 60;;
  }

  measure: utilization_percent_7_day {
    label: "7 Day Utilization Percent"
    group_label: "Class Assets"
    value_format_name: percent_2
    type: number
    sql: div0null(${class_run_time_past_7_sum_hours}, ${class_potential_utilization_past_7_sum_hours} ) ;;
  }

  measure: utilization_percent_30_day {
    label: "30 Day Utilization Percent"
    group_label: "Class Assets"
    value_format_name: percent_2
    type: number
    sql: div0null(${class_run_time_past_30_sum_hours}, ${class_potential_utilization_past_30_sum_hours} ) ;;
  }

  measure: utilization_percent_60_day {
    label: "60 Day Utilization Percent"
    group_label: "Class Assets"
    value_format_name: percent_2
    type: number
    sql: div0null(${class_run_time_past_60_sum_hours}, ${class_potential_utilization_past_60_sum_hours} ) ;;
  }

  measure: utilization_percent_90_day {
    label: "90 Day Utilization Percent"
    group_label: "Class Assets"
    value_format_name: percent_2
    type: number
    sql: div0null(${class_run_time_past_90_sum_hours}, ${class_potential_utilization_past_90_sum_hours} ) ;;
  }

   measure: utilization_compare_7_day {
    label: "7 Day Utilization Compare"
    group_label: "Comparisons"
    type: string
    sql: case
    when ${individual_utilization_percent_7_day} - ${utilization_percent_7_day}  > .1 then 'Over Utilized Compared to Sub Class'
    when ${individual_utilization_percent_7_day} - ${utilization_percent_7_day}  <= .1
    and ${individual_utilization_percent_7_day} - ${utilization_percent_7_day}  >= -.1
    then 'Similarly Utilized Compared to Sub Class'
    else 'Under Utilized Compared to Sub Class'
    end
    ;;
  }

  measure: utilization_compare_30_day {
    label: "30 Day Utilization Compare"
    group_label: "Comparisons"
    type: string
    sql: case
          when ${individual_utilization_percent_30_day} - ${utilization_percent_30_day}  > .1 then 'Over Utilized Compared to Sub Class'
          when ${individual_utilization_percent_30_day} - ${utilization_percent_30_day}  <= .1
          and ${individual_utilization_percent_30_day} - ${utilization_percent_30_day}  >= -.1
          then 'Similarly Utilized Compared to Sub Class'
          else 'Under Utilized Compared to Sub Class'
          end
          ;;
  }

  measure: utilization_compare_60_day {
    label: "60 Day Utilization Compare"
    group_label: "Comparisons"
    type: string
    sql: case
          when ${individual_utilization_percent_60_day} - ${utilization_percent_60_day}  > .1 then 'Over Utilized Compared to Sub Class'
          when ${individual_utilization_percent_60_day} - ${utilization_percent_60_day}  <= .1
          and ${individual_utilization_percent_60_day} - ${utilization_percent_60_day}  >= -.1
          then 'Similarly Utilized Compared to Sub Class'
          else 'Under Utilized Compared to Sub Class'
          end
          ;;
  }

  measure: utilization_compare_90_day {
    label: "90 Day Utilization Compare"
    group_label: "Comparisons"
    type: string
    sql: case
          when ${individual_utilization_percent_90_day} - ${utilization_percent_90_day}  > .1 then 'Over Utilized Compared to Sub Class'
          when ${individual_utilization_percent_90_day} - ${utilization_percent_90_day}  <= .1
          and ${individual_utilization_percent_90_day} - ${utilization_percent_90_day}  >= -.1
          then 'Similarly Utilized Compared to Sub Class'
          else 'Under Utilized Compared to Sub Class'
          end
          ;;
  }

    dimension: run_time_7_percent {
      type: number
      sql: ${TABLE}."RUN_TIME_7_PERCENT" ;;
    }

    dimension: run_time_30_percent {
      type: number
      sql: ${TABLE}."RUN_TIME_30_PERCENT" ;;
    }

    dimension: run_time_60_percent {
      type: number
      sql: ${TABLE}."RUN_TIME_60_PERCENT" ;;
    }

    dimension: run_time_90_percent {
      type: number
      sql: ${TABLE}."RUN_TIME_90_PERCENT" ;;
    }

dimension: sub_category_run_date {
  type: date
  sql: ${TABLE}."SUB_CATEGORY_RUN_DATE" ;;
}

dimension: sub_category_on_time_past_7 {
  type: number
  sql: ${TABLE}."SUB_CATEGORY_ON_TIME_PAST_7" ;;
}

dimension: sub_category_on_time_past_30 {
  type: number
  sql: ${TABLE}."SUB_CATEGORY_ON_TIME_PAST_30" ;;
}

dimension: sub_category_on_time_past_60 {
  type: number
  sql: ${TABLE}."SUB_CATEGORY_ON_TIME_PAST_60" ;;
}

dimension: sub_category_on_time_past_90 {
  type: number
  sql: ${TABLE}."SUB_CATEGORY_ON_TIME_PAST_90" ;;
}

dimension: sub_category_idle_time_past_7 {
  type: number
  sql: ${TABLE}."SUB_CATEGORY_IDLE_TIME_PAST_7" ;;
}

dimension: sub_category_idle_time_past_30 {
  type: number
  sql: ${TABLE}."SUB_CATEGORY_IDLE_TIME_PAST_30" ;;
}

dimension: sub_category_idle_time_past_60 {
  type: number
  sql: ${TABLE}."SUB_CATEGORY_IDLE_TIME_PAST_60" ;;
}

dimension: sub_category_idle_time_past_90 {
  type: number
  sql: ${TABLE}."SUB_CATEGORY_IDLE_TIME_PAST_90" ;;
}

dimension: sub_category_run_time_past_7 {
  type: number
  sql: ${TABLE}."SUB_CATEGORY_RUN_TIME_PAST_7" ;;
}

  measure: sub_category_run_time_past_7_sum_hours {
    label: "Sub Category Run Time - Last 7 (Hours)"
    group_label: "Sub Category Assets"
    type: sum
    sql: ${sub_category_run_time_past_7} / 60 / 60;;
  }

dimension: sub_category_run_time_past_30 {
  type: number
  sql: ${TABLE}."SUB_CATEGORY_RUN_TIME_PAST_30" ;;
}

  measure: sub_category_run_time_past_30_sum_hours {
    label: "Sub Category Run Time - Last 30 (Hours)"
    group_label: "Sub Category Assets"
    type: sum
    sql: ${sub_category_run_time_past_30} / 60 / 60;;
  }

dimension: sub_category_run_time_past_60 {
  type: number
  sql: ${TABLE}."SUB_CATEGORY_RUN_TIME_PAST_60" ;;
}

  measure: sub_category_run_time_past_60_sum_hours {
    label: "Sub Category Run Time - Last 60 (Hours)"
    group_label: "Sub Category Assets"
    type: sum
    sql: ${sub_category_run_time_past_60} / 60 / 60;;
  }

dimension: sub_category_run_time_past_90 {
  type: number
  sql: ${TABLE}."SUB_CATEGORY_RUN_TIME_PAST_90" ;;
}

  measure: sub_category_run_time_past_90_sum_hours {
    label: "Sub Category Run Time - Last 90 (Hours)"
    group_label: "Sub Category Assets"
    type: sum
    sql: ${sub_category_run_time_past_90} / 60 / 60;;
  }

dimension: sub_category_potential_utilization_past_7 {
  type: number
  sql: ${TABLE}."SUB_CATEGORY_POTENTIAL_UTILIZATION_PAST_7" ;;
}

  measure: sub_category_potential_utilization_past_7_sum_hours {
    label: "Sub Category Potential Utilization - Last 7 (Hours)"
    group_label: "Sub Category Assets"
    type: sum
    sql: ${sub_category_potential_utilization_past_7} / 60 / 60;;
  }

dimension: sub_category_potential_utilization_past_30 {
  type: number
  sql: ${TABLE}."SUB_CATEGORY_POTENTIAL_UTILIZATION_PAST_30" ;;
}

  measure: sub_category_potential_utilization_past_30_sum_hours {
    label: "Sub Category Potential Utilization - Last 30 (Hours)"
    group_label: "Sub Category Assets"
    type: sum
    sql: ${sub_category_potential_utilization_past_30} / 60 / 60;;
  }

dimension: sub_category_potential_utilization_past_60 {
  type: number
  sql: ${TABLE}."SUB_CATEGORY_POTENTIAL_UTILIZATION_PAST_60" ;;
}

  measure: sub_category_potential_utilization_past_60_sum_hours {
    label: "Sub Category Potential Utilization - Last 60 (Hours)"
    group_label: "Sub Category Assets"
    type: sum
    sql: ${sub_category_potential_utilization_past_60} / 60 / 60;;
  }

dimension: sub_category_potential_utilization_past_90 {
  type: number
  sql: ${TABLE}."SUB_CATEGORY_POTENTIAL_UTILIZATION_PAST_90" ;;
}

  measure: sub_category_potential_utilization_past_90_sum_hours {
    label: "Sub Category Potential Utilization - Last 90 (Hours)"
    group_label: "Sub Category Assets"
    type: sum
    sql: ${sub_category_potential_utilization_past_90} / 60 / 60;;
  }

  measure: sub_category_utilization_percent_7_day {
    label: "7 Day Utilization Percent"
    group_label: "Sub Category Assets"
    value_format_name: percent_2
    type: number
    sql: div0null(${sub_category_run_time_past_7_sum_hours}, ${sub_category_potential_utilization_past_7_sum_hours} ) ;;
  }

  measure: sub_category_utilization_percent_30_day {
    label: "30 Day Utilization Percent"
    group_label: "Sub Category Assets"
    value_format_name: percent_2
    type: number
    sql: div0null(${sub_category_run_time_past_30_sum_hours}, ${sub_category_potential_utilization_past_30_sum_hours} ) ;;
  }

  measure: sub_category_utilization_percent_60_day {
    label: "60 Day Utilization Percent"
    group_label: "Sub Category Assets"
    value_format_name: percent_2
    type: number
    sql: div0null(${sub_category_run_time_past_60_sum_hours}, ${sub_category_potential_utilization_past_60_sum_hours} ) ;;
  }

  measure: sub_category_utilization_percent_90_day {
    label: "90 Day Utilization Percent"
    group_label: "Sub Category Assets"
    value_format_name: percent_2
    type: number
    sql: div0null(${sub_category_run_time_past_90_sum_hours}, ${sub_category_potential_utilization_past_90_sum_hours} ) ;;
  }

dimension: asset_class {
  type: string
  sql: ${TABLE}."ASSET_CLASS" ;;
}

dimension: asset_class_distinct_assets {
  type: number
  sql: ${TABLE}."ASSET_CLASS_DISTINCT_ASSETS" ;;
}

dimension: asset_class_on_time {
  type: number
  sql: ${TABLE}."ASSET_CLASS_ON_TIME" ;;
}

dimension: asset_class_idle_time {
  type: number
  sql: ${TABLE}."ASSET_CLASS_IDLE_TIME" ;;
}

dimension: asset_class_run_time {
  type: number
  sql: ${TABLE}."ASSET_CLASS_RUN_TIME" ;;
}

dimension: asset_class_potential_utilization {
  type: number
  sql: ${TABLE}."ASSET_CLASS_POTENTIAL_UTILIZATION" ;;
}

dimension: class_past_7_day_flag {
  type: number
  sql: ${TABLE}."CLASS_PAST_7_DAY_FLAG" ;;
}

dimension: class_past_30_day_flag {
  type: number
  sql: ${TABLE}."CLASS_PAST_30_DAY_FLAG" ;;
}

dimension: class_past_60_day_flag {
  type: number
  sql: ${TABLE}."CLASS_PAST_60_DAY_FLAG" ;;
}

dimension: class_past_90_day_flag {
  type: number
  sql: ${TABLE}."CLASS_PAST_90_DAY_FLAG" ;;
}

set: detail {
  fields: [
    run_date,
    asset_id,
    custom_name,
    sub_cat_name,
    on_time,
    idle_time,
    run_time,
    potential_utilization,
    individual_run_time_past_7,
    individual_run_time_past_30,
    individual_run_time_past_60,
    individual_run_time_past_90,
    individual_potential_utilization_past_7,
    individual_potential_utilization_past_30,
    individual_potential_utilization_past_60,
    individual_potential_utilization_past_90,
    renting_company,
    owning_company,
    sub_category_run_date,
    sub_category_name,
    sub_category_distinct_assets,
    sub_category_on_time,
    sub_category_idle_time,
    sub_category_run_time,
    sub_category_potential_utilization,
    past_7_day_flag,
    past_30_day_flag,
    past_60_day_flag,
    past_90_day_flag,
    sub_category_on_time_past_7,
    sub_category_on_time_past_30,
    sub_category_on_time_past_60,
    sub_category_on_time_past_90,
    sub_category_idle_time_past_7,
    sub_category_idle_time_past_30,
    sub_category_idle_time_past_60,
    sub_category_idle_time_past_90,
    sub_category_run_time_past_7,
    sub_category_run_time_past_30,
    sub_category_run_time_past_60,
    sub_category_run_time_past_90,
    sub_category_potential_utilization_past_7,
    sub_category_potential_utilization_past_30,
    sub_category_potential_utilization_past_60,
    sub_category_potential_utilization_past_90,
    class_run_date,
    asset_class,
    asset_class_distinct_assets,
    asset_class_on_time,
    asset_class_idle_time,
    asset_class_run_time,
    asset_class_potential_utilization,
    class_past_7_day_flag,
    class_past_30_day_flag,
    class_past_60_day_flag,
    class_past_90_day_flag,
    class_on_time_past_7,
    class_on_time_past_30,
    class_on_time_past_60,
    class_on_time_past_90,
    class_idle_time_past_7,
    class_idle_time_past_30,
    class_idle_time_past_60,
    class_idle_time_past_90,
    class_run_time_past_7,
    class_run_time_past_30,
    class_run_time_past_60,
    class_run_time_past_90,
    class_potential_utilization_past_7,
    class_potential_utilization_past_30,
    class_potential_utilization_past_60,
    class_potential_utilization_past_90,
    run_time_7_percent,
    run_time_30_percent,
    run_time_60_percent,
    run_time_90_percent
  ]
}
}
