view: total_inventory_per_store {
  derived_table:{
    sql:with inventory_on_hand as (select sp.STORE_ID
                                , sp.PART_ID
                                , sp.store_part_id
                                , sp.QUANTITY
                                , sp.available_quantity
                           from ES_WAREHOUSE.INVENTORY.STORE_PARTS sp
                           where sp.store_id not in (432, 6004, 9814)
)

select m.part_id
    , m.store_part_id
    , m.store_id
    , m.QUANTITY                                          as total_in_inventory
    , m.AVAILABLE_QUANTITY
    , acs.weighted_average_cost                           as avg_cost
    , m.QUANTITY * acs.weighted_average_cost              as total_dollars_in_inventory
    , coalesce(xw.MARKET_ID, ma.market_id)                as the_market_id
    , coalesce(xw.MARKET_NAME, ma.NAME)                   as the_market_name
    , coalesce(xw._id_dist, ma.district_id)               as the_district_id
    , coalesce(xw.DISTRICT, d.name)                       as the_district_name
    , coalesce(xw.REGION, d.REGION_ID)                    as the_region_id
    , coalesce(xw.REGION_NAME, r.name)                    as the_region_name
    , s.name                                              as store_name
    , p.master_part_id                     as the_part_id
    , l.latitude --heidi added for use in a map
    , l.longitude
from inventory_on_hand m
join analytics.parts_inventory.parts p
    on m.part_id = p.part_id
left join ES_WAREHOUSE.INVENTORY.WEIGHTED_AVERAGE_COST_SNAPSHOTS acs
    on the_part_id = acs.product_id
        and m.STORE_ID = acs.inventory_location_id
        and acs.is_current = true
join ES_WAREHOUSE.INVENTORY.INVENTORY_LOCATIONS s
    on m.STORE_ID = s.INVENTORY_LOCATION_ID
left join ANALYTICS.PUBLIC.MARKET_REGION_XWALK xw
    on s.BRANCH_ID = xw.MARKET_ID
left join ES_WAREHOUSE.PUBLIC.MARKETS ma
    on s.BRANCH_ID = ma.MARKET_ID
left join ES_WAREHOUSE.PUBLIC.LOCATIONS l
on ma.location_id=l.location_id
left join ES_WAREHOUSE.PUBLIC.DISTRICTS d
    on ma.DISTRICT_ID = d.DISTRICT_ID
left join ES_WAREHOUSE.PUBLIC.REGIONS r
    on d.REGION_ID = r.REGION_ID
where -- s.date_archived is null --removed so inactive store inventory can be seen
    --and m.QUANTITY > 0
     the_region_id is not null
    and s.INVENTORY_LOCATION_ID in (select il.inventory_location_id -- this is the accounting JE suppression piece
                     from ES_WAREHOUSE.INVENTORY.INVENTORY_LOCATIONS il
                              join ES_WAREHOUSE.PUBLIC.MARKETS m
                                   on il.BRANCH_ID = m.MARKET_ID
                     where il.company_id = 1854
                       and il.date_archived is null -- vishesh agreed with ignoring qty on inactive stores and active stores that are tied to an archived market
                       and m.ACTIVE = TRUE) -- inactive store & market suppression
;;
   }

  dimension: part_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.the_part_id ;;
  }

  dimension: store_part_id {
    primary_key: yes
    type: number
    value_format_name: id
    sql: ${TABLE}.store_part_id ;;
  }

  dimension: store_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.store_id ;;
  }

  dimension: store_name {
    type: string
    sql: ${TABLE}.store_name;;
  }

  dimension: quantity_in_inventory {
    type: number
    sql: ${TABLE}.total_in_inventory ;;
  }

  dimension: available_quantity {
    type: number
    sql: ${TABLE}.available_quantity ;;
  }

  measure: total_available_quantity {
    type:  sum
    sql: ${available_quantity} ;;
  }
  dimension: average_cost {
    type: number
    sql: ${TABLE}.avg_cost ;;
  }

  dimension: value_in_inventory {
    type: number
    sql: ${TABLE}.total_dollars_in_inventory ;;
  }

  dimension_group: last_used_date {
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
    sql:${TABLE}.last_used_date ;;
  }

  dimension_group: snap_reference {
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
    sql:${TABLE}.snap_reference ;;
  }

  dimension: dead_stock_quantity {
    type: number
    sql: ${TABLE}.dead_stock_quantity ;;
  }

  dimension: dead_stock_dollars {
    type: number
    sql: ${TABLE}.dead_stock_dollars ;;
  }

  dimension: market_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.the_market_id ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}.the_market_name ;;
  }

  dimension: market_lat_long {
    type: location
    sql_latitude: ${TABLE}.latitude;;
    sql_longitude: ${TABLE}.longitude;;
   # drill_fields: [store_name,available_quantity,last_used_date_date, pm_emails]
  }

  dimension: district_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.the_district_id ;;
  }

  dimension: district_name {
    type: string
    sql: ${TABLE}.the_district_name ;;
  }

  dimension: region_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.the_region_id ;;
  }

  dimension: region_name {
    type: string
    sql: ${TABLE}.the_region_name ;;
  }

  dimension: selected_hierarchy_dimension {
    label: "Filtered Location"
    type: string
    # link: {label:"El ChuPARTcabra Dashboard"
    #   url:"https://equipmentshare.looker.com/dashboards/937?Market+Name=&District+Name=&Region+Name="}
    sql: {% if market_name._in_query %}
           ${store_name}
         {% elsif district_name._in_query %}
           ${market_name}
         {% elsif region_name._in_query %}
           ${district_name}
         {% else %}
           ${region_name}
         {% endif %};;
  }

  dimension: selected_hierarchy_dimension_inverted {
    type: string
  #   # link: {label:"El ChuPARTcabra Dashboard"
  #   #   url:"https://equipmentshare.looker.com/dashboards/937?Market+Name=&District+Name=&Region+Name="}
    sql: {% if region_name._in_query %}
          ${region_name}
        {% elsif district_name._in_query %}
          ${district_name}
        {% elsif market_name._in_query %}
          ${market_name}
        {% else %}
          null--${market_name}
        {% endif %};;
  }

  measure: total_quantity_in_inventory {
    type: sum
    sql: ${quantity_in_inventory} ;;
    drill_fields: [
      store_name,
      parts.part_number,
      parts.search,
      providers.name,
      total_quantity_in_inventory,
      value_in_inventory
    ]
  }

  measure: total_value_in_inventory {
    type: sum
    value_format_name: usd
    sql: ${value_in_inventory} ;;
    drill_fields: [
      selected_hierarchy_dimension,
      parts.part_number,
      part_types.description,
      providers.name,
      total_quantity_in_inventory,
      total_value_in_inventory
    ]
  }
 }

