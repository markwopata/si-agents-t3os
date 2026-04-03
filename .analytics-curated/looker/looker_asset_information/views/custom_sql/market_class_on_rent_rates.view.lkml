##
# The purpose of this view is to add rental rates aggregates for market/class combination.
# Initially requested measure is average by month.
#
# Related story:
# [https://app.shortcut.com/businessanalytics/story/278230/class-count-by-location-add-avg-monthly-rental-rates]
#
# Britt Shanklin | Built 2023-06-28
view: market_class_on_rent_rates {
  derived_table: {
    # persist_for: "24 hours"
    sql: with on_rent as (
    select rental_id, asset_id, price_per_day, price_per_week, price_per_month, price_per_hour
    from ES_WAREHOUSE.PUBLIC.RENTALS r
    where rental_status_id = 5 and deleted = false
    )
    select
        p.market_id,
        p.equipment_class_id,
        p.equipment_class,
        count(p.asset_id) as asset_count,
        sum(r.price_per_month) as total_price_per_month,
        row_number() over ( order by p.market_id, p.equipment_class_id, p.equipment_class) as row_number
    from on_rent r
    inner join analytics.public.rateachievement_points p on r.rental_id = p.rental_id and r.asset_id = p.asset_id
    where {% condition class_name %} p.equipment_class {% endcondition %}
    group by p.market_id, p.equipment_class_id, p.equipment_class
       ;;
   }

  dimension: row_number {
    hidden: yes
    primary_key: yes
    type: number
    sql: ${TABLE}."ROW_NUMBER" ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: equipment_class_id {
    type: number
    sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
  }

  dimension: class_name {
    type: string
    sql: ${TABLE}."EQUIPMENT_CLASS" ;;
  }

  dimension: asset_count {
    type: number
    sql: ${TABLE}."ASSET_COUNT" ;;
  }

  dimension: total_price_per_month {
    type: number
    sql: ${TABLE}."TOTAL_PRICE_PER_MONTH" ;;
  }

  measure: avg_price_per_month {
    label: "Average Monthly Rate for Open Contracts"
    value_format_name: usd
    type: average
    sql: ${total_price_per_month}/${asset_count}  ;;
  }
}
