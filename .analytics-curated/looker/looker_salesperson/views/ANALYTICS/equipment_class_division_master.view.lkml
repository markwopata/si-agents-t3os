# The name of this view in Looker is "Equipment Class Division Master"
view: equipment_class_division_master {
  # The sql_table_name parameter indicates the underlying database table
  # to be used for all fields in this view.
  sql_table_name: "PUBLIC"."EQUIPMENT_CLASS_DIVISION_MASTER"
    ;;
  # No primary key is defined for this view. In order to join this view in an Explore,
  # define primary_key: yes on a dimension that has no repeated values.

  # Here's what a typical dimension looks like in LookML.
  # A dimension is a groupable field that can be used to filter query results.
  # This dimension will be called "Day to Week Ratio" in Explore.

  dimension: day_to_week_ratio {
    type: string
    sql: ${TABLE}."DAY_TO_WEEK_RATIO" ;;
  }

  dimension: division {
    type: string
    sql: coalesce(${TABLE}."DIVISION",'No Division Assigned') ;;
  }

  dimension: equipment_class {
    type: string
    sql: ${TABLE}."EQUIPMENT_CLASS" ;;
  }

  dimension: equipment_class_id {
    type: number
    sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
  }

  dimension: month_benchmark {
    type: number
    sql: ${TABLE}."MONTH_BENCHMARK" ;;
    value_format_name: usd
  }

  # A measure is a field that uses a SQL aggregate function. Here are defined sum and average
  # measures for this dimension, but you can also add measures of many different aggregates.
  # Click on the type parameter to see all the options in the Quick Help panel on the right.

  measure: total_month_benchmark {
    type: sum
    sql: ${month_benchmark} ;;
  }

  measure: average_month_benchmark {
    type: average
    sql: ${month_benchmark} ;;
  }

  dimension: week_to_month_ratio {
    type: number
    sql: ${TABLE}."WEEK_TO_MONTH_RATIO" ;;
  }

  dimension: rate_autofill {
    type:  string
    #sql: concat('&entry.1054089447=',${equipment_classes.equipment_class_id},'&entry.1915296239=',${equipment_classes.name},'&entry.1417219038=',${month_benchmark},'&entry.797099518=',${day_to_week_ratio},'&entry.1523782879=',${week_to_month_ratio}) ;;
    sql: concat('&entry.1054089447=',${equipment_classes_active.equipment_class_id},'&entry.1915296239=',${equipment_classes_active.name},'&entry.1417219038=',coalesce(${month_benchmark},0),'&entry.797099518=',coalesce(${day_to_week_ratio},2.75),'&entry.1523782879=',coalesce(${week_to_month_ratio},2.25)) ;;

  }

  dimension: rate_submission_form {
    type:  string
    #html: <font color="blue "><u><a href = "https://docs.google.com/forms/d/e/1FAIpQLSfPXvXP4IQF6xD6QfVqHINuMYFrzw5P6Zosz-FKLmpc3NVC_g/viewform?usp=pp_url&entry.1025750783={{  _user_attributes['name'] }}&entry.988069412={{  _user_attributes['email'] }}&entry.1054089447={{ equipment_class_division_master.equipment_class_id._value }}&entry.1915296239={{ equipment_class_division_master.equipment_class._value }}&entry.1417219038={{ equipment_class_division_master.month_benchmark._value }}&entry.797099518={{ equipment_class_division_master.day_to_week_ratio._value }}&entry.1523782879={{ equipment_class_division_master.week_to_month_ratio._value }}"target="_blank">Submit Equipment Class Change</a></font></u> ;;
    html: <font color="blue "><u><a href = "https://docs.google.com/forms/d/e/1FAIpQLSfPXvXP4IQF6xD6QfVqHINuMYFrzw5P6Zosz-FKLmpc3NVC_g/viewform?usp=pp_url&entry.1025750783={{  _user_attributes['name'] }}{{equipment_class_division_master.rate_autofill._value}}"target="_blank">Submit Equipment Class Change</a></font></u> ;;
    sql: ${rate_autofill} ;;
  }

  dimension: missing_rate {
    type: yesno
    sql: ${month_benchmark} is null ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
