with source as (
      select * from {{ source('analytics_microsoft_dynamics', 'inventory_transactions_origin') }}
),
renamed as (
    select
        -- ids
        id,
        inventtransid,
        itemid,
        iteminventdimid,
        referenceid,
        recid,
        tableid,
        versionnumber,
        modifiedtransactionid,
        createdtransactionid,
        dataareaid,

        -- strings
        referencecategory,
        party,
        sysdatastatecode,

        -- numerics
        recversion,
        partition,
        sysrowversion,

        -- booleans
        isexcludedfrominventoryvalue,
        _fivetran_deleted,

        -- dates
        createdon,
        modifiedon,

        -- timestamps
        sink_created_on,
        sink_modified_on,
        modifieddatetime,
        createddatetime,
        _fivetran_synced

    from source
)
select * from renamed
