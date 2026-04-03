view: job_changes {
  derived_table: {sql:
    WITH gp AS (
    SELECT employee_id,
    LAST_VALUE(first_name) OVER (PARTITION BY employee_id ORDER BY _es_update_timestamp) AS first_name,
    LAST_VALUE(last_name) OVER (PARTITION BY employee_id ORDER BY _es_update_timestamp)  AS last_name,
    employee_title,
    market_id,
    location,
    _es_update_timestamp                                           AS effective_date,
    RANK() OVER (PARTITION BY employee_id, employee_title ORDER BY _es_update_timestamp) AS change_num
    FROM analytics.payroll.company_directory_vault cd_v
    WHERE employee_title IS NOT NULL
    QUALIFY change_num = 1)
    SELECT employee_id,
    first_name,
    market_id,
    location,
    last_name,
    effective_date,
    employee_title                                                                       AS current_title,
    LEAD(employee_title, 1) OVER (PARTITION BY employee_id ORDER BY effective_date DESC) AS previous_title
    FROM gp
    WHERE employee_title IS NOT NULL
    ORDER BY effective_date
    ;;}

  dimension: primary_key {
    primary_key: yes
    type: number
    sql: concat(${TABLE}."EMPLOYEE_ID", ${TABLE}."CURRENT_TITLE", ${TABLE}."PREVIOUS_TITLE", ${TABLE}."EFFECTIVE_DATE") ;;
  }

  dimension: employee_id {
    type: number
    sql: ${TABLE}."EMPLOYEE_ID" ;;
    value_format_name: id
  }

  dimension: current_title {
    type: string
    sql: ${TABLE}."CURRENT_TITLE" ;;
  }

  dimension_group: effective_date {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: cast(${TABLE}."EFFECTIVE_DATE" AS TIMESTAMP_NTZ) ;;

  }

  dimension: last_12_month_job_changes {
    type: yesno
    sql: ${effective_date_date} >= dateadd('second',1,(dateadd('month',-12,(dateadd('second',-1,date_trunc('month',current_date))))))
      and ${effective_date_date} <= dateadd('second',-1,date_trunc('month',current_date));;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
    value_format_name: id
  }

  dimension: location {
    type: string
    sql: ${TABLE}."LOCATION" ;;
  }

  dimension: first_name {
    type: string
    sql: ${TABLE}."FIRST_NAME" ;;
  }

  dimension: last_name {
    type: string
    sql: ${TABLE}."LAST_NAME" ;;
  }

  dimension: prior_title {
    type: string
    sql: ${TABLE}."PREVIOUS_TITLE" ;;
  }

  dimension: key_ops_jobs_previous{
    type: string
    sql: CASE WHEN CONTAINS(${TABLE}."PREVIOUS_TITLE", 'General Manager') AND NOT CONTAINS(${TABLE}."PREVIOUS_TITLE", 'Assistant General Manager') THEN 'General Managers'
          WHEN CONTAINS(${TABLE}."PREVIOUS_TITLE", 'Assistant General Manager') THEN 'Assistant General Managers'
          WHEN (CONTAINS(${TABLE}."PREVIOUS_TITLE", 'CDL') AND CONTAINS(${TABLE}."PREVIOUS_TITLE", 'Driver') AND NOT CONTAINS(${TABLE}."PREVIOUS_TITLE", 'non-CDL') AND NOT CONTAINS(${TABLE}."PREVIOUS_TITLE", 'Non-CDL')) THEN 'Drivers (CDL)'
          WHEN CONTAINS(${TABLE}."PREVIOUS_TITLE", 'Driver') THEN 'Drivers'
          WHEN CONTAINS(${TABLE}."PREVIOUS_TITLE", 'Field Technician') THEN 'Field Technicians'
          WHEN CONTAINS(${TABLE}."PREVIOUS_TITLE", 'Shop Technician') THEN 'Shop Technicians'
          WHEN CONTAINS(${TABLE}."PREVIOUS_TITLE", 'Yard Technician') THEN 'Yard Technician'
          WHEN CONTAINS(${TABLE}."PREVIOUS_TITLE", 'Rental Coordinator') THEN 'Rental Coordinators'
          WHEN CONTAINS(${TABLE}."PREVIOUS_TITLE", 'Service Manager') THEN 'Service Managers'
          WHEN CONTAINS(${TABLE}."PREVIOUS_TITLE", 'Parts Assistant') THEN 'Parts Assistants'
          WHEN CONTAINS(${TABLE}."PREVIOUS_TITLE", 'Parts Manager') THEN 'Parts Managers'
          WHEN CONTAINS(${TABLE}."PREVIOUS_TITLE", 'Dispatcher') THEN 'Dispatchers'
          WHEN CONTAINS(${TABLE}."PREVIOUS_TITLE", 'Regional Manager') THEN 'Regional Managers'
          WHEN CONTAINS(${TABLE}."PREVIOUS_TITLE", 'District Manager') THEN 'District Managers'
          WHEN CONTAINS(${TABLE}."PREVIOUS_TITLE", 'Territory Account Manager') THEN 'Territory Account Managers'
          WHEN CONTAINS(${TABLE}."PREVIOUS_TITLE", 'Telematics Installer') THEN 'Telematics Installers'
          ELSE 'Other' END ;;
  }

  dimension: key_ops_jobs_current{
    type: string
    sql: CASE WHEN CONTAINS(${TABLE}."CURRENT_TITLE", 'General Manager') AND NOT CONTAINS(${TABLE}."CURRENT_TITLE", 'Assistant General Manager') THEN 'General Managers'
          WHEN CONTAINS(${TABLE}."CURRENT_TITLE", 'Assistant General Manager') THEN 'Assistant General Managers'
          WHEN (CONTAINS(${TABLE}."CURRENT_TITLE", 'CDL') AND CONTAINS(${TABLE}."CURRENT_TITLE", 'Driver') AND NOT CONTAINS(${TABLE}."CURRENT_TITLE", 'non-CDL') AND NOT CONTAINS(${TABLE}."CURRENT_TITLE", 'Non-CDL')) THEN 'Drivers (CDL)'
          WHEN CONTAINS(${TABLE}."CURRENT_TITLE", 'Driver') THEN 'Drivers'
          WHEN CONTAINS(${TABLE}."CURRENT_TITLE", 'Field Technician') THEN 'Field Technicians'
          WHEN CONTAINS(${TABLE}."CURRENT_TITLE", 'Shop Technician') THEN 'Shop Technicians'
          WHEN CONTAINS(${TABLE}."CURRENT_TITLE", 'Yard Technician') THEN 'Yard Technician'
          WHEN CONTAINS(${TABLE}."CURRENT_TITLE", 'Rental Coordinator') THEN 'Rental Coordinators'
          WHEN CONTAINS(${TABLE}."CURRENT_TITLE", 'Service Manager') THEN 'Service Managers'
          WHEN CONTAINS(${TABLE}."CURRENT_TITLE", 'Parts Assistant') THEN 'Parts Assistants'
          WHEN CONTAINS(${TABLE}."CURRENT_TITLE", 'Parts Manager') THEN 'Parts Managers'
          WHEN CONTAINS(${TABLE}."CURRENT_TITLE", 'Dispatcher') THEN 'Dispatchers'
          WHEN CONTAINS(${TABLE}."CURRENT_TITLE", 'Regional Manager') THEN 'Regional Managers'
          WHEN CONTAINS(${TABLE}."CURRENT_TITLE", 'District Manager') THEN 'District Managers'
          WHEN CONTAINS(${TABLE}."CURRENT_TITLE", 'Territory Account Manager') THEN 'Territory Account Managers'
          WHEN CONTAINS(${TABLE}."CURRENT_TITLE", 'Telematics Installer') THEN 'Telematics Installers'
          ELSE 'Other' END ;;
  }

  measure: promotion_rate {
    type: number
    sql: ${total_count}/nullifzero(${ee_company_directory_12_month.headcount}) ;;
    value_format_name: percent_1
  }

  measure: total_count {
    type: count
    #sql: ${employee_id} ;;
    drill_fields: [effective_date_date,employee_id,first_name, last_name, current_title, prior_title]
  }

  measure: promotions_with_rate {
    type: count
    drill_fields: [effective_date_date,employee_id,first_name, last_name, current_title, prior_title]
    html: Promotion Count - {{rendered_value}} || Promotion Rate - {{promotion_rate._rendered_value}};;
  }

  measure: total_monthly_drill {
    type: count
    drill_fields: [effective_date_month, promotions_with_rate]
    link: {
      label: "View Promotions by Month"
      url: "
      {% assign vis_config = '{
          \"x_axis_gridlines\":false,
          \"y_axis_gridlines\":true,
          \"show_view_names\":false,
          \"show_y_axis_labels\":true,
          \"show_y_axis_ticks\":true,
          \"y_axis_tick_density\":\"default\",
          \"y_axis_tick_density_custom\":5,
          \"show_x_axis_label\":true,
          \"show_x_axis_ticks\":true,
          \"y_axis_scale_mode\":\"linear\",
          \"x_axis_reversed\":false,
          \"y_axis_reversed\":false,
          \"plot_size_by_field\":false,
          \"trellis\":\"\",
          \"stacking\":\"\",
          \"limit_displayed_rows\":false,
          \"legend_position\":\"center\",
          \"point_style\":\"none\",
          \"show_value_labels\":true,
          \"label_density\":25,
          \"x_axis_scale\":\"auto\",
          \"y_axis_combined\":true,
          \"ordering\":\"none\",
          \"show_null_labels\":false,
          \"show_totals_labels\":false,
          \"show_silhouette\":false,
          \"totals_color\":\"#808080\",
          \"y_axes\":[{\"label\":\"Total Job Changes\",
            \"orientation\":\"left\",
            \"series\":[{\"axisId\":\"job_changes.promotion_with_rate\",
              \"id\":\"job_changes.promotion_with_rate\",
              \"name\":\"Total Count\"}],
          \"showLabels\":true,\"showValues\":true,
          \"unpinAxis\":false,\"tickDensity\":\"default\",
          \"tickDensityCustom\":5,\"type\":\"linear\"}],
      \"x_axis_label\":\"Month\",
      \"x_axis_zoom\":true,
      \"y_axis_zoom\":true,
      \"series_types\":{},
      \"series_colors\":{\"job_changes.promotion_with_rate\":\"#004d99\"},
      \"type\":\"looker_column\",
      \"show_null_points\":true,
      \"interpolation\":\"linear\",
      \"defaults_version\":1
      }' %}
    {{ link }}&vis_config={{ vis_config | encode_uri }}&toggle=dat,pik,vis&limit=5000"
  }
}

  set: detail {
    fields: [employee_id, first_name, last_name, current_title, prior_title,key_ops_jobs_previous, key_ops_jobs_current, effective_date_date, effective_date_week, location, market_id, total_count]
  }

}
