view: int_asset_historical_current_day {

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

  dimension: T3_Link{
    type:  string
    sql: ${asset_id} ;;
    html: {% if asset_inventory_status._value == "Soft Down"
   or asset_inventory_status._value == "Hard Down"
   or asset_inventory_status._value == "Needs Inspection" %}
  <font color="blue">
    <u>
      <a href="https://app.estrack.com/#/assets/all/asset/{{ asset_id }}/service/work-orders" target="_blank">
        T3 Workorders
      </a>
    </u>
  </font>
{% else %}
 <font color="blue">
<u>
  <a href="https://admin.equipmentshare.com/#/home/assets/asset/{{ asset_id }}/edit" target="_blank">
    T3
  </a>
   </u>
{% endif %};;
  }

  measure: total_open_work_orders {
    type: count_distinct
    sql: CASE WHEN ${work_orders_for_markets.work_order_status_id} = 1 AND
      ${work_orders_for_markets.work_order_type_id} = 1 AND
      ${work_orders_for_markets.archived_date} is null
      THEN ${work_orders_for_markets.work_order_id} END  ;;
  }

  dimension: T3_Link_with_work_orders{
    label: "T3 Link"
    type:  string
    sql: ${asset_id} ;;
    html: {% if  total_open_work_orders._value > 1  %}
        <font color="blue">
          <u>
            <a href="https://app.estrack.com/#/assets/all/asset/{{ asset_id }}/service/work-orders" target="_blank">
              <strong>{{total_open_work_orders._value}} Open Work Orders</strong>
            </a>
          </u>
        </font>
        {% elsif  total_open_work_orders._value == 1  %}
        <font color="blue">
          <u>
            <a href="https://app.estrack.com/#/assets/all/asset/{{ asset_id }}/service/work-orders" target="_blank">
            <strong>  {{total_open_work_orders._value}} Open Work Order</strong>
            </a>
          </u>
        </font>
      {% else %}
       <font color="blue">
      <u>
        <a href="https://admin.equipmentshare.com/#/home/assets/asset/{{ asset_id }}/rental-history" target="_blank">
          T3 Rental History
        </a>
         </u>
      {% endif %};;
  }

  measure: asset_count {
    type: count_distinct
    sql: ${asset_id} ;;
    drill_fields: [asset_in_status_count_detail*]
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

  dimension: rental_fleet_oec {
    description: "OEC of asset where in_rental_fleet = TRUE"
    type: number
    sql: ${TABLE}."RENTAL_FLEET_OEC" ;;
  }

  measure: rental_fleet_oec_sum_drill_less {
    label: "Rental Fleet OEC"
    type: sum
    sql: ${rental_fleet_oec} ;;
    value_format_name: usd_0
  }

  measure: rental_fleet_oec_sum {
    description: "Sum of OEC of assets in rental fleet with drill fields broken down by region"
    label: "Rental Fleet OEC"
    type: sum
    sql: ${rental_fleet_oec} ;;
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    drill_fields: [company_oec_status_detail*]
  }

  measure: rental_fleet_oec_sum_region {
    description: "Sum of OEC of assets in rental fleet with drill fields broken down by district"
    group_label: "Rental Fleet OEC - Region"
    label: "Rental Fleet OEC"
    type: sum
    sql: ${rental_fleet_oec} ;;
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    drill_fields: [region_oec_status_detail*]
  }

  measure: rental_fleet_oec_sum_district {
    description: "Sum of OEC of assets in rental fleet with drill fields broken down by market"
    group_label: "Rental Fleet OEC - District"
    label: "Rental Fleet OEC"
    type: sum
    sql: ${rental_fleet_oec} ;;
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    drill_fields: [district_oec_status_detail*]
  }

  measure: rental_fleet_oec_sum_market {
    description: "Sum of OEC of assets in rental fleet with drill fields broken down by asset"
    group_label: "Rental Fleet OEC - Market"
    label: "Rental Fleet OEC"
    type: sum
    sql: ${rental_fleet_oec} ;;
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    drill_fields: [market_oec_status_detail*]
  }

  measure: rental_fleet_oec_percent_of_total {
    label: "Rental Fleet OEC % of Total"
    type: number
    sql: ${rental_fleet_oec_sum} / NULLIF(SUM(${rental_fleet_oec_sum}) OVER (), 0);;
    value_format_name: percent_1
    drill_fields: [market_oec_status_detail*]
  }

  dimension: rental_fleet_units {
    type: number
    sql: ${TABLE}."RENTAL_FLEET_UNITS" ;;
  }

  measure: rental_fleet_units_sum {
    description: "Total units in the rental fleet with drill fields broken down by region"
    label: "Rental Fleet Units"
    type: sum
    sql: ${rental_fleet_units} ;;
    drill_fields: [company_oec_status_detail*]
  }

  measure: rental_fleet_units_sum_drill_less {
    label: "Rental Fleet Units"
    type: sum
    sql: ${rental_fleet_units} ;;
  }

  measure: rental_fleet_units_sum_region {
    group_label: "Rental Fleet Units - Region"
    label: "Rental Fleet Units"
    description: "Total units in the rental fleet with drill fields broken down by district"
    type: sum
    sql: ${rental_fleet_units} ;;
    drill_fields: [region_oec_status_detail*]
  }

  measure: rental_fleet_units_sum_district {
    group_label: "Rental Fleet Units - District"
    label: "Rental Fleet Units"
    description: "Total units in the rental fleet with drill fields broken down by market"
    type: sum
    sql: ${rental_fleet_units} ;;
    drill_fields: [district_oec_status_detail*]
  }

  measure: rental_fleet_units_sum_market {
    group_label: "Rental Fleet Units - Market"
    label: "Rental Fleet Units"
    description: "Total units in the rental fleet with drill fields broken down by asset"
    type: sum
    sql: ${rental_fleet_units} ;;
    drill_fields: [market_oec_status_detail*]
  }

  measure: units_on_rent {
    type: sum
    sql: ${TABLE}."UNITS_ON_RENT" ;;
  }

  measure: unit_utilization {
    description: "Units rented divided by available rental days"
    type: number
    sql: DIV0NULL(${units_on_rent}, ${rental_fleet_units_sum}) ;;
    value_format_name: percent_1
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

  dimension: is_contributing_oec {
    description: "Checking if the asset is on rent and has not been swapped out for another asset on it's rental id. If yes, the asset's OEC is contributing to OEC on rent for the day."
    type: yesno
    sql: ${is_on_rent} AND ${is_last_rental_in_day} ;;
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

  measure: oec_on_rent_sum {
    description: "Total OEC of assets on rent after considering asset swaps"
    type: sum
    sql: ${oec_on_rent} ;;
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
  }

  measure: oec_on_rent_perc {
    description: "Percentage of oec on rent of all rental fleet oec"
    type: number
    sql: DIV0NULL(${oec_on_rent_sum}, ${rental_fleet_oec_sum});;
    value_format_name: percent_1
  }

  dimension: is_asset_unavailable {
    group_label: "Asset Inventory Status Info"
    type: yesno
    sql: ${TABLE}."IS_ASSET_UNAVAILABLE" ;;
  }

  dimension: unavailable_oec {
    group_label: "Asset Inventory Status Info"
    description: "OEC of asset with inventory status of Make Ready, Needs Inspection, Soft Down, or Hard Down"
    type: number
    sql: ${TABLE}."UNAVAILABLE_OEC" ;;
    value_format_name: usd_0
  }

  measure: unavailable_oec_sum {
    group_label: "Asset Inventory Status Info"
    description: "Sum of OEC of assets with inventory status of Make Ready, Needs Inspection, Soft Down, or Hard Down"
    type: sum
    sql: ${unavailable_oec} ;;
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
  }

  measure: unavailable_oec_perc {
    description: "Percentage of unavailable oec of all rental fleet oec"
    type: number
    sql:  DIV0NULL(${unavailable_oec_sum}, ${rental_fleet_oec_sum});;
    value_format_name: percent_1
  }

  dimension: unavailable_units {
    type: number
    sql: ${TABLE}."UNAVAILABLE_UNITS" ;;
  }

  measure: unavailable_units_sum {
    description: "Count of all unavailable assets"
    type: sum
    sql: ${unavailable_units} ;;
  }

  dimension: is_severe_status {
    type: yesno
    sql:
      CASE WHEN ${asset_inventory_status} ILIKE 'Pending Return' THEN ${days_in_status} > 3
        WHEN ${asset_inventory_status} ILIKE 'Needs Inspection' THEN ${days_in_status} > 3
        WHEN ${asset_inventory_status} ILIKE 'Soft Down' THEN ${days_in_status} > 30
        WHEN ${asset_inventory_status} ILIKE 'Hard Down' THEN ${days_in_status} > 30
        ELSE NULL END ;;
  }

  dimension: pending_return_oec {
    group_label: "Asset Inventory Status Info"
    description: "OEC of asset with Pending Return inventory status"
    type: number
    sql: ${TABLE}."PENDING_RETURN_OEC" ;;
    value_format_name: usd_0
  }

  measure: pending_return_oec_sum {
    group_label: "Asset Inventory Status Info"
    description: "Sum of OEC of assets with Pending Return inventory status"
    type: sum
    sql: ${pending_return_oec} ;;
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
  }

  measure: pending_return_oec_perc {
    description: "Percentage of pending return oec of all rental fleet oec"
    type: number
    sql:  DIV0NULL(${pending_return_oec_sum}, ${rental_fleet_oec_sum});;
    value_format_name: percent_1
    drill_fields: [pending_detail*]
  }

  dimension: pending_return_units {
    group_label: "Asset Inventory Status Info"
    type: number
    sql: ${TABLE}."PENDING_RETURN_UNITS" ;;
    value_format_name: usd_0
  }

  measure: pending_return_units_sum {
    group_label: "Asset Inventory Status Info"
    description: "Count of assets with Pending Return inventory status"
    type: sum
    sql: ${pending_return_units} ;;
    filters: [asset_inventory_status: "Pending Return"]
    drill_fields: [pending_detail*]
  }

  measure: pending_over_3_days_asset_count {
    group_label: "Days In Status Counts"
    type: count_distinct
    sql: ${asset_id} ;;
    filters: [asset_inventory_status: "Pending Return",
      days_in_status: "> 3"]
    drill_fields: [asset_in_status_count_detail*]
  }

  measure: needs_inspection_asset_count {
    group_label: "Asset Inventory Status Info"
    type: count_distinct
    sql: ${asset_id};;
    filters: [asset_inventory_status: "Needs Inspection"]
    drill_fields: [asset_in_status_count_detail*]
  }

  measure: needs_inspection_over_3_days_asset_count {
    group_label: "Days In Status Counts"
    type: count_distinct
    sql:${asset_id} ;;
    filters: [asset_inventory_status: "Needs Inspection",
      days_in_status: "> 3"]
    drill_fields: [asset_in_status_count_detail*]
  }

  dimension: needs_inspection_oec {
    group_label: "Asset Inventory Status Info"
    description: "OEC of asset with Needs Inspection inventory status"
    type: number
    sql: CASE WHEN ${asset_inventory_status} ILIKE 'Needs Inspection' THEN ${TABLE}."TOTAL_OEC" ELSE NULL END;;
    value_format_name: usd_0
  }

  measure: needs_inspection_oec_sum {
    group_label: "Asset Inventory Status Info"
    description: "Sum of OEC of assets with Needs Inspection inventory status"
    type: sum
    sql: ${needs_inspection_oec} ;;
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
  }

  measure: needs_inspection_oec_perc {
    description: "Percentage of Needs Inspection oec of all rental fleet oec"
    type: number
    sql:  DIV0NULL(${needs_inspection_oec_sum}, ${rental_fleet_oec_sum});;
    value_format_name: percent_1
  }

  dimension: needs_inspection_units {
    group_label: "Asset Inventory Status Info"
    type: number
    sql: CASE WHEN ${asset_inventory_status} ILIKE 'Needs Inspection' THEN ${TABLE}."TOTAL_UNITS" ELSE NULL END ;;
    value_format_name: usd_0
  }

  measure: needs_inspection_units_sum {
    group_label: "Asset Inventory Status Info"
    description: "Count of assets with Needs Inspection inventory status"
    type: sum
    sql: ${needs_inspection_units} ;;
  }

  measure: soft_down_asset_count {
    group_label: "Asset Inventory Status Info"
    type: count_distinct
    sql: ${asset_id};;
    filters: [asset_inventory_status: "Soft Down"]
    drill_fields: [asset_in_status_count_detail*]
  }

  measure: soft_down_over_30_days_asset_count {
    group_label: "Days In Status Counts"
    type: count_distinct
    sql: ${asset_id};;
    filters: [asset_inventory_status: "Soft Down",
      days_in_status: "> 30"]
    drill_fields: [asset_in_status_count_detail*]
  }

  measure: hard_down_asset_count {
    group_label: "Asset Inventory Status Info"
    type: count_distinct
    sql: ${asset_id};;
    filters: [asset_inventory_status: "Hard Down"]
    drill_fields: [asset_in_status_count_detail*]
  }

  measure: hard_down_over_30_days_asset_count {
    group_label: "Days In Status Counts"
    type: count_distinct
    sql: ${asset_id};;
    filters: [asset_inventory_status: "Hard Down",
      days_in_status: "> 30"]
    drill_fields: [asset_in_status_count_detail*]
  }

  measure: inventory_total_oec {
    #using max for drill downs to sort the drill by most to least OEC
    label: "OEC"
    type: max
    description: "OEC of assets where in_total_fleet = TRUE"
    sql: coalesce(${oec},0) ;;
    value_format_name: usd_0
  }


  set: pending_detail {
    fields: [formatted_date, rental_branch_name, asset_inventory_status, days_in_status, asset_id, oec_sum]
  }

  set: company_oec_status_detail {
    fields: [asset_inventory_status, market_region_xwalk.region_name, rental_fleet_units_sum_drill_less, rental_fleet_oec_sum_drill_less , rental_fleet_oec_percent_of_total]
  }

  set: region_oec_status_detail {
    fields: [asset_inventory_status, market_region_xwalk.district, rental_fleet_units_sum_drill_less, rental_fleet_oec_sum_drill_less , rental_fleet_oec_percent_of_total]
  }

  set: district_oec_status_detail {
    fields: [asset_inventory_status, market_region_xwalk.market_name, rental_fleet_units_sum_drill_less, rental_fleet_oec_sum_drill_less , rental_fleet_oec_percent_of_total]
  }

  set: market_oec_status_detail {
    fields: [asset_inventory_status, days_in_status, asset_id, rental_branch_name, service_branch_name, equipment_class, year, make, model, T3_Link_with_work_orders, inventory_total_oec]
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
      days_in_status,
      oec_sum]
  }
}
