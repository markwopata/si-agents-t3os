with source as (
    select 
        corporate_account_number as corporate_account_number,
        corporate_account_name   as corporate_account_name,
        card_type                as card_type
    from {{ source('analytics_credit_card', 'corporate_card_accounts') }}
)
select * from source