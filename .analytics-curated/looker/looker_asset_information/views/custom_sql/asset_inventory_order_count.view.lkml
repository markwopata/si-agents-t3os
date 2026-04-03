view: asset_inventory_order_count {

  derived_table: {
    sql:
      select
          a.asset_inventory_status,
          a.is_managed_by_es_owned_market,
          a.asset_id,
          a.asset_type_id,
          a.serial_number,
          a.custom_name,
          a.is_deleted,
          a.rental_branch_id,
          a.inventory_branch_id,
          a.equipment_model_id,
          coalesce(a.market_id, cpoli.market_id) as market_id,
          ec.name as equipment_class_name,
          cpoli.order_status,
          cpoli.company_purchase_order_line_item_id,
          cpoli.deleted_at as cpo_deleted_at,
          cpoli.invoice_date,
          cpoli.finance_status,
          cpoli.company_purchase_order_id,
          cpoli.equipment_model_id as cpo_equipment_model_id,
          cpoli.equipment_class_id as cpo_equipment_class_id,
          cpoli.year,
          cpoli.attachments,
          cpoli.factory_build_specifications,
          cpot.name as company_purchase_order_type_name,
          cpo.approved_by_user_id,
          v.name as vendor_name,
          em.name as model_name,
          ema.name as make_name,
          mrx.market_type,
          mrx.market_name,
          mrx.district,
          mrx.region_name
      from analytics.assets.int_assets a
      full outer join es_warehouse.public.company_purchase_order_line_items cpoli
        on a.asset_id = cpoli.asset_id
      left join es_warehouse.public.company_purchase_orders cpo
        on cpoli.company_purchase_order_id = cpo.company_purchase_order_id
      left join es_warehouse.public.company_purchase_order_types cpot
        on cpo.company_purchase_order_type_id = cpot.company_purchase_order_type_id
      left join es_warehouse.public.equipment_classes_models_xref ecm
        on ecm.equipment_model_id = coalesce(a.equipment_model_id, cpoli.equipment_model_id)
      left join es_warehouse.public.equipment_classes ec
        on ec.equipment_class_id = coalesce(a.equipment_class_id, cpoli.equipment_class_id, ecm.equipment_class_id)
      left join es_warehouse.public.companies v
        on cpo.vendor_id = v.company_id
      left join es_warehouse.public.equipment_models em
        on ecm.equipment_model_id = em.equipment_model_id
      left join es_warehouse.public.equipment_makes ema
        on em.equipment_make_id = ema.equipment_make_id
      left join analytics.public.market_region_xwalk mrx
        on mrx.market_id = coalesce(a.market_id, cpoli.market_id)

    ;;
  }

  dimension: asset_inventory_status {
    type: string
    sql: ${TABLE}."ASSET_INVENTORY_STATUS" ;;
  }

  dimension: is_managed_by_es_owned_market {
    type: yesno
    sql:coalesce(${TABLE}."IS_MANAGED_BY_ES_OWNED_MARKET",'Yes') ;;
  }

  dimension: asset_id {
    type: string
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: asset_id_flag {
    type: string
    sql: case when ${asset_id} is null then 'Yes' else 'No' end;;
  }

  dimension: asset_type_id {
    type: number
    sql: coalesce(${TABLE}."ASSET_TYPE_ID", 999) ;;
  }

  dimension: serial_number {
    type: string
    sql: ${TABLE}."SERIAL_NUMBER" ;;
  }

  dimension: custom_name {
    type: string
    sql: ${TABLE}."CUSTOM_NAME" ;;
  }

  dimension: deleted_flag {
    type: yesno
    sql: ${TABLE}."IS_DELETED" ;;
  }

  dimension: rental_branch_id {
    type: number
    sql: ${TABLE}."RENTAL_BRANCH_ID" ;;
  }

  dimension: inventory_branch_id {
    type: number
    sql: ${TABLE}."INVENTORY_BRANCH_ID" ;;
  }

  dimension: equipment_model_id {
    type: number
    sql: ${TABLE}."EQUIPMENT_MODEL_ID" ;;
  }

  dimension: order_status_flag {
    type: yesno
    sql: ${TABLE}."ORDER_STATUS" in ('Okay to Ship', 'Shipped', 'Ordered') ;;
  }

  dimension: order_status {
    type: string
    sql:
      case
        when ${TABLE}."ORDER_STATUS" = 'Okay to Ship' then 'Released'
        else ${TABLE}."ORDER_STATUS"
      end ;;
  }

  dimension: equipment_class_name {
    type: string
    sql: ${TABLE}."EQUIPMENT_CLASS_NAME" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension: market_type {
    type: string
    sql: ${TABLE}."MARKET_TYPE" ;;
  }

  dimension: company_purchase_order_line_item_id {
    type: string
    sql: ${TABLE}."COMPANY_PURCHASE_ORDER_LINE_ITEM_ID" ;;
  }

  dimension: attachments {
    type: string
    sql: ${TABLE}."ATTACHMENTS" ;;
  }

  dimension: factory_build_specifications {
    type: string
    sql: ${TABLE}."FACTORY_BUILD_SPECIFICATIONS" ;;
  }

  dimension: company_purchase_order_type_name_flag {
    type: string
    sql:
      case
        when ${TABLE}."COMPANY_PURCHASE_ORDER_TYPE_NAME" ilike '%Serialized Rental Asset%' then 'Yes'
        else 'No'
      end ;;
  }

  dimension_group: deleted_date {
    type: time
    timeframes: [date]
    sql: cast(${TABLE}."CPO_DELETED_AT" as timestamp_ntz) ;;
  }

  dimension_group: invoice_date {
    type: time
    timeframes: [
      date,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."INVOICE_DATE" ;;
  }

  dimension: finance_status {
    type: string
    sql: ${TABLE}."FINANCE_STATUS" ;;
  }

  dimension: finance_status_flag {
    type: string
    sql:
      case
        when ${TABLE}."FINANCE_STATUS" ilike '%Retail%'     then 'Yes'
        when ${TABLE}."FINANCE_STATUS" ilike '%Dealership%' then 'Yes'
        else 'No'
      end ;;
  }

  dimension: approved_by_user_id {
    type: string
    sql: ${TABLE}."APPROVED_BY_USER_ID" ;;
  }

  dimension: approved_by_user_flag {
    type: string
    sql:
      case
        when ${TABLE}."APPROVED_BY_USER_ID" is null then 'Yes'
        else 'No'
      end ;;
  }

  dimension: year {
    type: string
    sql: ${TABLE}."YEAR" ;;
  }

  dimension: vendor {
    type: string
    sql: ${TABLE}."VENDOR_NAME" ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}."MODEL_NAME" ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}."MAKE_NAME" ;;
  }

  measure: current_inventory_total {
    type: count_distinct
    sql: ${asset_id};;
    description: "Total asset count of all inventory statuses."
    drill_fields: [inventory_detail*]
    filters: [asset_id_flag: "No"]
  }

  measure: count {
    type: count
  }

  measure: ready_to_rent_count {
    type: sum
    sql:case when ${asset_inventory_status} = 'Ready To Rent' then 1 else 0 end ;;
    drill_fields: [inventory_detail*]
    filters: [asset_inventory_status: "Ready To Rent"]
  }

  measure: on_rent_count {
    type: sum
    sql:case when ${asset_inventory_status} = 'On Rent' then 1 else 0 end ;;
    drill_fields: [inventory_detail*]
    filters: [asset_inventory_status: "On Rent"]
  }

  measure: soft_down_count {
    type: sum
    sql:case when ${asset_inventory_status} = 'Soft Down' then 1 else 0 end ;;
    drill_fields: [inventory_detail*]
    filters: [asset_inventory_status: "Soft Down"]
  }

  measure: hard_down_count {
    type: sum
    sql:case when ${asset_inventory_status} = 'Hard Down' then 1 else 0 end ;;
    drill_fields: [inventory_detail*]
    filters: [asset_inventory_status: "Hard Down"]
  }

  measure: needs_inspection_count {
    type: sum
    sql:case when ${asset_inventory_status} = 'Needs Inspection' then 1 else 0 end ;;
    drill_fields: [inventory_detail*]
    filters: [asset_inventory_status: "Needs Inspection"]
  }

  measure: pending_return_count {
    type: sum
    sql:case when ${asset_inventory_status} = 'Pending Return' then 1 else 0 end ;;
    drill_fields: [inventory_detail*]
    filters: [asset_inventory_status: "Pending Return"]
  }

  measure: assigned_count {
    type: sum
    sql:case when ${asset_inventory_status} = 'Assigned' then 1 else 0 end ;;
    drill_fields: [inventory_detail*]
    filters: [asset_inventory_status: "Assigned"]
  }

  measure: make_ready_count {
    type: sum
    sql:case when ${asset_inventory_status} = 'Make Ready' then 1 else 0 end ;;
    drill_fields: [inventory_detail*]
    filters: [asset_inventory_status: "Make Ready"]
  }

  measure: pre_delivered_count {
    type: sum
    sql:case when ${asset_inventory_status} = 'Pre-Delivered' then 1 else 0 end ;;
    drill_fields: [inventory_detail*]
    filters: [asset_inventory_status: "Pre-Delivered"]
  }

  measure: on_rpo_count {
    type: sum
    sql:case when ${asset_inventory_status} = 'On RPO' then 1 else 0 end ;;
    drill_fields: [inventory_detail*]
    filters: [asset_inventory_status: "On RPO"]
  }

  measure: ordered_count {
    type: count_distinct
    sql: ${company_purchase_order_line_item_id} ;;
    drill_fields: [order_detail*]
    filters: [
      order_status_flag: "Yes",
      finance_status_flag: "No",
      deleted_flag: "No",
      company_purchase_order_type_name_flag: "Yes",
      approved_by_user_flag: "No"
    ]
    description: "Includes order types: Ordered, Released, and Shipped. Does not include Receieved orders. Use the Order Status filter on the dashboard to see specific order type counts. There is also no filtering of invoice dates so includes all invoice dates and null invoice dates."
  }

  set: order_detail {
    fields: [
      equipment_class_name,
      company_purchase_order_line_item_id,
      market_name,
      order_status,
      invoice_date_date,
      asset_id,
      vendor,
      year,
      make,
      model,
      attachments,
      factory_build_specifications
    ]
  }

  set: inventory_detail {
    fields: [
      asset_id,
      market_name,
      asset_inventory_status
    ]
  }

}
