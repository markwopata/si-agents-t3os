view: ancillary_rev_market_refresh_dash_v2 {
sql_table_name: analytics.intacct_models.int_revenue;;


    measure: count {
      type: count
      drill_fields: [detail*]
    }

    dimension_group: gl_date {
      type: time
      sql: ${TABLE}."GL_DATE" ;;
    }

    dimension: formatted_date_gl {
      group_label: "GL HTML Formatted Date"
      label: "Date"
      type: date
      sql: ${gl_date_date} ;;
      html: {{ rendered_value | date: "%b %d, %Y" }};;
    }

    dimension: formatted_date_as_month_gl {
      group_label: "GL HTML Formatted Date"
      label: "Month Date"
      type: date
      sql: ${gl_date_date} ;;
      html: {{ rendered_value | date: "%b %Y"  }};;
    }

    dimension: formatted_month_gl {
      group_label: "GL HTML Formatted Date"
      label: "Month"
      type: date
      sql: DATE_TRUNC(month,${gl_date_date}::DATE) ;;
      html: {{ rendered_value | date: "%b %Y"  }};;
    }

    dimension: market_id {
      type: string
      sql: ${TABLE}."MARKET_ID" ;;
    }

    dimension: company_id {
      type: string
      sql: ${TABLE}."COMPANY_ID" ;;
    }

    dimension: customer_name {
      type: string
      sql: ${TABLE}."CUSTOMER_NAME" ;;
    }

    dimension: line_item_id {
      type: string
      sql: ${TABLE}."LINE_ITEM_ID" ;;
    }

    dimension: line_item_type_id {
      type: string
      sql: ${TABLE}."LINE_ITEM_TYPE_ID" ;;
    }

    dimension: is_rental_revenue {
      type: yesno
      sql: ${TABLE}."IS_RENTAL_REVENUE" ;;
    }

    dimension: line_item_type_name {
      type: string
      sql: ${TABLE}."LINE_ITEM_TYPE_NAME" ;;
    }

    dimension: revenue_type {
      type: string
      sql:
        case when line_item_type_id in (11, 12, 25, 29, 49, 151) then 'Parts'
          when line_item_type_id in (24, 50, 80, 81, 110, 111, 123, 141, 145, 147, 148, 149, 150, 152, 153) then 'Retail'
          when line_item_type_id in (13, 20, 26) then 'Service'
          when line_item_type_id in (44) then 'Bulk'
          when line_item_type_id in (130,129,132,131) then 'Onsite Fuel'
          when line_item_type_id in (5) then 'Delivery'
          when line_item_type_id in (28, 2, 7, 21, 98, 99, 100, 101, 9) then 'Other'
          else NULL
          end;;
    }

    dimension: is_intercompany {
      type: yesno
      sql: ${TABLE}."IS_INTERCOMPANY" ;;
    }

    dimension: amount {
      type: number
      sql: ${TABLE}."AMOUNT" ;;
      value_format_name: usd_0
    }

    measure: amount_sum {
      label: "Revenue Total"
      type: sum
      sql: COALESCE(${amount},0);;
      value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
      drill_fields: [company_ans_rev_detail*]
    }

    measure: amount_sum_region {
      group_label: "Region"
      label: "Revenue Total"
      type: sum
      sql: COALESCE(${amount},0);;
      value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
      drill_fields: [region_ans_rev_detail*]
    }

    measure: amount_sum_district {
      group_label: "District"
      label: "Revenue Total"
      type: sum
      sql: COALESCE(${amount},0);;
      value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
      drill_fields: [district_ans_rev_detail*]
    }

    measure: amount_sum_market {
      group_label: "Market"
      label: "Revenue Total"
      type: sum
      sql: COALESCE(${amount},0);;
      value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
      drill_fields: [market_ans_rev_detail*]
    }

    dimension: asset_id {
      type: string
      sql: ${TABLE}."ASSET_ID" ;;
    }

    dimension: rental_id {
      type: string
      sql: ${TABLE}."RENTAL_ID" ;;
    }

    dimension: primary_salesperson_id {
      type: string
      sql: ${TABLE}."PRIMARY_SALESPERSON_ID" ;;
    }

    dimension: secondary_salesperson_ids {
      type: string
      sql: ${TABLE}."SECONDARY_SALESPERSON_IDS" ;;
    }

    dimension: ordered_revenue_types {
      description: "Ordered categories for revenue types to be used in formatting."
      type: string
      sql:
      CASE
        WHEN ${revenue_type} = 'Retail' THEN '1 - Retail'
        WHEN ${revenue_type} = 'Delivery' THEN '2 - Delivery'
        WHEN ${revenue_type} = 'Service' THEN '3 - Service'
        WHEN ${revenue_type} = 'Parts' THEN '4 - Parts'
        WHEN ${revenue_type} = 'Other' THEN '5 - Other'
        WHEN ${revenue_type} = 'Bulk' THEN '6 - Bulk'
        WHEN ${revenue_type} = 'Onsite Fuel' THEN '7 - Onsite Fuel'
        ELSE '8 - Unknown'
      END ;;
    }

    set: company_ans_rev_detail {
      fields: [formatted_month_gl, market_region_xwalk.region_name, revenue_type, amount_sum]
    }

    set: region_ans_rev_detail {
      fields: [formatted_month_gl, market_region_xwalk.district, revenue_type, amount_sum]
    }

    set: district_ans_rev_detail {
      fields: [formatted_month_gl, market_region_xwalk.market_name, revenue_type, amount_sum]
    }

    set: market_ans_rev_detail {
      fields: [formatted_month_gl, market_region_xwalk.market_name, revenue_type, amount_sum]
    }

    set: detail {
      fields: [
        gl_date_date,
        market_id,
        company_id,
        customer_name,
        line_item_id,
        line_item_type_id,
        is_rental_revenue,
        line_item_type_name,
        revenue_type,
        amount,
        asset_id,
        rental_id,
        primary_salesperson_id,
        secondary_salesperson_ids
      ]
    }
  }
