
view: regional_hierarchy_inventory_status {
  derived_table: {
    sql:
       SELECT
          mrx.market_name as market,
          mrx.region_name as region,
          mrx.district,
          mrx.market_type,
          case when right(mrx.market_name, 9) = 'Hard Down' then true else false end as hard_down,
          vmt.is_current_months_open_greater_than_twelve,
          i.status as inventory_status,
          aa.oec,
          ao.asset_id,
          concat(aa.make,' ',aa.model) as asset_make_and_model,
          ec.NAME as equipment_class,
          aa.SERIAL_NUMBER,
          ao.rentable
      FROM
          analytics.bi_ops.asset_ownership ao
          JOIN ES_WAREHOUSE.PUBLIC.assets_aggregate aa ON ao.asset_id = aa.asset_id
          LEFT JOIN ES_WAREHOUSE.PUBLIC.EQUIPMENT_CLASSES ec on aa.EQUIPMENT_CLASS_ID = ec.EQUIPMENT_CLASS_ID
          JOIN (
          select
              asset_id,
              value as status
          from
              es_warehouse.public.asset_status_key_values
          where
              name = 'asset_inventory_status'
              AND value is not null
              --- For the Ownerships, there are more than just ES and OWN assets being pulled in the old markets dashboard (except Re-Rents). This can be changed at ease.
              AND asset_id in (select asset_id from analytics.bi_ops.asset_ownership where ownership in ('ES', 'OWN', 'CUSTOMER', 'RETAIL') and market_company_id = 1854)) i on i.asset_id = ao.asset_id

          JOIN analytics.public.market_region_xwalk mrx on mrx.market_id = ao.market_id
           left join (select market_id, market_name, state, region, region_name, is_current_months_open_greater_than_twelve from analytics.public.v_market_t3_analytics
      group by market_id, market_name, state, region, region_name, is_current_months_open_greater_than_twelve) vmt
            on vmt.market_id = ao.market_id
      where
        (mrx.division_name = 'Equipment Rental' OR mrx.division_name is null) ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: primary_key {
    type: string
    primary_key: yes
    sql: concat(${market_type},'-',${region},'-',${district}) ;; # This Primary Key is needed for the counts of assets in a certain status.
  }

  dimension: market {
    type: string
    sql: ${TABLE}."MARKET" ;;
  }

  dimension: region {
    type: string
    sql: ${TABLE}."REGION" ;;
  }

  dimension: is_selected_region {
    type: yesno
    sql: ${TABLE}.is_selected_region ;;
  }

  dimension: selected_region_name {
    type: string
    sql: case when ${is_selected_region} = 'Yes' then 'Highlighted' else ' ' end ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: market_type {
    type: string
    sql: ${TABLE}."MARKET_TYPE" ;;
  }

  dimension: hard_down {
    type: yesno
    sql: ${TABLE}."HARD_DOWN" ;;
  }

  dimension: months_open_over_12 {
    type: yesno
    sql: ${TABLE}."IS_CURRENT_MONTHS_OPEN_GREATER_THAN_TWELVE" ;;
  }

  dimension: inventory_status {
    type: string
    sql: ${TABLE}."INVENTORY_STATUS" ;;
  }

  dimension: make_and_model {
    label: "Make and Model"
    type: string
    sql: ${TABLE}."ASSET_MAKE_AND_MODEL" ;;
  }

  dimension: equipment_class {
    type: string
    sql: ${TABLE}."EQUIPMENT_CLASS" ;;
  }

  dimension: serial_number {
    type: string
    sql: ${TABLE}."SERIAL_NUMBER" ;;
  }

  dimension: oec {
    type: number
    sql: ${TABLE}."OEC" ;;
    value_format_name: usd_0
  }

  dimension: asset_id {
    type: string
    sql: ${TABLE}."ASSET_ID" ;;
    html: <font color="#0063f3 "><u><a href="https://equipmentshare.looker.com/dashboards/169?Asset+ID={{asset_id}}" target="_blank">{{ asset_id._value }}</a></font></u> ;;
    value_format_name: id
  }

  dimension: asset_id_num {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
    value_format_name: id
  }

  dimension: rentable {
    type: yesno
    sql: ${TABLE}."RENTABLE" ;;
  }

  dimension: equipmentshare {
    type: string
    sql: 'EquipmentShare' ;;
  }

  measure: total_oec {
    type: sum
    label: "Total OEC"
    sql: ${oec} ;;
    value_format_name: usd
    filters: [rentable: "YES"]
  }

  measure: total_oec_with_inventory {
    group_label: "With Inventory Branch"
    type: sum
    label: "Total OEC"
    sql: ${oec} ;;
    value_format_name: usd
  }

  measure: total_oec_formatted {
    group_label: "Total OEC With Percent"
    type: sum
    label: "Total OEC"
    sql: ${oec} ;;
    value_format_name: usd
    html: {{rendered_value}} || {{total_overall_oec_percentage._rendered_value}} of total;;
    filters: [rentable: "YES"]
  }

  measure: total_assets {
    type: count_distinct
    label: "Total Units"
    sql: ${asset_id} ;;
    drill_fields: [asset_id, make_and_model, equipment_class, serial_number, inventory_status, total_oec ]
    filters: [rentable: "YES"]
  }

  measure: total_assets_on_rent {
    type: count_distinct
    label: "Total Units On Rent"
    sql: ${asset_id} ;;
    filters: [inventory_status: "On Rent"]
    filters: [rentable: "YES"]
  }

  measure: unit_utilization {
    type: number
    sql: ${total_assets_on_rent} / NULLIF(${total_assets},0) ;;
    value_format_name: percent_1
  }

  measure: unit_utilization_bar_percentage {
    type: number
    sql: ${percent_bar} - ${unit_utilization} ;;
    value_format_name: percent_1
  }

  measure: total_unavailable_oec {
    type: sum
    label: "Total Unavailable OEC %"
    value_format_name: usd_0
    sql: ${oec} ;;
    filters: [inventory_status: "Pending Return,Make Ready, Needs Inspection, Soft Down, Hard Down"]
  }

  measure: total_unavailable_oec_percentage {
    type: number
    sql: ${total_unavailable_oec} / nullifzero(${total_oec_with_inventory}) ;;
    value_format_name: percent_1
  }

  measure: unavailable_oec_bar_percentage {
    type: number
    sql: ${percent_bar} - ${total_unavailable_oec_percentage} ;;
    value_format_name: percent_1
  }

  measure: total_oec_on_rent {
    type: sum
    label: "Total OEC On Rent"
    sql: ${oec} ;;
    filters: [inventory_status: "On Rent"]
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    filters: [rentable: "YES"]
  }

  measure: total_available_oec {
    type: sum
    label: "Total Available OEC"
    sql: ${oec} ;;
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    filters: [rentable: "YES"]
  }

  measure: total_oec_on_rent_format {
    type: string
    sql: case when ${total_oec_on_rent} >= .75 then 'Green'
    when ${total_oec_on_rent} < .70 then 'Red'
    else 'Yellow' end;;
  }

  measure: oec_on_rent_percentage {
    type: number
    sql: ${total_oec_on_rent} / nullifzero(${total_available_oec}) ;;
    value_format_name: percent_1
  }

  measure: percent_bar {
    type: number
    sql: 1 ;;
    value_format_name: percent_0
  }

  measure: oec_on_rent_bar_percentage {
    type: number
    sql: ${percent_bar} - ${oec_on_rent_percentage};;
    value_format_name: percent_0
  }

  measure: total_overall_oec_percentage {
    label: "OEC %"
    type: percent_of_total
    sql: ${total_oec} ;;
    value_format: "0.0\%"
    filters: [rentable: "YES"]
  }

  measure: total_overall_oec_percentage_formatted {
    group_label: "Formatted OEC %"
    label: "OEC %"
    type: number
    sql: ${total_overall_oec_percentage} ;;
    html:
    {% if inventory_status._value == 'Pending Return' and total_overall_oec_percentage._value >= 3 %}
    <p style="color: black; background-color: #f38c8e;">{{ total_overall_oec_percentage._rendered_value }}</p>
    {% elsif inventory_status._value == 'Needs Inspection' and total_overall_oec_percentage._value >= 1 %}
      <p style="color: black; background-color: #f38c8e;">{{ total_overall_oec_percentage._rendered_value }}</p>
    {% else %}
      {{ total_overall_oec_percentage._rendered_value }}
    {% endif %}
    ;;
  }

  measure: total_count_of_assets_in_needs_inspection {
    type: count_distinct
    sql: ${asset_id};;
    filters: [inventory_status: "Needs Inspection"]
    drill_fields: [detail_2*]
  }

  measure: total_count_of_assets_in_make_ready {
    type: count_distinct
    sql: ${asset_id};;
    filters: [inventory_status: "Make Ready"]
    drill_fields: [detail_2*]
  }

  measure: total_count_of_assets_in_pending_return {
    type: count_distinct
    sql: ${asset_id};;
    filters: [inventory_status: "Pending Return"]
    drill_fields: [detail_2*]
  }

  measure: total_count_of_assets_soft_down {
    type: count_distinct
    sql: ${asset_id};;
    filters: [inventory_status: "Soft Down"]
    drill_fields: [detail_2*]
  }

  measure: total_count_of_assets_hard_down {
    type: count_distinct
    sql: ${asset_id};;
    filters: [inventory_status: "Hard Down"]
    drill_fields: [detail_2*]
  }


  dimension: oec_breakdown {
    type: string
    sql: case
    when ${inventory_status} = 'Assigned' then 'Assigned'
    when ${inventory_status} = 'Ready To Rent' OR ${inventory_status} = 'Pre-Delivered' then 'Available'
    when ${inventory_status} = 'Pending Return'
         OR ${inventory_status} = 'Pending Return'
         OR ${inventory_status} = 'Make Ready'
         OR ${inventory_status} = 'Needs Inspection'
         OR ${inventory_status} = 'Soft Down'
         OR ${inventory_status} = 'Hard Down'
          then 'Unavailable'
    when ${inventory_status} = 'On Rent' then 'On Rent'
    end
    ;;
  }

  measure: non_rentable_assets_unavail_count {
    group_label: "Unavailable OEC Comparison Metrics"
    type: count_distinct
    sql: ${asset_id};;
    filters: [inventory_status: "Pending Return, Make Ready, Needs Inspection, Soft Down, Hard Down", rentable: "FALSE"]
    drill_fields: [asset_id, make_and_model, oec, inventory_status, rentable]
  }

  measure: non_rentable_assets_unavail_oec {
    group_label: "Unavailable OEC Comparison Metrics"
    type: sum
    sql: ${oec};;
    filters: [inventory_status: "Pending Return,Make Ready, Needs Inspection, Soft Down, Hard Down", rentable: "FALSE"]
    value_format_name: usd_0
  }

  measure: assets_pending {
    group_label: "Unavailable OEC Comparison Metrics"
    type: count_distinct
    sql: ${asset_id};;
    filters: [inventory_status: "Pending Return"]
    drill_fields: [asset_id, make_and_model, oec, inventory_status, rentable]
  }

  measure: assets_pending_oec {
    group_label: "Unavailable OEC Comparison Metrics"
    type: sum
    sql: ${oec};;
    filters: [inventory_status: "Pending Return"]
    value_format_name: usd_0
  }

  measure: assets_unavailable {
    group_label: "Unavailable OEC Comparison Metrics"
    type: count_distinct
    sql: ${asset_id};;
    filters: [inventory_status: "Pending Return, Make Ready, Needs Inspection, Soft Down, Hard Down"]
    drill_fields: [asset_id, make_and_model, oec, inventory_status, rentable]
  }






  filter: region_name_filter {
    type: string
  }

  set: detail {
    fields: [
        market,
  region,
  district,
  market_type,
  inventory_status,
  total_oec,
  total_assets
    ]
  }

  set: detail_2 {
    fields: [
      asset_id,
      total_oec,
      inventory_status,
      market,
      region,
      district,
      market_type
    ]
  }
}