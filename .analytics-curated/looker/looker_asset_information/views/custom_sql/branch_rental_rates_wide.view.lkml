view: branch_rental_rates_wide {
  # Or, you could make this view a derived table, like this:
  derived_table: {
    sql:SELECT brr1.equipment_class_id,
               brr1.branch_id,
              (select concat('$',ceil(sum(brr2.price_per_day)),' / $',ceil(sum(brr2.price_per_week)),' / $',ceil(sum(brr2.price_per_month)))
               from es_warehouse.public.branch_rental_rates brr2
              where brr2.branch_id = brr1.branch_id
              and brr2.equipment_class_id = brr1.equipment_class_id
              and brr2.rate_type_id = 1
              and brr2.active=true) online_rates,
              (select concat('$',ceil(sum(brr2.price_per_day)),' / $',ceil(sum(brr2.price_per_week)),' / $',ceil(sum(brr2.price_per_month)))
               from es_warehouse.public.branch_rental_rates brr2
              where brr2.branch_id = brr1.branch_id
              and brr2.equipment_class_id = brr1.equipment_class_id
              and brr2.rate_type_id = 2
              and brr2.active=true) benchmark_rates,
              (select concat('$',ceil(sum(brr2.price_per_day)),' / $',ceil(sum(brr2.price_per_week)),' / $',ceil(sum(brr2.price_per_month)))
               from es_warehouse.public.branch_rental_rates brr2
              where brr2.branch_id = brr1.branch_id
              and brr2.equipment_class_id = brr1.equipment_class_id
              and brr2.rate_type_id = 3
              and brr2.active=true) floor_rates
      FROM es_warehouse.public.branch_rental_rates brr1
      where brr1.active=true
      ;;
  }

  # Define your dimensions and measures here, like this:
  dimension: branch_x_equipment_id {
    primary_key: yes
    type: string
    sql: concat(${TABLE}.branch_id,'-',${TABLE}.equipment_class_id) ;;
  }

  dimension: branch_id {
    type: number
    sql: ${TABLE}.branch_id ;;
  }

  dimension: equipment_class_id {
    type: number
    sql: ${TABLE}.equipment_class_id ;;
  }

  dimension: online_rates {
    type: string
    sql: ${TABLE}.online_rates ;;
  }

  dimension: benchmark_rates {
    type: string
    sql: ${TABLE}.benchmark_rates ;;
  }

  dimension: benchmark_rates_month {
    type: number
    sql: split_part(${TABLE}.benchmark_rates, '/ $', 3) ;;
  }

  dimension: floor_rates {
    type: string
    sql: ${TABLE}.floor_rates ;;
  }

}
