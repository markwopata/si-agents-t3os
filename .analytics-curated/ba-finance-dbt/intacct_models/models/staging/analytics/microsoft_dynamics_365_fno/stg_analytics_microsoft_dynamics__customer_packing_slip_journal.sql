with source as (
      select * from {{ source('analytics_microsoft_dynamics', 'customer_packing_slip_journal') }}
),
renamed as (
    select
        -- ids
        id,
        billofladingid,
        internalpackingslipid,
        inventlocationid,
        languageid,
        packingslipid,
        parmid,
        printmgmtsiteid,
        salesid,
        sourcedocumentheader,
        taxid,
        partytaxid,
        modifiedtransactionid,
        createdtransactionid,
        tableid,
        recid,
        dataareaid,

        -- strings
        bolfreightedby,
        freightsliptype,
        intercompanyposted,
        inventprofiletype_ru,
        listcode,
        sysdatastatecode,
        printblankdate_lt,
        printed,
        refnum,
        salestype,
        shipcarrierblindshipment,
        postedstate,
        orderaccount,
        compiler,
        customerref,
        defaultdimension,
        deliveryname,
        deliverypostaladdress,
        dlvmode,
        dlvterm,
        invoiceaccount,
        invoicepostaladdress,
        invoicingname,
        ledgervoucher,
        purchaseorder,
        reasontableref_br,
        returnitemnum,
        transportationdeliverycontractor,
        transportationdeliveryloader,
        transportationdeliveryowner,
        transportationdocument,
        workersalestaker,
        banklcexportline,

        -- numerics
        volume,
        weight,
        pdscwqty,
        qty,
        fintag,
        recversion,
        partition,
        sysrowversion,

        -- booleans
        intercompanyposted,
        printed,
        shipcarrierblindshipment,
        _fivetran_deleted,

        -- dates
        deliverydate,
        documentdate,
        intrastatfulfillmentdate_hu,
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
