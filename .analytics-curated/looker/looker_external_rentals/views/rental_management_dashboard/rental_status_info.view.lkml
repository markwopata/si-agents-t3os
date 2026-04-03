view: rental_status_info {
  derived_table: {
    sql:
    select
    RENTAL_ID
    , STATUS
    , rsi.ASSET_ID
    , RENTAL_START_DATE
    , RENTAL_END_DATE
    , PRICE_PER_DAY
    , PRICE_PER_WEEK
    , PRICE_PER_MONTH
    , ORDERED_BY
    , ASSET
    , ASSET_CLASS
    , PURCHASE_ORDER
    , PURCHASE_ORDER_ID
    , DELIVERY_ADDRESS
    , COMPANY_ID
    , JOBSITE
    , NEXT_CYCLE_DATE
    , CYCLES_NEXT_SEVEN_DAYS
    , PULL_RECENT_ASSET_ASSIGNMENT
    , VENDOR
    , sub_renting_company
    , sub_renting_contact
    from
    business_intelligence.triage.stg_t3__rental_status_info rsi
    where
      (
       (    status = 'off_rent' and convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start date_filter %})::date <= rental_start_date
       and status = 'off_rent' and convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end date_filter %})::date >= rental_start_date
      ) or
       ( status = 'off_rent' and convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start date_filter %})::date <= rental_end_date
       and status = 'off_rent' and convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end date_filter %})::date >= rental_end_date)
       or status != 'off_rent'  )
        and
        {% condition po_filter %} purchase_order {% endcondition %}
        and {% condition asset_filter %} asset {% endcondition %}
        and {% condition class_filter %} asset_class {% endcondition %}
        and {% condition jobsite_filter %} jobsite {% endcondition %}
        and {% condition vendor_filter %} vendor {% endcondition %}
        and {% condition ordered_by_filter %} ordered_by {% endcondition %}
        and company_id = {{ _user_attributes['company_id'] }}::integer
      ;;
  }

  measure: count {
    type: count
    html: {{rendered_value}} assets ;;
    drill_fields: [detail*]
  }

  filter: date_filter {
    type: date_time
  }

  filter: asset_filter {
    type: string
  }

  filter: class_filter {
    type: string
  }

  filter: po_filter {
    type: string
  }

  filter: jobsite_filter {
    type: string
  }

  filter: vendor_filter {
    type: string
  }

  filter: rental_rate_filter {
    type: yesno
  }

  filter: ordered_by_filter {
    type: string
  }


  dimension: rental_id {
    type: number
    sql: ${TABLE}."RENTAL_ID" ;;
    value_format_name: id
    primary_key: yes
  }

  dimension: rental_link {
    group_label: "Rental Contract Link"
    label: "Rental ID"
    type: string
    sql: ${rental_id} ;;
    html: <font color="#0063f3"><u><a href="https://app.estrack.com/#/assets/all/rentals/{{ rental_id._filterable_value }}/overview" target="_blank">{{rental_id._rendered_value}}</a></font></u>;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
    value_format_name: id
  }

  dimension_group: rental_start_date {
    type: time
    sql: ${TABLE}."RENTAL_START_DATE" ;;
  }

  dimension_group: rental_end_date {
    type: time
    sql: ${TABLE}."RENTAL_END_DATE" ;;
  }

  dimension: price_per_day {
    label: "Price Per Day"
    type: number
    sql: ${TABLE}."PRICE_PER_DAY" ;;
    value_format_name: usd_0
  }

  dimension: price_per_week {
    label: "Price Per Week"
    type: number
    sql: ${TABLE}."PRICE_PER_WEEK" ;;
    value_format_name: usd_0
  }

  dimension: price_per_month {
    label: "Price Per Month"
    type: number
    sql: ${TABLE}."PRICE_PER_MONTH" ;;
    value_format_name: usd_0
  }

  dimension: ordered_by {
    type: string
    sql: ${TABLE}."ORDERED_BY" ;;
  }

  dimension: asset {
    type: string
    sql: ${TABLE}."ASSET" ;;
  }

  dimension: asset_class {
    label: "Class"
    type: string
    sql: ${TABLE}."ASSET_CLASS" ;;
  }

  dimension: purchase_order_id {
    type: number
    sql: ${TABLE}."PURCHASE_ORDER_ID" ;;
  }

  dimension: purchase_order {
    type: string
    sql: ${TABLE}."PURCHASE_ORDER" ;;
    required_fields: [purchase_order_id]
    html: <font color="blue"><u><a href="https://app.estrack.com/#/company-admin/work/purchase-orders/edit/{{ rental_status_info.purchase_order_id._value }}" target="_blank">{{value}}</a></font?</u> ;;
  }

  dimension: delivery_address {
    type: string
    sql: ${TABLE}."DELIVERY_ADDRESS" ;;
  }

  dimension: next_cycle_date {
    type: date
    sql: ${TABLE}."NEXT_CYCLE_DATE" ;;
  }

  dimension: cycles_next_seven_days {
    type: yesno
    sql: ${TABLE}."CYCLES_NEXT_SEVEN_DAYS" ;;
  }

  dimension: jobsite {
    type: string
    sql: ${TABLE}."JOBSITE" ;;
  }

  dimension: vendor {
    type: string
    sql: ${TABLE}."VENDOR" ;;
  }

  dimension: sub_renting_company {
    type: string
    sql: ${TABLE}."SUB_RENTING_COMPANY" ;;
  }

  dimension: sub_renting_contact {
    type: string
    sql: ${TABLE}."SUB_RENTING_CONTACT" ;;
  }

  dimension: rental_start_date_formatted {
    group_label: "HTML Formatted Time"
    label: "Rental Start Date"
    type: date
    sql: ${rental_start_date_raw} ;;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  dimension: rental_end_date_formatted {
    group_label: "HTML Formatted Time"
    label: "Rental End Date"
    type: date
    sql: ${rental_end_date_raw} ;;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  dimension: asset_link_to_asset_info {
    group_label: "Link to T3"
    label: "Asset"
    type: string
    sql: ${asset};;
    # html: <font color="#0063f3"><u><a href="https://app.estrack.com/#/assets/all/asset/{{ asset_id._filterable_value }}/status" target="_blank">{{value}}</a></font></u>;;
    html:
    {% if vendor._value == 'EQUIPMENTSHARE.COM INC' %}
    <font color="#0063f3"><u><a href="https://app.estrack.com/#/assets/all/rentals/{{ rental_id._filterable_value }}/history?selectedDate={{ current_date._value}}" target="_blank">{{value}}</a></font></u>
    {% else %}
    <font color="#0063f3"><u><a href="https://app.estrack.com/#/assets/all/asset/{{ assets.asset_id._value }}/history?selectedDate={{ current_date._value}}" target="_blank">{{value}}</a></font></u>
    {% endif %};;
  }

  dimension: current_date {
    type: date
    sql: current_date() ;;
  }

  measure: on_rent_count {
    type: count
    filters: [status_formatted: "On Rent"]
    html: {{rendered_value}} Assets On Rent ;;
    drill_fields: [detail*]
  }

  measure: waiting_for_pickup_count {
    label: "Needing Pick Up Count"
    type: count
    filters: [status: "waiting_for_pickup"]
    html: {{rendered_value}} Assets Waiting for Pickup ;;
  }

  measure: reservations_count {
    type: count
    filters: [status: "reservation"]
    html: {{rendered_value}} Current Reservations ;;
    drill_fields: [detail*]
  }

  measure: cycling_this_week_count {
    type: count
    filters: [cycles_next_seven_days: "Yes"]
    html: {{rendered_value}} Assets Cycling This Week ;;
    drill_fields: [detail*]
  }

  measure: off_rent_count {
    type: count
    filters: [status: "off_rent"]
    html: {{rendered_value}} Assets Off Rent ;;
    drill_fields: [detail*]
  }

  dimension: status_formatted {
    label: "Rental Status"
    type: string
    sql: case
    when ${cycles_next_seven_days} = 'Yes' then 'Cycling This Week'
    when ${status} = 'on_rent' and ${cycles_next_seven_days} = 'No' then 'On Rent'
    when ${status} = 'reservation' then 'Reservation'
    when ${status} = 'waiting_for_pickup' then 'Needing Pick Up'
    when ${status} = 'off_rent' then 'Off Rent'
    else 'Unknown'
    end;;
    html:
    {% if value == 'On Rent' %}
    <font color="#00CB86">❯</font> {{rendered_value }}
    {% elsif value == 'Reservation' %}
    <font color="#FFB14E">❯</font> {{rendered_value }}
    {% elsif value == 'Cycling This Week' %}
    <font color="#336CA4">❯</font> {{rendered_value }}
    {% elsif value == 'Off Rent' %}
    <font color="#fcdd6a">❯</font> {{rendered_value }}
    {% endif %};;
    # html:
    # {% if value == 'On Rent' %}
    # <p style="color: white; background-color: #00CB86; font-size:100%; text-align:center; border-radius: 20px; height: 18px">{{ rendered_value }}</p>
    # {% elsif value == 'Reservation' %}
    # <p style="color: white; background-color: #FFB14E; font-size:100%; text-align:center; border-radius: 20px; height: 18px">{{ rendered_value }}</p>
    # {% elsif value == 'Cycling This Week' %}
    # <p style="color: white; background-color: #336CA4; font-size:100%; text-align:center; border-radius: 20px; height: 18px">{{ rendered_value }}</p>
    # {% elsif value == 'Off Rent' %}
    # <p style="color: white; background-color: #fcdd6a; font-size:100%; text-align:center; border-radius: 20px; height: 18px">{{ rendered_value }}</p>
    # {% endif %};;
  }

  dimension: status_formatted_pie_chart {
    type: string
    sql: case when ${status} = 'on_rent' then 'On Rent'
          when ${status} = 'reservation' then 'Reservation'
          when ${status} = 'waiting_for_pickup' then 'Needing Pick Up'
          when ${cycles_next_seven_days} = 'Yes' then 'Cycling Next 7 Days'
          when ${status} = 'off_rent' then 'Off Rent'
          else 'Unknown'
          end;;
  }

  measure: rental_insight {
    type: string
    sql: ${on_rent_count} ;;
    html: <p><font color="#51d39d" size="6px"><b>{{on_rent_count._rendered_value}}</b></font> <font color="#51d39d"> on rent assets</font></p>
    <p><font color="#eb7922" size="5px"><b>{{cycling_this_week_count._rendered_value}}</b></font> <font color="#eb7922"> cycling this week</font></p>
    <p><font color="#002f94" size="5px"><b>{{reservations_count._rendered_value}}</b></font> <font color="#002f94">rental reservations</font></p>
    ;;
  }

  set: detail {
    fields: [
      status_formatted,
      companies.name,
      rental_link,
      asset_link_to_asset_info,
      asset_class,
      jobsite,
      purchase_order,
      ordered_by,
      rental_start_date_formatted,
      rental_end_date_formatted,
      price_per_day,
      price_per_week,
      price_per_month
    ]
  }
}
