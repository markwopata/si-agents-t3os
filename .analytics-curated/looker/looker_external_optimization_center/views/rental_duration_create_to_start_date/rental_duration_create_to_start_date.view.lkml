view: rental_duration_create_to_start_date {
  derived_table: {
    sql: with rental_list as (
      select
          r.rental_id,
          r.asset_id,
          r.date_created,
          r.start_date
      from
          es_warehouse.public.rentals r
          join es_warehouse.public.assets a on r.asset_id = a.asset_id
      where
          r.rental_type_id = 1
          AND r.rental_status_id in (5,7,9) --On Rent, Completed, Billed
          AND YEAR(r.date_created) >= 2021
          AND r.asset_id is not null
          AND r.date_created <= r.start_date
          AND a.asset_type_id in (1,2)
      )
      , asset_status_info as (
      select
          rl.rental_id,
          rl.asset_id,
          rl.date_created,
          rl.start_date,
          ais.asset_inventory_status,
          ais.date_start as status_start_date,
          ais.date_end as status_end_date,
          dense_rank() OVER (partition by rl.rental_id order by rl.start_date asc, ais.date_start asc) as ranking
      from
          rental_list rl
          join scd.scd_asset_inventory_status ais on rl.asset_id = ais.asset_id and rl.start_date::date <= ais.date_start::date
      where
          ais.asset_inventory_status = 'On Rent'
          --AND rl.asset_id = 98843
          --AND rl.asset_id = 101453
      )
      select
          rental_id,
          asset_id,
          date_created as rental_create_date,
          status_start_date as on_rent_status_date,
          datediff(second,rental_create_date,on_rent_status_date) as second_difference
      from
          asset_status_info
      where
          ranking = 1
          AND second_difference <= 275000 --avg second difference from rental to rental start date is 273,839
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: rental_id {
    type: number
    sql: ${TABLE}."RENTAL_ID" ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension_group: rental_create_date {
    type: time
    sql: ${TABLE}."RENTAL_CREATE_DATE" ;;
  }

  dimension_group: on_rent_status_date {
    type: time
    sql: ${TABLE}."ON_RENT_STATUS_DATE" ;;
  }

  dimension: second_difference {
    type: number
    sql: ${TABLE}."SECOND_DIFFERENCE" ;;
  }

  measure: average_hours {
    type: average
    sql: ${second_difference}/3600 ;;
    value_format_name: decimal_2
  }

  measure: total_hours {
    type: number
    sql: ${second_difference}/3600 ;;
    value_format_name: decimal_2
  }

  dimension: total_hours_bin {
    type: tier
    tiers: [0,1,2,3,4,5,10,15,20,25,30,35,40,45,50,55,60,65,70,75,100,125,150,175,200,225,250,500,1000,2000,3000,4000,5000]
    style: integer
    sql: ${second_difference}/3600 ;;
    value_format_name: decimal_2
  }

  set: detail {
    fields: [rental_id, asset_id, rental_create_date_time, on_rent_status_date_time, second_difference]
  }
}
