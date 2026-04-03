with source as (
    select * from {{ source('analytics_public', 'fuel_card_transactions') }}
),

renamed as (
    select
        -- ids
        fct.transaction_id,
        case
            when fct.driver_id = '011400' then '011401'
            when fct.driver_id = '053002' then '053000'
            -- Senteno has 3 old transactions where driver_id doesn't show in drivers table.
            when fct.driver_id = '971101' then '009542'
            -- Some Webb transactions have the wrong driver_id?
            when fct.driver_id = '011085' and fct.last_name = 'WEBB' then '011805'
            when fct.driver_id = '677700' then '005083' -- 677700 driver id doesn't have an employee id 
            when fct.driver_id = '528200' then '004632' -- 528200 driver id doesn't have an employee id
            else fct.driver_id
        end as driver_id,
        fct.card_id,
        fct.vehicle_id,

        -- strings
        trim(upper(fct.first_name)) as first_name,
        trim(upper(fct.last_name)) as last_name,
        trim(upper(concat(fct.first_name, ' ', fct.last_name))) as full_name,
        0::text as mcc_code,
        'fuel_card' as card_type,
        'Open' as status,
        fct.product_description as mcc,
        fct.merchant_name,
        fct.account_name,
        fct.transaction_time,
        fct.invoice_number,
        fct.merchant_address,
        fct.merchant_city,
        fct.merchant_state,
        fct.merchant_zip,
        fct.prompt_type,
        fct.type_of_sale_description,
        fct.vin,
        fct.middle_initial,
        fct.accounting_code,

        -- numerics
        fct.transaction_line_amount as transaction_amount,
        fct.actual_odometer,
        fct.account_number,
        fct.assessed_state_taxes,
        fct.assessed_local_taxes,

        -- booleans
        false as is_bypass_verification,

        -- dates
        fct.transaction_occurred_date as transaction_date,
        fct._es_update_timestamp


    from source as fct
)

select * from renamed
qualify row_number() over (
        partition by transaction_id, _es_update_timestamp
        order by _es_update_timestamp desc
    ) = 1
