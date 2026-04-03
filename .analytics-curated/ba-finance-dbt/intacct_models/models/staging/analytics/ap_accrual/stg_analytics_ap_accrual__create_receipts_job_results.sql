with source as (

    select * from {{ source('analytics_ap_accrual', 'create_receipts_job_results') }}

),

renamed as (

    select
        -- strings
        document_number,
        xml,
        result as result_status,

        -- timestamps
        run_timestamp

    from source

)

select * from renamed
