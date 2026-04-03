view: service_efficiency {
  sql_table_name: "ANALYTICS"."SERVICE"."SERVICE_EFFICIENCY";;

  parameter: drop_down_selection_with_tech {
    type: string
    # allowed_value: {value: "Company"}
    allowed_value: {value: "Region"}
    allowed_value: {value: "District"}
    allowed_value: {value: "Market"}
    allowed_value: {value: "Technician"}
  }
  dimension: dynamic_location_with_tech {
    description: "Allows user to pick between Company, Region, District, and Market Axis."
    label_from_parameter: drop_down_selection_with_tech
    sql:
    {% if drop_down_selection_with_tech._parameter_value == "'Region'" %}
      ${region_name}
    {% elsif drop_down_selection_with_tech._parameter_value == "'District'" %}
      ${district}
    {% elsif drop_down_selection_with_tech._parameter_value == "'Market'" %}
      ${market_name}
    {% elsif drop_down_selection_with_tech._parameter_value == "'Technician'" %}
      case
            when ${employee_name} is null then 'Unassigned' else ${employee_name}
      end
    {% else %}
      NULL
    {% endif %} ;;
  }
  dimension: dynamic_location_with_prev_tech {
    description: "Allows user to pick between Company, Region, District, and Market Axis.  This field should only be used to get the previous tech on 7 day breakdown work orders."
    label_from_parameter: drop_down_selection_with_tech
    sql:
    {% if drop_down_selection_with_tech._parameter_value == "'Region'" %}
      ${region_name}
    {% elsif drop_down_selection_with_tech._parameter_value == "'District'" %}
      ${district}
    {% elsif drop_down_selection_with_tech._parameter_value == "'Market'" %}
      ${market_name}
    {% elsif drop_down_selection_with_tech._parameter_value == "'Technician'" %}
      case
        when ${7day_breakdowns.prev_tech_name} is null then 'Unassigned' else ${7day_breakdowns.prev_tech_name}
      end
    {% else %}
      NULL
    {% endif %} ;;
  }

  parameter: include_traveling_techs {
    label: "Include Traveling Techs"
    type: string
    allowed_value: {value: "Yes"}
    allowed_value: {value: "No"}
    default_value: "Yes"
  }
  dimension: include_traveling_techs_filter {
    group_label: "Technician Details"
    label_from_parameter: include_traveling_techs
    # type: string
    # hidden: yes
    sql:{% if include_traveling_techs._parameter_value == "'Yes'" %}
          'Yes'
        {% else %}
          case when ${tech_location} = 'Branch Tech' then 'Yes'
               when ${tech_location} = 'Traveling Tech' then 'No'
          end
        {% endif %}
     ;;
  }
  dimension: pkey {
    description: "Primary Key made of work_order_id and user_id"
    primary_key: yes
    type: number
    sql: ${TABLE}.PK ;;
  }

  # Work order details }
  dimension: work_order_id {
    group_label: "Work Order Information"
    type: number
    value_format_name: id
    sql: ${TABLE}.WORK_ORDER_ID ;;
  }
  dimension: description {
    group_label: "Work Order Information"
    type: string
    sql: ${TABLE}.DESCRIPTION ;;
  }
  dimension: asset_id{
    group_label: "Work Order Information"
    value_format_name: id
    type: number
    sql: ${TABLE}.ASSET_ID ;;
  }
  dimension: severity_level_name {
    group_label: "Work Order Information"
    type: string
    sql: ${TABLE}.SEVERITY_LEVEL_NAME ;;
  }
  dimension: work_order_type_name {
    group_label: "Work Order Information"
    type: string
    sql: ${TABLE}.WORK_ORDER_TYPE_NAME ;;
  }
  dimension: work_order_type_id {
    group_label: "Work Order Information"
    value_format_name: id
    type: number
    sql: ${TABLE}.WORK_ORDER_TYPE_ID ;;
  }
  dimension: wo_type_descrip {
    group_label: "Work Order Information"
    label: "Work Order Type Description"
    type: string
    sql: ${TABLE}.wo_type_descrip ;;
  }
  dimension: wo_type_origin {
    group_label: "Work Order Information"
    label: "Work Order Origin"
    type: string
    sql: ${TABLE}.wo_type_origin ;;
  }
  dimension: work_order_tasks_pass {
    group_label: "Work Order Information"
    type: number
    sql: ${TABLE}.pass ;;
  }
  dimension: days_to_complete {
    group_label: "Work Order Information"
    type: number
    sql: datediff(days, ${date_created_date}, coalesce(${date_completed_date}, current_date())) ;;
  }
  dimension_group: date_created {
    group_label: "Work Order Information"
    type: time
    timeframes: [date, week, month, quarter, year]
    sql: ${TABLE}.DATE_CREATED ;;
  }
  dimension_group: date_completed {
    group_label: "Work Order Information"
    type: time
    timeframes: [date, week, month, quarter, year]
    sql: ${TABLE}.DATE_COMPLETED ;;
  }
  dimension: region {
    group_label: "Work Order Information"
    description: "Region of the work order"
    type: string
    sql: ${TABLE}.WO_REGION ;;
  }
  dimension: region_name {
    group_label: "Work Order Information"
    description: "Region of the work order"
    type: string
    sql: ${TABLE}.WO_REGION_NAME ;;
  }
  dimension: district {
    group_label: "Work Order Information"
    description: "District of the work order"
    type: string
    sql: ${TABLE}.WO_DISTRICT ;;
  }
  dimension: branch_id {
    group_label: "Work Order Information"
    description: "Market of the work order"
    label: "Market ID"
    value_format_name: id
    type: number
    sql: ${TABLE}.WO_BRANCH_ID ;;
  }
  dimension: market_name {
    group_label: "Work Order Information"
    description: "Market of the work order"
    type: string
    sql: ${TABLE}.WO_MARKET_NAME ;;
  }

  # Technician Details
  dimension: user_id {
    group_label: "Technician Details"
    value_format_name: id
    type: number
    sql: ${TABLE}.USER_ID ;;
  }
  dimension: employee_id {
    group_label: "Technician Details"
    value_format_name: id
    type: number
    sql: ${TABLE}.EMPLOYEE_ID ;;
  }
  dimension: employee_name {
    description: "Employee is either assigned to work order or has a time entry."
    group_label: "Technician Details"
    type: string
    sql: case when ${TABLE}.wo_emp_branch_match = 'Traveling Tech' then concat(${TABLE}.EMPLOYEE_NAME,'*') else ${TABLE}.EMPLOYEE_NAME end ;;
  }
  dimension: emp_region {
    group_label: "Technician Details"
    description: "Region of the Technician"
    type: string
    sql: ${TABLE}.EMP_REGION ;;
  }
  dimension: emp_region_name {
    group_label: "Technician Details"
    description: "Region of the Technician"
    type: string
    sql: ${TABLE}.EMP_REGION_NAME ;;
  }
  dimension: emp_district {
    group_label: "Technician Details"
    description: "District of the Technician"
    type: string
    sql: ${TABLE}.EMP_DISTRICT ;;
  }
  dimension: emp_branch_id {
    group_label: "Technician Details"
    description: "Market of the Technician"
    label: "Market ID"
    value_format_name: id
    type: number
    sql: ${TABLE}.EMP_BRANCH_ID ;;
  }
  dimension: emp_market_name {
    group_label: "Technician Details"
    description: "Market of the Technician"
    type: string
    sql: ${TABLE}.EMP_MARKET_NAME ;;
  }
  # dimension: wo_emp_branch_match {
  #   hidden: yes
  #   type: string
  #   sql: ${TABLE}.WO_EMP_BRANCH_MATCH ;;
  # }
  dimension: tech_location {
    description: "Determines if the tech is a branch tech or a traveling tech.  Traveling techs are technicians with time on a work order other than their home branch."
    group_label: "Technician Details"
    label_from_parameter: drop_down_selection_with_tech
    # type: string
    sql: case when ${employee_name} is null then 'Unassigned' else ${TABLE}.wo_emp_branch_match end ;;
  }
  dimension: tech_position {
    group_label: "Technician Details"
    type: string
    # Before case here, this was grouping null employee_names as 'Non-Tech' leading to errors in the calulations for tech type counts on service efficiency dashboard.
    sql: case when ${employee_name} is null then null else ${TABLE}.tech_position end ;;
    description: "Uses the technicians title to group them into Shop Tech, Field Tech, Telematics Tech or General Tech buckets."
  }

  # Hours & billing
  dimension: emp_hours {
    group_label: "Hours and Billing"
    description: "Total hours of the employee (Regular + Overtime)"
    type: number
    value_format_name: decimal_2
    sql: ${TABLE}.EMP_HOURS ;;
  }
  dimension: expected_emp_hours {
    group_label: "Hours and Billing"
    description: "Hours expected for the work the work being performed.  General work orders are calculated by the avg component replacement time, inspection work orders are calculated by the avg time for tand inspection to be completed on the same make/model. "
    type: number
    value_format_name: decimal_2
    sql: ${TABLE}.EXPECTED_EMP_HOURS ;;
  }
  dimension: reg_hours {
    group_label: "Hours and Billing"
    label: "Regular hours"
    type: number
    value_format_name: decimal_2
    sql: ${TABLE}.REG_HOURS ;;
  }
  dimension: ot_hours {
    group_label: "Hours and Billing"
    label: "Overtime hours"
    type: number
    value_format_name: decimal_2
    sql: ${TABLE}.OT_HOURS ;;
  }
  dimension: billed_hours_share {
    group_label: "Hours and Billing"
    description: "Employees share of the total cost of billed hours on the work order."
    type: number
    value_format_name: decimal_2
    sql: ${TABLE}.BILLED_HOURS_SHARE ;;
  }
  dimension: wo_hours {
    group_label: "Hours and Billing"
    description: "Total hours on the work order from all employees"
    type: number
    value_format_name: decimal_2
    sql: ${TABLE}.WO_HOURS ;;
  }
  dimension: total_billed_hours {
    group_label: "Hours and Billing"
    description: "Total cost of billed work order hours."
    type: number
    value_format_name: decimal_2
    sql: ${TABLE}.TOTAL_BILLED_HOURS ;;
  }
  dimension: employees_on_wo {
    group_label: "Hours and Billing"
    description: "Number of employees that have time on the work order."
    type: number
    sql: zeroifnull(${TABLE}.EMPLOYEES_ON_WO) ;;
  }

  # Parts efficiency (from pe)
  dimension: pe_wo_id {
    group_label: "Parts Efficiency"
    type: number
    value_format_name: id
    sql: ${TABLE}.part_efficiency_wo_id ;; }
  dimension: unused_parts_percent {
    group_label: "Parts Efficiency"
    type: number
    # value_format: "0.##"
    sql: ${TABLE}.UNUSED_PARTS_PERCENT ;; }
  dimension_group: first_po_date {
    group_label: "Parts Efficiency"
    type: time
    timeframes: [date, week, month, quarter, year]
    sql: ${TABLE}.FIRST_PO_DATE ;; }
  dimension_group: last_po_date {
    group_label: "Parts Efficiency"
    type: time
    timeframes: [date, week, month, quarter, year]
    sql: ${TABLE}.LAST_PO_DATE ;; }
  dimension: order_count {
    group_label: "Parts Efficiency"
    type: number
    sql: ${TABLE}.ORDER_COUNT ;; }



  # ------------ Measures ------------
  measure: count {
    type: count
    drill_fields: [work_order_details*]
  }
  measure: count_assigned_wos {
    type: count
    link: { label: "Work Order Details" url: "{{work_order_details._link}}" }
  }
  measure: work_order_techs_list {
    label: "Assigned Techs"
    type: list
    list_field: employee_name
    # sql: select ${work_order_id}, LISTAGG(${employee_name}, ', ') WITHIN GROUP (ORDER BY ${employee_name}) FROM ANALYTICS.SERVICE.SERVICE_EFFICIENCY GROUP BY ${work_order_id} ;;
  }
  measure: distinct_work_orders {
    type: count_distinct
    sql: ${work_order_id} ;;
    drill_fields: [work_order_details*]
  }
  measure: work_order_closures {
    type: count_distinct
    sql: ${work_order_id};;
    link: { label: "Technician Details" url: "{{tech_details._link}}" }
    link: { label: "Work Order Details" url: "{{work_order_details._link}}" }
  }
  measure: distinct_employees {
    type: count_distinct sql: ${employee_id} ;;
    drill_fields: [tech_details*]
  }
  measure: count_total_technicians {
    type: count_distinct sql: ${employee_id} ;;
    drill_fields: [tech_details*]
    filters: [tech_position: "General Mechanic, Field Tech, Shop Tech, Telematics Tech, Yard Techs, Non-Technician"]
    label: "Total Techs - Excluding Non-Techs"
  }
  measure: count_total_technicians2 {
    type: count_distinct sql: ${employee_id} ;;
    drill_fields: [tech_details*]
    filters: [tech_position: "General Mechanic, Field Tech, Shop Tech, Telematics Tech, Yard Techs"]
    label: "Total Techs - Including Non-Techs"
  }
  measure: count_general_mechanic {
    type: count_distinct sql: ${employee_id} ;;
    drill_fields: [tech_details*]
    filters: [tech_position: "General Mechanic"]
    label: "General Mechanics"
    html: {{general_tech_percent._rendered_value}};;
  }
  measure: count_field_tech{
    type: count_distinct sql: ${employee_id} ;;
    drill_fields: [tech_details*]
    filters: [tech_position: "Field Tech"]
    label: "Field Techs"
    html: {{field_tech_percent._rendered_value}};;
  }
  measure: count_non_tech {
    type: count_distinct sql: ${employee_id} ;;
    drill_fields: [tech_details*]
    filters: [tech_position: "Non-Technician"]
    label: "Non-Techs"
    html: {{non_tech_percent._rendered_value}};;
  }
  measure: count_shop_tech {
    type: count_distinct sql: ${employee_id} ;;
    drill_fields: [tech_details*]
    filters: [tech_position: "Shop Tech"]
    label: "Shop Techs"
    html: {{shop_tech_percent._rendered_value}};;
  }
  measure: count_telematics_tech {
    type: count_distinct sql: ${employee_id} ;;
    drill_fields: [tech_details*]
    filters: [tech_position: "Telematics Tech"]
    label: "Telematics Techs"
    html: {{telematics_tech_percent._rendered_value}};;
  }
  measure: count_yard_tech {
    type: count_distinct sql: ${employee_id} ;;
    drill_fields: [tech_details*]
    filters: [tech_position: "Yard Tech"]
    label: "Yard Techs"
    html: {{yard_tech_percent._rendered_value}};;
  }
  measure: general_tech_percent {
    value_format_name: percent_2
    sql:${count_general_mechanic} / nullifzero(${count_total_technicians}) ;;
  }
  measure: field_tech_percent {
    value_format_name: percent_2
    sql:${count_field_tech} / nullifzero(${count_total_technicians}) ;;
  }
  measure: non_tech_percent {
    value_format_name: percent_2
    sql:${count_non_tech} / nullifzero(${count_total_technicians}) ;;
  }
  measure: shop_tech_percent {
    value_format_name: percent_2
    sql:${count_shop_tech} / nullifzero(${count_total_technicians}) ;;
  }
  measure: telematics_tech_percent {
    value_format_name: percent_2
    sql:${count_telematics_tech} / nullifzero(${count_total_technicians}) ;;
  }
  measure: yard_tech_percent {
    value_format_name: percent_2
    sql:${count_yard_tech} / nullifzero(${count_total_technicians}) ;;
  }
  measure: total_emp_hours {
    type: sum
    value_format_name: decimal_1
    sql: ${emp_hours} ;;
    drill_fields: [work_order_details*, emp_hours, expected_emp_hours]
  }
  measure: total_expected_emp_hours {
    type: sum
    value_format_name: decimal_1
    sql: ${expected_emp_hours};;
    drill_fields: [work_order_details*]
  }
  measure: total_wo_hours {
    type: sum
    value_format_name: decimal_1
    sql: ${wo_hours} ;;
    drill_fields: [work_order_details*]
  }
  measure: total_billed_hours_sum {
    type: sum
    value_format_name: decimal_1
    sql: ${total_billed_hours};;
    drill_fields: [work_order_details*]
  }
  measure: total_work_order_tasks{
    type: count
    drill_fields: [work_order_details*]
  }
  measure: total_passed_inspections {
    type: sum
    sql: ${work_order_tasks_pass};;
    filters: [work_order_tasks_pass: "1"]
    drill_fields: [work_order_details*]
  }
  measure: percent_tasks_passed {
    label: "% of Inspection Tasks Passed"
    type: number
    value_format_name: percent_2
    sql: ${total_passed_inspections} / ${total_work_order_tasks} ;;
    drill_fields: [work_order_details*]
  }
  measure: avg_unused_parts_percent {
    type: average value_format: "0.00\%"
    sql: ${unused_parts_percent};;
    link: { label: "Technician Details" url: "{{unused_parts_tech_details._link}}" }
    link: { label: "Work Order Details" url: "{{unused_parts_wo_details._link}}" }
  }
  measure: avg_emps_on_wo {
    type: average
    value_format_name: decimal_1
    sql: ${employees_on_wo} ;;
    drill_fields: [work_order_details*, employees_on_wo]
  }
  measure: avg_days_to_complete {
    type: average
    value_format_name: decimal_1
    sql: ${days_to_complete};;
    drill_fields: [work_order_details*,days_to_complete]
  }
  measure: avg_hours {
    type: number
    value_format_name: decimal_1
    sql: ${total_emp_hours} / ${distinct_work_orders} ;;
    drill_fields: [work_order_details*, total_emp_hours]
  }

  # Below are used to allow multiple drill options
  measure: tech_details               { drill_fields: [tech_details*] hidden: yes sql: 1=1 ;; }
  measure: work_order_details         { drill_fields: [work_order_details*] hidden: yes sql: 1=1 ;; }
  measure: unused_parts_tech_details  { drill_fields: [tech_details*,unused_parts_percent] hidden: yes sql: 1=1 ;; }
  measure: unused_parts_wo_details    { drill_fields: [work_order_details*,unused_parts_percent] hidden: yes sql: 1=1 ;; }

  measure: work_order_tech_list {
    type: string
    sql: LISTAGG(${employee_name},', ') WITHIN GROUP (ORDER BY ${employee_name}) ;;
    # order_by_field: work_order_id
  }

  # ----------- Drills -----------
  set: tech_details {
    fields: [
              employee_name,
              company_directory.employee_title,
              market_name,
              count_assigned_wos
            ]
  }
  set: work_order_details {
    fields: [
              date_created_date,
              date_completed_date,
              market_name,
              work_orders.work_order_id_with_link_to_work_order,
              work_orders.description,
              work_orders.work_order_status_name,
              billing_types.name,
              work_order_tech_list
            ]
  }
}

