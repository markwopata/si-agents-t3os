view: secondary_sales_rep_revenue {
  derived_table: {
    sql:
        SELECT li.GL_DATE_CREATED                      as date,
                    i.INVOICE_ID,
                    li.RENTAL_ID,
                    i.salesperson_user_id as primary_salesperson_id,
                    secondary_reps.secondary_salesperson_id,
                    li.AMOUNT,
                    li.LINE_ITEM_TYPE_ID,
                    li.LINE_ITEM_ID,
                    li.CREDIT_NOTE_LINE_ITEM_ID,
                    li.BRANCH_ID                as market_id,
                    TRUE                        as date_created_tf,
                    i.COMPANY_ID,
                    ra.RATE_TIER,
                    ra.EQUIPMENT_CLASS as final_equipment_class,
                    ra.percent_discount,
                    ifnull(bs.name, 'No Asset Listed') as business_segment_name,
                    case
                    when bs.name = 'Gen Rental' then 1
                    when bs.name = 'Advanced Solutions' then 2
                    when bs.name = 'ITL' then 3
                    else 5 end as segment_sort

                    FROM es_warehouse.public.invoices i
                    JOIN analytics.public.v_line_items li
                    ON i.invoice_id = li.invoice_id
                    LEFT JOIN es_warehouse.public.assets a on a.asset_id = li.asset_id
                    LEFT JOIN es_warehouse.public.equipment_classes ec ON ec.equipment_class_id = a.equipment_class_id
                    LEFT JOIN ES_WAREHOUSE.PUBLIC.BUSINESS_SEGMENTS bs ON bs.business_segment_id = ec.business_segment_id
                    JOIN (SELECT INVOICE_ID
                          , VALUE AS SECONDARY_SALESPERSON_ID
                          FROM ES_WAREHOUSE.PUBLIC.APPROVED_INVOICE_SALESPERSONS
                            , TABLE ( FLATTEN(SECONDARY_SALESPERSON_IDS) )
                    WHERE SECONDARY_SALESPERSON_IDS <> '[]') SECONDARY_REPS
                    ON I.INVOICE_ID = SECONDARY_REPS.INVOICE_ID
                    LEFT JOIN es_warehouse.public.orders o
                    ON i.order_id = o.order_id
                    LEFT JOIN es_warehouse.public.rentals r
                    ON i.order_id = r.order_id AND li.asset_id = r.asset_id and li.rental_id = r.rental_id
                    LEFT JOIN analytics.public.rateachievement_points ra
                    ON li.rental_id = ra.rental_id AND i.invoice_id = ra.invoice_id AND li.asset_id = ra.asset_id
                    LEFT JOIN es_warehouse.public.users u on u.user_id = secondary_reps.secondary_salesperson_id
             WHERE li.GL_DATE_CREATED >= DATEADD(YEAR,-1,current_date)
                  AND i.company_id not in (1854,1855,8151,155)
                  AND
                  {% if _user_attributes['department']  == "'salesperson'" %}
                  u.email_address = '{{ _user_attributes['email'] }}'
                  {% else %}
                  1 = 1
                  {% endif %}
             UNION ALL
             SELECT li.GL_BILLING_APPROVED_DATE as date,
                    i.INVOICE_ID,
                    li.RENTAL_ID,
                    i.salesperson_user_id as primary_salesperson_id,
                    secondary_reps.secondary_salesperson_id,
                    li.AMOUNT,
                    li.LINE_ITEM_TYPE_ID,
                    li.LINE_ITEM_ID,
                    li.CREDIT_NOTE_LINE_ITEM_ID,
                    li.BRANCH_ID                as market_id,
                    FALSE                       as date_created_tf,
                    i.COMPANY_ID,
                    ra.RATE_TIER,
                    ra.EQUIPMENT_CLASS as final_equipment_class,
                    ra.percent_discount,
                    ifnull(bs.name, 'No Asset Listed') as business_segment_name,
                    case
                    when bs.name = 'Gen Rental' then 1
                    when bs.name = 'Advanced Solutions' then 2
                    when bs.name = 'ITL' then 3
                    else 5 end as segment_sort
             FROM es_warehouse.public.invoices i
                    JOIN analytics.public.v_line_items li
                    ON i.invoice_id = li.invoice_id
                    -- on analytics.public.v_line_items li
                    LEFT JOIN es_warehouse.public.assets a on a.asset_id = li.asset_id
                    LEFT JOIN es_warehouse.public.equipment_classes ec ON ec.equipment_class_id = a.equipment_class_id
                    LEFT JOIN ES_WAREHOUSE.PUBLIC.BUSINESS_SEGMENTS bs ON bs.business_segment_id = ec.business_segment_id
                    JOIN (SELECT INVOICE_ID
                          , VALUE AS SECONDARY_SALESPERSON_ID
                          FROM ES_WAREHOUSE.PUBLIC.APPROVED_INVOICE_SALESPERSONS
                            , TABLE ( FLATTEN(SECONDARY_SALESPERSON_IDS) )
                    WHERE SECONDARY_SALESPERSON_IDS <> '[]') SECONDARY_REPS
                    ON I.INVOICE_ID = SECONDARY_REPS.INVOICE_ID
                    LEFT JOIN es_warehouse.public.orders o
                    ON i.order_id = o.order_id
                    LEFT JOIN es_warehouse.public.rentals r
                    ON i.order_id = r.order_id AND li.asset_id = r.asset_id and li.rental_id = r.rental_id
                    LEFT JOIN analytics.public.rateachievement_points ra
                    ON r.rental_id = ra.rental_id AND i.invoice_id = ra.invoice_id AND r.asset_id = ra.asset_id
                    LEFT JOIN es_warehouse.public.users u on u.user_id = secondary_reps.secondary_salesperson_id
             WHERE li.GL_BILLING_APPROVED_DATE is not null
             AND li.GL_BILLING_APPROVED_DATE >= DATEADD(YEAR,-1,current_date)
             AND i.company_id not in (1854,1855,8151,155)
            AND
            {% if _user_attributes['department']  == "'salesperson'" %}
            u.email_address = '{{ _user_attributes['email'] }}'
            {% else %}
            1 = 1
            {% endif %}
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

  dimension: invoice_id {
    type: number
    sql: ${TABLE}."INVOICE_ID" ;;
    value_format_name: id
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

  dimension: primary_salesperson_id {
    type: number
    sql: ${TABLE}."PRIMARY_SALESPERSON_ID";;
    value_format_name: id
  }

  dimension: secondary_salesperson_id {
    type: number
    sql: ${TABLE}."SECONDARY_SALESPERSON_ID" ;;
    value_format_name: id
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

  dimension: business_segment_name {
    label: "Business Segment"
    type: string
    sql: ${TABLE}."BUSINESS_SEGMENT_NAME" ;;
  }

  dimension: segment_sort {
    type: number
    sql: ${TABLE}."SEGMENT_SORT" ;;
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

  dimension: commission_line_items {
    type: yesno
    sql: (${line_item_type_id} in (6,8,108,109,44)
      or (${line_item_type_id} = 5 and ${amount}>=95 and ${date_raw}>'2022-01-31'::date and ${date_raw}<'2022-09-01'::date)
      or (${line_item_type_id} = 5 and ${amount}>=125 and ${date_raw}>'2022-08-31'::date) ;;
  }

  dimension: rental_line_items {
    type: yesno
    sql: ${line_item_type_id} in (6,8,108,109) ;;
  }

  dimension: line_item_name {
    type: string
    sql: case when ${line_item_type_id} in (6,8,108,109) then 'Rental'
      when ${line_item_type_id} = 5 then 'Delivery'
      when ${line_item_type_id} = 44 then 'Nonserialized (Bulk)' else null end;;
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
    drill_fields: [detail*]
    html: {{rendered_value}};;
    value_format_name: usd_0
  }

  measure: billing_approved_amount_gen_rental {
    group_label: "Business Segment Bill Approved Amounts"
    label: "Gen Rental"
    type: sum
    sql: ${amount} ;;
    filters: [date_created_tf: "No", business_segment_name: "Gen Rental"]
    drill_fields: [detail*]
    html: {{rendered_value}} || {{gen_rental_pct_of_billing_aprroved_amount._rendered_value}} of total ;;
    value_format_name: usd_0
  }

  measure: gen_rental_pct_of_billing_aprroved_amount {
    type: number
    sql: ${billing_approved_amount_gen_rental}/${billing_approved_amount} ;;
    value_format_name: percent_1
  }

  measure: billing_approved_amount_advanced_solutions {
    group_label: "Business Segment Bill Approved Amounts"
    label: "Advanced Solutions"
    type: sum
    sql: ${amount} ;;
    filters: [date_created_tf: "No", business_segment_name: "Advanced Solutions"]
    drill_fields: [detail*]
    html: {{rendered_value}} || {{advanced_solutions_pct_of_billing_aprroved_amount._rendered_value}} of total ;;
    value_format_name: usd_0
  }

  measure: advanced_solutions_pct_of_billing_aprroved_amount {
    type: number
    sql: ${billing_approved_amount_advanced_solutions}/${billing_approved_amount} ;;
    value_format_name: percent_1
  }

  measure: billing_approved_amount_itl {
    group_label: "Business Segment Bill Approved Amounts"
    label: "ITL"
    type: sum
    sql: ${amount} ;;
    filters: [date_created_tf: "No", business_segment_name: "ITL" ]
    drill_fields: [detail*]
    html: {{rendered_value}} || {{itl_pct_of_billing_aprroved_amount._rendered_value}} of total ;;
    value_format_name: usd_0
  }

  measure: itl_pct_of_billing_aprroved_amount {
    type: number
    sql: ${billing_approved_amount_itl}/${billing_approved_amount} ;;
    value_format_name: percent_1
  }

  measure: billing_approved_amount_no_asset_listed {
    group_label: "Business Segment Bill Approved Amounts"
    label: "No Asset Listed"
    type: sum
    sql: ${amount} ;;
    filters: [date_created_tf: "No", business_segment_name: "No Asset Listed"]
    drill_fields: [detail*]
    html: {{rendered_value}} || {{no_asset_listed_pct_of_billing_aprroved_amount._rendered_value}} of total ;;
    value_format_name: usd_0
  }

  measure: no_asset_listed_pct_of_billing_aprroved_amount {
    type: number
    sql: ${billing_approved_amount_no_asset_listed}/${billing_approved_amount} ;;
    value_format_name: percent_1
  }

  measure: date_created_amount {
    type: sum
    sql: ${amount} ;;
    filters: [date_created_tf: "Yes"]
    drill_fields: [detail*]
    ##  html: Rental - {{ total_rental_revenue._rendered_value }} <br> >$95 Delivery - {{ total_delivery_revenue._rendered_value }} ;;
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

  measure: below_floor_billing_approved {
    type: sum
    sql: ${amount} ;;
    filters: [date_created_tf: "No", rate_tier: "3"]
    drill_fields: [detail*]
    html: {{rendered_value}} || {{below_floor_pct_of_billing_approved._rendered_value}} of total ;;
    value_format_name: usd_0
  }

  measure: between_floor_online_billing_approved {
    type: sum
    sql: ${amount} ;;
    filters: [date_created_tf: "No", rate_tier: "0,2,null"]
    drill_fields: [detail*]
    html: {{rendered_value}} || {{btw_floor_online_pct_of_billing_approved._rendered_value}} of total ;;
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

  measure: above_online_billing_approved {
    type: sum
    sql: ${amount} ;;
    filters: [date_created_tf: "No", rate_tier: "1"]
    drill_fields: [detail*]
    html: {{rendered_value}} || {{above_online_pct_of_billing_approved._rendered_value}} of total ;;
    value_format_name: usd_0
  }

  measure: below_floor_pct_of_date_created {
    type: number
    sql: ${below_floor_date_created}/${date_created_amount} ;;
    value_format_name: percent_1
  }

## Adding case statements since there was an issue with a salesperson having 0 for one month KC 12/6/23
## https://equipmentshare.slack.com/archives/CSMH54ZNG/p1701882264219719 for reference
  measure: below_floor_pct_of_billing_approved {
    type: number
    sql: case when ${billing_approved_amount} = 0 then null else ${below_floor_billing_approved}/${billing_approved_amount} end ;;
    value_format_name: percent_1
  }

  measure: btw_floor_online_pct_of_date_created {
    type: number
    sql: ${between_floor_online_date_created}/${date_created_amount} ;;
    value_format_name: percent_1
  }

## Adding case statements since there was an issue with a salesperson having 0 for one month KC 12/6/23
## https://equipmentshare.slack.com/archives/CSMH54ZNG/p1701882264219719 for reference
  measure: btw_floor_online_pct_of_billing_approved {
    type: number
    sql: case when ${billing_approved_amount} = 0 then null else ${between_floor_online_billing_approved}/${billing_approved_amount} end ;;
    value_format_name: percent_1
  }

  measure: above_online_pct_of_date_created {
    type: number
    sql: ${above_online_date_created}/${date_created_amount} ;;
    value_format_name: percent_1
  }

## Adding case statements since there was an issue with a salesperson having 0 for one month KC 12/6/23
## https://equipmentshare.slack.com/archives/CSMH54ZNG/p1701882264219719 for reference
  measure: above_online_pct_of_billing_approved {
    type: number
    sql: case when ${billing_approved_amount} = 0 then null else ${above_online_billing_approved}/${billing_approved_amount} end ;;
    value_format_name: percent_1
  }

  set: detail {
    fields: [
      market_id,
      market_region_xwalk.market_name,
      company_id,
      companies.name,
      invoice_id,
      primary_salesperson.Primary_Sales_Rep,
      final_equipment_class,
      total_amount,
      percent_discount
    ]
  }
}
