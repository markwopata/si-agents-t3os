with source as (
      select * from {{ source('analytics_microsoft_dynamics', 'inventory_transactions') }}
),
renamed as (
    select
        -- ids
        id,
        inventdimid,
        inventtransorigin,
        invoiceid,
        itemid,
        packingslipid,
        pickingrouteid,
        projcategoryid,
        loadid,
        itmcosttransrecid,
        transchildrefid,
        dataareaid,
        recid,

        -- strings
        sysdatastatecode,
        currencycode,
        transchildtype,
        voucher,
        voucherphysical,
        statusissue,
        statusreceipt,
        
        -- numerics
        costamountposted,
        markingrefinventtransorigin,
        returninventtransorigin,
        groupreftype_ru,
        inventtransorigindelivery_ru,
        inventtransoriginsales_ru,
        inventtransorigintransit_ru,
        valueopen,
        valueopenseccur_ru,
        costamountadjustment,
        costamountoperations,
        costamountphysical,
        costamountposted,
        costamountseccuradjustment_ru,
        costamountseccurphysical_ru,
        costamountseccurposted_ru,
        costamountsettled,
        costamountsettledseccur_ru,
        costamountstd,
        costamountstdseccur_ru,
        revenueamountphysical,
        taxamountphysical,
        recversion,
        partition,
        sysrowversion,
        pdscwqty,
        pdscwsettled,
        qty,
        qtysettled,
        qtysettledseccur_ru,
        invoicereturned,
        packingslipreturned,
        storno_ru,
        stornophysical_ru,
        itmskipvarianceupdate,
        itmmustskipadjustment,
        nonfinancialtransferinventclosing,

        -- booleans

        _fivetran_deleted,

        -- dates
        dateclosed,
        dateclosedseccur_ru,
        dateexpected,
        datefinancial,
        dateinvent,
        datephysical,
        datestatus,
        shippingdateconfirmed,
        shippingdaterequested,
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
