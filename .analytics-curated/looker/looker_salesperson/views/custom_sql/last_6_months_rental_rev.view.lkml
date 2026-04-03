view: last_6_months_rental_rev {
  sql_table_name: analytics.bi_ops.sp_6_month_rental_rev_hist ;;


    filter: salesperson_filter {
    }

    dimension_group: date {
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
      sql: CAST(${TABLE}."DATE" AS TIMESTAMP_NTZ) ;;
    }

  dimension_group: date_refresh_timestamp {
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
    sql: ${TABLE}."DATE_REFRESH_TIMESTAMP" ;;
  }

    dimension_group: gl_billing_approved_date {
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
      sql: CAST(${TABLE}."GL_BILLING_APPROVED_DATE" AS TIMESTAMP_NTZ) ;;
    }

    dimension: invoice_id {
      type: number
      sql: ${TABLE}."INVOICE_ID" ;;
      value_format_name: id
    }

    dimension: invoice_no {
      type: string
      sql: ${TABLE}."INVOICE_NO" ;;
    }

    dimension: invoice_id_pk {
      type: number
      sql: concat(${TABLE}."INVOICE_ID", ${TABLE}."LINE_ITEM_ID",COALESCE(${TABLE}."CREDIT_NOTE_LINE_ITEM_ID",0)) ;;
      primary_key: yes
    }

    dimension: rental_id {
      type: number
      sql: ${TABLE}."RENTAL_ID" ;;
      value_format_name: id
    }

    dimension: salesperson_user_id {
      type: number
      sql: ${TABLE}."SALESPERSON_USER_ID" ;;
      value_format_name: id
    }

  dimension: salesperson_email_address {
    type: string
    sql: ${TABLE}."SALESPERSON_EMAIL_ADDRESS" ;;
  }

    dimension: amount {
      type: number
      sql: ${TABLE}."AMOUNT" ;;
      value_format_name: usd
    }

    dimension: line_item_type_id {
      type: number
      sql: ${TABLE}."LINE_ITEM_TYPE_ID" ;;
      value_format_name: id
    }

    dimension: market_id {
      type: number
      sql: ${TABLE}."MARKET_ID" ;;
      value_format_name: id
    }
  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;

  }

    dimension: date_created_tf {
      type: yesno
      sql: ${TABLE}."DATE_CREATED_TF" ;;
    }

    dimension: is_main_market {
      type: yesno
      sql: ${TABLE}."IS_MAIN_MARKET" ;;
    }

    dimension: company_id {
      type: number
      sql: ${TABLE}."COMPANY_ID" ;;
      value_format_name: id
    }

    dimension: rate_tier {
      type: number
      sql: ${TABLE}."RATE_TIER" ;;
    }

    dimension: final_equipment_class {
      label: "Equipment Class"
      type: string
      sql: ${TABLE}."FINAL_EQUIPMENT_CLASS" ;;
    }

    dimension: percent_discount {
      type: number
      sql: ${TABLE}."PERCENT_DISCOUNT" ;;
      value_format_name: percent_0
    }

    dimension: rate_tier_name {
      type: string
      sql: case when ${rate_tier} = 0 then 'Below Online/Above Floor'
              when ${rate_tier} = 1 then 'Above Online'
              when ${rate_tier} = 2 then 'Below Online/Above Floor'
              when ${rate_tier} = 3 then 'Below Floor' else 'Below Online/Above Floor' end;;
    }

    dimension: secondary_salesperson_ind {
      type: string
      sql: ${TABLE}."SECONDARY_SALESPERSON_IND" ;;
      html: <p style="text-align: center">{{rendered_value}}</p> ;;
    }

    dimension: salesperson_with_id {
      type: string
      sql: ${TABLE}."SALESPERSON_WITH_ID" ;;
    }

    dimension: commission_line_items {
      type: yesno
      sql: (${line_item_type_id} in (6,8,108,109,44)
        or (${line_item_type_id} = 5 and ${amount}>=95 and ${date_raw}>'2022-01-31'::date) and ${date_raw}<'2022-09-01'::date)
        or (${line_item_type_id} = 5 and ${amount}>=125 and ${date_raw}>'2022-08-31'::date);;
    }


    dimension: line_item_name {
      type: string
      sql: case when ${line_item_type_id} in (6,8,108,109) then 'Rental' else null end;;
    }

    measure: billing_approved_amount{
      type: sum
      sql: ${amount} ;;
      value_format_name: usd_0
      drill_fields: [detail*]
    }


    dimension: business_segment_name {
      label: "Business Segment"
      type: string
      sql: ${TABLE}."BUSINESS_SEGMENT_NAME" ;;
    }


    measure: billing_approved_amount_gen_rental {
      group_label: "Business Segment Bill Approved Amounts"
      label: "Gen Rental"
      type: sum
      sql: CASE WHEN ${business_segment_name} = 'Gen Rental' then ${amount} end ;;

      drill_fields: [detail*]
      html: {{rendered_value}} || {{gen_rental_pct_of_billing_aprroved_amount._rendered_value}} of total ;;
      value_format_name: usd_0
    }

    measure: gen_rental_pct_of_billing_aprroved_amount {
      type: number
      sql: ${billing_approved_amount_gen_rental}/NULLIFZERO(${billing_approved_amount}) ;;
      value_format_name: percent_1
    }

    measure: billing_approved_amount_advanced_solutions {
      group_label: "Business Segment Bill Approved Amounts"
      label: "Advanced Solutions"
      type: sum
      sql:  CASE WHEN ${business_segment_name} = 'Advanced Solutions' then ${amount} end ;;
      drill_fields: [detail*]
      html: {{rendered_value}} || {{advanced_solutions_pct_of_billing_aprroved_amount._rendered_value}} of total ;;
      value_format_name: usd_0
    }

    measure: advanced_solutions_pct_of_billing_aprroved_amount {
      type: number
      sql: ${billing_approved_amount_advanced_solutions}/NULLIFZERO(${billing_approved_amount}) ;;
      value_format_name: percent_1
    }

    measure: billing_approved_amount_itl {
      group_label: "Business Segment Bill Approved Amounts"
      label: "ITL"
      type: sum
      sql:  CASE WHEN ${business_segment_name} = 'ITL' then ${amount} end ;;

      drill_fields: [detail*]
      html: {{rendered_value}} || {{itl_pct_of_billing_aprroved_amount._rendered_value}} of total ;;
      value_format_name: usd_0
    }

    measure: itl_pct_of_billing_aprroved_amount {
      type: number
      sql: ${billing_approved_amount_itl}/NULLIFZERO(${billing_approved_amount}) ;;
      value_format_name: percent_1
    }

    measure: billing_approved_amount_no_asset_listed {
      group_label: "Business Segment Bill Approved Amounts"
      label: "No Class Listed"
      type: sum
      sql:  CASE WHEN ${business_segment_name} = 'No Class Listed' then ${amount} end ;;
      drill_fields: [detail*]
      html: {{rendered_value}} || {{no_asset_listed_pct_of_billing_aprroved_amount._rendered_value}} of total ;;
      value_format_name: usd_0
    }

    measure: no_asset_listed_pct_of_billing_aprroved_amount {
      type: number
      sql: ${billing_approved_amount_no_asset_listed}/NULLIFZERO(${billing_approved_amount}) ;;
      value_format_name: percent_1
    }


    measure: in_market_rental_revenue {
      type: sum
      sql: CASE WHEN ${is_main_market} = TRUE THEN ${amount} ELSE NULL END;;

      drill_fields: [detail*]
      html: {{rendered_value}} || {{in_market_pct_of_billing_approved._rendered_value}} of total ;;
      value_format_name: usd_0
    }

    measure: out_of_market_rental_revenue {
      type: sum
      sql: CASE WHEN ${is_main_market} = FALSE THEN ${amount} ELSE NULL END;;

      drill_fields: [detail*]
      html: {{rendered_value}} || {{out_of_market_pct_of_billing_approved._rendered_value}} of total ;;
      value_format_name: usd_0
    }

    measure: total_rental_revenue {
      type: sum
      sql: ${amount} ;;
      value_format_name: usd_0

      drill_fields: [detail*]
    }


    measure: below_floor_billing_approved {
      type: sum
      sql: ${amount} ;;
      filters: [rate_tier: "3"]
      drill_fields: [detail*]
      html: {{rendered_value}} || {{below_floor_pct_of_billing_approved._rendered_value}} of total ;;
      value_format_name: usd_0
    }


    measure: between_floor_online_billing_approved {
      type: sum
      sql: ${amount} ;;
      filters: [rate_tier: "0,2,null"]
      drill_fields: [detail*]
      html: {{rendered_value}} || {{btw_floor_online_pct_of_billing_approved._rendered_value}} of total ;;
      value_format_name: usd_0
    }


    measure: above_online_billing_approved {
      type: sum
      sql: ${amount} ;;
      filters: [rate_tier: "1"]
      drill_fields: [detail*]
      html: {{rendered_value}} || {{above_online_pct_of_billing_approved._rendered_value}} of total ;;
      value_format_name: usd_0
    }




    measure: below_floor_pct_of_billing_approved {
      type: number
      sql: ${below_floor_billing_approved}/nullifzero(${billing_approved_amount}) ;;
      value_format_name: percent_1
    }



    measure: btw_floor_online_pct_of_billing_approved {
      type: number
      sql: ${between_floor_online_billing_approved}/nullifzero(${billing_approved_amount}) ;;
      value_format_name: percent_1
    }


    measure: above_online_pct_of_billing_approved {
      type: number
      sql: ${above_online_billing_approved}/nullifzero(${billing_approved_amount}) ;;
      value_format_name: percent_1
    }

    measure: in_market_pct_of_billing_approved {
      type: number
      sql: ${in_market_rental_revenue}/nullifzero(${billing_approved_amount}) ;;
      value_format_name: percent_1
    }

    measure: out_of_market_pct_of_billing_approved {
      type: number
      sql: ${out_of_market_rental_revenue}/nullifzero(${billing_approved_amount}) ;;
      value_format_name: percent_1
    }

    set: detail {
      fields: [
        market_id,
        market_name,
        company_id,
        companies.name,
        invoice_id,
        rental_id,
        secondary_salesperson_ind,
        business_segment_name,
        final_equipment_class,
        percent_discount,
        total_rental_revenue
      ]
    }


  }
