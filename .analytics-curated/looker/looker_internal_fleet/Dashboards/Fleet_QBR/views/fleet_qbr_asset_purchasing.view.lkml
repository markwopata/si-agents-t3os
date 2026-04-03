view: fleet_qbr_asset_purchasing {
    derived_table: {
      sql:
        Select
        company_purchase_order_line_item_id,
        equipment_model_id,
        equipment_model,
        equipment_make_id,
        equipment_make,
        equipment_class_id,
        equipment_class,
        category,
        sub_category,
        market_id,
        vendor_id,
        vendor_name_clean,
        vendor_parent,
        order_status,
        po_date,
        invoice_date,
        --, invoice_qtr achieved through invoice date grouping
        release_date,
        promise_year,
        company_purchase_order_type_id,
        po_type,
        finance_status,
        net_price,
        quantity,
        freight_cost_clean,
        total_cost,
        calculated_oec,
        --, po_approved
        open_order_flag,
        promised_this_year_flag,
        promised_next_year_flag,
        is_ideal_make_flag
        from data_science_stage.fleet_testing.asset_purchases_for_qbr
          ;;
    }

    dimension: p_key {
      type:  number
      description: "unique line item for purchase"
      primary_key: yes
      hidden: yes
      sql:${TABLE}."COMPANY_PURCHASE_ORDER_LINE_ITEM_ID";;
    }

    dimension_group: invoice {
      type: time
      description: "date grouping for invoice dates"
      timeframes: [
        date,
        week,
        month,
        quarter,
        year
      ]
      sql: ${TABLE}."INVOICE_DATE" ;;
    }

  dimension_group: po {
    type: time
    description: "date grouping for PO dates"
    timeframes: [
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."PO_DATE" ;;

  }

  dimension_group: release {
    type: time
    description: "date grouping for release dates (when ES receives asset from vendor)"
    timeframes: [
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."RELEASE_DATE" ;;
    }

    dimension: equipment_model {
      type: string
      sql: ${TABLE}."EQUIPMENT_MODEL" ;;
    }

  dimension: equipment_make {
    type: string
    sql: ${TABLE}."EQUIPMENT_MAKE" ;;
  }

  dimension: equipment_class {
    type: string
    sql: ${TABLE}."EQUIPMENT_CLASS" ;;
  }

  dimension: equipment_class_id {
    type: number
    hidden: yes
    sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
  }

  dimension: category {
    type: string
    description: "parent category derived from standard hierarchy"
    sql: ${TABLE}."CATEGORY" ;;
  }

  dimension: subcategory {
    type: string
    description: "child category derived from standard hierarchy"
    sql: ${TABLE}."SUB_CATEGORY" ;;
  }

  dimension: vendor_id {
    type: number
    description: "Vendor identifier"
    sql: ${TABLE}."VENDOR_ID" ;;
  }

  dimension: vendor_name {
    type: string
    description: "vendor from which asset was purchased. May differ from OEM. Lightly cleaned to remove punctuation and render to proper case"
    sql: ${TABLE}."VENDOR_NAME_CLEAN" ;;
  }

  dimension: vendor_parent {
    type: string
    description: "Grouped parent supplier of vendor. Recommended for vendor-level analysis."
    sql: ${TABLE}."VENDOR_PARENT" ;;
  }

  dimension: order_status {
    type: string
    description: "from purchase order line items table"
    sql: ${TABLE}."ORDER_STATUS" ;;
  }

  dimension: finance_status {
    type: string
    description: "from purchase order line items table. Finance and dealership are excluded"
    sql: ${TABLE}."FINANCE_STATUS" ;;
  }

  dimension: po_type {
    type: string
    description: "from purchase order/purchase order type tables (company_purchase_order_types.name). "
    sql: ${TABLE}."PO_TYPE" ;;
  }

  dimension: open_order {
    type: string
    description: "boolean: invoice_date is null and order_status is shipped, okay to ship, or ordered"
    sql: ${TABLE}."OPEN_ORDER_FLAG" ;;
  }

  dimension: promised_this_year {
    type: string
    description: "derived from current_promise_date: year of 2024 or 2099 is promised in 2024"
    sql: ${TABLE}."PROMISED_THIS_YEAR_FLAG" ;;
  }

  dimension: promised_next_year {
    type: string
    description: "derived from current_promise_date: year of 2025 or 2100 is promised in 2025"
    sql: ${TABLE}."PROMISED_NEXT_YEAR_FLAG" ;;
  }

  dimension: ideal_make_flag {
    type: string
    description: "for use in by-class purchasing analysis: flags if the make purchased for the class is considered ideal"
    sql: ${TABLE}."IS_IDEAL_MAKE_FLAG" ;;
  }

  measure: net_price {
    type: sum
    description: "net price of asset"
    value_format: "$#,##0"
    sql: ${TABLE}."NET_PRICE" ;;
  }

  measure: freight_cost {
    type: sum
    description: "recorded freight, coalesced to 0 when null"
    value_format: "$#,##0"
    sql: ${TABLE}."FREIGHT_COST_CLEAN" ;;
  }

  measure: quantity {
    type: sum
    description: "recorded quantity"
    value_format: "0"
    sql: ${TABLE}."QUANTITY" ;;
  }

  measure: total_cost {
    type: sum
    description: "net price * quantity"
    value_format: "$#,##0"
    sql: ${TABLE}."TOTAL_COST" ;;
  }

  measure: calculated_oec {
    type: sum
    description: "total cost + freight"
    value_format: "$#,##0"
    sql: ${TABLE}."CALCULATED_OEC" ;;
  }

  dimension: subcategory_top10 {
    type:  yesno
    sql:
      exists(
        select *
        from (
          select
            "SUB_CATEGORY"
            from ${TABLE}
            group by "SUB_CATEGORY"
            order by sum("CALCULATED_OEC") desc
            limit 10
        ) as top_10
        where ${subcategory} = top_10.sub_category
      );;
  }
}