view: se_headcount_oec_agg {
  derived_table: {
    sql:
      WITH asset_agg AS (
        SELECT
          iah.MARKET_ID AS market_id,
          COUNT(DISTINCT iah.asset_id) AS asset_count,
          SUM(iah.TOTAL_OEC)  AS total_oec
        FROM ANALYTICS.ASSETS.INT_ASSET_HISTORICAL iah
        -- FROM "PLATFORM"."GOLD"."V_ASSETS" AS va
        where iah.daily_timestamp::date = current_date
          and iah.IN_RENTAL_FLEET = 1
        GROUP BY 1
      ),
      tech_agg AS (
        SELECT
          cd.market_id AS market_id,
          COUNT(DISTINCT CASE
          WHEN se.tech_position IN ('General Mechanic','Field Tech','Shop Tech')
            THEN se.employee_id -- or se.employee_name if no stable ID
          END) AS total_techs
        FROM "ANALYTICS"."SERVICE"."SERVICE_EFFICIENCY" AS se
        LEFT JOIN "ANALYTICS"."PAYROLL"."COMPANY_DIRECTORY" as cd on cd.employee_id::string = se.employee_id::string
        where cd.date_terminated is null
        GROUP BY 1
      )
      SELECT
        xw.market_id,
        COALESCE(a.asset_count, 0) AS asset_count,
        COALESCE(a.total_oec, 0)   AS total_oec,
        COALESCE(t.total_techs, 0) AS total_techs,
        case when total_techs = 0 then 0 else SUM(total_oec) / SUM(total_techs) end AS avg_oec_per_tech
      FROM "ANALYTICS"."PUBLIC"."MARKET_REGION_XWALK" AS xw
      LEFT JOIN asset_agg a ON xw.market_id = a.market_id
      LEFT JOIN tech_agg  t ON xw.market_id = t.market_id
      GROUP BY xw.market_id, a.asset_count, a.total_oec, t.total_techs;;
  }
  dimension: market_id {
    primary_key: yes
    value_format_name: id
    type: number
    sql: ${TABLE}.market_id ;;
  }

  measure: avg_oec_per_tech {
    label: "Avg OEC per Tech"
    type: average
    value_format_name: usd_0
    sql: ${TABLE}.avg_oec_per_tech ;;
    # link: { label: "Technician Details" url: "{{technicians._link}}" }
    # link: { label: "Asset Details" url: "{{assets._link}}" }
  }
  measure: sum_total_techs {
    label: "Total Techs"
    type: sum
    sql: ${TABLE}.total_techs ;;
  }
  measure: sum_total_oec {
    label: "Total OEC"
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}.total_oec ;;
    # link: { label: "Asset Details" url: "{{assets._link}}" }
  }
  measure: sum_total_assets {
    label: "Total Assets"
    type: sum
    sql: ${TABLE}.asset_count;;
    # link: { label: "Asset Details" url: "{{assets._link}}" }
  }
# Below are used to allow multiple drill options
  measure: technicians  { drill_fields: [technicians*] hidden: yes sql: 1=1 ;; }
  measure: assets       { drill_fields: [assets*] hidden: yes sql: 1=1 ;; }
  set: technicians {
    fields: [
            service_efficiency.employee_name,
            service_efficiency.tech_position
            ]
  }
  set: assets {
    fields: [
            v_assets.asset_inventory_market_name,
            v_assets.asset_equipment_subcategory_name,
            v_assets.asset_company_name,
            v_assets.asset_service_market_name,
            v_assets.asset_rental_market_name,
            v_assets.asset_market_name,
            v_assets.asset_equipment_class_name,
            v_assets.asset_equipment_model_name,
            v_assets.asset_equipment_category_name,
            v_assets.asset_current_oec
            ]
  }
}
