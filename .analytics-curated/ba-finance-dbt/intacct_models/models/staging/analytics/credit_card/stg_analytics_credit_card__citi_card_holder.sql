with source as (
    select * from {{ source('analytics_credit_card', 'citi_card_holder') }}
),

renamed as (
    select
        -- ids
        replace(employee_id, 'CW', '')::int as employee_id,
        corporate_account_number,

        -- strings
        full_name,
        card_status,
        iff(card_status_description = 'OPEN','Open',card_status_description) as card_status_description,        

        -- date
        account_open_date,
        card_activation_date,
        card_closed_date,
        card_expiration_date,
        coalesce(card_closed_date, account_open_date) as account_open_or_closed_date,


        -- booleans
        coalesce(card_status = 'Open', false) as is_card_open

    from source
)

select * from renamed
