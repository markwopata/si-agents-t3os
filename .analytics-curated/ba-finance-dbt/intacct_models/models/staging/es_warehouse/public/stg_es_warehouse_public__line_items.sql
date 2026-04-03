with source as (

    select * from {{ source('es_warehouse_public', 'line_items') }}

),

renamed as (

    select

        -- ids
        li.rental_id,
        li.line_item_id,
        li.line_item_type_id,
        li.invoice_id,
        li.branch_id,
        li.asset_id,
        coalesce(li.part_id, li.extended_data:"part_id") as part_id,
        li.extended_data:"part_number" as part_number,
        li.tax_rate_id,

        -- strings
        li.description,
        li.extended_data,
        li.override_market_tax_rate,

        -- numerics
        li.tax_rate_percentage,
        li.tax_amount,
        li.number_of_units,
        li.price_per_unit,
        round(amount, 2) as amount,

        -- booleans
        li.taxable,
        li.payouts_processed,

        -- timestamps
        li._es_update_timestamp,
        li.date_updated,
        li.date_created,

        -- nested_fields
        li.extended_data:"rental" as extended_data__rental,
        li.extended_data:"rental":"cheapest_period_week_count"::int
            as extended_data__rental__cheapest_period_week_count,
        li.extended_data:"rental":"location" as extended_data__rental__location,
        li.extended_data:"rental":"location":"street_1" as extended_data__rental__location__street_1,
        nullif(li.extended_data:"rental":"price_per_month"::string, 'null') as extended_data__rental__price_per_month,
        li.extended_data:"rental":"shift_info":"shift_type" as extended_data__rental__shift_info__shift_type,
        li.extended_data:"rental":"location":"state" as extended_data__rental__location__state,
        li.extended_data:"rental":"equipment_assignments" as extended_data__rental__equipment_assignments,
        li.extended_data:"rental":"location":"street_2" as extended_data__rental__location__street_2,
        nullif(li.extended_data:"rental":"price_per_day"::string, 'null') as extended_data__rental__price_per_day,
        li.extended_data:"rental":"rental_bill_type"::text as extended_data__rental__rental_bill_type,
        li.extended_data:"delivery" as extended_data__delivery,
        li.extended_data:"delivery":"asset_id" as extended_data__delivery__asset_id,
        li.extended_data:"rental":"location":"zip_code" as extended_data__rental__location__zip_code,
        nullif(li.extended_data:"rental":"price_per_hour"::string, 'null') as extended_data__rental__price_per_hour,
        li.extended_data:"part_number" as extended_data__part_number,
        li.extended_data:"rental":"equipment_class_name" as extended_data__rental__equipment_class_name,
        li.extended_data:"rental":"shift_info":"shift_type_id" as extended_data__rental__shift_info__shift_type_id,
        li.extended_data:"rental":"location":"city" as extended_data__rental__location__city,
        li.extended_data:"delivery":"scheduled_date" as extended_data__delivery__scheduled_date,
        nullif(li.extended_data:"rental":"price_per_week"::string, 'null') as extended_data__rental__price_per_week,
        li.extended_data:"rental":"rental_id" as extended_data__rental__rental_id,
        li.extended_data:"rental":"cheapest_period_hour_count"::int
            as extended_data__rental__cheapest_period_hour_count,
        li.extended_data:"rental":"cheapest_period_month_count"::int
            as extended_data__rental__cheapest_period_month_count,
        li.extended_data:"rental":"end_date" as extended_data__rental__end_date,
        li.extended_data:"rental":"start_date" as extended_data__rental__start_date,
        li.extended_data:"delivery":"delivery_id" as extended_data__delivery__delivery_id,
        li.extended_data:"rental":"shift_info" as extended_data__rental__shift_info,
        li.extended_data:"delivery":"rental_id" as extended_data__delivery__rental_id,
        li.extended_data:"rental":"cheapest_period_day_count"::int as extended_data__rental__cheapest_period_day_count,
        li.extended_data:"rental":"location":"nickname" as extended_data__rental__location__nickname,
        li.extended_data:"part_id" as extended_data__part_id,
        datediff(day, li.extended_data:"rental":"start_date", li.extended_data:"rental":"end_date")
            as rental_billed_days,
        li.extended_data:"rental":"cheapest_period_four_week_count"::int
            as extended_data__rental__cheapest_period_four_week_count,
        nullif(li.extended_data:"rental":"price_per_four_weeks"::string, 'null')
            as extended_data__rental__price_per_four_weeks,

        -- Present Cheapest Period in a user readable format
        case
            when li.line_item_type_id = 8
                then 'Month: ' || coalesce((li.extended_data:"rental":"cheapest_period_month_count")::text, '0')
                    || ' | Week: ' || coalesce((li.extended_data:"rental":"cheapest_period_week_count")::text, '0')
                    || ' | Day: ' || coalesce((li.extended_data:"rental":"cheapest_period_day_count")::text, '0')
        end as cheapest_period,

        -- Present Rates in a user readable format
        case
            when li.line_item_type_id = 8
                then 'Month: ' || coalesce((li.extended_data:"rental":"price_per_month")::text, '0')
                    || ' | Week: ' || coalesce((li.extended_data:"rental":"price_per_week")::text, '0')
                    || ' | Day: ' || coalesce((li.extended_data:"rental":"price_per_day")::text, '0')
        end as quoted_rates

    from source as li

)

select * from renamed
