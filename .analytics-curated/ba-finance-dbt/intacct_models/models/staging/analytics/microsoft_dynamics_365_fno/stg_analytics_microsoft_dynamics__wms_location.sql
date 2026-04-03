with source as (
      select * from {{ source('analytics_microsoft_dynamics', 'wms_location') }}
),
renamed as (
    select
        -- ids
        createdtransactionid,
        recid,
        tableid,
        aisleid,
        dataareaid,
        id,
        inputblockingcauseid,
        inventlocationid,
        locprofileid,
        outputblockingcauseid,
        pallettypegroupid,
        pickingareaid,
        storeareaid,
        wmslocationid,
        zoneid,

        -- strings
        additionalzone_1,
        additionalzone_2,
        additionalzone_3,
        checktext,
        createdby,
        inputlocation,
        modifiedby,

        -- numerics
        absoluteheight,
        depth,
        height,
        maxvolume,
        maxweight,
        volume,
        width,
        level,
        locationtype,
        manualname,
        manualsortcode,
        maxpalletcount,
        mcrreservationpriority,
        partition,
        position,
        rack,
        recversion,
        sortcode,
        sysdatastatecode,
        sysrowversion,
        versionnumber,

        -- booleans
        _fivetran_deleted,

        -- dates

        -- timestamps
        createddatetime,
        createdon,
        lastcountedutcdatetime,
        modifieddatetime,
        modifiedon,
        sink_created_on,
        sink_modified_on,
        _fivetran_synced



    from source
)
select * from renamed
  