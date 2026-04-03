view: bulk_on_rent_rolling_90_days {
  derived_table: {
    sql:

        WITH rental_day_list AS
        (
            select
            dateadd(
            day,
            '-' || row_number() over (order by null),
            dateadd(day, '+1', current_timestamp())
            ) as rental_day
            from table (generator(rowcount => 90))
        )
        , prep_store_part_cost as (
                select STORE_PART_ID
                     , STORE_PART_COST_ID
                     , COST
                     , DATE_ARCHIVED
                     , DATE_CREATED
                     , coalesce(lag(DATE_ARCHIVED::timestamp_ntz)
                                    over (partition by STORE_PART_ID order by date_archived, STORE_PART_COST_ID),
                                0::timestamp_ntz)::timestamp_ntz                           as date_start
                     , coalesce(DATE_ARCHIVED::timestamp_ntz, '2099-12-31'::timestamp_ntz) as date_end
                from ES_WAREHOUSE.INVENTORY.STORE_PART_COSTS
                order by STORE_PART_ID, STORE_PART_COST_ID
        )
        -- incorporate average cost from last snapshot
        , average_cost as (
              select store_id
                   , market_id
                   , current_part_id
                   , AVG_COST
              from ANALYTICS.PUBLIC.AVERAGE_COST_SNAPSHOT
              where SNAPSHOT_DATE = (select max(snapshot_date) from analytics.PUBLIC.AVERAGE_COST_SNAPSHOT)
        )
        , on_rent as (
            select rdl.rental_day::date as rental_day
                 , r.rental_id
                 , r.rental_type_id
                 , o.order_id
                 , o.MARKET_ID
                 , m.NAME                  as               market_name
                 , sp.STORE_PART_ID
                 , pt.part_type_id
                 , pt.description
                 , coalesce(p2.part_id, p1.PART_ID)         part_id
                 , coalesce(p2.part_number, p1.part_number) part_number
                 , rpa.QUANTITY
                 , iff((ac.avg_cost = 0 or ac.avg_cost is null),spc.COST,ac.AVG_COST) as cost
                 , sp.STORE_ID
                 , rpa.QUANTITY * cost as               total_cost
                 , rpa.START_DATE::date as start_date
                 , rpa.END_DATE::date as end_date
            from ES_WAREHOUSE.PUBLIC.RENTAL_PART_ASSIGNMENTS rpa
                     join ES_WAREHOUSE.PUBLIC.RENTALS r
                          on rpa.RENTAL_ID = r.RENTAL_ID
                     join ES_WAREHOUSE.PUBLIC.ORDERS o
                          on r.ORDER_ID = o.ORDER_ID
                     join ES_WAREHOUSE.PUBLIC.MARKETS m
                          on o.MARKET_ID = m.MARKET_ID
                     join ES_WAREHOUSE.INVENTORY.inventory_locations s
                          on o.MARKET_ID = s.BRANCH_ID
                     join ES_WAREHOUSE.INVENTORY.PARTS p1
                          on rpa.part_id = p1.part_id
                     left join es_warehouse.INVENTORY.parts p2
                               on p1.DUPLICATE_OF_ID = p2.part_id
                     join ES_WAREHOUSE.INVENTORY.STORE_PARTS sp
                          on s.inventory_location_id = sp.STORE_ID
                              and sp.PART_ID = coalesce(p2.part_id, p1.part_id)
                     join rental_day_list rdl
                          on rdl.rental_day BETWEEN (convert_timezone('America/Chicago', rpa.start_date))
                            and COALESCE((convert_timezone('America/Chicago', rpa.end_date)), '2099-12-31')
                     join prep_store_part_cost spc
                          on sp.STORE_PART_ID = spc.STORE_PART_ID
                              and rpa.start_date >= spc.date_start
                              and rpa.start_date < spc.date_end
                     join ES_WAREHOUSE.INVENTORY.PART_TYPES pt
                          on pt.PART_TYPE_ID = coalesce(p2.PART_TYPE_ID, p1.PART_TYPE_ID)
                    left join average_cost ac --kaa
                          on ac.current_part_id = coalesce(p2.part_id, p1.PART_ID) and ac.store_id = sp.store_id
            )
            select rental_day
                 , market_id
                 , market_name
                 , rental_id
                 , rental_type_id
                 , order_id
                 , store_id
                 , store_part_id
                 , part_id
                 , part_number
                 , description
                 , start_date
                 , end_date
                 , sum(cost) as bulk_unit_cost_on_rent
                 , sum(quantity) as bulk_parts_on_rent
                 , sum(total_cost) as bulk_cost_on_rent
                 , current_date() as last_updated
                 , row_number() OVER(ORDER BY rental_day DESC) as unique_record
            from on_rent
            group by rental_day, market_id, market_name, rental_id, rental_type_id, order_id, store_id, store_part_id, part_id, part_number, description, start_date, end_date
            order by market_id, rental_day desc;;
            }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: unique_record {
    hidden: yes
    type: number
    primary_key: yes
    sql: ${TABLE}."UNIQUE_RECORD" ;;
  }

  dimension: rental_day {
    type: date
    sql: ${TABLE}."RENTAL_DAY" ;;
  }

  dimension: rental_id {
    type: number
    sql: ${TABLE}."RENTAL_ID" ;;
  }

  dimension: rental_type_id {
    type: number
    sql: ${TABLE}."RENTAL_TYPE_ID" ;;
  }

  dimension: order_id {
    type: number
    sql: ${TABLE}."ORDER_ID"  ;;
    value_format_name: id
  }

  dimension: store_id {
    type: number
    sql: ${TABLE}."STORE_ID" ;;
    value_format_name: id
  }

  dimension: store_part_id {
    type: number
    sql: ${TABLE}."STORE_PART_ID" ;;
  }

  dimension: part_id {
    type: number
    sql: ${TABLE}."PART_ID" ;;
    value_format_name: id
  }

  dimension: part_number {
    type: string
    sql: ${TABLE}."PART_NUMBER" ;;
  }

  dimension: part_description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
    value_format_name: id
  }

  dimension_group: start_date {
    type: time
    datatype: date
    sql: ${TABLE}."START_DATE" ;;
  }

  dimension_group: end_date {
    type: time
    datatype: date
    sql: ${TABLE}."END_DATE" ;;
  }

  dimension: bulk_parts_on_rent {
    type: number
    sql: ${TABLE}."BULK_PARTS_ON_RENT" ;;
  }

  dimension: bulk_cost_on_rent {
    description: "Sum of Cost * Quantity of Parts"
    type: number
    sql: ${TABLE}."BULK_COST_ON_RENT" ;;
    value_format_name: usd
  }

  dimension: bulk_unit_cost_on_rent {
    type: number
    sql: ${TABLE}."BULK_UNIT_COST_ON_RENT" ;;
    value_format_name: usd
  }

  dimension: last_updated {
    type: date
    sql: ${TABLE}."LAST_UPDATED" ;;
  }

  measure: unit_total {
    label: "Sum of Quantity of Parts"
    type:  sum
    drill_fields: [detail*]
    sql: ${bulk_parts_on_rent} ;;
  }

  measure: cost_total {
    label: "Total Cost"
    type:  sum
    drill_fields: [detail*]
    sql: ${bulk_cost_on_rent} ;;
    value_format_name: usd
  }

  measure: unit_cost_total {
    label: "Cost of Parts per Unit"
    type: sum
    sql: ${bulk_unit_cost_on_rent} ;;
    value_format_name: usd
  }

  set: detail {
    fields: [market_id, market_name, rental_id, order_id, start_date_date, end_date_date, part_id, part_number, part_description, store_id, store_part_id, unit_total, unit_cost_total, cost_total]
  }
}
