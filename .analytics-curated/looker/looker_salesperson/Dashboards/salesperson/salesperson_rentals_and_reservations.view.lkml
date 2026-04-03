view: salesperson_rentals_and_reservations {
  derived_table: {
    sql: select srar.*,
      COALESCE(aa.oec,0) as oec,
      xw.is_open_over_12_months,
      xw.market_type
      from "ANALYTICS"."BI_OPS"."SALESPERSON_RENTALS_AND_RESERVATIONS" srar
      LEFT JOIN (select asset_id, oec from es_warehouse.public.assets_aggregate where oec IS NOT NULL) aa ON aa.asset_id = srar.asset_id
      LEFT JOIN analytics.public.market_region_xwalk xw on xw.market_id = srar.market_id
    ;;
}
    dimension: rental_type {
      type: string
      sql: ${TABLE}."RENTAL_TYPE" ;;
    }

    dimension: type_of_rental {
      type: string
      sql: ${TABLE}."TYPE_OF_RENTAL" ;;
    }

  dimension: rental_status_full_list {
    type: string
    sql: ${TABLE}."RENTAL_STATUS" ;;
  }

    dimension: rental_status {
      type: string
      sql: case when ${TABLE}."RENTAL_STATUS" in ('Draft', 'Pending') then 'Reservation' else ${TABLE}."RENTAL_STATUS" end ;;
    }

  dimension: rental_status_formatted {
    group_label: "Rental Status Formatted"
    label: "Rental Status"
    type: string
    sql: case when ${TABLE}."RENTAL_STATUS" in ('Draft', 'Pending') then 'Reservation' else ${TABLE}."RENTAL_STATUS" end ;;
    html: {% if rental_status_formatted._value == 'On Rent' %}

    <span style="color: #00CB86;">❯ </span>‎ ‎{{rendered_value}}

    {% elsif rental_status_formatted._value == 'Billed' %}

    <span style="color: #8C8C8C;">❯ </span>‎ ‎{{rendered_value}}

    {% elsif rental_status_formatted._value == 'Reservation' %}

    <span style="color: #FFBF00;">❯ </span>‎ ‎{{rendered_value}}

    {% elsif rental_status_formatted._value == 'Off Rent' %}

    <span style="color: #8C8C8C;">❯ </span>‎ ‎{{rendered_value}}

    {% else %}

    {% endif %};;
  }

    dimension: company {
      type: string
      sql: ${TABLE}."COMPANY" ;;
    }

    dimension: company_id {
      type: string
      sql: ${TABLE}."COMPANY_ID" ;;
    }

    dimension: customer_name {
      group_label: "Customer Name With ID"
      type: string
      sql: concat(${TABLE}."COMPANY",' ID: ',${TABLE}."COMPANY_ID") ;;
    }

    dimension: customer {
      description: "This Customer is used for drill purposes"
      group_label: "Customer Name for Drills and Tables"
      type: string
      sql: ${TABLE}."COMPANY" ;;
      html: <font color="0063f3 "><a href="https://equipmentshare.looker.com/dashboards/28?Company+Name={{ filterable_value | url_encode }}" target="_blank">{{rendered_value}} ➔ </a></font>
    <td>
      <span style="color: #8C8C8C;"> ID: {{company_id._value}} </span>
      </td>;;
    }


    dimension: customer_formatted_for_map {
      description: "This Customer is used only for the map on the Salesperson Rentals page"
      group_label: "Customer Name for Geo-Map"
      label: "Customer"
      sql: ${TABLE}."COMPANY" ;;
      html: {{rendered_value}}
            <br> ‎ </br>;;
    }

    dimension: ordered_by {
      type: string
      sql: ${TABLE}."ORDERED_BY" ;;
    }

    dimension: tam {
      label: "Salesperson"
      type: string
      sql: ${TABLE}."TAM" ;;
    }

    dimension: tam_user_id {
      label: "Salesperson User ID"
      type: string
      sql: ${TABLE}."TAM_USER_ID";;
    }

    dimension: tam_email_address {
      label: "Salesperson Email"
      type: string
      sql: ${TABLE}."TAM_EMAIL_ADDRESS" ;;
    }

    dimension: nam_email_address {
      type: string
      sql: ${TABLE}."NAM_EMAIL_ADDRESS" ;;
    }

    dimension: market_id {
      type: string
      sql: ${TABLE}."MARKET_ID" ;;
    }

    dimension: market_name {
      label: "Market"
      type: string
      sql: ${TABLE}."MARKET_NAME" ;;
    }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: region_name {
    label: "Region"
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension: market_type {
    type: string
    sql: ${TABLE}."MARKET_TYPE" ;;
  }

  dimension: is_open_over_12_months {
    type: yesno
    sql: ${TABLE}."IS_OPEN_OVER_12_MONTHS" ;;
  }

    dimension: rental_id {
      label: "Rental ID"
      type: string
      sql: ${TABLE}."RENTAL_ID" ;;
      # html: <font color="#0063f3 "><u><a href="https://admin.equipmentshare.com/#/home/rentals/{{rendered_value}}" target="_blank">{{rendered_value}}</a></font></u> ;;
      # TAMs don't have access to Admin so this is useless. Keeping it in just in case this ever changes.
    }

    dimension_group: rental_start {
      type: time
      sql: ${TABLE}."RENTAL_START_DATE" ;;
      html: {{ rendered_value | date: "%b %d, %Y"  }};;
    }

  dimension_group: rental_end {
    type: time
    sql: ${TABLE}."RENTAL_END_DATE" ;;
    html: {% if overdue_rental._value == 'Yes' %}

    <span style="color: #DA344D;"> {{ rendered_value | date: "%b %d, %Y"  }} </span>

    {% elsif overdue_rental._value == 'No' %}

    {{ rendered_value | date: "%b %d, %Y"  }}

    {% else %}

    {% endif %};;
  }

  dimension_group: scheduled_drop_off_delivery {
    type: time
    sql: ${TABLE}."SCHEDULED_DROP_OFF_DELIVERY_DATE" ;;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  dimension: no_asset_assigned_for_upcoming_dropoff {
    type: number
    sql: ${TABLE}."NO_ASSET_ASSIGNED_FOR_UPCOMING_DROPOFF" ;;
    ## In the source table, this flag indicates there is no asset/bulk assigned within 24 hours of the scheduled delivery drop off date
  }

  dimension: overdue_rental {
    type: yesno
    sql: ${TABLE}."OVERDUE_RENTAL" ;;
  }

  dimension: days_until_rental_end_date {
    type: number
    sql: ${TABLE}."DAYS_UNTIL_RENTAL_END_DATE" ;;
  }

  dimension: rental_protection_plan {
    type: string
    sql: ${TABLE}."RENTAL_PROTECTION_PLAN" ;;
  }

  dimension_group: asset_start {
    label: "Asset Assigned Start"
    type: time
    sql: ${TABLE}."ASSET_START_DATE" ;;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  dimension_group: asset_end { ## This will most likely always be null
    type: time
    sql: ${TABLE}."ASSET_END_DATE" ;;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  dimension: asset_id {
    group_label: "Unformatted Asset ID"
    type: string
    sql: ${TABLE}."ASSET_ID" ;;
    primary_key: yes
  }

  dimension: asset_id_formatted {
    description: "This Asset ID is used for drill purposes only"
    group_label: "Formatted Asset With Link"
    label: "Asset ID"
    sql: ${TABLE}."ASSET_ID" ;;
    html: <font color="#0063f3 "><u><a href="https://equipmentshare.looker.com/dashboards/169?Asset+ID={{asset_id}}" target="_blank">{{ asset_id._value }}</a></font></u> ;;
  }

  dimension: asset_id_with_swap{
    group_label: "Asset ID With Swap, Assignment Pending, & Link"
    label: "Asset ID"
    type: string
    sql: coalesce(${TABLE}."ASSET_ID"::string, 'Needed for formatting') ;;
    html: {% if value == 'Needed for formatting' and no_asset_assigned_for_upcoming_dropoff._value == 1 %}
    <td>
    <span style="color: #DA344D;"> Pending </span>
    </td>

    {% elsif value == 'Needed for formatting' %}
    <td>
    <span style="color: #8C8C8C;"> Pending </span>
    </td>

    {% elsif type_of_rental._value == 'Assets' and value <> 'Needed for formatting' and is_swap._value == 'Yes' %}

    <font color="#0063f3 "><a href="https://equipmentshare.looker.com/dashboards/169?Asset+ID={{filterable_value | url_encode}}" target="_blank">{{rendered_value}} ➔ </a></font>
    <td>
    <span style="color: #e8646c;"> Swap </span>
    </td>

    {% elsif type_of_rental._value == 'Assets' and value <> 'Needed for formatting' and is_swap._value == 'No' %}

    <font color="#0063f3 "><a href="https://equipmentshare.looker.com/dashboards/169?Asset+ID={{filterable_value | url_encode}}" target="_blank">{{rendered_value}} ➔ </a></font>
    <td>
    </td>

    {% else %}

    <font color="#0063f3 "><a href="https://equipmentshare.looker.com/dashboards/169?Asset+ID={{filterable_value | url_encode}}" target="_blank">{{rendered_value}}}} ➔ </a></font>

    {% endif %};;
  }

  dimension: equipment_class {
    type: string
    sql: ${TABLE}."EQUIPMENT_CLASS" ;;
  }

  dimension: is_rerent {
    type: yesno
    sql: ${TABLE}."IS_RERENT" ;;
  }

  dimension: make_and_model {
    label: "Asset Make and Model"
    type: string
    sql: ${TABLE}."MAKE_AND_MODEL" ;;
  }

  dimension: is_swap {
    type: string
    sql: ${TABLE}."IS_SWAP" ;;
  }

  dimension: rep_type {
    type: string
    sql: ${TABLE}."REP_TYPE" ;;
  }

  dimension: asset_last_known_lat {
    type: number
    sql: ${TABLE}."ASSET_LAST_KNOWN_LAT" ;;
  }

  dimension: asset_last_known_lon {
    type: number
    sql: ${TABLE}."ASSET_LAST_KNOWN_LON" ;;
  }

  dimension: current_rental_location {
    label: "Rental Location"
    type: location
    sql_latitude: ${asset_last_known_lat} ;;
    sql_longitude: ${asset_last_known_lon} ;;
  }

  dimension: asset_last_known_address {
    type: string
    sql: ${TABLE}."ASSET_LAST_KNOWN_ADDRESS" ;;
  }

  dimension: price_per_day {
    type: number
    sql: ${TABLE}."PRICE_PER_DAY" ;;
    value_format_name: usd_0
    html: {% if below_floor_day._value == 'Yes' and type_of_rental._value == 'Assets' %}

    <span style="color: #DA344D;"> {{rendered_value}} </span>

    {% else %}

    {{rendered_value}}

    {% endif %};;
  }

  dimension: price_per_week {
    type: number
    sql: ${TABLE}."PRICE_PER_WEEK" ;;
    value_format_name: usd_0
    html: {% if below_floor_week._value == 'Yes' and type_of_rental._value == 'Assets' %}

    <span style="color: #DA344D;"> {{rendered_value}} </span>

    {% else %}

    {{rendered_value}}

    {% endif %};;
  }

  dimension: price_per_month {
    type: number
    sql: ${TABLE}."PRICE_PER_MONTH" ;;
    value_format_name: usd_0
    html: {% if below_floor_month._value == 'Yes' and type_of_rental._value == 'Assets' %}

    <span style="color: #DA344D;"> {{rendered_value}} </span>

    {% else %}

    {{rendered_value}}

    {% endif %};;
  }

  dimension: floor_day_rate {
    type: number
    sql: ${TABLE}."FLOOR_DAY_RATE" ;;
  }

  dimension: floor_week_rate {
    type: number
    sql: ${TABLE}."FLOOR_WEEK_RATE" ;;
  }

  dimension: floor_month_rate {
    type: number
    sql: ${TABLE}."FLOOR_MONTH_RATE" ;;
  }

  dimension: below_floor_day {
    type: yesno
    sql: ${TABLE}."BELOW_FLOOR_DAY" ;;
  }

  dimension: below_floor_week {
    type: yesno
    sql: ${TABLE}."BELOW_FLOOR_WEEK" ;;
  }

  dimension: below_floor_month {
    type: yesno
    sql: ${TABLE}."BELOW_FLOOR_MONTH" ;;
  }

  dimension: deal_rate_price_per_month {
    type: number
    sql: ${TABLE}."DISCOUNT_PRICE_PER_MONTH" ;;
    html: {% if below_discount_rate._value == 'Yes' %}

    {{rendered_value}}
    <td>
    <span style="color: #8C8C8C;"> Below Floor: <span style="color: #DA344D;"> {{below_discount_rate._value}} </span></span>
    </td>

    {% elsif below_discount_rate._value == 'No' %}

    {{rendered_value}}
    <td>
    <span style="color: #8C8C8C;"> Below Floor: {{below_discount_rate._value}} </span>
    </td>

    {% else %}

    {% endif %};;
  }

  dimension: below_monthly_floor_above_discount {
    type: yesno
    sql: ${TABLE}."BELOW_MONTHLY_FLOOR_ABOVE_DISCOUNT" ;;
  }

  dimension: below_discount_rate {
    type: yesno
    sql: ${TABLE}."BELOW_DISCOUNT_RATE" ;;
  }

  measure: total_count_of_active_rentals {
    type: count_distinct
    sql: ${rental_id} ;;
    filters: [rental_type: "on_rent", type_of_rental: "Assets"]
  }

  measure: total_count_of_assets_on_rent {
    type: count
    #sql: ${asset_id} ;;
    filters: [rental_type: "on_rent", type_of_rental: "Assets"]
    drill_fields: [asset_id_formatted, make_and_model, equipment_class, asset_start_date, rental_id, customer, rental_start_date, rental_end_date, is_swap]
  }

  measure: total_count_of_assets_on_rent_for_map {
    description: "This count of assets is only used for the map"
    label: "Total Count of Assets On Rent"
    type: count
    #sql: ${asset_id} ;;
    filters: [rental_type: "on_rent", type_of_rental: "Assets"]
    drill_fields: [asset_id_formatted, make_and_model, equipment_class, asset_last_known_address]
  }

  measure: total_count_of_rerents_on_rent {
    label: "Total Count of Re-Rents On Rent"
    type: count
    #sql: ${asset_id} ;;
    filters: [rental_type: "on_rent", is_rerent: "Yes", type_of_rental: "Assets"]
    drill_fields: [asset_id_formatted, make_and_model, equipment_class, asset_start_date, rental_id, customer, rental_start_date, rental_end_date, is_swap]
  }

  measure: total_count_of_actively_renting_customer {
    type: count_distinct
    sql: ${company_id} ;;
    filters: [rental_type: "on_rent", type_of_rental: "Assets"]
  }

  measure: total_count_of_reservation {
    type: count_distinct
    sql: ${rental_id} ;;
    filters: [rental_type: "reservation", type_of_rental: "Assets"]
    drill_fields: [asset_id_formatted, make_and_model, equipment_class, asset_start_date, rental_id, customer, rental_start_date, rental_end_date, is_swap]
  }

  dimension: rental_start_date_is_next_30_days {
    type: yesno
    sql: datediff(days,current_date,${rental_start_date}) <= 30 ;;
  }

    measure: oec {
      type: sum
      sql: ${TABLE}."OEC" ;;
      value_format_name: usd_0
    }

 }
