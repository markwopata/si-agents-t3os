SELECT
    rrc.num_days,
    rrc.rental_id,
    rrc.num_weeks,
    rrc.day_cost,
    rrc.round_down_week_plus_days,
    rrc.round_up_week,
    rrc.month_cost,
    rrc.price_per_day,
    rrc.price_per_week,
    rrc.price_per_month,
    rrc.cheapest_option
FROM {{ source('es_warehouse_public', 'remaining_rental_cost') }} as rrc