# view: total_inventory_per_market {
#   derived_table: {
#     explore_source: inventory {
#       column: market_id           {field: total_inventory_per_store.market_id}
#       column: part_id             {field: total_inventory_per_store.part_id}
#       column: total_in_inventory  {field: total_inventory_per_store.total_in_inventory}
#       column: available_quantity  {field: total_inventory_per_store.available_quantity}
#     }
#   }
#   dimension: market_id {
#     sql: ${TABLE}.market_id ;;
#   }
#   dimension: part_id {
#     sql: ${TABLE}.part_id ;;
#   }
#   dimension: total_in_inventory {
#     type: number
#     sql: ${TABLE}."TOTAL_IN_INVENTORY" ;;
#   }
#   dimension: available_quantity {
#     type: number
#     sql: ${TABLE}."AVAILABLE_QUANTITY" ;;
#   }
# }
view: total_inventory_per_market {
  derived_table: {
    sql:  select the_market_id as market_id,
                the_part_id as part_id,
                sum(total_in_inventory) as total_in_inventory,
                sum(available_quantity) as available_quantity
          from ${total_inventory_per_store.SQL_TABLE_NAME}
          group by 1,2;;
  }
  dimension: market_id {
    sql: ${TABLE}."MARKET_ID" ;;
  }
  dimension: part_id {
    sql: ${TABLE}."PART_ID" ;;
  }
  dimension: total_in_inventory {
    type: number
    sql: ${TABLE}."TOTAL_IN_INVENTORY" ;;
  }
  dimension: available_quantity {
    type: number
    sql: ${TABLE}."AVAILABLE_QUANTITY" ;;
  }
}
