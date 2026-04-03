with source as (
    select * from {{ source('analytics_intacct', 'gl_journal') }} 
)

, renamed as (
    select
        -- ids

        recordno as pk_journal_id,
        reversedkey as fk_reversed_from_journal_id,
        createdby as fk_created_by_user_id,
        modifiedby as fk_updated_by_user_id,
        modifiedby as fk_approved_by_user_id,
        userkey as fk_last_updated_by_user_id,

        -- strings
        batch_title as journal_title,
        journal as journal_type,
        state as journal_state,
    

        -- numerics
        batchno as journal_transaction_number,
        module as intacct_module,

        -- date
        batch_date as journal_date,

        -- timestamps
        reversed as date_reversed,
        whencreated as date_created,
        whenmodified as date_updated,
        _es_update_timestamp,
        ddsreadtime as dds_read_timestamp

    from source

)
select * from renamed
