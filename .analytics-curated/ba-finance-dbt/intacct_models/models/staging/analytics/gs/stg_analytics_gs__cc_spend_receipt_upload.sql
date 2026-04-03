with source as (
      select * from {{ source('analytics_gs', 'cc_spend_receipt_upload') }}
)

, users as (
    select * from {{ ref('stg_es_warehouse_public__users') }}
)

, renamed as (
    select
        -- ids
        _row

        -- strings
        , employee_name
        , account_type
        , additional_notes
        , upload_receipt
        , case
            when trim(lower(employee_email_address)) not like '%equipmentshare.com%' then email_address
            else employee_email_address
          end as correct_email_address -- there is a typo in employee_email_address: this addresses it

        -- numerics
        , receipt_amount

        -- dates
        , transaction_date

        -- timestamps
        , timestamp

    from source
)

, join_in_users as (

    select
        r.*
        , concat(u.first_name ,' ',u.last_name ) as full_name
    from renamed r
    left join users u
        on r.correct_email_address = u.email_address
)

select * from join_in_users  
