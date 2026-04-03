view: last_6_12_month_asset_statuses {
  derived_table: {
    sql:




                                    {% if status_date_breakdown._parameter_value == "'Last 6 Months'" %}




    select GENERATED_DAY,
             sc.ASSET_ID,
             sc.ASSET_INVENTORY_STATUS, --- Asset's inventory status at that point in time
             concat(ap.MAKE,' ',ap.MODEL) as asset_make_model,
             ap.SERIAL_NUMBER,
             ap.EQUIP_CLASS_NAME,
             ap.OEC,
             sc.RENTAL_BRANCH_ID,
             xw.MARKET_NAME,
             xw.district,
             xw.region_name as region,
             case when sc.ASSET_INVENTORY_STATUS = 'Assigned' then 'Assigned'
                  when sc.ASSET_INVENTORY_STATUS = 'Ready To Rent'
                       OR sc.ASSET_INVENTORY_STATUS = 'Pre-Delivered'
                          then 'Available'
                  when sc.ASSET_INVENTORY_STATUS = 'Pending Return'
                       OR sc.ASSET_INVENTORY_STATUS = 'Pending Return'
                       OR sc.ASSET_INVENTORY_STATUS = 'Make Ready'
                       OR sc.ASSET_INVENTORY_STATUS = 'Needs Inspection'
                       OR sc.ASSET_INVENTORY_STATUS = 'Soft Down'
                       OR sc.ASSET_INVENTORY_STATUS = 'Hard Down'
                          then 'Unavailable'
                  when sc.ASSET_INVENTORY_STATUS = 'On Rent'
                          then 'On Rent'
                       end as asset_inventory_status_breakdown,
                   case when GENERATED_DAY = current_date then 1 else 0 end as current_day_flag
            from analytics.bi_ops.asset_status_and_rsp_daily_snapshot sc
            left join ANALYTICS.ASSET_DETAILS.ASSET_PHYSICAL ap on sc.ASSET_ID = ap.ASSET_ID
            left join analytics.public.market_region_xwalk xw on sc.rental_branch_id = xw.market_id
            left join analytics.bi_ops.asset_ownership ao on sc.asset_id = ao.asset_id
            where --ap.OEC is not null -- Removing this since we should be coalescing in purchase price. Also I believe this isn't relevant
                  --and
                  xw.MARKET_NAME is not null
                  and GENERATED_DAY >= DATEADD(month,-6,current_date)
                  and ao.ownership in ('ES','OWN')
                  and ao.rentable = TRUE







                                    {% elsif status_date_breakdown._parameter_value == "'Last 12 Months'" %}



    select GENERATED_DAY,
             sc.ASSET_ID,
             sc.ASSET_INVENTORY_STATUS, --- Asset's inventory status at that point in time
             concat(ap.MAKE,' ',ap.MODEL) as asset_make_model,
             ap.SERIAL_NUMBER,
             ap.EQUIP_CLASS_NAME,
             ap.OEC,
             sc.RENTAL_BRANCH_ID,
             xw.MARKET_NAME,
             xw.district,
             xw.region_name as region,
             case when sc.ASSET_INVENTORY_STATUS = 'Assigned' then 'Assigned'
                  when sc.ASSET_INVENTORY_STATUS = 'Ready To Rent'
                       OR sc.ASSET_INVENTORY_STATUS = 'Pre-Delivered'
                          then 'Available'
                  when sc.ASSET_INVENTORY_STATUS = 'Pending Return'
                       OR sc.ASSET_INVENTORY_STATUS = 'Pending Return'
                       OR sc.ASSET_INVENTORY_STATUS = 'Make Ready'
                       OR sc.ASSET_INVENTORY_STATUS = 'Needs Inspection'
                       OR sc.ASSET_INVENTORY_STATUS = 'Soft Down'
                       OR sc.ASSET_INVENTORY_STATUS = 'Hard Down'
                          then 'Unavailable'
                  when sc.ASSET_INVENTORY_STATUS = 'On Rent'
                          then 'On Rent'
                       end as asset_inventory_status_breakdown,
                   case when GENERATED_DAY = current_date then 1 else 0 end as current_day_flag
            from analytics.bi_ops.asset_status_and_rsp_daily_snapshot sc
            left join ANALYTICS.ASSET_DETAILS.ASSET_PHYSICAL ap on sc.ASSET_ID = ap.ASSET_ID
            left join analytics.public.market_region_xwalk xw on sc.rental_branch_id = xw.market_id
            left join analytics.bi_ops.asset_ownership ao on sc.asset_id = ao.asset_id
            where --ap.OEC is not null
                  --and
                  xw.MARKET_NAME is not null
                  and GENERATED_DAY >= DATEADD(month,-12,current_date)
                  and ao.ownership in ('ES','OWN')
                  and ao.rentable = TRUE





                  {% else %}
                  {% endif %};;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension_group: generated {
    type: time
    sql: ${TABLE}."GENERATED_DAY" ;;
  }

  dimension: asset_id {
    type: string
    sql: ${TABLE}."ASSET_ID" ;;
    primary_key: yes
  }

  dimension: asset_inventory_status {
    type: string
    sql: ${TABLE}."ASSET_INVENTORY_STATUS" ;;
  }

  dimension: asset_make_model {
    type: string
    sql: ${TABLE}."ASSET_MAKE_MODEL" ;;
  }

  dimension: serial_number {
    type: string
    sql: ${TABLE}."SERIAL_NUMBER" ;;
  }

  dimension: equip_class_name {
    type: string
    sql: ${TABLE}."EQUIP_CLASS_NAME" ;;
  }

  dimension: oec {
    type: number
    sql: ${TABLE}."OEC" ;;
  }

  dimension: rental_branch_id {
    type: string
    sql: ${TABLE}."RENTAL_BRANCH_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: region {
    type: string
    sql: ${TABLE}."REGION" ;;
  }

  dimension: asset_inventory_status_breakdown {
    type: string
    sql: ${TABLE}."ASSET_INVENTORY_STATUS_BREAKDOWN" ;;
  }

  dimension: current_day_flag {
    type: number
    sql: ${TABLE}."CURRENT_DAY_FLAG" ;;
  }

  measure: total_oec {
    group_label: "OEC Measures"
    label: "Total OEC"
    type: sum
    sql: ${oec} ;;
    value_format_name: usd_0
    drill_fields: [detail*]
  }

  measure: total_assigned_oec {
    group_label: "OEC Measures"
    label: "Total Assigned OEC"
    type: sum
    sql: ${oec} ;;
    filters: [asset_inventory_status_breakdown: "Assigned"]
    value_format_name: usd_0
    drill_fields: [detail*]
  }

  measure: total_available_oec {
    group_label: "OEC Measures"
    label: "Total Available OEC"
    type: sum
    sql: ${oec} ;;
    filters: [asset_inventory_status_breakdown: "Available"]
    value_format_name: usd_0
    drill_fields: [detail*]
  }

  measure: total_unavailable_oec {
    group_label: "OEC Measures"
    label: "Total Unavailable OEC"
    type: sum
    sql: ${oec} ;;
    filters: [asset_inventory_status_breakdown: "Unavailable"]
    value_format_name: usd_0
    drill_fields: [detail*]
  }

  measure: total_on_rent_oec {
    group_label: "OEC Measures"
    label: "Total On Rent OEC"
    type: sum
    sql: ${oec} ;;
    filters: [asset_inventory_status_breakdown: "On Rent"]
    value_format_name: usd_0
    drill_fields: [detail*]
  }

  measure: total_count_of_assets {
    group_label: "Count Measures"
    label: "Total Count of Assets"
    type: count_distinct
    drill_fields: [detail*]
  }

  measure: total_assigned_count {
    group_label: "Count Measures"
    label: "Total Assigned Count of Assets"
    type: count_distinct
    filters: [asset_inventory_status_breakdown: "Assigned"]
    drill_fields: [detail*]
  }

  measure: total_available_count {
    group_label: "Count Measures"
    label: "Total Available Count of Assets"
    type: count_distinct
    filters: [asset_inventory_status_breakdown: "Available"]
    drill_fields: [detail*]
  }

  measure: total_unavailable_count {
    group_label: "Count Measures"
    label: "Total Unavailable Count of Assets"
    type: count_distinct
    filters: [asset_inventory_status_breakdown: "Unavailable"]
    drill_fields: [detail*]
  }

  measure: total_on_rent_count {
    group_label: "Count Measures"
    label: "Total On Rent Count of Assets"
    type: count_distinct
    filters: [asset_inventory_status_breakdown: "On Rent"]
    drill_fields: [detail*]
  }

  measure: total_needs_inspection_count {
    group_label: "Count Measures"
    label: "Total Needs Inspection Count of Assets"
    type: count_distinct
    filters: [asset_inventory_status: "Needs Inspection"]
    drill_fields: [detail*]
  }

  measure: total_make_ready_count {
    group_label: "Count Measures"
    label: "Total Make Ready Count of Assets"
    type: count_distinct
    filters: [asset_inventory_status: "Make Ready"]
    drill_fields: [detail*]
  }

  measure: total_pending_return_count {
    group_label: "Count Measures"
    label: "Total Pending Return of Assets"
    type: count_distinct
    filters: [asset_inventory_status: "Pending Return"]
    drill_fields: [detail*]
  }

  measure: percent_of_total_oec_on_rent {
    group_label: "Percent of OEC"
    type: number
    sql: ${total_on_rent_oec}/${total_oec} ;;
    value_format_name: percent_1
  }

  measure: percent_of_total_oec_assigned {
    group_label: "Percent of OEC"
    type: number
    sql: ${total_assigned_oec}/${total_oec} ;;
    value_format_name: percent_1
  }

  measure: percent_of_total_oec_available {
    group_label: "Percent of OEC"
    type: number
    sql: ${total_available_oec}/${total_oec} ;;
    value_format_name: percent_1
  }

  measure: percent_of_total_oec_unavailable {
    group_label: "Percent of OEC"
    type: number
    sql: ${total_unavailable_oec}/${total_oec} ;;
    value_format_name: percent_1
  }

  measure: percent_of_total_count_on_rent {
    group_label: "Percent of Counts"
    type: number
    sql: round(${total_on_rent_count}/${total_count_of_assets})*100,1) ;;
  }

  measure: percent_of_total_count_assigned {
    group_label: "Percent of Counts"
    type: number
    sql: ${total_assigned_count}/${total_count_of_assets} ;;
    value_format_name: percent_1
  }

  measure: percent_of_total_count_available {
    group_label: "Percent of Counts"
    type: number
    sql: ${total_available_count}/${total_count_of_assets} ;;
    value_format_name: percent_1
  }

  measure: percent_of_total_count_unavailable {
    group_label: "Percent of Counts"
    type: number
    sql: ${total_unavailable_count}/${total_count_of_assets} ;;
    value_format_name: percent_1
  }

  measure: percent_of_total_count_needs_inspection {
    group_label: "Percent of Counts"
    type: number
    sql: round((${total_needs_inspection_count}/${total_unavailable_count})*100,1) ;; ## Idk if I should be using unavailble totals. Still deciding
  }

  measure: percent_of_total_count_make_ready {
    group_label: "Percent of Counts"
    type: number
    sql: round((${total_make_ready_count}/${total_unavailable_count})*100,1) ;;
  }

  measure: percent_of_total_count_pending_return {
    group_label: "Percent of Counts"
    type: number
    sql: round((${total_pending_return_count}/${total_unavailable_count})*100,1) ;;
  }

  #################################################### Dynamic Measures ####################################################

  measure: dynamic_needs_inspection {
    group_label: "Dynamic Percent and Count Measures"
    type: number
    sql: {% if dynamic_metric_selection._parameter_value == "'Percentage'" %}
      ${percent_of_total_count_needs_inspection}
    {% elsif dynamic_metric_selection._parameter_value == "'Count'" %}
      ${total_needs_inspection_count}
    {% else %}
      NULL
    {% endif %} ;;
    html: {% if dynamic_metric_selection._parameter_value == "'Percentage'" %}

    {{rendered_value}}%

    {% elsif dynamic_metric_selection._parameter_value == "'Count'" %}

    {{rendered_value}}

    {% else %}

    {% endif %};;
  }

  measure: dynamic_make_ready {
    group_label: "Dynamic Percent and Count Measures"
    type: number
    sql: {% if dynamic_metric_selection._parameter_value == "'Percentage'" %}
      ${percent_of_total_count_make_ready}
    {% elsif dynamic_metric_selection._parameter_value == "'Count'" %}
      ${total_make_ready_count}
    {% else %}
      NULL
    {% endif %} ;;
    html: {% if dynamic_metric_selection._parameter_value == "'Percentage'" %}

          {{rendered_value}}%

          {% elsif dynamic_metric_selection._parameter_value == "'Count'" %}

          {{rendered_value}}

          {% else %}

          {% endif %};;
  }

  measure: dynamic_pending_return {
    group_label: "Dynamic Percent and Count Measures"
    type: number
    sql: {% if dynamic_metric_selection._parameter_value == "'Percentage'" %}
      ${percent_of_total_count_pending_return}
    {% elsif dynamic_metric_selection._parameter_value == "'Count'" %}
      ${total_pending_return_count}
    {% else %}
      NULL
    {% endif %} ;;
    html: {% if dynamic_metric_selection._parameter_value == "'Percentage'" %}

          {{rendered_value}}%

          {% elsif dynamic_metric_selection._parameter_value == "'Count'" %}

          {{rendered_value}}

          {% else %}

          {% endif %};;
  }

  measure: dynamic_on_rent {
    group_label: "Dynamic Percent and Count Measures"
    type: number
    sql: {% if dynamic_metric_selection._parameter_value == "'Percentage'" %}
      ${percent_of_total_count_on_rent}
    {% elsif dynamic_metric_selection._parameter_value == "'Count'" %}
      ${total_on_rent_count}
    {% else %}
      NULL
    {% endif %} ;;
    html: {% if dynamic_metric_selection._parameter_value == "'Percentage'" %}

          {{rendered_value}}%

          {% elsif dynamic_metric_selection._parameter_value == "'Count'" %}

          {{rendered_value}}

          {% else %}

          {% endif %};;
  }

  set: detail {
    fields: [
      generated_date,
      asset_id,
      asset_inventory_status,
      asset_make_model,
      serial_number,
      equip_class_name,
      oec,
      rental_branch_id,
      market_name,
      district,
      region,
      asset_inventory_status_breakdown,
      current_day_flag
    ]
  }

  parameter: status_date_breakdown {
    type: string
    allowed_value: { value: "Last 6 Months"}
    allowed_value: { value: "Last 12 Months"}
  }

  parameter: dynamic_metric_selection {
    type: string
    allowed_value: { value: "Percentage"}
    allowed_value: { value: "Count"}
  }
}
