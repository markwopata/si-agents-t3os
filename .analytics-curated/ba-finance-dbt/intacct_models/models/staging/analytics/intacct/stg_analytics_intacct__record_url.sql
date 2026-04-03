with source as (
    select * from {{ source('analytics_intacct', 'record_url') }}
)

, renamed as (
    select
        -- ids
        md5(concat(recordno, '-', intacct_object)) as pk_record_url_id,

        -- strings
        recordno as intacct_recordno,
        record_url as url_sage,
        intacct_object,

        -- timestamps
        date_created,
        date_updated

    from source
)
select * from renamed
