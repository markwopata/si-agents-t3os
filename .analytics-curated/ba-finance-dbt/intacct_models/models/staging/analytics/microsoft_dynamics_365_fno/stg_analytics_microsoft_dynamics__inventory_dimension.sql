with source as (
      select * from {{ source('analytics_microsoft_dynamics', 'inventory_dimension') }}
),
renamed as (
    select
        -- ids
        id,
        inventbatchid,
        inventdimid,
        inventlocationid,
        inventserialid,
        inventsiteid,
        inventstatusid,
        licenseplateid,
        wmslocationid,
        modifiedtransactionid,
        createdtransactionid,
        tableid,
        recid,

        -- strings
        sysdatastatecode,
        sha_1_hashhex,
        sha_3_hashhex,
        modifiedby,
        dataareaid,

        -- numerics
        inventdimension_9,
        recversion,
        partition,
        sysrowversion,
        versionnumber,

        -- booleans
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
