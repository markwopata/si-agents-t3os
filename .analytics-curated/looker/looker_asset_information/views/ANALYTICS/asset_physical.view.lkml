view: asset_physical {
  sql_table_name: "ANALYTICS"."ASSET_DETAILS"."ASSETS_INCLUDING_PURCHASING"
    ;;

  dimension: asset_id {
    # primary_key: yes
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: asset_type {
    type: string
    sql: ${TABLE}."ASSET_TYPE" ;;
  }

  dimension: asset_type_id {
    type: number
    sql: ${TABLE}."ASSET_TYPE_ID" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: custom_name {
    type: string
    sql: ${TABLE}."CUSTOM_NAME" ;;
  }

  dimension: equip_class_name {
    type: string
    label: "Class"
    sql: ${TABLE}."EQUIP_CLASS_NAME" ;;
  }

  dimension: has_tracker {
    type: yesno
    sql: ${TABLE}."HAS_TRACKER" ;;
  }

  dimension: inventory_branch_id {
    type: number
    sql: ${TABLE}."INVENTORY_BRANCH_ID" ;;
  }

  dimension: inventory_branch {
    type: string
    sql: ${TABLE}."INVENTORY_BRANCH" ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}."MAKE" ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }

  dimension: oec {
    type: number
    sql: ${TABLE}."OEC" ;;
  }

  dimension: parent_category_name {
    type: string
    sql: ${TABLE}."PARENT_CATEGORY_NAME" ;;
  }

  dimension: rental_branch_id {
    type: number
    sql: ${TABLE}."RENTAL_BRANCH_ID" ;;
  }

  dimension: serial_number {
    type: string
    sql: ${TABLE}."SERIAL_NUMBER" ;;
  }

  dimension: service_branch_id {
    type: number
    sql: ${TABLE}."SERVICE_BRANCH_ID" ;;
  }

  dimension: sub_category_name {
    type: string
    sql: ${TABLE}."SUB_CATEGORY_NAME" ;;
  }

  dimension_group: table_update {
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
    sql: ${TABLE}."TABLE_UPDATE_DATE" ;;
  }

  dimension: vin {
    type: string
    sql: ${TABLE}."VIN" ;;
  }

  dimension: year {
    type: number
    sql: ${TABLE}."YEAR" ;;
  }

  dimension: date_created {
    type: date_time
    sql: ${TABLE}."DATE_CREATED" ;;
  }

  dimension: tracker_id {
    type: number
    sql: ${TABLE}."TRACKER_ID" ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  dimension: rental_branch {
    type: string
    sql: ${TABLE}."RENTAL_BRANCH" ;;
  }

  dimension: rental_branch_company_id {
    type: string
    sql: ${TABLE}."RENTAL_BRANCH_COMPANY_ID" ;;
  }

  dimension: service_branch {
    type: string
    sql: ${TABLE}."SERVICE_BRANCH" ;;
  }

  dimension: service_branch_company_id {
    type: string
    sql: ${TABLE}."SERVICE_BRANCH_COMPANY_ID" ;;
  }

  dimension: is_rerent {
    type: yesno
    sql: ${TABLE}."IS_RERENT" ;;
  }

  dimension: is_floor_plan {
    type: yesno
    sql: ${TABLE}."IS_FLOOR_PLAN" ;;
  }

  dimension: is_public_rsp {
    type: yesno
    sql: ${TABLE}."IS_PUBLIC_RSP" ;;
  }

  dimension: is_public_msp {
    type: yesno
    sql: ${TABLE}."IS_PUBLIC_MSP" ;;
  }

  dimension: purchase_order_status {
    type: string
    sql: ${TABLE}."PURCHASE_ORDER_STATUS" ;;
  }

  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: asset_inventory_status {
    type:string
    sql: ${TABLE}."ASSET_INVENTORY_STATUS";;
  }

  dimension: business_segment_id {
    type: number
    sql: ${TABLE}."BUSINESS_SEGMENT_ID" ;;
  }

  dimension: business_segment {
    type: string
    sql: ${TABLE}."BUSINESS_SEGMENT" ;;
  }

  dimension: record_source {
    type: string
    sql: ${TABLE}."RECORD_SOURCE" ;;
  }

  dimension: company_purchase_order_line_item_id {
    type: number
    sql: ${TABLE}."COMPANY_PURCHASE_ORDER_LINE_ITEM_ID" ;;
  }

  dimension: invoice_number {
    type: string
    sql: ${TABLE}."INVOICE_NUMBER" ;;
  }

  dimension: invoice_date {
    type: string
    sql: ${TABLE}."INVOICE_DATE" ;;
  }
  # - - - - - Custom Dimensions For Filtering - - - - -

  # dimension: is_received {
  #   type: yesno
  #   sql:  ;;
  # }

  # - - - - - MEASURES - - - - -

  # The HTML parameter and liquid condition is because Fleet specifically requested to see the nulls instead of 0.
  # They said that Class Count By Locations does it, but that's because it's a pivot table and mine isn't.
  # This is the only way I could figure out how to do it without completely restructuring my data and having to re-test everything
  # - Jack G., 2023-07-11

  measure: total_received {
    label: "Received"
    type: count
    html:
    {% if value == 0 %}
    ∅
    {% else %}
    {{linked_value}}
    {% endif %}
    ;;
    filters: [purchase_order_status: "Received"]
    drill_fields: [asset_detail*]
  }

  measure: total_shipped {
    label: "Shipped"
    type: count
    html:
    {% if value == 0 %}
    ∅
    {% else %}
    {{linked_value}}
    {% endif %}
    ;;
    filters: [purchase_order_status: "Shipped"]
    drill_fields: [asset_detail*]
  }

  measure: total_ordered {
    label: "Ordered"
    type: count
    html:
    {% if value == 0 %}
    ∅
    {% else %}
    {{linked_value}}
    {% endif %}
    ;;
    filters: [purchase_order_status: "Ordered"]
    drill_fields: [asset_detail*]
  }

  measure: total_okay_to_ship {
    label: "Okay To Ship"
    type: count
    html:
    {% if value == 0 %}
    ∅
    {% else %}
    {{linked_value}}
    {% endif %}
    ;;
    filters: [purchase_order_status: "Okay to Ship"]
    drill_fields: [asset_detail*]
  }

  measure: no_order_status {
    type: count
    html:
    {% if value == 0 %}
    ∅
    {% else %}
    {{linked_value}}
    {% endif %}
    ;;
    filters: [purchase_order_status: "NULL"]
    drill_fields: [asset_detail*]
  }

  measure: on_rent {
    type: count
    html:
    {% if value == 0 %}
    ∅
    {% else %}
    {{linked_value}}
    {% endif %}
    ;;
    filters: [asset_inventory_status: "On Rent"]
    drill_fields: [asset_detail*]
  }
  measure: assigned {
    type: count
    html:
    {% if value == 0 %}
    ∅
    {% else %}
    {{linked_value}}
    {% endif %}
    ;;
    filters: [asset_inventory_status: "Assigned"]
    drill_fields: [asset_detail*]
  }
  measure: ready_to_rent {
    type: count
    html:
    {% if value == 0 %}
    ∅
    {% else %}
    {{linked_value}}
    {% endif %}
    ;;
    filters: [asset_inventory_status: "Ready To Rent"]
    drill_fields: [asset_detail*]
  }
  measure: needs_inspection {
    type: count
    html:
    {% if value == 0 %}
    ∅
    {% else %}
    {{linked_value}}
    {% endif %}
    ;;
    filters: [asset_inventory_status: "Needs Inspection"]
    drill_fields: [asset_detail*]
  }
  measure: pending_return {
    type: count
    html:
    {% if value == 0 %}
    ∅
    {% else %}
    {{linked_value}}
    {% endif %}
    ;;
    filters: [asset_inventory_status: "Pending Return"]
    drill_fields: [asset_detail*]
  }
  measure: soft_down {
    type: count
    html:
    {% if value == 0 %}
    ∅
    {% else %}
    <p>{{linked_value}}</p>
    {% endif %}
    ;;
    filters: [asset_inventory_status: "Soft Down"]
    drill_fields: [asset_detail*]
  }
  measure: hard_down {
    type: count
    html:
    {% if value == 0 %}
    ∅
    {% else %}
    <p>{{linked_value}}</p>
    {% endif %}
    ;;
    filters: [asset_inventory_status: "Hard Down"]
    drill_fields: [asset_detail*]
  }
  measure: make_ready {
    type: count
    html:
    {% if value == 0 %}
    ∅
    {% else %}
    <p>{{linked_value}}</p>
    {% endif %}
    ;;
    filters: [asset_inventory_status: "Make Ready"]
    drill_fields: [asset_detail*]
  }
  measure: pre_delivered {
    type: count
    html:
    {% if value == 0 %}
    ∅
    {% else %}
    <p>{{linked_value}}</p>
    {% endif %}
    ;;
    filters: [asset_inventory_status: "Pre-Delivered"]
    drill_fields: [asset_detail*]
  }
  measure: on_rpo {
    type: count
    html:
    {% if value == 0 %}
    ∅
    {% else %}
    <p>{{linked_value}}</p>
    {% endif %}
    ;;
    filters: [asset_inventory_status: "On RPO"]
    drill_fields: [asset_detail*]
  }
  measure: no_status {
    type: count
    html:
    {% if value == 0 %}
    ∅
    {% else %}
    <p>{{linked_value}}</p>
    {% endif %}
    ;;
    filters: [asset_inventory_status: "NULL"]
    drill_fields: [asset_detail*]
  }

  measure: total_units {
    label: "Total Delivered"
    type: sum
    html:
    {% if value == 0 %}
    ∅
    {% else %}
    <p>{{linked_value}}</p>
    {% endif %}
    ;;
    sql: IFF(${purchase_order_status} = 'Received' OR ${asset_inventory_status} is not null, 1, null);;
    drill_fields: [asset_detail*]
  }

  measure: count_ute {
    type: number
    sql: ${on_rent} / NULLIFZERO(${on_rent} + ${assigned} + ${ready_to_rent} + ${needs_inspection} + ${pending_return} + ${soft_down} + ${hard_down} + ${make_ready} + ${pre_delivered} + ${on_rpo}) ;;
    drill_fields: [asset_detail*]
  }

  measure: count {
    type: count
    drill_fields: [asset_detail*]
  }

  # - - - - - SETS - - - - -

  set: asset_detail {
    fields: [record_source, asset_id, rental_branch, purchase_order_status, asset_type, company_name, custom_name, parent_category_name, sub_category_name, equip_class_name, make, model, date_created]
  }
}
