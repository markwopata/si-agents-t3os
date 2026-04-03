view: work_orders {
  sql_table_name: "WORK_ORDERS"."WORK_ORDERS"
    ;;
  drill_fields: [_work_order_id]

  dimension: _work_order_id {
    # primary_key: yes
    hidden: yes
    type: number
    sql: ${TABLE}."_WORK_ORDER_ID" ;;
  }

  dimension_group: _es_update_timestamp {
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
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: _work_order_status_id {
    type: number
    hidden: yes
    sql: ${TABLE}."_WORK_ORDER_STATUS_ID" ;;
  }

  dimension_group: archived {
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
    sql: CAST(${TABLE}."ARCHIVED_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: billing_notes {
    type: string
    sql: ${TABLE}."BILLING_NOTES" ;;
  }

  dimension: billing_type_id {
    type: number
    sql: ${TABLE}."BILLING_TYPE_ID" ;;
  }

  dimension: branch_id {
    type: number
    sql: ${TABLE}."BRANCH_ID" ;;
  }

  dimension: creator_user_id {
    type: number
    sql: ${TABLE}."CREATOR_USER_ID" ;;
  }

  dimension: customer_user_id {
    type: number
    sql: ${TABLE}."CUSTOMER_USER_ID" ;;
  }

  dimension_group: date_billed {
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
    sql: CAST(${TABLE}."DATE_BILLED" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: date_completed {
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
    sql: CAST(${TABLE}."DATE_COMPLETED" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: date_created {
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
    # sql: convert_timezone('{{ _user_attributes['user_timezone'] }}',CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ)) ;;
    sql:CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: date_updated {
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
    # sql: convert_timezone('{{ _user_attributes['user_timezone'] }}',CAST(${TABLE}."DATE_UPDATED" AS TIMESTAMP_NTZ)) ;;
    sql: CAST(${TABLE}."DATE_UPDATED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension_group: due {
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
    # sql: convert_timezone('{{ _user_attributes['user_timezone'] }}',CAST(${TABLE}."DUE_DATE" AS TIMESTAMP_NTZ)) ;;
    sql: CAST(${TABLE}."DUE_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: hours_at_service {
    type: number
    sql: ${TABLE}."HOURS_AT_SERVICE" ;;
  }

  dimension: invoice_number {
    type: string
    sql: ${TABLE}."INVOICE_NUMBER" ;;
  }

  dimension: mileage_at_service {
    type: number
    sql: ${TABLE}."MILEAGE_AT_SERVICE" ;;
  }

  dimension: severity_level_id {
    type: number
    sql: ${TABLE}."SEVERITY_LEVEL_ID" ;;
  }

  dimension: solution {
    type: string
    sql: ${TABLE}."SOLUTION";;
  }

  dimension: urgency_level_id {
    type: number
    sql: ${TABLE}."URGENCY_LEVEL_ID" ;;
  }

  dimension: work_order_id {
    primary_key: yes
    type: number
    # hidden: yes
    sql: ${TABLE}."WORK_ORDER_ID" ;;
    value_format_name: id
  }

  dimension: work_order_status_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_STATUS_ID" ;;
  }

  dimension: work_order_status_name {
    type: string
    sql: ${TABLE}."WORK_ORDER_STATUS_NAME" ;;
  }

  dimension: work_order_type_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_TYPE_ID" ;;
  }

  dimension: cost {
    type: number
    sql: ${TABLE}."COST" ;;
    value_format_name: usd
  }

  measure: count {
    type: count
    drill_fields: [_work_order_id, work_order_status_name, work_orders.work_order_status_name, work_orders._work_order_id, work_orders.count]
  }

  dimension: wo_solution {
    group_label: "WO Solution No Label"
    label: " "
    type: string
    sql: COALESCE(${TABLE}."SOLUTION",'In Progress') ;;
  }

  dimension: wo_export_date_created {
    group_label: "WO Export Dates Formatted"
    type: date_time
    # sql: ${date_created_raw} ;;
    sql: convert_timezone('America/Chicago',${date_created_raw}) ;;
    html: {{ rendered_value | date: "%x %r" }} ;;
  }

  dimension: complaint_description {
    group_label: "WO Export Description"
    label: " "
    type: string
    # sql: concat('Complaint: ',${description}) ;;
    sql: ${description} ;;
  }

  # dimension: wo_export_due_time {
  #   group_label: "WO Export Dates Formatted"
  #   type: string
  #   sql: coalesce(${due_raw},current_timestamp) ;;
  #   html: {% if work_orders.wo_export_due_time._rendered_value NOT NULL %}
  #   {{work_orders.wo_export_due_time._rendered_value | date: "%x %r" }}
  #   {% else %}
  #   'No Due Date'
  #   {% endif %} ;;
  # }
  #     {{ rendered_value | date: "%x %r" }}

  dimension: wo_export_due_time {
    group_label: "WO Export Dates Formatted"
    type: string
    # sql: ${due_raw} ;;
    sql: convert_timezone('America/Chicago',${due_raw}) ;;
    html: {{ rendered_value | date: "%x %r" }};;
  }

  dimension: wo_export_date_updated {
    group_label: "WO Export Dates Formatted"
    type: date_time
    # sql: ${date_updated_raw} ;;
    sql: convert_timezone('America/Chicago',${date_updated_raw}) ;;
    html: {{ rendered_value | date: "%x %r" }} ;;
  }

  dimension: wo_export_date_completed {
    group_label: "WO Export Dates Formatted"
    type: date_time
    # sql: ${date_updated_raw} ;;
    sql: convert_timezone('America/Chicago',${date_completed_raw}) ;;
    html: {{ rendered_value | date: "%x %r" }} ;;
  }

  dimension: date_due_formatted {
    group_label: "HTML Date Formatted"
    type: string
    sql: convert_timezone('America/Chicago',${due_raw}) ;;
    html: {{rendered_value | date: "%b %d, %Y %r"}} ;;
  }

  dimension: date_updated_formatted {
    group_label: "HTML Date Formatted"
    type: date_time
    sql: convert_timezone('America/Chicago',${date_updated_raw}) ;;
    html: {{rendered_value | date: "%b %d, %Y %r"}} ;;
  }

  dimension: date_created_formatted {
    group_label: "HTML Date Formatted"
    type: date_time
    sql: convert_timezone('America/Chicago',${date_created_raw}) ;;
    html: {{rendered_value | date: "%b %d, %Y %r"}} ;;
  }

  dimension: severity_level {
    type: string
    sql: case when ${severity_level_id} = 1 then 'Soft Down' else 'Hard Down' end;;
  }

  dimension: job_or_asset_label{
    type: string
    sql: case when ${asset_id} is not null then 'Asset ID: ' else 'Job : ' end ;;
  }

  dimension: top_left_info {
    group_label: "No Label Top WO Export Info"
    label: " "
    type: string
    sql: coalesce(${asset_id},0) ;;
    required_fields: [wo_export_date_created,wo_export_due_time,wo_export_date_updated]
    html:
    <table>
  <tr>
    <td><b>Asset ID:</b> </td>
    <td>
    <br />{{assets.custom_name._rendered_value}}
    <br />{{assets.make_and_model._rendered_value}}
    <br />{{assets.serial_number._rendered_value}}
    </td>
  </tr>
  <tr>
    <td><b>Created On:</b> </td>
    <td>{{work_orders.wo_export_date_created._rendered_value}}</td>
  </tr>
  <tr>
    <td><b>Due On:</b> </td>
    <td>
    {{work_orders.wo_export_due_time._rendered_value}}
    </td>
  </tr>
  <tr>
    <td><b>Last Updated:</b> </td>
    <td>{{work_orders.wo_export_date_updated._rendered_value}}</td>
  </tr>
  </table>
    ;;
  }

  dimension: link_to_work_order {
    type: string
    sql: ${work_order_id} ;;
    html: <font color="blue "><u><a href="https://app.estrack.com/#/service/work-orders/{{ work_order_id._value }}" target="_blank">View Work Order</a></font></u> ;;
  }

  dimension: top_right_info {
    group_label: "No Label Top WO Export Info"
    label: " "
    type: string
    sql: coalesce(${asset_id},0) ;;
    html:
    <table>
  <tr>
    <td><b>Status:</b> </td>
    <td>{{work_order_statuses.name._rendered_value}}</td>
  </tr>
  <tr>
    <td><b>Assigned To:</b> </td>
    <td>{{work_orders_assigned_to.assigned_to._rendered_value}}</td>
  </tr>
  <tr>
    <td><b>Priority:</b> </td>
    <td>{{urgency_levels.name._rendered_value}}</td>
  </tr>
  <tr>
    <td><b>Severity:</b> </td>
    <td>{{work_orders.severity_level._rendered_value}}</td>
  </tr>
  <tr>
    <td><b>Originator:</b> </td>
    <td>{{users_creator_id.full_name._rendered_value}}</td>
  </tr>
  <tr>
    <td><b>Invoice Number:</b> </td>
    <td>{{work_orders.invoice_number._rendered_value}}</td>
  </tr>
  <tr>
    <td><b>Work Order Cost:</b> </td>
    <td>{{work_orders.cost._rendered_value}}</td>
  </tr>
  <tr>
    <td><b>Hours at Service:</b> </td>
    <td>{{work_orders.hours_at_service._rendered_value}}</td>
  </tr>
  <tr>
    <td><b>Mileage at Service:</b> </td>
    <td>{{work_orders.mileage_at_service._rendered_value}}</td>
  </tr>
  </table>
    ;;
  }

  dimension: work_order_string {
    type: string
    sql:
    case when ${work_order_type_id} = 1 then
    concat('Work Order #',' ',${work_order_id})
    else
    concat('Inspection',' - ',${work_order_id})
    end
    ;;
  }

  dimension: fake_string {
    type: string
    sql: ' ' ;;
    description: "Used to populate WO Export Tiles if no data"
  }

  dimension: work_order_lite_top_right_info {
    group_label: "No Label Top WO Export Info"
    label: " "
    type: string
    sql: coalesce(${asset_id},0) ;;
    html:
    <table>
  <tr>
    <td><b>Status:</b> </td>
    <td>{{work_order_statuses.name._rendered_value}}</td>
  </tr>
  <tr>
    <td><b>Priority:</b> </td>
    <td>{{urgency_levels.name._rendered_value}}</td>
  </tr>
  <tr>
    <td><b>Severity:</b> </td>
    <td>{{work_orders.severity_level._rendered_value}}</td>
  </tr>
  <tr>
    <td><b>Invoice Number:</b> </td>
    <td>{{work_orders.invoice_number._rendered_value}}</td>
  </tr>
  <tr>
    <td><b>Hours at Service:</b> </td>
    <td>{{work_orders.hours_at_service._rendered_value}}</td>
  </tr>
  <tr>
    <td><b>Mileage at Service:</b> </td>
    <td>{{work_orders.mileage_at_service._rendered_value}}</td>
  </tr>
  </table>
    ;;
  }


}
