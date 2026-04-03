with source as (
    select * from {{ source('analytics_intacct', 'entity') }}
)

, renamed as (
    select
        -- ids
        recordno as pk_entity_id,
        locationid as entity_id,
        parentkey as fk_parent_entity_id,
        createdby as fk_created_by_user_id,
        modifiedby as fk_updated_by_user_id,

        -- strings
        name as entity_name,
        reportprintas as extended_entity_name,
        status as entity_status,

        -- timestamps
        whenmodified as date_updated,
        whencreated as date_created,
        _es_update_timestamp,
        ddsreadtime as dds_read_timestamp
    
    from source
)
select * from renamed
