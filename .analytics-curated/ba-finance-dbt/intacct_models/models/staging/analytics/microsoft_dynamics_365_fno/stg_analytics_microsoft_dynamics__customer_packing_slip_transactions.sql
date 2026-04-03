with source as (
      select * from {{ source('analytics_microsoft_dynamics', 'customer_packing_slip_transactions') }}
),
renamed as (
    select
        -- ids
        id,        
        inventtransid,        
        deferredpostinvoicetransrecid,        
        recid,
        tableid,
        versionnumber,
        salesid,
        salescategory,
        sourcedocumentline,
        itemid,
        modifiedtransactionid,
        createdtransactionid,
        packingslipid,
        dataareaid,

        -- strings
        deliverytype,
        inventreftype,
        defaultdimension,
        deliverypostaladdress,
        dlvterm,
        intrastatcommodity,
        name,
        ngpcodestable_fr,
        salesunit,
        sysdatastatecode,

        -- numerics
        partition,
        amountcur,
        inventqty,
        linenum,
        priceunit,
        qty,
        remain,
        remaininvent,
        statisticvalue_lt,
        statvaluemst,
        valuemst,
        weight,
        pdscwqty,
        pdscwremain,
        fintag,
        sysrowversion,
        recversion,

        -- booleans
        fullymatched,
        scrap,
        stockedproduct,
        lineheader,
        ordered,
        parmline,
        _fivetran_deleted,

        -- dates
        deliverydate,
        intrastatfulfillmentdate_hu,
        saleslineshippingdateconfirmed,
        saleslineshippingdaterequested,
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
