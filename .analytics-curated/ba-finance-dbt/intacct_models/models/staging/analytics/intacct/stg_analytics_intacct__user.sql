with source as (
    select * from {{ source('analytics_intacct', 'user') }}
)

, renamed as (
    select
        -- ids
        recordno as pk_user_id,

        -- strings
        loginid as username,
        description as user_description,
        status as user_status,
        user_access_notes,

        -- booleans
        admin as is_admin,
        visible as is_visible,

        -- timestamp
        whenmodified as date_updated,
        whencreated as date_created,
        _es_update_timestamp,
        ddsreadtime as dds_read_timestamp

    from source

)
select * from renamed
