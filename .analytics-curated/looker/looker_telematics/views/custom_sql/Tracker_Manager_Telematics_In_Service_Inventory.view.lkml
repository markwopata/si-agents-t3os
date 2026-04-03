view: Tracker_Manager_Telematics_In_Service_Inventory {
  derived_table: {
    sql:
with sales_table_cust_ref as (
    select
        to_varchar(customerref) as CUSTOMERREF
    from
        ANALYTICS.MICROSOFT_DYNAMICS_365_FNO.SALESTABLE
)


, deal_cust_ref as (
    select
        to_varchar(DEAL_ID) as DEAL_ID
    from
        ANALYTICS.HUBSPOT_CUSTOMER_SUCCESS.DEAL
)


, matching_cust_refs as (
    select
        sales_table_cust_ref.CUSTOMERREF
    from
        sales_table_cust_ref
    inner join
        deal_cust_ref
    on
        sales_table_cust_ref.CUSTOMERREF = deal_cust_ref.DEAL_ID
)


, t3_saas_inventtrans_d365 as (
    select
        CPST.ITEMID as PART_ID,
        CPST.NAME as PART_DESCRIPTION,
        ID.inventserialid as WAREHOUSE_SHIPPED_SERIAL,
        IT.DATEPHYSICAL as WAREHOUSE_PHYSICAL_DATE,
        SALESHEADER.SHIPPINGDATEREQUESTED as WAREHOUSE_REQUESTED_SHIP_DATE,
        case
            when ID.INVENTSERIALID is null then CIT.LINEAMOUNT
            when ID.INVENTSERIALID is not null then CIT.salesprice
        end as D365_CUST_INVOICE_LINE_SUM,
        CIT.lineamount as D365_CUST_INVOICE_LINE_AMOUNT,
        CIT.salesprice as D365_CUST_INVOICE_SALES_PRICE,
        CIT.invoiceid as D365_CUST_INVOICE_ID,
        CIT.origsalesid as D365_CUST_SALES_ORDER_NUMBER,
        SALESHEADER.customerref as SALES_ORDER_CUSTOMER_REF,
        GAB.NAME as D365_CUSTOMER_NAME
    from
        ANALYTICS.MICROSOFT_DYNAMICS_365_FNO.custpackingsliptrans CPST
    left join
        ANALYTICS.MICROSOFT_DYNAMICS_365_FNO.inventtransorigin ITO
        on CPST.inventtransid = ITO.inventtransid
    left join
        ANALYTICS.MICROSOFT_DYNAMICS_365_FNO.inventtrans IT
        on ITO.RECID = IT.inventtransorigin
        and CPST.packingslipid = IT.packingslipid
    left join
        ANALYTICS.MICROSOFT_DYNAMICS_365_FNO.inventdim ID
        on IT.inventdimid = ID.inventdimid
    left join ANALYTICS.MICROSOFT_DYNAMICS_365_FNO.salestable SALESHEADER
        on CPST.salesid = SALESHEADER.salesid
    left join ANALYTICS.MICROSOFT_DYNAMICS_365_FNO.CUSTTABLE CT
        on CT.ACCOUNTNUM = SALESHEADER.CUSTACCOUNT
    left join ANALYTICS.MICROSOFT_DYNAMICS_365_FNO.DIRPARTYTABLE GAB
        on CT.PARTY = GAB.RECID
    left join
        ANALYTICS.MICROSOFT_DYNAMICS_365_FNO.custinvoicetrans CIT
        ON CIT.inventtransid = ITO.inventtransid
    where
        SALESHEADER.custgroup = 'T3'
    and
        (SALESHEADER.inventsiteid != 'MBY'
        or
            SALESHEADER.SALESID in ('SOv000004', 'SOv000086', 'SOv001098', 'SOv001048', 'SOv000604', 'SOv001599', 'SOv004680', 'SOv000515', 'SOv002251'))
    and
        SALESHEADER.customerref in
        (select
            matching_cust_refs.CUSTOMERREF
        from
            matching_cust_refs)
    -- AND
    --     IT.DATEPHYSICAL BETWEEN '2023-11-01' AND '2024-10-30'
    -- AND
    --     (SALESHEADER.salesname NOT LIKE 'Direct Wire%' OR SALESHEADER.salesname NOT LIKE 'Michigan Pneumatic%')
    order by
        CIT.origsalesid
)

, t3_saas_inventtrans_d365_union as (
    select distinct
        CASE
            WHEN part_mapping.LINKED_DEVICE_TYPE is not null THEN part_mapping.LINKED_DEVICE_TYPE
            WHEN part_mapping.LINKED_DEVICE_TYPE is null THEN 'Attachment'
        END as WAREHOUSE_LINKED_DEVICE_TYPE,
        t3_saas_inventtrans_d365.PART_DESCRIPTION as WAREHOUSE_SHIPPED_PART_DESCRIPTION,
        t3_saas_inventtrans_d365.WAREHOUSE_SHIPPED_SERIAL as WAREHOUSE_SHIPPED_SERIAL,
        REPLACE(t3_saas_inventtrans_d365.WAREHOUSE_SHIPPED_SERIAL, '-', '') as WAREHOUSE_SHIPPED_SERIAL_FORMATTED,
        t3_saas_inventtrans_d365.WAREHOUSE_PHYSICAL_DATE as WAREHOUSE_PHYSICAL_DATE,
        t3_saas_inventtrans_d365.WAREHOUSE_REQUESTED_SHIP_DATE as WAREHOUSE_REQUESTED_SHIP_DATE,
        t3_saas_inventtrans_d365.D365_CUST_INVOICE_LINE_SUM as D365_CUST_INVOICE_LINE_SUM,
        t3_saas_inventtrans_d365.D365_CUST_INVOICE_SALES_PRICE as D365_CUST_INVOICE_SALES_PRICE,
        TO_VARCHAR(t3_saas_inventtrans_d365.D365_CUST_INVOICE_ID) as D365_CUST_INVOICE_ID,
        t3_saas_inventtrans_d365.D365_CUST_SALES_ORDER_NUMBER as D365_CUST_SALES_ORDER_NUMBER,
        TO_VARCHAR(t3_saas_inventtrans_d365.SALES_ORDER_CUSTOMER_REF) as SALES_ORDER_CUSTOMER_REF,
        t3_saas_inventtrans_d365.D365_CUSTOMER_NAME as D365_CUSTOMER_NAME,
        ROW_NUMBER() over(partition by WAREHOUSE_SHIPPED_SERIAL order by WAREHOUSE_PHYSICAL_DATE) as SERIAL_NUMBER_SHIPPED_INSTANCE
    from
        t3_saas_inventtrans_d365
    left join
        analytics.t3_saas_billing.part_mapping part_mapping
        on part_mapping.PART_ID = t3_saas_inventtrans_d365.PART_ID
)

, t3_saas_inventtrans_fb as (
    -- van stocks & fishbowl records --
    select distinct
    LEGACY_SHIPMENT_DATA.LINKED_DEVICE_TYPE as WAREHOUSE_LINKED_DEVICE_TYPE,
    LEGACY_SHIPMENT_DATA.PART_DESCRIPTION as WAREHOUSE_SHIPPED_PART_DESCRIPTION,
    LEGACY_SHIPMENT_DATA.SERIAL_NUMBER as WAREHOUSE_SHIPPED_SERIAL,
    LEGACY_SHIPMENT_DATA.SERIAL_FORMATTED as WAREHOUSE_SHIPPED_SERIAL_FORMATTED,
    LEGACY_SHIPMENT_DATA.SHIPPED as WAREHOUSE_PHYSICAL_DATE,
    LEGACY_SHIPMENT_DATA.SHIPPED as WAREHOUSE_REQUESTED_SHIP_DATE,
    0.00 as D365_CUST_INVOICE_LINE_SUM,
    0.00 as D365_CUST_INVOICE_SALES_PRICE,
    'Legacy Shipment' as D365_CUST_INVOICE_ID,
    'Legacy Shipment' as D365_CUST_SALES_ORDER_NUMBER,
    TO_VARCHAR(LEGACY_SHIPMENT_DATA.SALES_REF_ID) as SALES_ORDER_CUSTOMER_REF,
    'Legacy Shipment' as D365_CUSTOMER_NAME
from
    ANALYTICS.T3_SAAS_BILLING.LEGACY_SHIPMENT_DATA
where
    LEN(TO_VARCHAR(LEGACY_SHIPMENT_DATA.SALES_REF_ID)) > 7
)

, t3_saas_inventtrans_fb_union as (
    select
        t3_saas_inventtrans_fb.*,
        ROW_NUMBER() over(partition by WAREHOUSE_SHIPPED_SERIAL order by WAREHOUSE_PHYSICAL_DATE) as SERIAL_NUMBER_SHIPPED_INSTANCE
    from
        t3_saas_inventtrans_fb
)

, t3_saas_inventtrans_full as (
    select
        *
    from
        t3_saas_inventtrans_d365_union
    union
    select
        *
    from
        t3_saas_inventtrans_fb_union
)

, hubspot_pipelines as (
    select distinct
        TO_VARCHAR(DEAL.DEAL_ID) as HUBSPOT_ID,
        TO_VARCHAR(DEAL.DEAL_PIPELINE_STAGE_ID) as PIPELINE_ID
    from
        ANALYTICS.HUBSPOT_CUSTOMER_SUCCESS.DEAL
    union
    select distinct
        TO_VARCHAR(TICKET.ID) as HUBSPOT_ID,
        TO_VARCHAR(TICKET.PROPERTY_HS_PIPELINE) as PIPELINE_ID
    from
        ANALYTICS.HUBSPOT_CUSTOMER_SUCCESS.TICKET
)

, t3_saas_inventtrans_full_edit1 as (
    -- hubspot pipeline mapping --
    select
        t3_saas_inventtrans_full.*,
        case
            when hubspot_pipelines.PIPELINE_ID in ('20251023', '179039634', 'bc1beaf7-7b0e-4542-b7c8-d982ae89d2ff') THEN 'T3aaS Subscription'
            when hubspot_pipelines.PIPELINE_ID = '1965456' THEN 'RMA'
            else 'HubSpot ID No Match'
         end as HUBSPOT_PIPELINE
    from
        t3_saas_inventtrans_full
    left join
        hubspot_pipelines
        on hubspot_pipelines.HUBSPOT_ID = t3_saas_inventtrans_full.SALES_ORDER_CUSTOMER_REF
)

, t3_saas_inventtrans_full_edit2 as (
    -- serial_number_shipped_instance record validation --
    select
        t3_saas_inventtrans_full_edit1.WAREHOUSE_LINKED_DEVICE_TYPE as WAREHOUSE_LINKED_DEVICE_TYPE,
        t3_saas_inventtrans_full_edit1.WAREHOUSE_SHIPPED_PART_DESCRIPTION as WAREHOUSE_SHIPPED_PART_DESCRIPTION,
        t3_saas_inventtrans_full_edit1.WAREHOUSE_SHIPPED_SERIAL as WAREHOUSE_SHIPPED_SERIAL,
        t3_saas_inventtrans_full_edit1.WAREHOUSE_SHIPPED_SERIAL_FORMATTED as WAREHOUSE_SHIPPED_SERIAL_FORMATTED,
        t3_saas_inventtrans_full_edit1.WAREHOUSE_PHYSICAL_DATE as WAREHOUSE_PHYSICAL_DATE,
        t3_saas_inventtrans_full_edit1.WAREHOUSE_REQUESTED_SHIP_DATE as WAREHOUSE_REQUESTED_SHIP_DATE,
        t3_saas_inventtrans_full_edit1.D365_CUST_INVOICE_LINE_SUM as D365_CUST_INVOICE_LINE_SUM,
        t3_saas_inventtrans_full_edit1.D365_CUST_INVOICE_SALES_PRICE as D365_CUST_INVOICE_SALES_PRICE,
        t3_saas_inventtrans_full_edit1.D365_CUST_INVOICE_ID as D365_CUST_INVOICE_ID,
        t3_saas_inventtrans_full_edit1.D365_CUST_SALES_ORDER_NUMBER as D365_CUST_SALES_ORDER_NUMBER,
        t3_saas_inventtrans_full_edit1.SALES_ORDER_CUSTOMER_REF as SALES_ORDER_CUSTOMER_REF,
        t3_saas_inventtrans_full_edit1.D365_CUSTOMER_NAME as D365_CUSTOMER_NAME,
        case
            when WAREHOUSE_SHIPPED_SERIAL is not null then SERIAL_NUMBER_SHIPPED_INSTANCE
            when  WAREHOUSE_SHIPPED_SERIAL is null then 1
        end as SERIAL_NUMBER_SHIPPED_INSTANCE,
        t3_saas_inventtrans_full_edit1.HUBSPOT_PIPELINE
    from
        t3_saas_inventtrans_full_edit1
)

, t3_saas_inventtrans_full_edit3 as (
    -- adding DYNAMIC_INDEX --
    SELECT
        row_number() over (order by WAREHOUSE_PHYSICAL_DATE) as DYNAMIC_INDEX,
        t3_saas_inventtrans_full_edit2.*
    FROM
        t3_saas_inventtrans_full_edit2
)

, deactivation_billing_adjustments as (
    select * from analytics.T3_SAAS_BILLING.DEACTIVATION_BILLING_ADJUSTMENTS
)

, t3_saas_inventtrans_full_edit4 as (
    -- adding SN_UNIQUE_IDENTIFIER --
    select
        CONCAT(WAREHOUSE_SHIPPED_SERIAL_FORMATTED, ' ', DYNAMIC_INDEX) as SN_UNIQUE_IDENTIFIER,
        t3_saas_inventtrans_full_edit3.*
    from
        t3_saas_inventtrans_full_edit3
)

, deactivation_billing_adjustments as (
    select * from analytics.T3_SAAS_BILLING.DEACTIVATION_BILLING_ADJUSTMENTS
)

, t3_saas_inventtrans_full_final as (
    select
        t3_saas_inventtrans_full_edit4.*,
        DEACTS.DEACTIVATION_DATE as DEACTIVATION_DATE,
        DEACTS.DEACTIVATION_TICKET_ID as DEACTIVATION_TICKET_ID
    from
        t3_saas_inventtrans_full_edit4
    left join
        deactivation_billing_adjustments DEACTS
        on DEACTS.SERIAL_FORMATTED = t3_saas_inventtrans_full_edit4.WAREHOUSE_SHIPPED_SERIAL_FORMATTED
)

, shipped_inventory_UOR as (
select
    WAREHOUSE_LINKED_DEVICE_TYPE,
    WAREHOUSE_SHIPPED_SERIAL_FORMATTED,
    date(WAREHOUSE_PHYSICAL_DATE) as WAREHOUSE_PHYSICAL_DATE,
    D365_CUST_SALES_ORDER_NUMBER,
    SERIAL_NUMBER_SHIPPED_INSTANCE,
    case
        when SERIAL_NUMBER_SHIPPED_INSTANCE = (select max(SERIAL_NUMBER_SHIPPED_INSTANCE) from t3_saas_inventtrans_full_final MRINST_MAX where t3_saas_inventtrans_full_final.WAREHOUSE_SHIPPED_SERIAL_FORMATTED = MRINST_MAX.WAREHOUSE_SHIPPED_SERIAL_FORMATTED) then 'UNIT OF RECORD'
        else 'ARCHIVE'
    end as SHIPMENT_UNIT_OF_RECORD
from
    t3_saas_inventtrans_full_final
)

--------------------------------------------------------------------------



, esp_total_tracker as (
    select
        ATA.ASSET_ID as ASSET_ID,
        TRA.TRACKER_ID as DEVICE_ID,
        AST.NAME as ASSET_NAME,
        ATA.COMPANY_ID as COMPANY_ID,
        COM.NAME as COMPANY_NAME,
        ATA.TRACKER_ID as TRACKER_ID,
        TRA.DEVICE_SERIAL as TRACKER_SERIAL,
        concat('ATA', ATA.ASSET_TRACKER_ID) as ASSIGNMENT_ID,
        date(ATA.DATE_INSTALLED) as DATE_INSTALLED,
        date(ATA.DATE_UNINSTALLED) as DATE_UNINSTALLED,
        case
            when ATA.TRACKER_ID is not null then 'ESP'
            else 'ESP'
        end as SOURCE
    from
        ES_WAREHOUSE.PUBLIC.ASSET_TRACKER_ASSIGNMENTS ATA
    left join
        ES_WAREHOUSE.PUBLIC.TRACKERS TRA
        on TRA.TRACKER_ID = ATA.TRACKER_ID
    left join
        ES_WAREHOUSE.PUBLIC.ASSETS AST
        on AST.ASSET_ID = ATA.ASSET_ID
    left join
        ES_WAREHOUSE.PUBLIC.COMPANIES COM
        on COM.COMPANY_ID = ATA.COMPANY_ID
    )

    , total_trackers as (
    select
        esp_total_tracker.ASSET_ID as ASSET_ID,
        esp_total_tracker.DEVICE_ID as DEVICE_ID,
        esp_total_tracker.ASSET_NAME as ASSET_NAME,
        esp_total_tracker.TRACKER_SERIAL as DEVICE_SERIAL,
        esp_total_tracker.COMPANY_ID as COMPANY_ID,
        esp_total_tracker.ASSIGNMENT_ID as ASSIGNMENT_ID,
        'TRACKER' as DEVICE_TYPE,
        esp_total_tracker.DATE_INSTALLED as DATE_INSTALLED,
        esp_total_tracker.DATE_UNINSTALLED as DATE_UNINSTALLED,
        esp_total_tracker.SOURCE as SOURCE
    from
        esp_total_tracker
    )

    , esp_total_camera as (
    select
        ACA.ASSET_ID as ASSET_ID,
        CAM.CAMERA_ID as DEVICE_ID,
        AST.NAME as ASSET_NAME,
        AST.COMPANY_ID as COMPANY_ID,
        COM.NAME as COMPANY_NAME,
        ACA.CAMERA_ID as CAMERA_ID,
        CAM.device_serial as CAMERA_SERIAL,
        concat('ACA', ACA.ASSET_CAMERA_ID) as ASSIGNMENT_ID,
        date(ATA.DATE_INSTALLED) as DATE_INSTALLED,
        date(ATA.DATE_UNINSTALLED) as DATE_UNINSTALLED,
        case
            when ACA.CAMERA_ID is not null then 'ESP'
            else 'ESP'
        end as SOURCE
    from
        ES_WAREHOUSE.PUBLIC.ASSET_CAMERA_ASSIGNMENTS ACA
    left join
        ES_WAREHOUSE.PUBLIC.CAMERAS CAM
        on CAM.CAMERA_ID = ACA.CAMERA_ID
    left join
        ES_WAREHOUSE.PUBLIC.ASSETS AST
        on AST.ASSET_ID = ACA.ASSET_ID
    left join
        ES_WAREHOUSE.PUBLIC.ASSET_TRACKER_ASSIGNMENTS ATA
        on AST.TRACKER_ID = ATA.TRACKER_ID
    left join
        ES_WAREHOUSE.PUBLIC.COMPANIES COM
        on COM.COMPANY_ID = AST.COMPANY_ID
    )

    , total_cameras as (
    select
        esp_total_camera.ASSET_ID as ASSET_ID,
        esp_total_camera.DEVICE_ID as DEVICE_ID,
        esp_total_camera.ASSET_NAME as ASSET_NAME,
        esp_total_camera.CAMERA_SERIAL as DEVICE_SERIAL,
        esp_total_camera.COMPANY_ID as COMPANY_ID,
        esp_total_camera.ASSIGNMENT_ID as ASSIGNMENT_ID,
        'CAMERA' AS DEVICE_TYPE,
        esp_total_camera.DATE_INSTALLED as DATE_INSTALLED,
        esp_total_camera.DATE_UNINSTALLED as DATE_UNINSTALLED,
        esp_total_camera.SOURCE as SOURCE
    from
        esp_total_camera
    )

    , esp_total_keypad as (
    select
        AKA.ASSET_ID as ASSET_ID,
        KPD.KEYPAD_ID as DEVICE_ID,
        AST.NAME as ASSET_NAME,
        AST.COMPANY_ID as COMPANY_ID,
        COM.NAME as COMPANY_NAME,
        AKA.KEYPAD_ID as KEYPAD_ID,
        KPD.SERIAL_NUMBER as KEYPAD_SERIAL,
        concat('AKA', AKA.KEYPAD_ASSET_ASSIGNMENT_ID) as ASSIGNMENT_ID,
        date(ATA.DATE_INSTALLED) as DATE_INSTALLED,
        date(ATA.DATE_UNINSTALLED) as DATE_UNINSTALLED,
        case
            when AKA.KEYPAD_ID is not null then 'ESP'
            else 'ESP'
        end as SOURCE
    from
        ES_WAREHOUSE.PUBLIC.KEYPAD_ASSET_ASSIGNMENTS AKA
    left join
        ES_WAREHOUSE.PUBLIC.KEYPADS KPD
        on KPD.KEYPAD_ID = AKA.KEYPAD_ID
    left join
        ES_WAREHOUSE.PUBLIC.ASSETS AST
        on AST.ASSET_ID = AKA.ASSET_ID
    left join
        ES_WAREHOUSE.PUBLIC.ASSET_TRACKER_ASSIGNMENTS ATA
        on AST.TRACKER_ID = ATA.TRACKER_ID
    left join
        ES_WAREHOUSE.PUBLIC.COMPANIES COM
        on COM.COMPANY_ID = AST.COMPANY_ID
    )

    , total_keypads as (
    select
        esp_total_keypad.ASSET_ID as ASSET_ID,
        esp_total_keypad.DEVICE_ID as DEVICE_ID,
        esp_total_keypad.ASSET_NAME as ASSET_NAME,
        esp_total_keypad.KEYPAD_SERIAL AS DEVICE_SERIAL,
        esp_total_keypad.COMPANY_ID as COMPANY_ID,
        esp_total_keypad.ASSIGNMENT_ID as ASSIGNMENT_ID,
        'KEYPAD' as DEVICE_TYPE,
        esp_total_keypad.DATE_INSTALLED as DATE_INSTALLED,
        esp_total_keypad.DATE_UNINSTALLED as DATE_UNINSTALLED,
        esp_total_keypad.SOURCE as SOURCE
    from
        esp_total_keypad
    )

    , total_devices as (
    select
        ASSET_ID,
        ASSET_NAME,
        DEVICE_ID,
        DEVICE_SERIAL,
        COMPANY_ID,
        ASSIGNMENT_ID,
        DEVICE_TYPE,
        DATE_INSTALLED,
        DATE_UNINSTALLED
    from
        total_trackers

    union

    select
        ASSET_ID,
        ASSET_NAME,
        DEVICE_ID,
        DEVICE_SERIAL,
        COMPANY_ID,
        ASSIGNMENT_ID,
        DEVICE_TYPE,
        DATE_INSTALLED,
        DATE_UNINSTALLED
    from
        total_cameras

    union

    select
        ASSET_ID,
        ASSET_NAME,
        DEVICE_ID,
        DEVICE_SERIAL,
        COMPANY_ID,
        ASSIGNMENT_ID,
        DEVICE_TYPE,
        DATE_INSTALLED,
        DATE_UNINSTALLED
    from
        total_keypads
    )

    , total_devices_shipped_MR as (
    select
        total_devices.ASSET_ID as ASSET_ID,
        total_devices.ASSET_NAME as ASSET_NAME,
        total_devices.DEVICE_ID as DEVICE_ID,
        total_devices.DEVICE_SERIAL as DEVICE_SERIAL,
        total_devices.DEVICE_TYPE as DEVICE_TYPE,
        total_devices.COMPANY_ID as COMPANY_ID,
        total_devices.ASSIGNMENT_ID as ASSIGNMENT_ID,
        total_devices.DATE_INSTALLED as DATE_INSTALLED,
        total_devices.DATE_UNINSTALLED as DATE_UNINSTALLED,
        ROW_NUMBER() OVER(PARTITION by total_devices.DEVICE_SERIAL order by total_devices.DATE_INSTALLED) as SERIAL_NUMBER_INSTALL_INSTANCE
    from
        total_devices
    )

    ,  total_devices_asset_MR as (
    select
        total_devices.ASSET_ID as ASSET_ID,
        total_devices.ASSET_NAME as ASSET_NAME,
        total_devices.DEVICE_ID as DEVICE_ID,
        total_devices.DEVICE_SERIAL as DEVICE_SERIAL,
        total_devices.DEVICE_TYPE as DEVICE_TYPE,
        total_devices.COMPANY_ID as COMPANY_ID,
        total_devices.ASSIGNMENT_ID as ASSIGNMENT_ID,
        total_devices.DATE_INSTALLED as DATE_INSTALLED,
        total_devices.DATE_UNINSTALLED as DATE_UNINSTALLED,
        ROW_NUMBER() OVER(PARTITION by total_devices.ASSET_ID order by total_devices.DATE_INSTALLED) as ASSET_INSTALL_INSTANCE
    from
        total_devices
    )

    , total_devices_MR_instance_1 as (
    select
        *
    from
        total_devices_shipped_MR
    where
        total_devices_shipped_MR.COMPANY_ID <> '1854'
    )

    , total_devices_MR_instance_2 as (
    select
        *
        ,
        case
            when DATE_INSTALLED is null then 'NO INSTALL RECORD'
            when DATE_INSTALLED is not null and DATE_UNINSTALLED is null then 'ACTIVE'
            when DATE_INSTALLED is not null and DATE_UNINSTALLED is not null then 'DEACTIVATED'
        end as ASSET_STATUS
    from
        total_devices_MR_instance_1 MRINST
    where
        SERIAL_NUMBER_INSTALL_INSTANCE = (select max(SERIAL_NUMBER_INSTALL_INSTANCE) from total_devices_MR_instance_1 MRINST_MAX where MRINST.DEVICE_SERIAL = MRINST_MAX.DEVICE_SERIAL)
    )


, last_install_by_shipped_SN as (
    select
        *,
        'UNIT OF RECORD' as LINK_TO_SHIPMENTS
    from
        total_devices_MR_instance_2
)

, last_install_by_shipped_SN_1 as (
select
    shipped_inventory_UOR.*,
    last_install_by_shipped_SN.ASSET_ID,
    last_install_by_shipped_SN.COMPANY_ID,
    last_install_by_shipped_SN.ASSIGNMENT_ID as ASSIGNMENT_ID,
    last_install_by_shipped_SN.DATE_INSTALLED as DATE_INSTALLED,
    last_install_by_shipped_SN.DATE_UNINSTALLED as DATE_UNINSTALLED
from
    shipped_inventory_UOR
left join
    last_install_by_shipped_SN
    on shipped_inventory_UOR.WAREHOUSE_SHIPPED_SERIAL_FORMATTED = last_install_by_shipped_SN.DEVICE_SERIAL and last_install_by_shipped_SN.LINK_TO_SHIPMENTS = shipped_inventory_UOR.SHIPMENT_UNIT_OF_RECORD
)

-- NEW --

, total_devices_asset_instance as (
select
    total_devices.ASSET_ID as ASSET_ID,
    total_devices.ASSET_NAME as ASSET_NAME,
    total_devices.DEVICE_ID as DEVICE_ID,
    total_devices.DEVICE_SERIAL as DEVICE_SERIAL,
    total_devices.DEVICE_TYPE as DEVICE_TYPE,
    total_devices.COMPANY_ID as COMPANY_ID,
    total_devices.ASSIGNMENT_ID as ASSIGNMENT_ID,
    total_devices.DATE_INSTALLED as DATE_INSTALLED,
    total_devices.DATE_UNINSTALLED as DATE_UNINSTALLED,
    ROW_NUMBER() OVER(PARTITION BY total_devices.ASSET_ID ORDER BY total_devices.DATE_INSTALLED) as ASSET_INSTALL_INSTANCE
from
    total_devices
)

, total_devices_SN_instance_ as (
select
    total_devices.ASSET_ID as ASSET_ID,
    total_devices.ASSET_NAME as ASSET_NAME,
    total_devices.DEVICE_ID as DEVICE_ID,
    total_devices.DEVICE_SERIAL as DEVICE_SERIAL,
    total_devices.DEVICE_TYPE as DEVICE_TYPE,
    total_devices.COMPANY_ID as COMPANY_ID,
    total_devices.ASSIGNMENT_ID as ASSIGNMENT_ID,
    total_devices.DATE_INSTALLED as DATE_INSTALLED,
    total_devices.DATE_UNINSTALLED as DATE_UNINSTALLED,
    case
        when total_devices.DATE_INSTALLED is null then 'NO INSTALL RECORD'
        when total_devices.DATE_INSTALLED is not null and total_devices.DATE_UNINSTALLED is null then 'ACTIVE'
        when total_devices.DATE_INSTALLED is not null and total_devices.DATE_UNINSTALLED is not null then 'DEACTIVATED'
    end as ASSET_STATUS,
    ROW_NUMBER() OVER(PARTITION by total_devices.DEVICE_SERIAL order by total_devices.DATE_INSTALLED) as SERIAL_NUMBER_INSTALL_INSTANCE
from
    total_devices
)

, total_devices_SN_instance as (
select * from total_devices_SN_instance_ where ASSET_STATUS != 'NO INSTALL RECORD'
)

, total_devices_asset_instance_1 as (
select
    *
from
    total_devices_asset_instance
where
    total_devices_asset_instance.COMPANY_ID <> '1854'
)

, total_devices_max_SN_instance as (
select
    *
from
    total_devices_SN_instance MRINST
where
    SERIAL_NUMBER_INSTALL_INSTANCE = (select max(SERIAL_NUMBER_INSTALL_INSTANCE) from total_devices_SN_instance MRINST_MAX where MRINST.DEVICE_SERIAL = MRINST_MAX.DEVICE_SERIAL)
)

, total_devices_min_SN_instance as (
select
    *
from
    total_devices_SN_instance
where
    SERIAL_NUMBER_INSTALL_INSTANCE = 1
)

, total_devices_SN_service_timeline as (
select
    total_devices_min_SN_instance.DEVICE_SERIAL as DEVICE_SERIAL,
    total_devices_min_SN_instance.DEVICE_ID as DEVICE_ID,
    total_devices_min_SN_instance.DEVICE_TYPE as DEVICE_TYPE,
    total_devices_min_SN_instance.ASSET_ID as FIRST_INSTALL_ASSET_ID,
    total_devices_min_SN_instance.ASSIGNMENT_ID as FIRST_INSTALL_ASSIGNMENT_ID,
    total_devices_min_SN_instance.COMPANY_ID as FIRST_INSTALL_COMPANY_ID,
    total_devices_min_SN_instance.DATE_INSTALLED as IN_SERVICE_DATE,
    total_devices_max_SN_instance.ASSET_ID as LAST_INSTALL_ASSET_ID,
    total_devices_max_SN_instance.ASSIGNMENT_ID as LAST_INSTALL_ASSIGNMENT_ID,
    total_devices_max_SN_instance.COMPANY_ID as LAST_INSTALL_COMPANY_ID,
    total_devices_max_SN_instance.DATE_UNINSTALLED as END_SERVICE_DATE
from
    total_devices_min_SN_instance
join
    total_devices_max_SN_instance
    on total_devices_min_SN_instance.DEVICE_SERIAL = total_devices_max_SN_instance.DEVICE_SERIAL
order by total_devices_min_SN_instance.DEVICE_SERIAL
)

, total_devices_max_asset_instance as (
select
    *
from
    total_devices_asset_instance TD1
where
    ASSET_INSTALL_INSTANCE = (select MAX(ASSET_INSTALL_INSTANCE) FROM total_devices_asset_instance TD1_MAX WHERE TD1.ASSET_ID = TD1_MAX.ASSET_ID)
)

, total_devices_asset_instance_2 as (
select
    *,
    case
        when DATE_INSTALLED is not null and DATE_UNINSTALLED is null then 'ACTIVE'
        when DATE_INSTALLED is not null and DATE_UNINSTALLED is not null then 'DEACTIVATED'
        when DATE_INSTALLED is null then 'NO INSTALL RECORD'
    end as ASSET_STATUS
from
    total_devices_asset_instance_1
)

, total_devices_asset_instance_3 as (
select
    *,
    case
        when ASSET_STATUS = 'ACTIVE' then concat(ASSET_ID, ASSET_STATUS, DEVICE_SERIAL)
        else null
    end as UNIQUE_IDENTIFIER
from
    total_devices_asset_instance_2
)

, closed_t3_units as (
select
    total_devices_asset_instance_3.*,
    total_devices_SN_service_timeline.END_SERVICE_DATE
from
    total_devices_asset_instance_3
left join
    total_devices_SN_service_timeline
    on total_devices_asset_instance_3.DEVICE_SERIAL = total_devices_SN_service_timeline.DEVICE_SERIAL and total_devices_asset_instance_3.ASSIGNMENT_ID = total_devices_SN_service_timeline.LAST_INSTALL_ASSIGNMENT_ID
)

, t3_swap_history AS (
  SELECT
    ASSET_ID,
    ASSIGNMENT_ID,
    DEVICE_TYPE,
    DEVICE_SERIAL,
    DATE_INSTALLED,
    END_SERVICE_DATE,
    ROW_NUMBER() OVER (PARTITION BY ASSET_ID ORDER BY DATE_INSTALLED) AS rn
  FROM closed_t3_units
)

, t3_swap_joined_history AS (
  SELECT
    curr.ASSET_ID as ASSET_ID,
    curr.DEVICE_TYPE as DEVICE_TYPE,
    prev.ASSIGNMENT_ID as prior_assignment_id,
    prev.DEVICE_SERIAL AS prior_device_serial,
    prev.END_SERVICE_DATE AS prior_end_service_date,
    curr.DEVICE_SERIAL AS current_device_serial,
    curr.ASSIGNMENT_ID as current_assignment_id,
    curr.DATE_INSTALLED AS current_install_date,
    curr.END_SERVICE_DATE as current_end_service_date
  FROM t3_swap_history curr
  JOIN t3_swap_history prev
    ON curr.ASSET_ID = prev.ASSET_ID
   AND curr.rn = prev.rn + 1
)

, t3_swap_joined_history_EOS_units as (
SELECT *
FROM t3_swap_joined_history
WHERE prior_end_service_date IS NOT NULL
and CURRENT_INSTALL_DATE is not null
ORDER BY ASSET_ID, current_install_date
)

, t3_swap_joined_history_excl_same_swaps as (
select
    *
from
    t3_swap_joined_history_EOS_units
where
    current_device_serial != prior_device_serial
)

, t3_swap_joined_history_excl_invalid_swaps as (
select
    *
from
    t3_swap_joined_history_excl_same_swaps
where
    current_install_date >= prior_end_service_date
)

, total_devices_min_SN_instance_T3 as (
select
    *
from
    total_devices_min_SN_instance
where
    total_devices_min_SN_instance.SERIAL_NUMBER_INSTALL_INSTANCE = 1
)

, full_swaps as (
select
    t3_swap_joined_history_excl_invalid_swaps.*,
from
    t3_swap_joined_history_excl_invalid_swaps
left join
    total_devices_min_SN_instance_T3
    on t3_swap_joined_history_excl_invalid_swaps.ASSET_ID = total_devices_min_SN_instance_T3.ASSET_ID
    and t3_swap_joined_history_excl_invalid_swaps.current_assignment_id = total_devices_min_SN_instance_T3.ASSIGNMENT_ID
    and t3_swap_joined_history_excl_invalid_swaps.current_device_serial = total_devices_min_SN_instance_T3.DEVICE_SERIAL
where
    total_devices_min_SN_instance_T3.DEVICE_SERIAL is not null
)

, full_swaps_with_swap_instances as (
select
    *,
    ROW_NUMBER() OVER (PARTITION BY ASSET_ID ORDER BY CURRENT_INSTALL_DATE) AS ASSET_SWAP_INSTANCE
from
    full_swaps

)

, shipped_inventory_UOR_2 as (
select
    *
from
    shipped_inventory_UOR
where
    SHIPMENT_UNIT_OF_RECORD = 'UNIT OF RECORD'
)

, shipped_swaps as (
select
    full_swaps_with_swap_instances.*
from
    full_swaps_with_swap_instances
join
    shipped_inventory_UOR_2
    on full_swaps_with_swap_instances.prior_device_serial = shipped_inventory_UOR_2.WAREHOUSE_SHIPPED_SERIAL_FORMATTED
)

, min_swap_instance as (
select
    ASSET_ID,
    DEVICE_TYPE,
    PRIOR_DEVICE_SERIAL,
    PRIOR_ASSIGNMENT_ID,
    PRIOR_END_SERVICE_DATE
from
    shipped_swaps
where
    ASSET_SWAP_INSTANCE = 1
)

, max_swap_instance as (
select
    ASSET_ID,
    DEVICE_TYPE,
    CURRENT_DEVICE_SERIAL,
    CURRENT_ASSIGNMENT_ID,
    CURRENT_INSTALL_DATE,
    CURRENT_END_SERVICE_DATE,
    ASSET_SWAP_INSTANCE
from
    shipped_swaps FS1
where
    ASSET_SWAP_INSTANCE = (select MAX(ASSET_SWAP_INSTANCE) FROM shipped_swaps FS1_MAX WHERE FS1.ASSET_ID = FS1_MAX.ASSET_ID)
)


, swaps_UOR as (
select distinct
    min_swap_instance.ASSET_ID,
    min_swap_instance.DEVICE_TYPE,
    min_swap_instance.PRIOR_DEVICE_SERIAL,
    min_swap_instance.PRIOR_ASSIGNMENT_ID,
    min_swap_instance.PRIOR_END_SERVICE_DATE,
    max_swap_instance.CURRENT_DEVICE_SERIAL,
    max_swap_instance.CURRENT_ASSIGNMENT_ID,
    max_swap_instance.CURRENT_INSTALL_DATE,
    max_swap_instance.CURRENT_END_SERVICE_DATE,
    max_swap_instance.ASSET_SWAP_INSTANCE
from
    min_swap_instance
join
    max_swap_instance
    on min_swap_instance.ASSET_ID = max_swap_instance.ASSET_ID
)

, t3_total_devices_service_timeline as (
select
    total_devices_SN_service_timeline.DEVICE_SERIAL as DEVICE_SERIAL,
    total_devices_SN_service_timeline.DEVICE_ID as DEVICE_ID,
    total_devices_SN_service_timeline.FIRST_INSTALL_ASSET_ID as FIRST_INSTALL_ASSET_ID,
    total_devices_SN_service_timeline.FIRST_INSTALL_COMPANY_ID as FIRST_INSTALL_COMPANY_ID,
    total_devices_SN_service_timeline.IN_SERVICE_DATE as IN_SERVICE_DATE,
    total_devices_SN_service_timeline.LAST_INSTALL_ASSET_ID as LAST_INSTALL_ASSET_ID,
    total_devices_SN_service_timeline.LAST_INSTALL_COMPANY_ID as LAST_INSTALL_COMPANY_ID,
    case
        when swaps_UOR.CURRENT_DEVICE_SERIAL is not null THEN 'SWAP'
        when swaps_UOR.CURRENT_DEVICE_SERIAL is null THEN 'SHIP'
    end as SWAP_STATUS,
    swaps_UOR.CURRENT_DEVICE_SERIAL as CURRENT_DEVICE_SERIAL,
    swaps_UOR.CURRENT_ASSIGNMENT_ID as CURRENT_ASSIGNMENT_ID,
    swaps_UOR.CURRENT_INSTALL_DATE as CURRENT_INSTALL_DATE,
    swaps_UOR.ASSET_SWAP_INSTANCE as ASSET_SWAP_INSTANCE,
    case
        when swaps_UOR.CURRENT_DEVICE_SERIAL is not null THEN swaps_UOR.CURRENT_END_SERVICE_DATE
        when swaps_UOR.CURRENT_DEVICE_SERIAL is null THEN total_devices_SN_service_timeline.END_SERVICE_DATE
    end as END_SERVICE_DATE
from
    total_devices_SN_service_timeline
left join
    swaps_UOR
    on total_devices_SN_service_timeline.DEVICE_SERIAL = swaps_UOR.PRIOR_DEVICE_SERIAL
)

, t3_total_devices_service_timeline_billing_units as (
select
    *,
    case
        when t3_total_devices_service_timeline.END_SERVICE_DATE is null THEN 'INSTALL ASSIGNMENT'
        when t3_total_devices_service_timeline.END_SERVICE_DATE is not null THEN 'UNINSTALL'
    end as BILLING_UNIT
from
    t3_total_devices_service_timeline
)

, market_ids as (
    select service_timeline.*, m.market_id as MARKET_ID, m.name as MARKET_NAME
    from total_devices_SN_service_timeline service_timeline
    left join ES_WAREHOUSE.SCD.SCD_ASSET_MSP msp
        on msp.asset_id = service_timeline.first_install_asset_id
            and msp.date_start::DATE <= service_timeline.in_service_date::DATE
            and msp.date_end::DATE > service_timeline.in_service_date
    left join ES_WAREHOUSE.SCD.SCD_ASSET_RSP rsp
        on rsp.asset_id = service_timeline.first_install_asset_id
            and rsp.date_start::DATE <= service_timeline.in_service_date::DATE
            and rsp.date_end::DATE > service_timeline.in_service_date::DATE
    left join ES_WAREHOUSE.PUBLIC.MARKETS m
        on m.market_id = coalesce(rsp.rental_branch_id, msp.service_branch_id)
)

select * from market_ids
;;
}

dimension: DEVICE_SERIAL {
  type: string
  sql: ${TABLE}.DEVICE_SERIAL ;;
  primary_key: yes
}

dimension: DEVICE_ID {
  type: string
  sql: ${TABLE}.DEVICE_ID  ;;
}

dimension: DEVICE_TYPE {
  type: string
  sql: ${TABLE}.DEVICE_TYPE  ;;
}

dimension: FIRST_INSTALL_ASSET_ID {
  type: string
  sql: ${TABLE}.FIRST_INSTALL_ASSET_ID  ;;
}

dimension: FIRST_INSTALL_ASSIGNMENT_ID {
  type: string
  sql: ${TABLE}.FIRST_INSTALL_ASSIGNMENT_ID  ;;
}

dimension: FIRST_INSTALL_COMPANY_ID {
  type: string
  sql: ${TABLE}.FIRST_INSTALL_COMPANY_ID  ;;
}

dimension: IN_SERVICE_DATE {
  type: date
  sql: ${TABLE}.IN_SERVICE_DATE  ;;
}

dimension: LAST_INSTALL_ASSET_ID {
  type: string
  sql: ${TABLE}.LAST_INSTALL_ASSET_ID  ;;
}

dimension: LAST_INSTALL_ASSIGNMENT_ID {
  type: string
  sql: ${TABLE}.LAST_INSTALL_ASSIGNMENT_ID  ;;
}


dimension: LAST_INSTALL_COMPANY_ID {
  type: string
  sql: ${TABLE}.LAST_INSTALL_COMPANY_ID  ;;
}

dimension: END_SERVICE_DATE {
  type: date
  sql: ${TABLE}.END_SERVICE_DATE  ;;
}

dimension: CURRENT_DEVICE_SERIAL {
  type: string
  sql: ${TABLE}.CURRENT_DEVICE_SERIAL  ;;
}

dimension: MARKET_ID {
  type: string
  sql: ${TABLE}.MARKET_ID  ;;
}

dimension: MARKET_NAME {
  type: string
  sql: ${TABLE}.MARKET_NAME  ;;
}

}
