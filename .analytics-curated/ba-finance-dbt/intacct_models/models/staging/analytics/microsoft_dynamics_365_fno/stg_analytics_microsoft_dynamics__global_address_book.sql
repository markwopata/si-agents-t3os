with source as (
      select * from {{ source('analytics_microsoft_dynamics', 'global_address_book') }}
),
renamed as (
    select
        -- ids
        id,
        languageid,
        modifiedtransactionid,
        createdtransactionid,
        dataareaid,
        recid,
        tableid,
        partynumber,

        -- timestamps
        sink_created_on,
        sink_modified_on,
        modifieddatetime,
        createddatetime,
        createdon,
        modifiedon,
        _fivetran_synced,

        -- strings
        sysdatastatecode,
        instancerelationtype,
        knownas,
        name,
        namealias,
        primaryaddresslocation,
        primarycontactemail,
        primarycontactfax,
        primarycontactphone,
        primarycontacttelex,
        primarycontacturl,
        primarycontactfacebook,
        primarycontacttwitter,
        primarycontactlinkedin,
        legacyinstancerelationtype,
        modifiedby,
        createdby,

        -- numerics
        recversion,
        partition,
        sysrowversion,
        versionnumber,

        -- booleans
        _fivetran_deleted
        
    from source
)
select * from renamed
  