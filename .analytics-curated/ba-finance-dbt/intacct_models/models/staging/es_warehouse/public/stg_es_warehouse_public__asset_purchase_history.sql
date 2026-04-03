with source as (

    select * from {{ source('es_warehouse_public', 'asset_purchase_history') }}

),

renamed as (

    select

        -- ids
        asset_id,
        previous_company_id,
        purchase_history_id,
        company_id,
        financing_facility_type_id,
        financial_schedule_id,
        equipment_type_id,
        loan_status_type_id,
        invoice_number,

        -- numerics
        oec as original_equipment_cost,
        oec,
        purchase_price,

        -- strings
        round(coalesce(original_equipment_cost, purchase_price, 0), 2) as current_oec,

        case
            when current_oec between 0.01 and 250.00 then '$0 to $250'
            when current_oec between 250.01 and 500.00 then '$250 to $500'
            when current_oec between 500.01 and 1000.00 then '$500 to $1k'
            when current_oec between 1000.01 and 2500.00 then '$1k to $2.5k'
            when current_oec between 2500.01 and 5000.00 then '$2.5k to $5k'
            when current_oec between 5000.01 and 10000.00 then '$5k to $10k'
            when current_oec between 10000.01 and 20000.00 then '$10k to $20k'
            when current_oec between 20000.01 and 40000.00 then '$20k to $40k'
            when current_oec between 40000.01 and 60000.00 then '$40k to $60k'
            when current_oec between 60000.01 and 100000.00 then '$60k to $100k'
            when current_oec between 100000.01 and 250000.00 then '$100k to $250k'
            when current_oec between 250000.01 and 500000.00 then '$250k to $500k'
            when current_oec >= 500000.01 then '$500k and above'
            else 'unrecognized oec value'
        end as current_oec_bucket,

        case
            when current_oec between 0.00 and 250.00 then 1
            when current_oec between 250.01 and 500.00 then 2
            when current_oec between 500.01 and 1000.00 then 3
            when current_oec between 1000.01 and 2500.00 then 4
            when current_oec between 2500.01 and 5000.00 then 5
            when current_oec between 5000.01 and 10000.00 then 6
            when current_oec between 10000.01 and 20000.00 then 7
            when current_oec between 20000.01 and 40000.00 then 8
            when current_oec between 40000.01 and 60000.00 then 9
            when current_oec between 60000.01 and 100000.00 then 10
            when current_oec between 100000.01 and 250000.00 then 11
            when current_oec between 250000.01 and 500000.00 then 12
            when current_oec >= 500000.01 then 13
            else 14
        end as current_oec_bucket_sort,

        -- timestamps
        invoice_purchase_date as purchase_date,
        _es_update_timestamp

    from source

)

select * from renamed
