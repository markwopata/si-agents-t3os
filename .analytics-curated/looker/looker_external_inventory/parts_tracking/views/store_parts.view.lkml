view: store_parts {
  derived_table: {
    sql: with threshold_range as (
      select sp.store_id, sp.part_id, nullif(sp.threshold,0)/nullif(sp.available_quantity,0)*100 as percent_range
      from es_warehouse.inventory.store_parts sp
      group by store_id, part_id, available_quantity, threshold
      )
      select sp._es_update_timestamp, sp.store_part_id, sp.part_id, sp.store_id, sp.quantity, sp.threshold, sp.note,
                case
                  when threshold > available_quantity and threshold is not null then 'Below Minimum'
                  when tr.percent_range >= 80 or quantity - threshold in (1,2) then 'Approaching Minimum'
                  when threshold = available_quantity and threshold is not null then 'At Minimum'
                  when threshold is null then 'No Minimum Set'
                  else 'Sufficient'
                end as product_threshold
               from es_warehouse.inventory.store_parts sp
      join threshold_range tr on tr.store_id = sp.store_id and tr.part_id = sp.part_id
               where sp.store_id in (3917,3918,3920,3921)
            ;;
  }
  drill_fields: [store_part_id]

  dimension: store_part_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."STORE_PART_ID" ;;
  }

  dimension_group: _es_update_timestamp {
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
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: location {
    type: string
    sql: ${TABLE}."LOCATION" ;;
  }

  dimension: max {
    label: "Maximum"
    description: "Displays 'No Product Maximum' instead of NULLs"
    type: string
    sql: coalesce(cast(${TABLE}."MAX" as string), 'No Product Maximum');;
  }

  dimension: note {
    type: string
    sql: ${TABLE}."NOTE" ;;
  }

  dimension: part_id {
    type: number
    sql: ${TABLE}."PART_ID" ;;
  }

  dimension: quantity {
    type: number
    sql: ${TABLE}."QUANTITY" ;;
  }

  dimension: store_id {
    type: number
    sql: ${TABLE}."STORE_ID" ;;
  }

  dimension: threshold {
    label: "Minimum"
    description: "Displays 'No Product Minimum' instead of NULLs"
    type: string
    sql: coalesce(cast(${TABLE}."THRESHOLD" as string), 'No Product Minimum') ;;
  }

  dimension: product_threshold {
    type: string
    sql: ${TABLE}."PRODUCT_THRESHOLD" ;;
    html: {% if value == 'Sufficient' %}
          <p style="color: white; background-color: #00CB86; font-size:100%; text-align:center">{{ rendered_value }}</p>
          {% elsif value == 'Below Minimum' %}
          <p style="color: white; background-color: #DA344D; font-size:100%; text-align:center">{{ rendered_value }}</p>
          {% elsif value == 'Approaching Minimum' %}
          <p style="color: white; background-color: #fcdd6a; font-size:100%; text-align:center">{{ rendered_value }}</p>
          {% elsif value == 'At Minimum' %}
          <p style="color: white; background-color: #fcdd6a; font-size:100%; text-align:center">{{ rendered_value }}</p>
          {% elsif value == 'No Minimum Set' %}
          <p style="color: black; font-size:100%; text-align:center">{{ rendered_value }}</p>
          {% endif %} ;;
  }

  measure: parts_quantity {
    type: sum
    sql: ${quantity} ;;
    drill_fields: [store_part_id, providers.name, cost_by_provider.description, cost_by_provider.part_number, location, quantity, cost_by_provider.total_cost]
  }

  measure: count {
    type: count
    drill_fields: [store_part_id]
  }
}
