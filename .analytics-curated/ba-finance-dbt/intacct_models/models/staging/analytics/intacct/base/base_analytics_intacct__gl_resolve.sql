with source as (
    select * from {{ source('analytics_intacct', 'gl_resolve') }}
),

renamed as (
    select

        -- ids
        recordno as pk_gl_resolve_id,
        glentrykey as fk_gl_entry_id,
        coalesce(dochdrkey, prrecordkey) as fk_subledger_header_id,
        coalesce(prentrykey, docentrykey) as fk_subledger_line_id,
        createdby as fk_created_by_user_id,
        modifiedby as fk_updated_by_user_id,

        -- numerics
        amount as raw_amount,
        trx_amount as raw_trx_amount,
        currency as currency_code,

        -- timestamps
        whencreated as date_created,
        whenmodified as date_updated,
        _es_update_timestamp,
        ddsreadtime as dds_read_timestamp

    from source
)

select * from renamed
