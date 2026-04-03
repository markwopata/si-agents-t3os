view: last_6_months_rental_rev_agg {
    sql_table_name: analytics.bi_ops.sp_6_month_rental_rev_hist_agg ;;


    filter: salesperson_filter {
    }

    dimension_group: month {
      type: time
      timeframes: [
        date,
        month,
        year
      ]
      sql: ${TABLE}."MONTH" ;;
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


    dimension: pk {
      type: number
      sql: concat(${TABLE}."SALESPERSON_USER_ID", ${TABLE}."TOTAL_AMOUNT", COALESCE(${TABLE}."RATE_TIER",0), TO_CHAR(${TABLE}."MONTH"), ${TABLE}."IS_MAIN_MARKET") ;;
      primary_key: yes
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
      sql: ${TABLE}."TOTAL_AMOUNT" ;;
      value_format_name: usd
    }

  measure: total_amount_sum {
    type: sum
    sql: ${amount} ;;
    value_format_name: usd
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

    dimension: is_main_market {
      type: yesno
      sql: ${TABLE}."IS_MAIN_MARKET" ;;
    }

    dimension: rate_tier {
      type: number
      sql: ${TABLE}."RATE_TIER" ;;
    }

    dimension: rate_tier_name {
      type: string
      sql: case when ${rate_tier} = 0 then 'Below Online/Above Floor'
              when ${rate_tier} = 1 then 'Above Online'
              when ${rate_tier} = 2 then 'Below Online/Above Floor'
              when ${rate_tier} = 3 then 'Below Floor' else 'Below Online/Above Floor' end;;
    }

    dimension: salesperson_with_id {
      type: string
      sql: ${TABLE}."SALESPERSON_WITH_ID" ;;
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
      sql: ${billing_approved_amount_gen_rental}/NULLIFZERO(${total_amount_sum}) ;;
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
      sql: ${billing_approved_amount_advanced_solutions}/NULLIFZERO(${total_amount_sum}) ;;
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
      sql: ${billing_approved_amount_itl}/NULLIFZERO(${total_amount_sum}) ;;
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
      sql: ${billing_approved_amount_no_asset_listed}/NULLIFZERO(${total_amount_sum}) ;;
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
      sql: ${below_floor_billing_approved}/nullifzero(${total_amount_sum}) ;;
      value_format_name: percent_1
    }



    measure: btw_floor_online_pct_of_billing_approved {
      type: number
      sql: ${between_floor_online_billing_approved}/nullifzero(${total_amount_sum}) ;;
      value_format_name: percent_1
    }


    measure: above_online_pct_of_billing_approved {
      type: number
      sql: ${above_online_billing_approved}/nullifzero(${total_amount_sum}) ;;
      value_format_name: percent_1
    }

    measure: in_market_pct_of_billing_approved {
      type: number
      sql: ${in_market_rental_revenue}/nullifzero(${total_amount_sum}) ;;
      value_format_name: percent_1
    }

    measure: out_of_market_pct_of_billing_approved {
      type: number
      sql: ${out_of_market_rental_revenue}/nullifzero(${total_amount_sum}) ;;
      value_format_name: percent_1
    }

    set: detail {
      fields: [
        last_6_months_rental_rev.market_id,
        last_6_months_rental_rev.market_name,
        last_6_months_rental_rev.company_id,
        companies.name,
        last_6_months_rental_rev.invoice_id,
        last_6_months_rental_rev.secondary_salesperson_ind,
        last_6_months_rental_rev.business_segment_name,
        last_6_months_rental_rev.final_equipment_class,
        last_6_months_rental_rev.percent_discount,
        last_6_months_rental_rev.total_rental_revenue
      ]
    }


  }
