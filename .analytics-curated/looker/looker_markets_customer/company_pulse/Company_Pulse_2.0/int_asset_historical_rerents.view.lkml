view: int_asset_historical_rerents {
    sql_table_name: analytics.assets.int_asset_historical;;


    measure: count {
      type: count
      drill_fields: [detail*]
    }

    dimension_group: daily_timestamp {
      type: time
      sql: ${TABLE}."DAILY_TIMESTAMP" ;;
      html: {{ rendered_value | date: "%b %d, %Y" }};;
    }

    dimension: formatted_date {
      group_label: "HTML Formatted Date"
      label: "Date"
      type: date
      sql: ${daily_timestamp_date} ;;
      html: {{ rendered_value | date: "%b %d, %Y" }};;
    }

    dimension: formatted_date_as_month {
      group_label: "HTML Formatted Date"
      label: "Date as Month"
      type: date
      sql: ${daily_timestamp_date} ;;
      html: {{ rendered_value | date: "%b %Y"  }};;
    }

    dimension: formatted_month {
      group_label: "HTML Formatted Date"
      label: "Month"
      type: date
      sql: DATE_TRUNC(month,${daily_timestamp_date}::DATE) ;;
      html: {{ rendered_value | date: "%b %Y"  }};;
    }

    dimension: asset_id {
      group_label: "Asset Information"
      type: string
      sql: ${TABLE}."ASSET_ID" ;;
      html:<font color="#0063f3"><a href="https://equipmentshare.looker.com/dashboards/169?Asset+ID={{filterable_value}}"target="_blank">
            {{rendered_value}} ➔</a>
            <br />
            <font style="color: #8C8C8C; text-align: right;">Category: {{category._rendered_value }} </font> ;;
    }

    dimension: asset_id_drilless {
      group_label: "Asset Information"
      label: "Asset ID"
      type: string
      sql: ${asset_id} ;;
    }

    measure: asset_count {
      type: count_distinct
      sql: ${asset_id} ;;
    }

    dimension: asset_type_id {
      group_label: "Asset Information"
      type: string
      sql: ${TABLE}."ASSET_TYPE_ID" ;;
    }

    dimension: asset_type {
      group_label: "Asset Information"
      type: string
      sql: ${TABLE}."ASSET_TYPE" ;;
    }

    dimension_group: first_rental_date {
      group_label: "Asset Information"
      type: time
      sql: ${TABLE}."FIRST_RENTAL_DATE" ;;
    }

    dimension: make {
      group_label: "Asset Information"
      type: string
      sql: ${TABLE}."MAKE" ;;
    }

    dimension: model {
      group_label: "Asset Information"
      type: string
      sql: ${TABLE}."MODEL" ;;
    }

    dimension: make_model {
      group_label: "Asset Information"
      type: string
      sql: concat(${make},' ',${model}) ;;
    }

    dimension: year {
      group_label: "Asset Information"
      type: string
      sql: ${TABLE}."YEAR" ;;
    }

    dimension: category_id {
      group_label: "Asset Information"
      type: string
      sql: ${TABLE}."CATEGORY_ID" ;;
    }

    dimension: category {
      group_label: "Asset Information"
      type: string
      sql: ${TABLE}."CATEGORY" ;;
    }

    dimension: equipment_class_id {
      group_label: "Asset Information"
      type: string
      sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
    }

    dimension: equipment_class {
      group_label: "Asset Information"
      type: string
      sql: ${TABLE}."EQUIPMENT_CLASS" ;;
    }

    dimension: is_own_program_asset {
      group_label: "Asset Information"
      type: yesno
      sql: ${TABLE}."IS_OWN_PROGRAM_ASSET" ;;
    }

    dimension: is_most_recent {
      type:  yesno
      sql: ${daily_timestamp_date} = current_date;;
    }

    dimension: is_last_day_of_month {
      type:  yesno
      sql: CASE WHEN ${daily_timestamp_date} = LAST_DAY(${daily_timestamp_date}) OR ${is_most_recent} THEN TRUE ELSE FALSE END ;;
    }

    dimension: in_total_fleet {
      group_label: "Asset Information"
      type: yesno
      sql: ${TABLE}."IN_TOTAL_FLEET" ;;
    }

    dimension: total_oec {
      type: number
      description: "OEC of assets where in_total_fleet = TRUE"
      sql: ${TABLE}."TOTAL_OEC" ;;
      value_format_name: usd_0
    }

    measure: total_oec_sum {
      type: sum
      sql: ${total_oec} ;;
      value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    }

    dimension: in_rental_fleet {
      type: yesno
      sql: ${TABLE}."IN_RENTAL_FLEET" ;;
    }

    dimension: rental_branch_id {
      group_label: "Market Information"
      type: string
      sql: ${TABLE}."RENTAL_BRANCH_ID" ;;
    }

    dimension: rental_branch_name {
      group_label: "Market Information"
      type: string
      sql: ${TABLE}."RENTAL_BRANCH_NAME" ;;
      html:
          {{rendered_value}}
          <br />
          <font style="color: #8C8C8C; text-align: right;">Market ID: {{rental_branch_id._rendered_value }} </font>;;
    }

    dimension: service_branch_id {
      group_label: "Market Information"
      type: string
      sql: ${TABLE}."SERVICE_BRANCH_ID" ;;
    }

    dimension: service_branch_name {
      group_label: "Market Information"
      type: string
      sql: ${TABLE}."SERVICE_BRANCH_NAME" ;;
      html:
          {{rendered_value}}
          <br />
          <font style="color: #8C8C8C; text-align: right;">Market ID: {{service_branch_id._rendered_value }} </font>;;
    }

    dimension: inventory_branch_id {
      group_label: "Market Information"
      type: string
      sql: ${TABLE}."INVENTORY_BRANCH_ID" ;;
    }

    dimension: inventory_branch_name {
      group_label: "Market Information"
      type: string
      sql: ${TABLE}."INVENTORY_BRANCH_NAME" ;;
    }

    dimension: market_id {
      group_label: "Market Information"
      type: string
      sql: ${TABLE}."MARKET_ID" ;;
    }

    dimension: market_name {
      group_label: "Market Information"
      type: string
      sql: ${TABLE}."MARKET_NAME" ;;
    }

    dimension: is_rerent_asset {
      group_label: "Asset Information"
      type: yesno
      sql: ${TABLE}."IS_RERENT_ASSET" ;;
    }

    dimension: days_in_status {
      type: number
      sql: ${TABLE}."DAYS_IN_STATUS" ;;
    }

    dimension: asset_company_id {
      group_label: "Asset Information"
      type: string
      sql: ${TABLE}."ASSET_COMPANY_ID" ;;
    }

    dimension:  is_managed_by_es_owned_market {
      group_label: "Market Information"
      type: yesno
      sql: ${TABLE}."IS_MANAGED_BY_ES_OWNED_MARKET" ;;
    }

    dimension: market_company_id {
      group_label: "Market Information"
      type: string
      sql: ${TABLE}."MARKET_COMPANY_ID" ;;
    }

    dimension: oec {
      group_label: "Asset Information"
      label: "OEC"
      description: "OEC of asset"
      type: number
      sql: ${TABLE}."OEC" ;;
      value_format_name: usd_0
    }

    measure: oec_sum {
      label: "Total OEC"
      type: sum
      sql: ${oec} ;;
      value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    }

    dimension: rental_id {
      type: string
      sql: ${TABLE}."RENTAL_ID" ;;
    }

    dimension: is_on_rent {
      type: yesno
      sql: ${TABLE}."IS_ON_RENT" ;;
    }

    dimension: is_last_rental_in_day {
      type: yesno
      sql: ${TABLE}."IS_LAST_RENTAL_IN_DAY" ;;
    }


    dimension: asset_inventory_status {
      type: string
      sql: ${TABLE}."ASSET_INVENTORY_STATUS" ;;
    }

    dimension: oec_on_rent {
      description: "OEC of asset on rent after considering asset swaps"
      type: number
      sql: ${TABLE}."OEC_ON_RENT" ;;
    }


    dimension: is_asset_unavailable {
      group_label: "Asset Inventory Status Info"
      type: yesno
      sql: ${TABLE}."IS_ASSET_UNAVAILABLE" ;;
    }



    measure: rerent_on_rent_asset_count {
      group_label: "Re-Rents"
      description: "Count of re-rent assets that are on rent for a rental id that has not ended. "
      type: count_distinct
      sql: ${asset_id};;
      filters: [is_on_rent: "yes",
        is_last_rental_in_day: "yes",
        is_rerent_asset: "yes"]
      drill_fields: [rerent_detail*]
    }

    measure: inventory_total_oec {
      #using max for drill downs to sort the drill by most to least OEC
      label: "OEC"
      type: max
      description: "OEC of assets where in_total_fleet = TRUE"
      sql: coalesce(${oec},0) ;;
      value_format_name: usd_0
    }


    # dropping from market oec status detail...is_contributing_oec, rental_id

    set: detail {
      fields: [
        asset_id,
        daily_timestamp_time,
        rental_branch_id,
        service_branch_id,
        inventory_branch_id,
        market_id,
        asset_company_id,
        asset_inventory_status,
        is_rerent_asset,
        market_company_id,
        oec,
        asset_type_id,
        asset_type,
        first_rental_date_time,
        make,
        model,
        year,
        category_id,
        category,
        equipment_class_id,
        equipment_class,
        is_on_rent,
        rental_id
      ]
    }

    set: oec_detail {
      fields: [
        asset_id,
        category,
        equipment_class,
        rental_branch_id,
        market_region_xwalk.market_name,
        asset_inventory_status,
        oec,
        is_on_rent,
        rental_id
      ]
    }

    set: asset_in_status_count_detail {
      fields: [asset_id,
        rental_branch_name,
        service_branch_name,
        asset_inventory_status,
        days_in_status]
    }

    set: rerent_detail {
      fields: [asset_id_drilless, market_name, category, make, model, year]
    }
  }
