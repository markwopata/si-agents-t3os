view: product_specialist_historical_revenue {
  derived_table: {
    sql:
    WITH dated_orders AS (
                                SELECT os.*,
                                       o.date_created
                                  FROM es_warehouse.public.order_salespersons os
                                           LEFT JOIN es_warehouse.public.orders o
                                           ON os.order_id = o.order_id
                                 WHERE os.user_id IN (
                                                         SELECT salesperson_user_id
                                                           FROM analytics.public.commissions_salesperson_data
                                                          WHERE commission_type IN ('ITL', 'P&P'))
                                    AND os.salesperson_type_id = 2),
         filtered_orders AS (
                                SELECT distinct *
                                  FROM dated_orders do
                                           LEFT JOIN analytics.public.commissions_salesperson_data csd
                                           ON do.user_id = csd.salesperson_user_id
                                        --   AND do.date_created BETWEEN csd.guarantee_start_date AND csd.commission_end_date
                                 WHERE commission_type IN ('ITL', 'P&P'))
  SELECT li.gl_date_created AS date,
         li.gl_billing_approved_date,
         i.invoice_id,
         i.invoice_no,
         li.rental_id,
         fo.user_id,
         fo.salesperson_type_id,
         li.amount,
         li.line_item_type_id,
         li.line_item_id,
         li.credit_note_line_item_id,
         li.branch_id       AS market_id,
         TRUE               AS date_created_tf,
         i.company_id,
         ra.rate_tier,
         ra.final_equipment_class,
         ra.percent_discount
    FROM filtered_orders fo
             LEFT JOIN es_warehouse.public.invoices i
             ON fo.order_id = i.order_id
             LEFT JOIN analytics.public.v_line_items li
             ON i.invoice_id = li.invoice_id
             LEFT JOIN es_warehouse.public.rentals r
             ON i.order_id = r.order_id AND li.asset_id = r.asset_id AND li.rental_id = r.rental_id
             LEFT JOIN analytics.public.rateachievement_points ra
             ON li.rental_id = ra.rental_id AND i.invoice_id = ra.invoice_id AND li.asset_id = ra.asset_id
   WHERE li.gl_date_created >= DATEADD(YEAR, -1, CURRENT_DATE)
     AND i.company_id NOT IN (1854, 1855, 8151, 155)
   UNION ALL
  SELECT li.gl_billing_approved_date AS date,
         li.gl_billing_approved_date,
         i.invoice_id,
         i.invoice_no,
         li.rental_id,
         fo.user_id,
         fo.salesperson_type_id,
         li.amount,
         li.line_item_type_id,
         li.line_item_id,
         li.credit_note_line_item_id,
         li.branch_id                AS market_id,
         FALSE                       AS date_created_tf,
         i.company_id,
         ra.rate_tier,
         ra.final_equipment_class,
         ra.percent_discount
    FROM filtered_orders fo
             LEFT JOIN es_warehouse.public.invoices i
             ON fo.order_id = i.order_id
             LEFT JOIN analytics.public.v_line_items li
             ON i.invoice_id = li.invoice_id
             LEFT JOIN es_warehouse.public.rentals r
             ON i.order_id = r.order_id AND li.asset_id = r.asset_id AND li.rental_id = r.rental_id
             LEFT JOIN analytics.public.rateachievement_points ra
             ON r.rental_id = ra.rental_id AND i.invoice_id = ra.invoice_id AND r.asset_id = ra.asset_id
   WHERE li.gl_billing_approved_date IS NOT NULL
     AND li.gl_billing_approved_date >= DATEADD(YEAR, -1, CURRENT_DATE)
     AND i.company_id NOT IN (1854, 1855, 8151, 155)
;;
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
    sql: concat(${TABLE}."INVOICE_ID", ${TABLE}."LINE_ITEM_ID",COALESCE(${TABLE}."CREDIT_NOTE_LINE_ITEM_ID",0) ) ;;
    primary_key: yes
  }

  dimension: rental_id {
    type: number
    sql: ${TABLE}."RENTAL_ID" ;;
    value_format_name: id
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
    value_format_name: id
  }

  dimension: salesperson_type_id {
    type: string
    sql: case
          when ${TABLE}."SALESPERSON_TYPE_ID" = 1 then 'Primary'
          else 'Secondary'
          end;;
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

  dimension: date_created_tf {
    type: yesno
    sql: ${TABLE}."DATE_CREATED_TF" ;;
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

  # dimension: secondary_salesperson_ind {
  #   type: string
  #   sql: ${TABLE}."SECONDARY_SALESPERSON_IND" ;;
  #   html: <p style="text-align: center">{{rendered_value}}</p> ;;
  # }

  dimension: commission_line_items {
    type: yesno
    sql: (${line_item_type_id} in (6,8,108,109)
      or (${line_item_type_id} = 5 and ${amount}>=95 and ${date_raw}>'2022-01-31'::date)) ;;
  }

  dimension: product_specialist_line_items {
    type: yesno
    sql: ${line_item_type_id} in (6,8,108,109,13,20,44,21,98,99,100,101,102,103,104,105) ;;
  }

  dimension: rental_line_items {
    type: yesno
    sql: ${line_item_type_id} in (6,8,108,109) ;;
  }

  dimension: ancillary_line_items {
    type: yesno
    # hidden: yes
    sql: ${line_item_type_id} in (13,20,44,21,98,99,100,101,102,103,104,105);;
  }

  dimension: line_item_name {
    type: string
    sql: case when ${line_item_type_id} in (6,8,108,109) then 'Rental'
      when ${line_item_type_id} = 5 then 'Delivery' else null end;;
  }

  measure: total_amount {
    type: sum
    sql: ${amount} ;;
    value_format_name: usd_0
  }

  measure: billing_approved_amount {
    type: sum
    sql: ${amount} ;;
    filters: [date_created_tf: "No"]
    value_format_name: usd_0
    drill_fields: [detail*]
  }

  measure: date_created_amount {
    type: sum
    sql: ${amount} ;;
    filters: [date_created_tf: "Yes"]
    value_format_name: usd_0
    drill_fields: [detail*]
    ##  html: Rental - {{ total_rental_revenue._rendered_value }} <br> >$95 Delivery - {{ total_delivery_revenue._rendered_value }} ;;
  }

  measure: unapproved_total_amount {
    type: sum
    sql: ${amount} ;;
    filters: [date_created_tf: "Yes",gl_billing_approved_date_date: "null",]
    value_format_name: usd_0
    drill_fields: [unapproved_detail*]
  }

  measure: unapproved_rental_amount {
    type: sum
    sql: ${amount} ;;
    filters: [date_created_tf: "Yes",gl_billing_approved_date_date: "null", rental_line_items: "Yes"]
    value_format_name: usd_0
    drill_fields: [unapproved_detail*]
  }

  measure: unapproved_ancillary_amount {
    type: sum
    sql: ${amount} ;;
    filters: [date_created_tf: "Yes",gl_billing_approved_date_date: "null", ancillary_line_items: "Yes"]
    value_format_name: usd_0
    drill_fields: [unapproved_detail*]
  }

  measure: date_created_rental {
    type: sum
    sql: ${amount} ;;
    filters: [date_created_tf: "Yes",
      rental_line_items: "Yes"]
    drill_fields: [detail*]
    ##  html: Rental - {{ total_rental_revenue._rendered_value }} <br> >$95 Delivery - {{ total_delivery_revenue._rendered_value }} ;;
  }

  measure: date_created_delivery {
    type: sum
    sql: ${amount} ;;
    filters: [date_created_tf: "Yes",
      line_item_type_id: "5"]
    drill_fields: [detail*]
    ##  html: Rental - {{ total_rental_revenue._rendered_value }} <br> >$95 Delivery - {{ total_delivery_revenue._rendered_value }} ;;
  }

  # measure: in_market_rental_revenue {
  #   type: sum
  #   sql: ${amount} ;;
  #   value_format_name: usd
  #   filters: [salesperson_to_market.is_main_market: "yes",
  #     line_item_type_id: "6,8,108,109"]
  #   drill_fields: [detail*]
  # }

  # measure: out_of_market_rental_revenue {
  #   type: sum
  #   sql: ${amount} ;;
  #   value_format_name: usd
  #   filters: [salesperson_to_market.is_main_market: "no",
  #     line_item_type_id: "6,8,108,109"]
  #   drill_fields: [detail*]
  # }

  measure: total_delivery_revenue {
    type: sum
    sql: ${amount} ;;
    value_format_name: usd_0
    filters: [line_item_type_id: "5"]
    drill_fields: [detail*]
  }

  measure: total_rental_revenue {
    type: sum
    sql: ${amount} ;;
    value_format_name: usd_0
    filters: [rental_line_items: "yes"]
    drill_fields: [detail*]
  }

  measure: below_floor_date_created {
    type: sum
    sql: ${amount} ;;
    filters: [date_created_tf: "Yes", rate_tier: "3"]
    drill_fields: [detail*]
    html: {{rendered_value}} || {{below_floor_pct_of_date_created._rendered_value}} of total ;;
    value_format_name: usd_0
  }

  measure: between_floor_online_date_created {
    type: sum
    sql: ${amount} ;;
    filters: [date_created_tf: "Yes", rate_tier: "0,2,null"]
    drill_fields: [detail*]
    html: {{rendered_value}} || {{btw_floor_online_pct_of_date_created._rendered_value}} of total ;;
    value_format_name: usd_0
  }

  measure: above_online_date_created {
    type: sum
    sql: ${amount} ;;
    filters: [date_created_tf: "Yes", rate_tier: "1"]
    drill_fields: [detail*]
    html: {{rendered_value}} || {{above_online_pct_of_date_created._rendered_value}} of total ;;
    value_format_name: usd_0
  }

  # measure: no_rate_date_created {
  #   type: sum
  #   sql: ${amount} ;;
  #   filters: [date_created_tf: "Yes", rate_tier: "0, null"]
  #   drill_fields: [detail*]
  #   html: {{rendered_value}} || {{no_rate_pct_of_date_created._rendered_value}} of total ;;
  #   value_format_name: usd
  # }

  measure: below_floor_pct_of_date_created {
    type: number
    sql: ${below_floor_date_created}/${date_created_amount} ;;
    value_format_name: percent_1
  }

  measure: btw_floor_online_pct_of_date_created {
    type: number
    sql: ${between_floor_online_date_created}/${date_created_amount} ;;
    value_format_name: percent_1
  }

  measure: above_online_pct_of_date_created {
    type: number
    sql: ${above_online_date_created}/${date_created_amount} ;;
    value_format_name: percent_1
  }

  # measure: no_rate_pct_of_date_created {
  #   type: number
  #   sql: ${no_rate_date_created}/${date_created_amount} ;;
  #   value_format_name: percent_1
  # }

  set: detail {
    fields: [
      market_id,
      market_region_xwalk.market_name,
      company_id,
      companies.name,
      invoice_id,
      final_equipment_class,
      total_amount,
      percent_discount
    ]
  }

 set: unapproved_detail {
   fields: [company_id,
      companies.name,
      invoice_id,
      invoice_no,
      date_date,
      gl_billing_approved_date_date,
      unapproved_rental_amount,
      unapproved_ancillary_amount
    ]
 }
}
