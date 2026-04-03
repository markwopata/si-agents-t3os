
view: company_pulse_inventory_information {
  derived_table: {
    sql: with region_selection as (
      select
          distinct region_name as region
      from
          analytics.public.market_region_xwalk
      where
          {% condition region_name_filter %} region_name {% endcondition %}
      )
      , region_selection_count as (
      select
          count(distinct(region)) as total_regions_selected
      from
          region_selection
      )
      , assigned_region as (
      select
          IFF(split_part(DEFAULT_COST_CENTERS_FULL_PATH,'/',2) = 'Corp', 'Midwest',
            IFF(split_part(DEFAULT_COST_CENTERS_FULL_PATH,'/',2) = 'R2 Mountain West', 'Mountain West',
              IFF(
                  split_part(split_part(DEFAULT_COST_CENTERS_FULL_PATH,'/',2), ' ',2) = ''
                  ,'Midwest'
                  ,split_part(split_part(DEFAULT_COST_CENTERS_FULL_PATH,'/',2), ' ',2)
                  )
            )
          ) as region
      from
          analytics.payroll.company_directory
      where
          lower(work_email) = '{{ _user_attributes['email'] }}'
      )
      SELECT
          mrx.market_name as market,
          mrx.region_name as region,
          mrx.district,
          mrx.market_type,
          case when right(mrx.market_name, 9) = 'Hard Down' then true else false end as hard_down,
          vmt.is_current_months_open_greater_than_twelve,
          i.status as inventory_status,
          ao.rentable,
          IFF(
          IFF(total_regions_selected = 1,rs.region,ar.region)
          = mrx.region_name,TRUE,FALSE) as is_selected_region,
          sum(aa.oec) as oec,
          count(distinct(ao.asset_id)) as total_assets
          --row_number() OVER (partition by mrx.market_name, i.status order by mrx.market_name desc) as eliminate_dups
      FROM
          analytics.bi_ops.asset_ownership ao
          JOIN ES_WAREHOUSE.PUBLIC.assets_aggregate aa ON ao.asset_id = aa.asset_id
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
              group by market_id, market_name, state, region, region_name, is_current_months_open_greater_than_twelve) vmt on vmt.market_id = ao.market_id
           cross join region_selection_count rsc
           left join region_selection rs on rsc.total_regions_selected = 1
           cross join assigned_region ar
      where
          mrx.division_name = 'Equipment Rental'
      group by
          mrx.market_name,
          mrx.region_name,
          mrx.district,
          mrx.market_type,
          hard_down,
          vmt.is_current_months_open_greater_than_twelve,
          i.status,
          ao.rentable,
          is_selected_region
          ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: market {
    type: string
    sql: ${TABLE}."MARKET" ;;
  }

  dimension: region {
    type: string
    sql: ${TABLE}."REGION" ;;
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

  dimension: is_current_months_open_greater_than_twelve {
    type: yesno
    sql: ${TABLE}."IS_CURRENT_MONTHS_OPEN_GREATER_THAN_TWELVE" ;;
  }

  dimension: inventory_status {
    type: string
    sql: ${TABLE}."INVENTORY_STATUS" ;;
  }

  dimension: rentable {
    type: yesno
    sql: ${TABLE}."RENTABLE" ;;
  }

  dimension: is_selected_region {
    type: yesno
    sql: ${TABLE}."IS_SELECTED_REGION" ;;
  }

  dimension: oec {
    type: number
    sql: ${TABLE}."OEC" ;;
  }

  dimension: total_assets {
    type: number
    sql: ${TABLE}."TOTAL_ASSETS" ;;
  }

  dimension: selected_region_name {
    type: string
    sql: case when ${is_selected_region} = 'Yes' then 'Highlighted' else ' ' end ;;
  }

  measure: total_oec_on_rent_selected {
    group_label: "OEC Selected"
    type: sum
    label: "Total OEC On Rent"
    sql: ${oec} ;;
    filters: [inventory_status: "On Rent"]
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    filters: [rentable: "YES", is_selected_region: "YES"]
  }

  measure: total_oec_on_rent_unselected {
    group_label: "OEC Unselected"
    type: sum
    label: "Total OEC On Rent"
    sql: ${oec} ;;
    filters: [inventory_status: "On Rent"]
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    filters: [rentable: "YES", is_selected_region: "NO"]
  }

  measure: total_oec_on_rent {
    type: sum
    label: "Total OEC On Rent"
    sql: ${oec} ;;
    filters: [inventory_status: "On Rent"]
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    filters: [rentable: "YES"]
  }

  measure: total_available_oec {
    type: sum
    label: "Total Available OEC"
    sql: ${oec} ;;
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    drill_fields: [region, inventory_status, total_assets_per_region, total_oec_per_region ]
    filters: [rentable: "YES"]
  }

  measure: oec_on_rent_percentage_selected {
    group_label: "OEC Selected"
    label: "OEC On Rent %"
    type: number
    sql: ${total_oec_on_rent_selected} / nullifzero(${total_available_oec}) ;;
    value_format_name: percent_1
  }

  measure: oec_on_rent_percentage_unselected {
    group_label: "OEC Unselected"
    label: "OEC On Rent %"
    type: number
    sql: ${total_oec_on_rent_unselected} / nullifzero(${total_available_oec}) ;;
    value_format_name: percent_1
  }

  measure: oec_on_rent_percentage {
    label: "OEC On Rent %"
    type: number
    sql: ${total_oec_on_rent} / nullifzero(${total_available_oec}) ;;
    value_format_name: percent_1
  }

  measure: rest_of_percent_bar {
    label: "Percent Bar"
    type: number
    sql: 1 - ${oec_on_rent_percentage} ;;
    value_format_name: percent_1
  }

  measure: total_assets_per_region {
    type: sum
    label: "Total Units"
    sql: ${total_assets} ;;

    drill_fields: [region, inventory_status, total_assets_per_region, total_oec_per_region ]
    filters: [rentable: "YES"]
  }

  measure: total_oec_per_region {
    type: sum
    label: "Total OEC"
    sql: ${oec} ;;
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    drill_fields: [region, inventory_status, total_oec_per_region, total_assets_per_region]
    filters: [rentable: "YES"]
  }


  measure: total_overall_oec_percentage {
    label: "OEC %"
    type: percent_of_total
    sql: ${total_oec_per_region} ;;
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

  measure: total_available_oec_is_selected {
    group_label: "Region is selected"
    type: sum
    label: "Total Available OEC"
    sql: ${oec} ;;
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    filters: [rentable: "YES", is_selected_region: "YES"]
  }

  measure: total_available_oec_is_unselected {
    group_label: "Region is not selected"
    type: sum
    label: "Total Available OEC"
    sql: ${oec} ;;
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    filters: [rentable: "YES", is_selected_region: "NO"]
  }

  measure: total_available_oec_inventory_status {
    group_label: "Inventory Status OEC Combined"
    label: "Total OEC"
    type: number
    sql: IFF(${total_available_oec_is_selected} = 0,${total_available_oec_is_unselected},${total_available_oec_is_selected})  ;;
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    drill_fields: [district, inventory_status, total_available_oec]
  }

  filter: region_name_filter {
    type: string
  }

  dimension: equipmentshare {
    type: string
    sql: 'EquipmentShare' ;;
  }

  set: detail {
    fields: [
        market,
  region,
  district,
  market_type,
  hard_down,
  is_current_months_open_greater_than_twelve,
  inventory_status,
  rentable,
  is_selected_region,
  oec,
  total_assets
    ]
  }
}