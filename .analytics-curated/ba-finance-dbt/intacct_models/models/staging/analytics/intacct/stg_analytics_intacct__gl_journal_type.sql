with source as (
    select * from {{ source('analytics_intacct', 'gl_journal_type') }}
)

, renamed as (
    select
        -- ids
        recordno as pk_journal_type_id,
        createdby as fk_created_by_user_id,
        modifiedby as fk_updated_by_user_id,
        bookid as book_id,

        -- strings
        symbol as journal_type,
        title as extended_journal_type,
        status,

        -- booleans
        adj = 'T' as is_adjustment,

        -- timestamp   
        whenmodified as date_updated,
        whencreated as date_created, 
        ddsreadtime as dds_read_timestamp,
        _es_update_timestamp

    from source
)
select * from renamed
