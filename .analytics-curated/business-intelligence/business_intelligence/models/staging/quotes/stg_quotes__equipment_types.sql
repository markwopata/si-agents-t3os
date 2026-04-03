with 

source as (

    select * from {{ source('quotes', 'equipment_type') }}

),

renamed as (

    select
        id as equipment_type_id,
        cat_class,
        CAST(day_rate AS NUMBER(18,2)) as day_rate,
        equipment_class_id,
        equipment_class_name,
        CAST(four_week_rate AS NUMBER(18,2)) as four_week_rate,
        NULLIF(note, '') as note,
        order_index,
        parent_line_item_id,
        part_id,
        part_name,
        part_type_id,
        CAST(purchase_price AS NUMBER(18,2)) as purchase_price,
        COALESCE(quantity,0) as quantity,
        quote_id,
        selected_rate_type_id,
        shift_id,
        CAST(suggested_advertised_daily_rate AS NUMBER(18,2)) as suggested_advertised_daily_rate,
        CAST(suggested_advertised_monthly_rate AS NUMBER(18,2)) as suggested_advertised_monthly_rate,
        CAST(suggested_advertised_weekly_rate AS NUMBER(18,2)) as suggested_advertised_weekly_rate,
        CAST(suggested_bench_mark_daily_rate AS NUMBER(18,2)) as suggested_bench_mark_daily_rate,
        CAST(suggested_bench_mark_monthly_rate AS NUMBER(18,2)) as suggested_bench_mark_monthly_rate,
        CAST(suggested_bench_mark_weekly_rate AS NUMBER(18,2)) as suggested_bench_mark_weekly_rate,
        CAST(suggested_book_daily_rate AS NUMBER(18,2)) as suggested_book_daily_rate,
        CAST(suggested_book_monthly_rate AS NUMBER(18,2)) as suggested_book_monthly_rate,
        CAST(suggested_book_weekly_rate AS NUMBER(18,2)) as suggested_book_weekly_rate,
        CAST(suggested_company_daily_rate AS NUMBER(18,2)) as suggested_company_daily_rate,
        CAST(suggested_company_monthly_rate AS NUMBER(18,2)) as suggested_company_monthly_rate,
        CAST(suggested_company_weekly_rate AS NUMBER(18,2)) as suggested_company_weekly_rate,
        CAST(suggested_deal_daily_rate AS NUMBER(18,2)) as suggested_deal_daily_rate, 
        CAST(suggested_deal_monthly_rate AS NUMBER(18,2)) as suggested_deal_monthly_rate,
        CAST(suggested_deal_weekly_rate AS NUMBER(18,2)) as suggested_deal_weekly_rate,
        CAST(suggested_floor_daily_rate AS NUMBER(18,2)) as suggested_floor_daily_rate,
        CAST(suggested_floor_monthly_rate AS NUMBER(18,2)) as suggested_floor_monthly_rate,
        CAST(suggested_floor_weekly_rate AS NUMBER(18,2)) as suggested_floor_weekly_rate,
        CAST(suggested_online_daily_rate AS NUMBER(18,2)) as suggested_online_daily_rate,
        CAST(suggested_online_monthly_rate AS NUMBER(18,2)) as suggested_online_monthly_rate,
        CAST(suggested_online_weekly_rate AS NUMBER(18,2)) as suggested_online_weekly_rate,
        CAST(week_rate AS NUMBER(18,2)) as week_rate,
        _es_update_timestamp

    from source

)

select * from renamed
