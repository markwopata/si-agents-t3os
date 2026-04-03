view: t3_saas_in_service_inventory {
  derived_table: {
    sql:

-- T3 SAAS ADJUSTED VIEWS MARCH 2026 EW --
-- START WAREHOUSE_SHIPMENT_DATA_ADJ PULL --
with warehouse_shipment_data_dbt_all as (
-- DBT MART Warehouse Shipment Data --
select
    SN_UNIQUE_IDENTIFIER,
    LINKED_DEVICE_TYPE,
    PART_DESCRIPTION,
    SHIPPED_SERIAL_NUMBER,
    SHIPPED_SERIAL_FORMATTED,
    WAREHOUSE_PHYSICAL_DATE,
    WAREHOUSE_REQUESTED_SHIP_DATE,
    INVOICE_LINE_SUM,
    INVOICE_SALES_PRICE,
    INVOICE_ID,
    SALES_ORDER_NUMBER,
    FK_SALES_REF_ID,
    COMPANY_NAME_WHS,
    HUBSPOT_PIPELINE,
    DATE_DEACTIVATED,
    FK_DEACTIVATION_TICKET_ID,
    row_number()
            over (partition by SHIPPED_SERIAL_FORMATTED order by WAREHOUSE_PHYSICAL_DATE)
    as SERIAL_NUMBER_SHIPPED_INSTANCE
from
    financial_systems.t3_saas_gold.warehouse_shipment_data
)

, warehouse_shipment_data_dbt_all_first_shipment as (
-- DBT MART Warehouse Shipment Data FIRST SHIPMENT INSTANCE by SERIAL NUMBER --
select
    SN_UNIQUE_IDENTIFIER,
    LINKED_DEVICE_TYPE,
    PART_DESCRIPTION,
    SHIPPED_SERIAL_NUMBER,
    SHIPPED_SERIAL_FORMATTED,
    WAREHOUSE_PHYSICAL_DATE,
    WAREHOUSE_REQUESTED_SHIP_DATE,
    INVOICE_LINE_SUM,
    INVOICE_SALES_PRICE,
    INVOICE_ID,
    SALES_ORDER_NUMBER,
    FK_SALES_REF_ID,
    COMPANY_NAME_WHS,
    HUBSPOT_PIPELINE,
    DATE_DEACTIVATED,
    FK_DEACTIVATION_TICKET_ID,
    SERIAL_NUMBER_SHIPPED_INSTANCE
from
    warehouse_shipment_data_dbt_all
where
    serial_number_shipped_instance = '1'
)

, warehouse_shipment_data_dbt_all_second_shipment as (
-- DBT MART Warehouse Shipment Data SECONDARY SHIPMENT INSTANCE by SERIAL NUMBER Attached Details --
select
    SHIPPED_SERIAL_FORMATTED,
    CONCAT(WAREHOUSE_PHYSICAL_DATE, ' - ', SALES_ORDER_NUMBER, ' - ', FK_SALES_REF_ID) as SECONDARY_SHIPMENT_RECORD
from
    warehouse_shipment_data_dbt_all
where
    serial_number_shipped_instance = '2'
)

, warehouse_shipment_data_dbt as (
-- DBT MART Warehouse Shipment Data without Duplicate Serial Numbers --
select
    warehouse_shipment_data_dbt_all_first_shipment.SN_UNIQUE_IDENTIFIER,
    warehouse_shipment_data_dbt_all_first_shipment.SN_UNIQUE_IDENTIFIER as DYNAMIC_INDEX,
    warehouse_shipment_data_dbt_all_first_shipment.LINKED_DEVICE_TYPE,
    warehouse_shipment_data_dbt_all_first_shipment.PART_DESCRIPTION,
    warehouse_shipment_data_dbt_all_first_shipment.SHIPPED_SERIAL_NUMBER::TEXT as SHIPPED_SERIAL_NUMBER,
    warehouse_shipment_data_dbt_all_first_shipment.SHIPPED_SERIAL_FORMATTED::TEXT as SHIPPED_SERIAL_FORMATTED,
    warehouse_shipment_data_dbt_all_first_shipment.WAREHOUSE_PHYSICAL_DATE,
    warehouse_shipment_data_dbt_all_first_shipment.WAREHOUSE_REQUESTED_SHIP_DATE,
    warehouse_shipment_data_dbt_all_first_shipment.INVOICE_LINE_SUM,
    warehouse_shipment_data_dbt_all_first_shipment.INVOICE_SALES_PRICE,
    warehouse_shipment_data_dbt_all_first_shipment.INVOICE_ID,
    warehouse_shipment_data_dbt_all_first_shipment.SALES_ORDER_NUMBER,
    warehouse_shipment_data_dbt_all_first_shipment.FK_SALES_REF_ID as SALES_REF_ID,
    warehouse_shipment_data_dbt_all_first_shipment.COMPANY_NAME_WHS,
    warehouse_shipment_data_dbt_all_first_shipment.SERIAL_NUMBER_SHIPPED_INSTANCE,
    warehouse_shipment_data_dbt_all_first_shipment.HUBSPOT_PIPELINE,
    1 as BILL_BY_SHIPPED_UNIT,
    warehouse_shipment_data_dbt_all_first_shipment.DATE_DEACTIVATED as DEACTIVATION_DATE,
    warehouse_shipment_data_dbt_all_first_shipment.FK_DEACTIVATION_TICKET_ID as DEACTIVATION_TICKET_ID,
    warehouse_shipment_data_dbt_all_second_shipment.SECONDARY_SHIPMENT_RECORD
from
    warehouse_shipment_data_dbt_all_first_shipment
left join
    warehouse_shipment_data_dbt_all_second_shipment
    on warehouse_shipment_data_dbt_all_first_shipment.SHIPPED_SERIAL_FORMATTED = warehouse_shipment_data_dbt_all_second_shipment.SHIPPED_SERIAL_FORMATTED
)

, device_adjustments_first_instance as (
-- DEVICE ADJUSTMENTS First Instance Two Types of Device Adjustments are Replacements (RMAs) & Transfers --
select
    ID as ID,
    'RMA' as ADJUSTMENT_TYPE,
    ORIGINAL_SERIAL_NUMBER_FORMATTED::TEXT as ORIGINAL_SERIAL_NUMBER_FORMATTED,
    NEW_SERIAL_NUMBER_FORMATTED::TEXT as NEW_SERIAL_NUMBER_FORMATTED,
    REPLACEMENT_DATE as ADJUSTMENT_DATE,
    COMPANY_ID as OLD_COMPANY_ID,
    COMPANY_ID as NEW_COMPANY_ID
from
    analytics.t3_saas_billing.DEVICE_REPLACEMENTS
union
select
    ID as ID,
    'TRANSFER' as ADJUSTMENT_TYPE,
    SERIAL_FORMATTED::TEXT as ORIGINAL_SERIAL_NUMBER_FORMATTED,
    SERIAL_FORMATTED::TEXT as NEW_SERIAL_NUMBER_FORMATTED,
    TRANSFER_DATE as ADJUSTMENT_DATE,
    SENDING_COMPANY_ID as OLD_COMPANY_ID,
    RECEIVING_COMPANY_ID as NEW_COMPANY_ID
from
    analytics.t3_saas_billing.DEVICE_TRANSFERS
)


, warehouse_shipment_data_adj as (
-- DBT MART Warehouse Shipment Data without Duplicate Serial Numbers attaching DEVICE ADJUSTMENTS First Instance --
select
    warehouse_shipment_data_dbt.SN_UNIQUE_IDENTIFIER as DYNAMIC_INDEX,
    case
        when device_adjustments_first_instance.NEW_SERIAL_NUMBER_FORMATTED is not null then device_adjustments_first_instance.NEW_SERIAL_NUMBER_FORMATTED
        when device_adjustments_first_instance.NEW_SERIAL_NUMBER_FORMATTED is null then warehouse_shipment_data_dbt.SHIPPED_SERIAL_FORMATTED
    end as ADJ_CURRENT_SERIAL_FORMATTED,
    case
        when device_adjustments_first_instance.NEW_COMPANY_ID is not null then device_adjustments_first_instance.NEW_COMPANY_ID
        when device_adjustments_first_instance.NEW_COMPANY_ID is null then null
    end as ADJ_CURRENT_COMPANY_ID,
    case
        when device_adjustments_first_instance.NEW_SERIAL_NUMBER_FORMATTED is not null then device_adjustments_first_instance.ADJUSTMENT_DATE
        when device_adjustments_first_instance.NEW_SERIAL_NUMBER_FORMATTED is null then null
    end as FIRST_ADJUSTMENT_DATE,
    warehouse_shipment_data_dbt.SHIPPED_SERIAL_FORMATTED,
    warehouse_shipment_data_dbt.LINKED_DEVICE_TYPE,
    warehouse_shipment_data_dbt.PART_DESCRIPTION,
    warehouse_shipment_data_dbt.WAREHOUSE_PHYSICAL_DATE,
    warehouse_shipment_data_dbt.WAREHOUSE_PHYSICAL_DATE + 60 as WAREHOUSE_PHYSICAL_DATE_PLUS_60,
    warehouse_shipment_data_dbt.INVOICE_LINE_SUM,
    warehouse_shipment_data_dbt.INVOICE_SALES_PRICE,
    warehouse_shipment_data_dbt.INVOICE_ID,
    warehouse_shipment_data_dbt.SALES_ORDER_NUMBER,
    case
        when device_adjustments_first_instance.ADJUSTMENT_TYPE = 'TRANSFER' then concat('TR', warehouse_shipment_data_dbt.SALES_REF_ID)
        when device_adjustments_first_instance.ADJUSTMENT_TYPE != 'TRANSFER' then warehouse_shipment_data_dbt.SALES_REF_ID
        when device_adjustments_first_instance.ADJUSTMENT_TYPE is null then warehouse_shipment_data_dbt.SALES_REF_ID
    end as SALES_REF_ID,
    warehouse_shipment_data_dbt.COMPANY_NAME_WHS,
    warehouse_shipment_data_dbt.HUBSPOT_PIPELINE,
    case
        when device_adjustments_first_instance.NEW_SERIAL_NUMBER_FORMATTED is not null then device_adjustments_first_instance.ADJUSTMENT_TYPE
        when device_adjustments_first_instance.NEW_SERIAL_NUMBER_FORMATTED is null then null
    end as DEVICE_FIRST_ADJUSTMENT_TYPE,
    case
        when device_adjustments_first_instance.NEW_SERIAL_NUMBER_FORMATTED is not null then device_adjustments_first_instance.NEW_SERIAL_NUMBER_FORMATTED
        when device_adjustments_first_instance.NEW_SERIAL_NUMBER_FORMATTED is null then null
    end as DEVICE_FIRST_ADJUSTMENT_OLD_SERIAL_NUMBER_FORMATTED,
    case
        when device_adjustments_first_instance.NEW_SERIAL_NUMBER_FORMATTED is not null then device_adjustments_first_instance.NEW_SERIAL_NUMBER_FORMATTED
        when device_adjustments_first_instance.NEW_SERIAL_NUMBER_FORMATTED is null then null
    end as DEVICE_FIRST_ADJUSTMENT_NEW_SERIAL_NUMBER_FORMATTED,
    case
        when device_adjustments_first_instance.NEW_COMPANY_ID is not null then device_adjustments_first_instance.OLD_COMPANY_ID
        when device_adjustments_first_instance.NEW_COMPANY_ID is null then null
    end as DEVICE_FIRST_ADJUSTMENT_OLD_COMPANY_ID,
    case
        when device_adjustments_first_instance.NEW_COMPANY_ID is not null then device_adjustments_first_instance.NEW_COMPANY_ID
        when device_adjustments_first_instance.NEW_COMPANY_ID is null then null
    end as DEVICE_FIRST_ADJUSTMENT_NEW_COMPANY_ID,
    warehouse_shipment_data_dbt.DEACTIVATION_DATE,
    warehouse_shipment_data_dbt.SECONDARY_SHIPMENT_RECORD
from
    warehouse_shipment_data_dbt
left join
    device_adjustments_first_instance
    on warehouse_shipment_data_dbt.SHIPPED_SERIAL_FORMATTED = device_adjustments_first_instance.ORIGINAL_SERIAL_NUMBER_FORMATTED
)
-- END WAREHOUSE_SHIPMENT_DATA_ADJ PULL --

-- START HUBSPOT_CONTRACT_DATA_ADJ PULL --
, hubspot_contract_data_adj_dbt as (
-- DBT MART HubSpot Contract Data --
select
    FK_COMPANY_ID::TEXT as COMPANY_ID,
    COMPANY_NAME,
    FK_SALES_REF_ID::TEXT as SALES_REF_ID,
    FK_PRODUCT_ID::TEXT as PRODUCT_ID,
    CONTRACT_NAME,
    LINKED_DEVICE_TYPE,
    QTY_CONTRACTED as QUANTITY,
    MRR_CONTRACTED as CONTRACT_MRR,
    UNIT_COST_CONTRACTED as CONTRACT_UNIT_COST,
    DATE_CONTRACT_CLOSE as CONTRACT_CLOSE_DATE,
    CONTRACT_TERMS_IN_MONTHS,
    DATEADD(month, CONTRACT_TERMS_IN_MONTHS, DATE_CONTRACT_CLOSE) as CONTRACT_TERMS_END_DATE,
        /* Months remaining */
    FLOOR(
        MONTHS_BETWEEN(
            DATEADD(month, CONTRACT_TERMS_IN_MONTHS, CONTRACT_CLOSE_DATE),
            DATE_TRUNC('month', CURRENT_DATE)
        )
    ) AS MONTHS_REMAINING_ON_CONTRACT,
    CONTRACT_INSTALL_TYPE,
    CONTRACT_BUNDLE_INSTALL_STATUS,
    FK_ACCT_EXEC_ID as ACCT_EXEC_ID,
    ACCT_EXEC_NAME_FULL as ACCT_EXEC_NAME,
    ACCT_EXEC_EMAIL as ACCT_EXEC_EMAIL,
    PK_LINE_ITEM_ID::TEXT as LI_ID,
    FK_ADJUSTMENT_ID::TEXT as FIRST_ADJUSTMENT_ID,
    DATE_ADJUSTED as FIRST_ADJUSTMENT_DATE,
    BINARY_CUSTOMER_BILLING_DESIGNATION
from
    financial_systems.t3_saas_gold.hubspot_contract_data_adj
)

, contract_adjustments as (
select
    CONCAT('CONTRACTADJUSTMENT', _ROW) as ID,
    NEW_LINKED_DEVICE_TYPE,
    NEW_PRODUCT_ID,
    ADJUSTMENT_DATE,
    OLD_UNIT_COST,
    OLD_LINKED_DEVICE_TYPE,
    USER,
    SALES_REF_ID::TEXT as SALES_REF_ID,
    LI_ID::TEXT as LI_ID,
    NEW_UNIT_COST,
    OLD_PRODUCT_ID,
    BREAKING_BUNDLED_CONTRACT_TRACKER_SERIAL_FORMATTED
from
    analytics.t3_saas_billing.contract_adjustments
)

, receiving_transfers_totals as (
-- DEVICE TRANSFER Building a Dummy contact for Receiving Transfers. This part just grabs total QTY on the contract line --
select
    count (distinct SERIAL_FORMATTED) as TRANSFER_QTY,
    LI_ID,
    LINKED_DEVICE_TYPE
from
    analytics.t3_saas_billing.DEVICE_TRANSFERS
group by
    LI_ID,
    LINKED_DEVICE_TYPE
)

, receiving_transfers_contracts as (
-- DEVICE TRANSFER Building a Dummy contact for Receiving Transfers. This part extracts details from the upload table --
select distinct
    DEVICE_TRANSFERS.RECEIVING_COMPANY_ID::TEXT as COMPANY_ID,
    DEVICE_TRANSFERS.LINKED_DEVICE_TYPE,
    DEVICE_TRANSFERS.SALES_REF_ID::TEXT as SALES_REF_ID,
    DEVICE_TRANSFERS.PRODUCT_ID::TEXT as PRODUCT_ID,
    DEVICE_TRANSFERS.LI_ID::TEXT as LI_ID,
    DEVICE_TRANSFERS.UNIT_COST,
    DEVICE_TRANSFERS.UNIT_COST * receiving_transfers_totals.TRANSFER_QTY as CONTRACT_MRR,
    DEVICE_TRANSFERS.TRANSFER_DATE,
    receiving_transfers_totals.TRANSFER_QTY,
    SUBSTR(DEVICE_TRANSFERS.ID, 1, POSITION('-' IN DEVICE_TRANSFERS.ID) - 1) as ID
from
    analytics.t3_saas_billing.DEVICE_TRANSFERS
left join
    receiving_transfers_totals
    on DEVICE_TRANSFERS.LI_ID = receiving_transfers_totals.LI_ID
    and DEVICE_TRANSFERS.LINKED_DEVICE_TYPE = receiving_transfers_totals.LINKED_DEVICE_TYPE
)

, receiving_transfer_contracts_full as (
-- DEVICE TRANSFER Building a Dummy contact for Receiving Transfers. References DBT MART HubSpot Contract Data to fully mirror contract details --
select
    receiving_transfers_contracts.COMPANY_ID as COMPANY_ID,
    hubspot_contract_data_adj_dbt.COMPANY_NAME,
    concat('TR', receiving_transfers_contracts.SALES_REF_ID) as SALES_REF_ID,
    receiving_transfers_contracts.PRODUCT_ID,
    hubspot_contract_data_adj_dbt.CONTRACT_NAME,
    hubspot_contract_data_adj_dbt.LINKED_DEVICE_TYPE,
    receiving_transfers_contracts.TRANSFER_QTY as QUANTITY,
    receiving_transfers_contracts.CONTRACT_MRR,
    hubspot_contract_data_adj_dbt.CONTRACT_UNIT_COST,
    receiving_transfers_contracts.TRANSFER_DATE as CONTRACT_CLOSE_DATE,
        /* Months remaining */
    FLOOR(
        MONTHS_BETWEEN(
            DATEADD(month, hubspot_contract_data_adj_dbt.CONTRACT_TERMS_IN_MONTHS, hubspot_contract_data_adj_dbt.CONTRACT_CLOSE_DATE),
            DATE_TRUNC('month', receiving_transfers_contracts.TRANSFER_DATE)
        )
    ) AS CONTRACT_TERMS_IN_MONTHS,
                /* Months remaining */
    FLOOR(
        MONTHS_BETWEEN(
            DATEADD(month, CONTRACT_TERMS_IN_MONTHS, CONTRACT_CLOSE_DATE),
            DATE_TRUNC('month', CURRENT_DATE)
        )
    ) AS MONTHS_REMAINING_ON_CONTRACT,
    hubspot_contract_data_adj_dbt.CONTRACT_TERMS_END_DATE,
    hubspot_contract_data_adj_dbt.CONTRACT_INSTALL_TYPE,
    hubspot_contract_data_adj_dbt.CONTRACT_BUNDLE_INSTALL_STATUS,
    hubspot_contract_data_adj_dbt.ACCT_EXEC_ID,
    hubspot_contract_data_adj_dbt.ACCT_EXEC_NAME,
    hubspot_contract_data_adj_dbt.ACCT_EXEC_EMAIL,
    concat('TR', hubspot_contract_data_adj_dbt.LI_ID) as LI_ID,
    receiving_transfers_contracts.ID as FIRST_ADJUSTMENT_ID,
    receiving_transfers_contracts.TRANSFER_DATE as FIRST_ADJUSTMENT_DATE,
    hubspot_contract_data_adj_dbt.BINARY_CUSTOMER_BILLING_DESIGNATION
from
    receiving_transfers_contracts
left join
    hubspot_contract_data_adj_dbt
    on receiving_transfers_contracts.LI_ID = hubspot_contract_data_adj_dbt.LI_ID
    and receiving_transfers_contracts.LINKED_DEVICE_TYPE = hubspot_contract_data_adj_dbt.LINKED_DEVICE_TYPE
)

, hubspot_contract_data_adj as (
-- DBT MART HubSpot Contract Data plus Receiving Transfers Contracts --
select
    receiving_transfer_contracts_full.COMPANY_ID,
    receiving_transfer_contracts_full.COMPANY_NAME,
    receiving_transfer_contracts_full.SALES_REF_ID::TEXT as SALES_REF_ID,
    receiving_transfer_contracts_full.PRODUCT_ID,
    receiving_transfer_contracts_full.CONTRACT_NAME,
    receiving_transfer_contracts_full.LINKED_DEVICE_TYPE,
    receiving_transfer_contracts_full.CONTRACT_INSTALL_TYPE,
    receiving_transfer_contracts_full.BINARY_CUSTOMER_BILLING_DESIGNATION,
    receiving_transfer_contracts_full.QUANTITY as CONTRACT_QUANTITY,
    receiving_transfer_contracts_full.CONTRACT_UNIT_COST,
    receiving_transfer_contracts_full.CONTRACT_CLOSE_DATE,
    receiving_transfer_contracts_full.CONTRACT_MRR,
    receiving_transfer_contracts_full.CONTRACT_TERMS_IN_MONTHS,
    receiving_transfer_contracts_full.MONTHS_REMAINING_ON_CONTRACT,
    receiving_transfer_contracts_full.CONTRACT_BUNDLE_INSTALL_STATUS,
    receiving_transfer_contracts_full.CONTRACT_TERMS_END_DATE,
    receiving_transfer_contracts_full.ACCT_EXEC_ID as ACCT_EXEC_HS_ID,
    receiving_transfer_contracts_full.ACCT_EXEC_NAME,
    receiving_transfer_contracts_full.ACCT_EXEC_EMAIL,
    receiving_transfer_contracts_full.FIRST_ADJUSTMENT_ID,
    receiving_transfer_contracts_full.FIRST_ADJUSTMENT_DATE,
    receiving_transfer_contracts_full.LI_ID::TEXT as LI_ID
from
    receiving_transfer_contracts_full
union
select
    hubspot_contract_data_adj_dbt.COMPANY_ID,
    hubspot_contract_data_adj_dbt.COMPANY_NAME,
    hubspot_contract_data_adj_dbt.SALES_REF_ID::TEXT as SALES_REF_ID,
    hubspot_contract_data_adj_dbt.PRODUCT_ID,
    hubspot_contract_data_adj_dbt.CONTRACT_NAME,
    hubspot_contract_data_adj_dbt.LINKED_DEVICE_TYPE,
    hubspot_contract_data_adj_dbt.CONTRACT_INSTALL_TYPE,
    hubspot_contract_data_adj_dbt.BINARY_CUSTOMER_BILLING_DESIGNATION,
    hubspot_contract_data_adj_dbt.QUANTITY as CONTRACT_QUANTITY,
    hubspot_contract_data_adj_dbt.CONTRACT_UNIT_COST,
    hubspot_contract_data_adj_dbt.CONTRACT_CLOSE_DATE,
    hubspot_contract_data_adj_dbt.CONTRACT_MRR,
    hubspot_contract_data_adj_dbt.CONTRACT_TERMS_IN_MONTHS,
    hubspot_contract_data_adj_dbt.MONTHS_REMAINING_ON_CONTRACT,
    hubspot_contract_data_adj_dbt.CONTRACT_BUNDLE_INSTALL_STATUS,
    hubspot_contract_data_adj_dbt.CONTRACT_TERMS_END_DATE,
    hubspot_contract_data_adj_dbt.ACCT_EXEC_ID as ACCT_EXEC_HS_ID,
    hubspot_contract_data_adj_dbt.ACCT_EXEC_NAME,
    hubspot_contract_data_adj_dbt.ACCT_EXEC_EMAIL,
    hubspot_contract_data_adj_dbt.FIRST_ADJUSTMENT_ID,
    hubspot_contract_data_adj_dbt.FIRST_ADJUSTMENT_DATE,
    hubspot_contract_data_adj_dbt.LI_ID::TEXT as LI_ID
from
    hubspot_contract_data_adj_dbt
)
-- END HUBSPOT_CONTRACT_DATA_ADJ PULL --

-- START LEGACY_TRACKER_REPORT_NON_CONTRACTED_UNITS --
, tracker_type_mapping as (
-- mapping Tracker Types from ESDB --
select
    case
        when TRACKER_TYPE_ID in ('27', '28', '29', '30', '31') then 'FJ2500'
        when TRACKER_TYPE_ID in ('25', '26') then 'Queclink'
        when TRACKER_TYPE_ID in ('19', '20', '23', '40', '39') then 'MC4+'
        when TRACKER_TYPE_ID in ('24','22', '21') then 'Bluetooth'
        when TRACKER_TYPE_ID in ('41') then 'MC5'
        when TRACKER_TYPE_ID in ('37') then 'MCX101'
        when TRACKER_TYPE_ID in ('1') then '3030'
        when TRACKER_TYPE_ID in ('4') then '2830'
        when TRACKER_TYPE_ID in ('38') then 'Slap-N-Track'
        when TRACKER_TYPE_ID in ('34') then '730'
        else 'Tracker Type Not Found'
    end as LINKED_DEVICE_TYPE,
    TRACKER_TYPE_ID
from
    ES_WAREHOUSE.public.tracker_types
)

, legacy_tracker_report as (
-- Legacy Tracker Report Raw SQL --
select distinct
      et.device_serial,
      coalesce(tv.name, 'No tracker vendor') as vendor,
      coalesce(tt.config_version, 'No config found') as config,
      coalesce(tt.config_status, 'Unknown') as status,
      concat(coalesce(tt.script_version, '0'), '.', coalesce(tt.config_version, '0')) as version,
      tt.phone_number as tracker_phone,
      concat(a.custom_name, '.', a.model) as asset_name,
      c.company_id,
      c.name as company,
      u.username as email,
      concat(u.first_name, ' ', u.last_name) as owner,
      u.phone_number as phone,
      tt.firmware_version as firmware,
      aty.name as asset_type,
      -- Edit made to Legacy Tracker Report Raw SQL EW --
      case
        when tracker_type_mapping.linked_device_type is null and et.device_serial like '00%' then 'T3Camera'
        when tracker_type_mapping.linked_device_type = 'Tracker Type Not Found' and et.device_serial like '00%' then 'T3Camera'
        when tracker_type_mapping.linked_device_type is not null then tracker_type_mapping.linked_device_type
        else 'Tracker Type Not Found'
      end as LINKED_DEVICE_TYPE,
      KPAD.SERIAL_NUMBER AS keypad_serial,
      CAM.DEVICE_SERIAL AS camera_serial,
      CAMV.NAME AS camera_vendor
      from ES_WAREHOUSE.public.trackers et
          join ES_WAREHOUSE.trackers.trackers tt
              on et.device_serial = tt.device_serial
            left join tracker_type_mapping
              on et.tracker_type_id = tracker_type_mapping.tracker_type_id
          join ES_WAREHOUSE.public.assets a
              on a.tracker_id = et.tracker_id
          join ES_WAREHOUSE.public.tracker_vendors tv
              on tv.tracker_vendor_id = et.vendor_id
          join ES_WAREHOUSE.public.companies c
              on c.company_id = a.company_id
          join ES_WAREHOUSE.public.users u
              on u.user_id = c.owner_user_id
          join ES_WAREHOUSE.public.asset_types aty
              on aty.asset_type_id = a.asset_type_id
          left join ES_WAREHOUSE.PUBLIC.KEYPAD_ASSET_ASSIGNMENTS KAA
              on A.ASSET_ID = KAA.ASSET_ID
                  and KAA.END_DATE is NULL
          left join ES_WAREHOUSE.PUBLIC.KEYPADS KPAD
              on KAA.KEYPAD_ID = KPAD.KEYPAD_ID
          left join ES_WAREHOUSE.PUBLIC.ASSET_CAMERA_ASSIGNMENTS CAMA
                   on A.ASSET_ID = CAMA.ASSET_ID
                       and CAMA.DATE_UNINSTALLED is NULL
          left join ES_WAREHOUSE.PUBLIC.CAMERAS CAM
              ON CAMA.CAMERA_ID = CAM.CAMERA_ID
          left join ES_WAREHOUSE.PUBLIC.CAMERA_VENDORS CAMV
              ON CAM.CAMERA_VENDOR_ID = CAMV.CAMERA_VENDOR_ID
)

, legacy_tracker_report_not_found_units_warehouse_adj_view as (
-- Legacy Tracker Dummy Shipment Building --
select
    concat('LTR', legacy_tracker_report.device_serial) as SN_UNIQUE_IDENTIFIER,
    concat('LTR', legacy_tracker_report.device_serial) as DYNAMIC_INDEX,
    legacy_tracker_report.LINKED_DEVICE_TYPE,
    concat('LTR - ', legacy_tracker_report.asset_type) as PART_DESCRIPTION,
    legacy_tracker_report.device_serial as SHIPPED_SERIAL_NUMBER,
    legacy_tracker_report.device_serial as SHIPPED_SERIAL_FORMATTED,
    '2020-01-01' as WAREHOUSE_PHYSICAL_DATE,
    '2020-03-01' as WAREHOUSE_PHYSICAL_DATE_PLUS_60,
    '2020-01-01' as WAREHOUSE_REQUESTED_SHIP_DATE,
    0.00 as INVOICE_LINE_SUM,
    0.00 as INVOICE_SALES_PRICE,
    'LTR - No Invoice ID' as INVOICE_ID,
    'LTR - Sales Order Number' as SALES_ORDER_NUMBER,
    concat('LTR - ', legacy_tracker_report.company_id) as SALES_REF_ID,
    legacy_tracker_report.company as COMPANY_NAME_WHS,
    'LTR - No HubSpot Contract' SERIAL_NUMBER_SHIPPED_INSTANCE,
    'LTR - No HubSpot Contract' as HUBSPOT_PIPELINE,
    0 as BILL_BY_SHIPPED_UNIT,
    null as DEACTIVATION_DATE,
    null as DEACTIVATION_TICKET_ID,
    null as DEVICE_FIRST_ADJUSTMENT_TYPE,
    null as DEVICE_FIRST_ADJUSTMENT_OLD_SERIAL_NUMBER_FORMATTED,
    null as DEVICE_FIRST_ADJUSTMENT_NEW_SERIAL_FORMATTED,
    null as DEVICE_FIRST_ADJUSTMENT_OLD_COMPANY_ID,
    null as DEVICE_FIRST_ADJUSTMENT_NEW_COMPANY_ID,
    null as DEVICE_FIRST_ADJUSTMENT_DATE,
    legacy_tracker_report.device_serial as ADJ_CURRENT_SERIAL_FORMATTED,
    legacy_tracker_report.company_id as ADJ_CURRENT_COMPANY_ID
from
    legacy_tracker_report
left join
    warehouse_shipment_data_adj
    on legacy_tracker_report.device_serial = warehouse_shipment_data_adj.ADJ_CURRENT_SERIAL_FORMATTED
left join
    financial_systems.t3_saas_gold.customer_master
    on legacy_tracker_report.company_id = customer_master.pk_company_id
where
    warehouse_shipment_data_adj.ADJ_CURRENT_SERIAL_FORMATTED is null
    and legacy_tracker_report.COMPANY_ID != '1854'
    and customer_master.customer_billing_status = 'Active'
)

, legacy_tracker_report_dummy_contract_building_1 as (
-- Legacy Tracker Dummy Shipment Building cont., mapping contracts --
select
    ADJ_CURRENT_COMPANY_ID,
    SALES_REF_ID,
    LINKED_DEVICE_TYPE,
    case
        when PART_DESCRIPTION = 'LTR - vehicle' and LINKED_DEVICE_TYPE != 'T3Camera' then 'VEHICLE'
        when PART_DESCRIPTION = 'LTR - equipment' and LINKED_DEVICE_TYPE != 'T3Camera' then 'POWERED'
        when PART_DESCRIPTION = 'LTR - bucket' and LINKED_DEVICE_TYPE != 'T3Camera' then 'POWERED'
        when PART_DESCRIPTION = 'LTR - small tool' and LINKED_DEVICE_TYPE != 'T3Camera' then 'TRACKER'
        when PART_DESCRIPTION = 'LTR - trailer' and LINKED_DEVICE_TYPE != 'T3Camera' then 'NON POWERED'
        when PART_DESCRIPTION = 'LTR - attachment' and LINKED_DEVICE_TYPE != 'T3Camera' then 'NON POWERED'
        when LINKED_DEVICE_TYPE = 'T3Camera' then 'CAMERA'
    end as CONTRACT,
    SN_UNIQUE_IDENTIFIER
from
    legacy_tracker_report_not_found_units_warehouse_adj_view
)

, legacy_tracker_report_dummy_contract_building_2 as (
-- Legacy Tracker Dummy Shipment Building cont., summing number of units --
select
    ADJ_CURRENT_COMPANY_ID,
    SALES_REF_ID,
    LINKED_DEVICE_TYPE,
    CONTRACT,
    count(distinct SN_UNIQUE_IDENTIFIER) as CONTRACTED_UNITS
from
    legacy_tracker_report_dummy_contract_building_1
group by
    ADJ_CURRENT_COMPANY_ID,
    SALES_REF_ID,
    LINKED_DEVICE_TYPE,
    CONTRACT
)

, legacy_tracker_report_not_found_units_contract_adj_view as (
-- Legacy Tracker Dummy Shipment Building cont., finalizing contract details --
select
    legacy_tracker_report_dummy_contract_building_2.ADJ_CURRENT_COMPANY_ID as COMPANY_ID,
    companies.NAME as COMPANY_NAME,
    legacy_tracker_report_dummy_contract_building_2.SALES_REF_ID,
    case
        when legacy_tracker_report_dummy_contract_building_2.CONTRACT = 'TRACKER' then 'LTRTRACKER'
        when legacy_tracker_report_dummy_contract_building_2.CONTRACT = 'POWERED' then 'LTRPOWERED'
        when legacy_tracker_report_dummy_contract_building_2.CONTRACT = 'VEHICLE' then 'LTRVEHICLE'
        when legacy_tracker_report_dummy_contract_building_2.CONTRACT = 'NON POWERED' then 'LTRNONPOWERED'
        when legacy_tracker_report_dummy_contract_building_2.CONTRACT = 'CAMERA' then 'LTRCAMERA'
    end as PRODUCT_ID,
    case
        when legacy_tracker_report_dummy_contract_building_2.CONTRACT = 'TRACKER' then 'LEGACY ATR DEVICE MISSING CONTRACT - TRACKER'
        when legacy_tracker_report_dummy_contract_building_2.CONTRACT = 'POWERED' then 'LEGACY ATR DEVICE MISSING CONTRACT - POWERED'
        when legacy_tracker_report_dummy_contract_building_2.CONTRACT = 'VEHICLE' then 'LEGACY ATR DEVICE MISSING CONTRACT - VEHICLE'
        when legacy_tracker_report_dummy_contract_building_2.CONTRACT = 'NON POWERED' then 'LEGACY ATR DEVICE MISSING CONTRACT - NON POWERED'
        when legacy_tracker_report_dummy_contract_building_2.CONTRACT = 'CAMERA' then 'LEGACY ATR DEVICE MISSING CONTRACT - CAMERA'
    end as CONTRACT_NAME,
    legacy_tracker_report_dummy_contract_building_2.LINKED_DEVICE_TYPE,
    legacy_tracker_report_dummy_contract_building_2.CONTRACTED_UNITS as QUANTITY,
    0.00 as CONTRACT_MRR,
    0.00 as CONTRACT_UNIT_COST,
    '2020-01-01' as CONTRACT_CLOSE_DATE,
    null as CONTRACT_TERMS_IN_MONTHS,
    null as MONTHS_REMAINING_ON_CONTRACT,
    'ES Install' as CONTRACT_INSTALL_TYPE,
    'Install Included' as CONTRACT_BUNDLE_INSTALL_STATUS,
    null as ACCT_EXEC_ID,
    null as ACCT_EXEC_NAME,
    null as ACCT_EXEC_EMAIL,
    concat(legacy_tracker_report_dummy_contract_building_2.SALES_REF_ID, legacy_tracker_report_dummy_contract_building_2.CONTRACT) as LI_ID,
    null as FIRST_ADJUSTMENT_ID,
    null as FIRST_ADJUSTMENT_DATE
from
    legacy_tracker_report_dummy_contract_building_2
left join
    es_warehouse.public.companies
    on legacy_tracker_report_dummy_contract_building_2.ADJ_CURRENT_COMPANY_ID = companies.company_id
)

, legacy_tracker_report_not_found_units_mapping as (
-- Legacy Tracker Dummy Shipment Building cont., Mapping again --
select
    SHIPPED_SERIAL_FORMATTED,
    case
        when PART_DESCRIPTION = 'LTR - vehicle' and LINKED_DEVICE_TYPE != 'T3Camera' then 'LEGACY ATR DEVICE MISSING CONTRACT - VEHICLE'
        when PART_DESCRIPTION = 'LTR - equipment' and LINKED_DEVICE_TYPE != 'T3Camera' then 'LEGACY ATR DEVICE MISSING CONTRACT - POWERED'
        when PART_DESCRIPTION = 'LTR - bucket' and LINKED_DEVICE_TYPE != 'T3Camera' then 'LEGACY ATR DEVICE MISSING CONTRACT - POWERED'
        when PART_DESCRIPTION = 'LTR - small tool' and LINKED_DEVICE_TYPE != 'T3Camera' then 'LEGACY ATR DEVICE MISSING CONTRACT - TRACKER'
        when PART_DESCRIPTION = 'LTR - trailer' and LINKED_DEVICE_TYPE != 'T3Camera' then 'LEGACY ATR DEVICE MISSING CONTRACT - NON POWERED'
        when PART_DESCRIPTION = 'LTR - attachment' and LINKED_DEVICE_TYPE != 'T3Camera' then 'LEGACY ATR DEVICE MISSING CONTRACT - NON POWERED'
        when LINKED_DEVICE_TYPE = 'T3Camera' then 'LEGACY ATR DEVICE MISSING CONTRACT - CAMERA'
    end as CONTRACT_NAME,
    case
        when PART_DESCRIPTION = 'LTR - vehicle' and LINKED_DEVICE_TYPE != 'T3Camera' then 'LTRVEHICLE'
        when PART_DESCRIPTION = 'LTR - equipment' and LINKED_DEVICE_TYPE != 'T3Camera' then 'LTRPOWERED'
        when PART_DESCRIPTION = 'LTR - bucket' and LINKED_DEVICE_TYPE != 'T3Camera' then 'LTRPOWERED'
        when PART_DESCRIPTION = 'LTR - small tool' and LINKED_DEVICE_TYPE != 'T3Camera' then 'LTRTRACKER'
        when PART_DESCRIPTION = 'LTR - trailer' and LINKED_DEVICE_TYPE != 'T3Camera' then 'LTRNONPOWERED'
        when PART_DESCRIPTION = 'LTR - attachment' and LINKED_DEVICE_TYPE != 'T3Camera' then 'LTRNONPOWERED'
        when LINKED_DEVICE_TYPE = 'T3Camera' then 'LTRCAMERA'
    end as PRODUCT_ID,
    SALES_REF_ID,
    LINKED_DEVICE_TYPE
from
    legacy_tracker_report_not_found_units_warehouse_adj_view
)

, legacy_tracker_report_not_found_units_mapping_adj_view as (
-- Legacy Tracker Dummy Shipment to Contract Mapping --
select
    legacy_tracker_report_not_found_units_warehouse_adj_view.SALES_REF_ID::TEXT as SALES_REF_ID,
    legacy_tracker_report_not_found_units_warehouse_adj_view.SHIPPED_SERIAL_FORMATTED,
    legacy_tracker_report_not_found_units_mapping.CONTRACT_NAME,
    legacy_tracker_report_not_found_units_warehouse_adj_view.LINKED_DEVICE_TYPE,
    legacy_tracker_report_not_found_units_mapping.PRODUCT_ID::TEXT as PRODUCT_ID
from
    legacy_tracker_report_not_found_units_warehouse_adj_view
left join
    legacy_tracker_report_not_found_units_mapping
    on legacy_tracker_report_not_found_units_warehouse_adj_view.SALES_REF_ID = legacy_tracker_report_not_found_units_mapping.SALES_REF_ID
    and legacy_tracker_report_not_found_units_warehouse_adj_view.SHIPPED_SERIAL_FORMATTED = legacy_tracker_report_not_found_units_mapping.SHIPPED_SERIAL_FORMATTED
    and legacy_tracker_report_not_found_units_warehouse_adj_view.LINKED_DEVICE_TYPE = legacy_tracker_report_not_found_units_mapping.LINKED_DEVICE_TYPE
    )

, legacy_tracker_report_not_found_units_potential_billable_units as (
-- New Billable units per Legacy Tracker Report --
select
    'LEGACY TRACKER REPORT' as SHIPMENT_TYPE,
    legacy_tracker_report_not_found_units_warehouse_adj_view.SHIPPED_SERIAL_FORMATTED as SERIAL_FORMATTED,
    legacy_tracker_report_not_found_units_warehouse_adj_view.WAREHOUSE_PHYSICAL_DATE as PHYSICAL_DATE,
    legacy_tracker_report_not_found_units_warehouse_adj_view.WAREHOUSE_PHYSICAL_DATE_PLUS_60,
    legacy_tracker_report_not_found_units_contract_adj_view.COMPANY_ID as ADJ_CURRENT_COMPANY_ID,
    legacy_tracker_report_not_found_units_contract_adj_view.COMPANY_ID,
    legacy_tracker_report_not_found_units_contract_adj_view.SALES_REF_ID,
    legacy_tracker_report_not_found_units_contract_adj_view.PRODUCT_ID,
    legacy_tracker_report_not_found_units_contract_adj_view.CONTRACT_NAME,
    legacy_tracker_report_not_found_units_warehouse_adj_view.LINKED_DEVICE_TYPE,
    legacy_tracker_report_not_found_units_contract_adj_view.CONTRACT_INSTALL_TYPE,
    'Invoice Installed Units' as BINARY_CUSTOMER_BILLING_DESIGNATION,
    0.00 as CONTRACT_UNIT_COST
from
    legacy_tracker_report_not_found_units_warehouse_adj_view
left join
    legacy_tracker_report_not_found_units_mapping_adj_view
    on legacy_tracker_report_not_found_units_warehouse_adj_view.SALES_REF_ID = legacy_tracker_report_not_found_units_mapping_adj_view.SALES_REF_ID
    and legacy_tracker_report_not_found_units_warehouse_adj_view.LINKED_DEVICE_TYPE = legacy_tracker_report_not_found_units_mapping_adj_view.LINKED_DEVICE_TYPE
    and legacy_tracker_report_not_found_units_warehouse_adj_view.SHIPPED_SERIAL_FORMATTED = legacy_tracker_report_not_found_units_mapping_adj_view.SHIPPED_SERIAL_FORMATTED
left join
    legacy_tracker_report_not_found_units_contract_adj_view
    on legacy_tracker_report_not_found_units_contract_adj_view.SALES_REF_ID = legacy_tracker_report_not_found_units_mapping_adj_view.SALES_REF_ID
    and legacy_tracker_report_not_found_units_contract_adj_view.LINKED_DEVICE_TYPE = legacy_tracker_report_not_found_units_mapping_adj_view.LINKED_DEVICE_TYPE
    and legacy_tracker_report_not_found_units_contract_adj_view.CONTRACT_NAME = legacy_tracker_report_not_found_units_mapping_adj_view.CONTRACT_NAME
)
-- END LEGACY_TRACKER_REPORT_NON_CONTRACTED_UNITS --

-- START SHIPMENT_TO_CONTRACT_ADJ MAPPING --
, adj_transfer_shipment_to_contract_mapping as (
-- Replacement & Transfer only Shipment to Contract Mapping. Needed in Legacy Tracker Report dummy contract building --
select
    hubspot_contract_data_adj.SALES_REF_ID::TEXT as SALES_REF_ID,
    warehouse_shipment_data_adj.ADJ_CURRENT_SERIAL_FORMATTED as SHIPPED_SERIAL_FORMATTED,
    hubspot_contract_data_adj.CONTRACT_NAME,
    hubspot_contract_data_adj.LINKED_DEVICE_TYPE,
    hubspot_contract_data_adj.PRODUCT_ID::TEXT as PRODUCT_ID
from
    warehouse_shipment_data_adj
left join
    hubspot_contract_data_adj
    on hubspot_contract_data_adj.SALES_REF_ID = warehouse_shipment_data_adj.SALES_REF_ID
    and hubspot_contract_data_adj.LINKED_DEVICE_TYPE = warehouse_shipment_data_adj.LINKED_DEVICE_TYPE
where
    warehouse_shipment_data_adj.DEVICE_FIRST_ADJUSTMENT_TYPE in ('RMA', 'TRANSFER')
)

, contract_adjustment_shipment_to_contract_mapping as (
-- Replacement & Transfer only Shipment to Contract Mapping. Needed in Legacy Tracker Report dummy contract building --
select
    hubspot_contract_data_adj.SALES_REF_ID::TEXT as SALES_REF_ID,
    warehouse_shipment_data_adj.ADJ_CURRENT_SERIAL_FORMATTED as SHIPPED_SERIAL_FORMATTED,
    new_product_name.CONTRACT_NAME,
    contract_adjustments.NEW_LINKED_DEVICE_TYPE,
    contract_adjustments.NEW_PRODUCT_ID::TEXT as PRODUCT_ID
from
    warehouse_shipment_data_adj
left join
    hubspot_contract_data_adj
    on hubspot_contract_data_adj.SALES_REF_ID = warehouse_shipment_data_adj.SALES_REF_ID
    and hubspot_contract_data_adj.LINKED_DEVICE_TYPE = warehouse_shipment_data_adj.LINKED_DEVICE_TYPE
left join
    contract_adjustments
    on hubspot_contract_data_adj.SALES_REF_ID = contract_adjustments.SALES_REF_ID
    and hubspot_contract_data_adj.LI_ID = contract_adjustments.LI_ID
left join
    analytics.t3_saas_billing.product_mapping new_product_name
    on new_product_name.PRODUCT_ID = contract_adjustments.NEW_PRODUCT_ID
where
    contract_adjustments.OLD_PRODUCT_ID <> contract_adjustments.NEW_PRODUCT_ID
)

, shipment_to_contract_mapping_dbt_breaking_bundled_tracker_and_cameras as (
select
    contract_adjustments.SALES_REF_ID::TEXT as SALES_REF_ID,
    contract_adjustments.BREAKING_BUNDLED_CONTRACT_TRACKER_SERIAL_FORMATTED as SHIPPED_SERIAL_FORMATTED,
    new_product_name.CONTRACT_NAME,
    contract_adjustments.NEW_LINKED_DEVICE_TYPE as LINKED_DEVICE_TYPE,
    contract_adjustments.NEW_PRODUCT_ID::TEXT as PRODUCT_ID
from
    contract_adjustments
left join
    analytics.t3_saas_billing.product_mapping old_product_name
    on contract_adjustments.OLD_PRODUCT_ID = old_product_name.PRODUCT_ID
left join
    financial_systems.t3_saas_silver.stg_analytics_t3_saas_billing__deactivation_billing_adjustments deacts
    on contract_adjustments.SALES_REF_ID = deacts.FK_SALES_REF_ID
    and contract_adjustments.OLD_LINKED_DEVICE_TYPE = deacts.DEVICE_TYPE
    and old_product_name.CONTRACT_NAME = deacts.BUNDLE_TYPE
left join
    analytics.t3_saas_billing.product_mapping new_product_name
    on contract_adjustments.NEW_PRODUCT_ID = new_product_name.PRODUCT_ID
where
    contract_adjustments.OLD_PRODUCT_ID <> contract_adjustments.NEW_PRODUCT_ID
    and contract_adjustments.BREAKING_BUNDLED_CONTRACT_TRACKER_SERIAL_FORMATTED is not null
)

, shipment_to_contract_mapping_dbt_removing_bundled_tracker_and_cameras_and_contract_adjustments as (
select
    shipment_to_contract.FK_SALES_REF_ID::TEXT as SALES_REF_ID,
    shipment_to_contract.SHIPPED_SERIAL_FORMATTED,
    shipment_to_contract.CONTRACT_NAME,
    shipment_to_contract.LINKED_DEVICE_TYPE,
    hubspot_contract_data_adj.PRODUCT_ID::TEXT as PRODUCT_ID
from
    financial_systems.t3_saas_gold.shipment_to_contract
left join
    hubspot_contract_data_adj
    on shipment_to_contract.FK_SALES_REF_ID::TEXT = hubspot_contract_data_adj.SALES_REF_ID
    and shipment_to_contract.CONTRACT_NAME = hubspot_contract_data_adj.CONTRACT_NAME
    and shipment_to_contract.LINKED_DEVICE_TYPE = hubspot_contract_data_adj.LINKED_DEVICE_TYPE
where
    shipment_to_contract.SHIPPED_SERIAL_FORMATTED not in (select SHIPPED_SERIAL_FORMATTED from shipment_to_contract_mapping_dbt_breaking_bundled_tracker_and_cameras)
    and shipment_to_contract.SHIPPED_SERIAL_FORMATTED not in (select SHIPPED_SERIAL_FORMATTED from contract_adjustment_shipment_to_contract_mapping)
)

, shipment_to_contract_mapping_dbt_adj as (
select
    *
from
    shipment_to_contract_mapping_dbt_breaking_bundled_tracker_and_cameras
union
select
    *
from
    contract_adjustment_shipment_to_contract_mapping
union
select
    *
from
    shipment_to_contract_mapping_dbt_removing_bundled_tracker_and_cameras_and_contract_adjustments
)

, shipment_to_contract_mapping_without_product_id as (
-- DBT MART Shipment to Contract Mapping Unioned with Shipment to Contract Mapping and Unioned with Legacy Tracker Report Shipment to Contract Mapping --
select
    SALES_REF_ID,
    SHIPPED_SERIAL_FORMATTED,
    CONTRACT_NAME,
    LINKED_DEVICE_TYPE,
    PRODUCT_ID::TEXT as PRODUCT_ID
from
    shipment_to_contract_mapping_dbt_adj
union
select
    SALES_REF_ID::TEXT as SALES_REF_ID,
    SHIPPED_SERIAL_FORMATTED,
    CONTRACT_NAME,
    LINKED_DEVICE_TYPE,
    PRODUCT_ID::TEXT as PRODUCT_ID
from
    adj_transfer_shipment_to_contract_mapping
union
select
    SALES_REF_ID::TEXT as SALES_REF_ID,
    SHIPPED_SERIAL_FORMATTED,
    CONTRACT_NAME,
    LINKED_DEVICE_TYPE,
    PRODUCT_ID::TEXT as PRODUCT_ID
from
    legacy_tracker_report_not_found_units_mapping_adj_view
)

, shipment_to_contract_mapping_adj_dups as (
select
    shipment_to_contract_mapping_without_product_id.SALES_REF_ID,
    shipment_to_contract_mapping_without_product_id.SHIPPED_SERIAL_FORMATTED,
    case
        when shipment_to_contract_mapping_without_product_id.SHIPPED_SERIAL_FORMATTED in /* 36267120185 */ ('003F00A2C3', '003F00A4D3', '003F00A52E', '003F00A531', '003F00A7D5', '003F00A8DD', '003F00A943', '003F00AA9D', '003F00AB67', '003F00ADD1', '003F00AE82', '003F00AF19', '003F00AFAD', '003F00AFB6', '003F00AFBF', '003F00AFD5', '003F00B475', '003F00B4B9', '003F00B4D5', '003F00B4E1', '003F00B5C2', '003F00B65C', '003F00B6A7', '003F00B6F3') then 'TELEMATICS SERVICE TRACKER & CAMERA BUNDLE'
        when shipment_to_contract_mapping_without_product_id.SHIPPED_SERIAL_FORMATTED in  /* 36267120185 */ ('003F00AFBC', '003F00AF6C', '003F00A7AD', '003F00A2C5', '003F00B6FE', '003F00AFC9') then 'TELEMATICS SERVICE TRACKER & CAMERA BUNDLE'
        when shipment_to_contract_mapping_without_product_id.SHIPPED_SERIAL_FORMATTED in  /* 56179207608 */ ('00D20625BD', '00D20625BE', '00D20626E9', '00D2062789', '00D20627F6', '00D206286B', '00D20628E9', '00D206293E', '00D206296C', '00D2062986', '00D20632FD', '00D2063364', '00D206341B', '00D20634EF', '00D2063578', '00D20635A6', '00D20635D1', '00D2063688', '00D2063744', '00D20637D5', '00D206387E', '00D2063A57') then 'TELEMATICS SERVICE TRACKER, CAMERA, & AI FACIAL RECOGNITION BUNDLE'
        when shipment_to_contract_mapping_without_product_id.SHIPPED_SERIAL_FORMATTED in /* 11669052774 */ ('4673527703', '4673527719', '4673527720', '4673527721') then 'TELEMATICS SERVICE TRACKER BUNDLE'
        when shipment_to_contract_mapping_without_product_id.SHIPPED_SERIAL_FORMATTED in /* 47292850828 */ ('00D2062617', '00D206261E', '00D206263A', '00D2062719', '00D2062784', '00D20628A1') then 'TELEMATICS SERVICE TRACKER & CAMERA BUNDLE'
        when shipment_to_contract_mapping_without_product_id.SHIPPED_SERIAL_FORMATTED = /* 52884291510 */ '00D2063876' then 'TELEMATICS SERVICE TRACKER & CAMERA BUNDLE'
        else shipment_to_contract_mapping_without_product_id.CONTRACT_NAME
    end as CONTRACT_NAME,
    shipment_to_contract_mapping_without_product_id.LINKED_DEVICE_TYPE,
    case
        when shipment_to_contract_mapping_without_product_id.SHIPPED_SERIAL_FORMATTED in /* 36267120185 */ ('003F00A2C3', '003F00A4D3', '003F00A52E', '003F00A531', '003F00A7D5', '003F00A8DD', '003F00A943', '003F00AA9D', '003F00AB67', '003F00ADD1', '003F00AE82', '003F00AF19', '003F00AFAD', '003F00AFB6', '003F00AFBF', '003F00AFD5', '003F00B475', '003F00B4B9', '003F00B4D5', '003F00B4E1', '003F00B5C2', '003F00B65C', '003F00B6A7', '003F00B6F3') then '1499667074'
        when shipment_to_contract_mapping_without_product_id.SHIPPED_SERIAL_FORMATTED in  /* 36267120185 */ ('003F00AFBC', '003F00AF6C', '003F00A7AD', '003F00A2C5', '003F00B6FE', '003F00AFC9') then '1501947921'
        when shipment_to_contract_mapping_without_product_id.SHIPPED_SERIAL_FORMATTED in  /* 56179207608 */ ('00D20625BD', '00D20625BE', '00D20626E9', '00D2062789', '00D20627F6', '00D206286B', '00D20628E9', '00D206293E', '00D206296C', '00D2062986', '00D20632FD', '00D2063364', '00D206341B', '00D20634EF', '00D2063578', '00D20635A6', '00D20635D1', '00D2063688', '00D2063744', '00D20637D5', '00D206387E', '00D2063A57') then '2328556154'
        when shipment_to_contract_mapping_without_product_id.SHIPPED_SERIAL_FORMATTED in /* 11669052774 */ ('4673527703', '4673527719', '4673527720', '4673527721') then '1631093615'
        when shipment_to_contract_mapping_without_product_id.SHIPPED_SERIAL_FORMATTED in /* 47292850828 */ ('00D2062617', '00D206261E', '00D206263A', '00D2062719', '00D2062784', '00D20628A1') then '1501947921'
        when shipment_to_contract_mapping_without_product_id.SHIPPED_SERIAL_FORMATTED = /* 52884291510 */ '00D2063876' then '1501947921'
        else shipment_to_contract_mapping_without_product_id.PRODUCT_ID
    end as PRODUCT_ID
from
    shipment_to_contract_mapping_without_product_id
)

, shipment_to_contract_mapping_adj as (
select distinct * from shipment_to_contract_mapping_adj_dups
)

-- END SHIPMENT_TO_CONTRACT_ADJ MAPPING --

, contract_adjustments_serials_breaking_bundled_contracts as (
select
    contract_adjustments.ID,
    contract_adjustments.NEW_LINKED_DEVICE_TYPE,
    contract_adjustments.NEW_PRODUCT_ID::TEXT as NEW_PRODUCT_ID,
    new_product_name.contract_name as NEW_CONTRACT_NAME,
    contract_adjustments.ADJUSTMENT_DATE,
    contract_adjustments.OLD_UNIT_COST,
    contract_adjustments.OLD_LINKED_DEVICE_TYPE,
    contract_adjustments.USER,
    contract_adjustments.SALES_REF_ID::TEXT as SALES_REF_ID,
    contract_adjustments.LI_ID::TEXT as LI_ID,
    contract_adjustments.NEW_UNIT_COST,
    contract_adjustments.OLD_PRODUCT_ID::TEXT as OLD_PRODUCT_ID,
    old_product_name.contract_name as OLD_CONTRACT_NAME,
    contract_adjustments.BREAKING_BUNDLED_CONTRACT_TRACKER_SERIAL_FORMATTED as SERIAL_FORMATTED
from
    contract_adjustments
left join
    analytics.t3_saas_billing.product_mapping new_product_name
    on contract_adjustments.NEW_PRODUCT_ID = new_product_name.PRODUCT_ID
left join
    analytics.t3_saas_billing.product_mapping old_product_name
    on contract_adjustments.OLD_PRODUCT_ID = old_product_name.PRODUCT_ID
where
    BREAKING_BUNDLED_CONTRACT_TRACKER_SERIAL_FORMATTED is not null
)

, contract_adjustments_serials_not_breaking_bundles as (
select
    contract_adjustments.ID,
    contract_adjustments.NEW_LINKED_DEVICE_TYPE,
    contract_adjustments.NEW_PRODUCT_ID::TEXT as NEW_PRODUCT_ID,
    new_product_name.contract_name as NEW_CONTRACT_NAME,
    contract_adjustments.ADJUSTMENT_DATE,
    contract_adjustments.OLD_UNIT_COST,
    contract_adjustments.OLD_LINKED_DEVICE_TYPE,
    contract_adjustments.USER,
    contract_adjustments.SALES_REF_ID::TEXT as SALES_REF_ID,
    contract_adjustments.LI_ID,
    contract_adjustments.NEW_UNIT_COST,
    contract_adjustments.OLD_PRODUCT_ID::TEXT as OLD_PRODUCT_ID,
    old_product_name.contract_name as OLD_CONTRACT_NAME,
    shipment_to_contract_mapping_adj.SHIPPED_SERIAL_FORMATTED as SERIAL_FORMATTED
from
    contract_adjustments
left join
    analytics.t3_saas_billing.product_mapping new_product_name
    on contract_adjustments.NEW_PRODUCT_ID = new_product_name.PRODUCT_ID
left join
    analytics.t3_saas_billing.product_mapping old_product_name
    on contract_adjustments.OLD_PRODUCT_ID = old_product_name.PRODUCT_ID
left join
    shipment_to_contract_mapping_adj
    on shipment_to_contract_mapping_adj.SALES_REF_ID = contract_adjustments.SALES_REF_ID
    and shipment_to_contract_mapping_adj.CONTRACT_NAME = new_product_name.CONTRACT_NAME
    and shipment_to_contract_mapping_adj.LINKED_DEVICE_TYPE = contract_adjustments.NEW_LINKED_DEVICE_TYPE
    and shipment_to_contract_mapping_adj.PRODUCT_ID::TEXT = contract_adjustments.NEW_PRODUCT_ID::TEXT
where
    contract_adjustments.BREAKING_BUNDLED_CONTRACT_TRACKER_SERIAL_FORMATTED is null
)

, distinct_hubspot_contract_company as (
select distinct
    SALES_REF_ID::TEXT as SALES_REF_ID,
    COMPANY_ID
from
    analytics.t3_saas_billing.hubspot_contract_data
)

, contract_adjustments_all_serial_numbers as (
select
    ID,
    'CONTRACT ADJUSTMENT' as ADJUSTMENT_TYPE,
    ADJUSTMENT_DATE,
    OLD_PRODUCT_ID,
    OLD_CONTRACT_NAME,
    OLD_LINKED_DEVICE_TYPE,
    OLD_UNIT_COST,
    NEW_PRODUCT_ID,
    NEW_CONTRACT_NAME,
    NEW_LINKED_DEVICE_TYPE,
    NEW_UNIT_COST,
    SERIAL_FORMATTED as ORIGINAL_SERIAL_NUMBER_FORMATTED,
    SERIAL_FORMATTED as NEW_SERIAL_NUMBER_FORMATTED,
    distinct_hubspot_contract_company.COMPANY_ID as OLD_COMPANY_ID,
    distinct_hubspot_contract_company.COMPANY_ID as NEW_COMPANY_ID
from
    contract_adjustments_serials_breaking_bundled_contracts
left join
    distinct_hubspot_contract_company
    on contract_adjustments_serials_breaking_bundled_contracts.SALES_REF_ID = distinct_hubspot_contract_company.SALES_REF_ID
union
select
    ID,
    'CONTRACT ADJUSTMENT' as ADJUSTMENT_TYPE,
    ADJUSTMENT_DATE,
    OLD_PRODUCT_ID,
    OLD_CONTRACT_NAME,
    OLD_LINKED_DEVICE_TYPE,
    OLD_UNIT_COST,
    NEW_PRODUCT_ID,
    NEW_CONTRACT_NAME,
    NEW_LINKED_DEVICE_TYPE,
    NEW_UNIT_COST,
    SERIAL_FORMATTED as ORIGINAL_SERIAL_NUMBER_FORMATTED,
    SERIAL_FORMATTED as NEW_SERIAL_NUMBER_FORMATTED,
    distinct_hubspot_contract_company.COMPANY_ID as OLD_COMPANY_ID,
    distinct_hubspot_contract_company.COMPANY_ID as NEW_COMPANY_ID
from
    contract_adjustments_serials_not_breaking_bundles
left join
    distinct_hubspot_contract_company
    on contract_adjustments_serials_not_breaking_bundles.SALES_REF_ID = distinct_hubspot_contract_company.SALES_REF_ID
)

, devices_adjustments_all_serial_numbers as (
select
    ID,
    ADJUSTMENT_TYPE,
    ADJUSTMENT_DATE,
    null as OLD_PRODUCT_ID,
    null as OLD_CONTRACT_NAME,
    null as OLD_LINKED_DEVICE_TYPE,
    null as OLD_UNIT_COST,
    null as NEW_PRODUCT_ID,
    null as NEW_CONTRACT_NAME,
    null as NEW_LINKED_DEVICE_TYPE,
    null as NEW_UNIT_COST,
    ORIGINAL_SERIAL_NUMBER_FORMATTED,
    NEW_SERIAL_NUMBER_FORMATTED,
    OLD_COMPANY_ID,
    NEW_COMPANY_ID
from
    device_adjustments_first_instance
)

, adjustments_combined_all as (
select
    *,
    CONCAT(ORIGINAL_SERIAL_NUMBER_FORMATTED, ' - ', OLD_COMPANY_ID) as UNIQUE_IDENTIFIER
from
    contract_adjustments_all_serial_numbers
union
select
    *,
    CONCAT(ORIGINAL_SERIAL_NUMBER_FORMATTED, ' - ', OLD_COMPANY_ID) as UNIQUE_IDENTIFIER
from
    devices_adjustments_all_serial_numbers
)

, adjustments_combined_instance as (
select
    *,
    row_number()
            over (partition by UNIQUE_IDENTIFIER order by ADJUSTMENT_DATE)
            as adjustment_instance
from
    adjustments_combined_all
)

, first_adjustment_metadata as (
select
    ID,
    ADJUSTMENT_TYPE,
    ADJUSTMENT_DATE,
    UNIQUE_IDENTIFIER,
    ORIGINAL_SERIAL_NUMBER_FORMATTED,
    NEW_SERIAL_NUMBER_FORMATTED,
    OLD_COMPANY_ID,
    NEW_COMPANY_ID,
    case
        when OLD_PRODUCT_ID is not null then CONCAT('{ OLD_PRODUCT_ID: ', OLD_PRODUCT_ID, ', OLD_CONTRACT_NAME: ', OLD_CONTRACT_NAME, ', OLD_LINKED_DEVICE_TYPE: ', OLD_LINKED_DEVICE_TYPE, ', OLD_UNIT_COST: ', OLD_UNIT_COST, ', NEW_PRODUCT_ID: ', NEW_PRODUCT_ID, ', NEW_CONTRACT_NAME: ', NEW_CONTRACT_NAME, ', NEW_LINKED_DEVICE_TYPE: ', NEW_LINKED_DEVICE_TYPE,  ', NEW_UNIT_COST: ', NEW_UNIT_COST, ', ORIGINAL_SERIAL_NUMBER_FORMATTED: ', ORIGINAL_SERIAL_NUMBER_FORMATTED, ', NEW_SERIAL_NUMBER_FORMATTED: ', NEW_SERIAL_NUMBER_FORMATTED, ', OLD_COMPANY_ID: ', OLD_COMPANY_ID, ', NEW_COMPANY_ID: ', NEW_COMPANY_ID, ', UNIQUE_IDENTIFIER: ', UNIQUE_IDENTIFIER, ', ADJUSTMENT_INSTANCE: ', ADJUSTMENT_INSTANCE, '}')
        when OLD_PRODUCT_ID is null then CONCAT('{ OLD_PRODUCT_ID: ', 'null', ', OLD_CONTRACT_NAME: ',  'null', ', OLD_LINKED_DEVICE_TYPE: ',  'null', ', OLD_UNIT_COST: ',  'null', ', NEW_PRODUCT_ID: ',  'null', ', NEW_CONTRACT_NAME: ',  'null', ', NEW_LINKED_DEVICE_TYPE: ',  'null',  ', NEW_UNIT_COST: ',  'null', ', ORIGINAL_SERIAL_NUMBER_FORMATTED: ', ORIGINAL_SERIAL_NUMBER_FORMATTED, ', NEW_SERIAL_NUMBER_FORMATTED: ', NEW_SERIAL_NUMBER_FORMATTED, ', OLD_COMPANY_ID: ', OLD_COMPANY_ID, ', NEW_COMPANY_ID: ', NEW_COMPANY_ID, ', UNIQUE_IDENTIFIER: ', UNIQUE_IDENTIFIER, ', ADJUSTMENT_INSTANCE: ', ADJUSTMENT_INSTANCE, '}')
    end as FIRST_ADJUSTMENT_METADATA
from
    adjustments_combined_instance
)

-- START DEACTIVATIONS_BILLING_ADJUSTMENTS_WITH_TRANSFERS_SENDING --

, deactivation_billing_adjustments as (
-- DBT MART Deactivation Billing Adjustment Records --
    select
        concat(deacts.SERIAL_FORMATTED,'-', deacts.FK_DEACTIVATION_TICKET_ID,'-', deacts.DEACTIVATION_TYPE) as UNIQUE_IDENTIFIER,
        companies.name as COMPANY_NAME,
        deacts.FK_COMPANY_ID as COMPANY_ID,
        deacts.BUNDLE_TYPE,
        deacts.SERIAL_FORMATTED,
        TO_VARCHAR(deacts.FK_SALES_REF_ID) as SALES_REF_ID,
        deacts.FK_DEACTIVATION_TICKET_ID as DEACTIVATION_TICKET_ID,
        deacts.DEVICE_TYPE,
        deacts.DEACTIVATION_TYPE,
        deacts.DATE_DEACTIVATED as DEACTIVATION_DATE
    from
        financial_systems.t3_saas_silver.stg_analytics_t3_saas_billing__deactivation_billing_adjustments deacts
    left join
        es_warehouse.public.companies companies
        on deacts.FK_COMPANY_ID = companies.COMPANY_ID
)

, device_transfers_to_text as (
-- ALL Device Transfers raw upload table --
select
    SERIAL_FORMATTED,
    SALES_REF_ID::TEXT as SALES_REF_ID,
    LINKED_DEVICE_TYPE,
    SENDING_COMPANY_ID,
    TRANSFER_DATE,
    ID as TRANSFER_ID,
    PRODUCT_ID::TEXT as PRODUCT_ID
from
    ANALYTICS.T3_SAAS_BILLING.DEVICE_TRANSFERS
)

, transfer_sending_deactivations as (
-- Sending Transfers Deactivation --
select
    device_transfers_to_text.SERIAL_FORMATTED,
    device_transfers_to_text.SALES_REF_ID,
    device_transfers_to_text.LINKED_DEVICE_TYPE as DEVICE_TYPE,
    shipment_to_contract_mapping_adj.CONTRACT_NAME as BUNDLE_TYPE, -- Find Transfer out Bundle type --
    device_transfers_to_text.SENDING_COMPANY_ID as COMPANY_ID,
    device_transfers_to_text.TRANSFER_DATE as DEACTIVATION_DATE,
    TRANSFER_ID as DEACTIVATION_TICKET_ID,
    'TRANSFER' as DEACTIVATION_TYPE
from
    device_transfers_to_text
left join
    shipment_to_contract_mapping_adj
    on device_transfers_to_text.SERIAL_FORMATTED = shipment_to_contract_mapping_adj.SHIPPED_SERIAL_FORMATTED
    and device_transfers_to_text.LINKED_DEVICE_TYPE = shipment_to_contract_mapping_adj.LINKED_DEVICE_TYPE
    and device_transfers_to_text.SALES_REF_ID = shipment_to_contract_mapping_adj.SALES_REF_ID
    and device_transfers_to_text.PRODUCT_ID::TEXT = shipment_to_contract_mapping_adj.PRODUCT_ID::TEXT
)

, deactivations as (
select
    SERIAL_FORMATTED,
    SALES_REF_ID,
    DEVICE_TYPE,
    BUNDLE_TYPE,
    COMPANY_ID,
    DEACTIVATION_DATE,
    DEACTIVATION_TICKET_ID,
    DEACTIVATION_TYPE
from
    deactivation_billing_adjustments
union
select
    *
from
    transfer_sending_deactivations
)
-- END DEACTIVATIONS_BILLING_ADJUSTMENTS_WITH_TRANSFERS_SENDING --

-- START IN_SERVICE_INVENTORY with Install Billing LOGIC --
, devices_aggregate as (
-- DBT MART "In Service Inventory" --
    select
        *
    from
        financial_systems.telematics_gold.devices_aggregate
)

, devices_aggregate_install_instance as (
-- Install instance of device (SERIAL NUMBER) onto any asset --
    select
        fk_asset_id,
        fk_company_id,
        pk_assignment_id,
        asset_name,
        serial_number,
        serial_formatted,
        device_type,
        date_installed,
        date_uninstalled,
        --by device serial, identify chronological installation instances
        row_number()
            over (partition by serial_formatted order by date_installed)
            as serial_number_install_instance
    from
        devices_aggregate
)

, asset_customer_associations_first_install as (
-- First installation associated to a particular SERIAL NUMBER - COMPANY ID combination --
select
    FK_COMPANY_ID,
    SERIAL_FORMATTED,
    MIN(SERIAL_NUMBER_INSTALL_INSTANCE) as MIN_SERIAL_NUMBER_INSTALL_INSTANCE
from
    devices_aggregate_install_instance
group by
    FK_COMPANY_ID,
    SERIAL_FORMATTED
)

, asset_customer_associations_last_install as (
-- Last installation associated to a particular SERIAL NUMBER - COMPANY ID combination --
select
    FK_COMPANY_ID,
    SERIAL_FORMATTED,
    MAX(SERIAL_NUMBER_INSTALL_INSTANCE) as MAX_SERIAL_NUMBER_INSTALL_INSTANCE
from
    devices_aggregate_install_instance
group by
    FK_COMPANY_ID,
    SERIAL_FORMATTED
)

, asset_customer_first_associations as (
-- Getting full results from Install instance of device (SERIAL NUMBER) onto any asset but filtered for First installation associated to a particular SERIAL NUMBER - COMPANY ID combination --
select
    devices_aggregate_install_instance.*
from
    devices_aggregate_install_instance
join
    asset_customer_associations_first_install
    on devices_aggregate_install_instance.SERIAL_FORMATTED = asset_customer_associations_first_install.SERIAL_FORMATTED
    and devices_aggregate_install_instance.SERIAL_NUMBER_INSTALL_INSTANCE = asset_customer_associations_first_install.MIN_SERIAL_NUMBER_INSTALL_INSTANCE
    and devices_aggregate_install_instance.FK_COMPANY_ID = asset_customer_associations_first_install.FK_COMPANY_ID
)

, asset_customer_last_associations as (
-- Getting full results from Install instance of device (SERIAL NUMBER) onto any asset but filtered for Last installation associated to a particular SERIAL NUMBER - COMPANY ID combination --
select
    devices_aggregate_install_instance.*
from
    devices_aggregate_install_instance
join
    asset_customer_associations_last_install
    on devices_aggregate_install_instance.SERIAL_FORMATTED = asset_customer_associations_last_install.SERIAL_FORMATTED
    and devices_aggregate_install_instance.SERIAL_NUMBER_INSTALL_INSTANCE = asset_customer_associations_last_install.MAX_SERIAL_NUMBER_INSTALL_INSTANCE
    and devices_aggregate_install_instance.FK_COMPANY_ID = asset_customer_associations_last_install.FK_COMPANY_ID
)

, warehouse_shipment_data_adj_new_billable_units_shipments as (
-- Shipment New Billable Units --
select
    'SHIPMENT' as SHIPMENT_TYPE,
    SHIPPED_SERIAL_FORMATTED as SERIAL_FORMATTED,
    WAREHOUSE_PHYSICAL_DATE as PHYSICAL_DATE,
    WAREHOUSE_PHYSICAL_DATE_PLUS_60,
    SALES_REF_ID,
    LINKED_DEVICE_TYPE,
    ADJ_CURRENT_COMPANY_ID
from
    warehouse_shipment_data_adj
where
    SHIPPED_SERIAL_FORMATTED is not null
and
    DEVICE_FIRST_ADJUSTMENT_TYPE is null
)

, warehouse_shipment_data_adj_new_billable_units_adjustments as (
-- Adjustments New Billable Units --
select
    DEVICE_FIRST_ADJUSTMENT_TYPE as SHIPMENT_TYPE,
    ADJ_CURRENT_SERIAL_FORMATTED as SERIAL_FORMATTED,
    FIRST_ADJUSTMENT_DATE as PHYSICAL_DATE,
    null as WAREHOUSE_PHYSICAL_DATE_PLUS_60,
    SALES_REF_ID,
    LINKED_DEVICE_TYPE,
    ADJ_CURRENT_COMPANY_ID
from
    warehouse_shipment_data_adj
where
    SHIPPED_SERIAL_FORMATTED is not null
and
    DEVICE_FIRST_ADJUSTMENT_TYPE is not null
)

, warehouse_shipment_data_adj_new_billable_units as (
-- All New Billable Units --
select
    *
from
    warehouse_shipment_data_adj_new_billable_units_shipments
union
select
    *
from
    warehouse_shipment_data_adj_new_billable_units_adjustments
)

, contracted_new_billable_units as (
-- New Billable Units (Shipments, Adjustments) with Contracts --
select
    warehouse_shipment_data_adj_new_billable_units.SHIPMENT_TYPE,
    warehouse_shipment_data_adj_new_billable_units.SERIAL_FORMATTED,
    warehouse_shipment_data_adj_new_billable_units.PHYSICAL_DATE,
    warehouse_shipment_data_adj_new_billable_units.WAREHOUSE_PHYSICAL_DATE_PLUS_60,
    warehouse_shipment_data_adj_new_billable_units.ADJ_CURRENT_COMPANY_ID,
    hubspot_contract_data_adj.COMPANY_ID,
    hubspot_contract_data_adj.SALES_REF_ID,
    hubspot_contract_data_adj.PRODUCT_ID,
    hubspot_contract_data_adj.CONTRACT_NAME,
    hubspot_contract_data_adj.LINKED_DEVICE_TYPE,
    hubspot_contract_data_adj.CONTRACT_INSTALL_TYPE,
    hubspot_contract_data_adj.BINARY_CUSTOMER_BILLING_DESIGNATION,
    hubspot_contract_data_adj.CONTRACT_UNIT_COST
from
    warehouse_shipment_data_adj_new_billable_units
left join
    shipment_to_contract_mapping_adj
    on warehouse_shipment_data_adj_new_billable_units.SERIAL_FORMATTED = shipment_to_contract_mapping_adj.SHIPPED_SERIAL_FORMATTED
    and warehouse_shipment_data_adj_new_billable_units.SALES_REF_ID = shipment_to_contract_mapping_adj.SALES_REF_ID
    and warehouse_shipment_data_adj_new_billable_units.LINKED_DEVICE_TYPE = shipment_to_contract_mapping_adj.LINKED_DEVICE_TYPE
left join
    hubspot_contract_data_adj
    on hubspot_contract_data_adj.CONTRACT_NAME = shipment_to_contract_mapping_adj.CONTRACT_NAME
    and hubspot_contract_data_adj.SALES_REF_ID = shipment_to_contract_mapping_adj.SALES_REF_ID
    and hubspot_contract_data_adj.LINKED_DEVICE_TYPE = shipment_to_contract_mapping_adj.LINKED_DEVICE_TYPE
    and hubspot_contract_data_adj.PRODUCT_ID::TEXT = shipment_to_contract_mapping_adj.PRODUCT_ID::TEXT
)

, contracted_billable_units_plus_legacy_tracker_report_not_found_units as (
-- New Billable Units (Shipments, Adjustments) with Contracts and Legacy Tracker Report Dummy Units --
select
    *
from
    contracted_new_billable_units
union
select
    *
from
    legacy_tracker_report_not_found_units_potential_billable_units
)

, contracted_billable_units_first_association as (
-- First installation associated to a particular SERIAL NUMBER - COMPANY ID combination to New Billable Units (Shipments, Adjustments) with Contracts and Legacy Tracker Report Dummy Units --
select
    asset_customer_first_associations.fk_asset_id,
    asset_customer_first_associations.fk_company_id,
    asset_customer_first_associations.pk_assignment_id,
    asset_customer_first_associations.asset_name,
    contracted_billable_units_plus_legacy_tracker_report_not_found_units.serial_formatted,
    asset_customer_first_associations.device_type,
    asset_customer_first_associations.date_installed,
    asset_customer_first_associations.date_uninstalled,
    asset_customer_first_associations.serial_number_install_instance,
    contracted_billable_units_plus_legacy_tracker_report_not_found_units.SHIPMENT_TYPE,
    contracted_billable_units_plus_legacy_tracker_report_not_found_units.PHYSICAL_DATE,
    contracted_billable_units_plus_legacy_tracker_report_not_found_units.WAREHOUSE_PHYSICAL_DATE_PLUS_60,
    case
        when contracted_billable_units_plus_legacy_tracker_report_not_found_units.ADJ_CURRENT_COMPANY_ID is not null then contracted_billable_units_plus_legacy_tracker_report_not_found_units.ADJ_CURRENT_COMPANY_ID
        when contracted_billable_units_plus_legacy_tracker_report_not_found_units.ADJ_CURRENT_COMPANY_ID is null then TRUNC(contracted_billable_units_plus_legacy_tracker_report_not_found_units.COMPANY_ID)
    end as ADJ_CURRENT_COMPANY_ID,
    TRUNC(contracted_billable_units_plus_legacy_tracker_report_not_found_units.COMPANY_ID) as COMPANY_ID,
    contracted_billable_units_plus_legacy_tracker_report_not_found_units.SALES_REF_ID,
    contracted_billable_units_plus_legacy_tracker_report_not_found_units.PRODUCT_ID,
    contracted_billable_units_plus_legacy_tracker_report_not_found_units.CONTRACT_NAME,
    contracted_billable_units_plus_legacy_tracker_report_not_found_units.LINKED_DEVICE_TYPE,
    contracted_billable_units_plus_legacy_tracker_report_not_found_units.CONTRACT_INSTALL_TYPE,
    contracted_billable_units_plus_legacy_tracker_report_not_found_units.BINARY_CUSTOMER_BILLING_DESIGNATION,
    contracted_billable_units_plus_legacy_tracker_report_not_found_units.CONTRACT_UNIT_COST
from
    contracted_billable_units_plus_legacy_tracker_report_not_found_units
left join
    asset_customer_first_associations
    on asset_customer_first_associations.SERIAL_FORMATTED = contracted_billable_units_plus_legacy_tracker_report_not_found_units.SERIAL_FORMATTED
    and asset_customer_first_associations.FK_COMPANY_ID = contracted_billable_units_plus_legacy_tracker_report_not_found_units.COMPANY_ID
)

, install_billing_units_calc_1 as (
-- Install Billing Calculation Logic Step 1. Starting unit count at 1. Shipped also defined at 1 because deacts will recalculate in this section --
select
    *,
    1 as BILL_BY_SHIPPED_UNIT,
    1 as BILL_BY_INSTALL_UNIT
from
    contracted_billable_units_first_association
)

, install_billing_units_calc_3 as (
-- If First association install date is null, change Bill by Install Unit to 0 --
select
    *,
    case
        when DATE_INSTALLED is not null then BILL_BY_INSTALL_UNIT
        when DATE_INSTALLED is null then 0
    end as BILL_BY_INSTALL_UNIT_3
from
    install_billing_units_calc_1
)

, install_billing_units_calc_4 as (
-- Build first part of new terms & conditions logic statement based on install billing calculation taking place 60 days past shipment event --
select
    *,
    case
        when WAREHOUSE_PHYSICAL_DATE_PLUS_60 <= CURRENT_DATE then '60 DAYS EXPIRED'
        when WAREHOUSE_PHYSICAL_DATE_PLUS_60 > CURRENT_DATE then '60 DAY PERIOD'
        when WAREHOUSE_PHYSICAL_DATE_PLUS_60 is null then '60 DAYS EXPIRED'
    end as WAREHOUSE_PHYSICAL_DATE_PLUS_60_BILLING
from
    install_billing_units_calc_3
)

, install_billing_units_calc_5 as (
-- Build second part of new terms & conditions logic statement based on install billing calculation taking place based on Install type on contract --
select
    *,
    case
        when CONTRACT_INSTALL_TYPE = 'ES Install' then concat(WAREHOUSE_PHYSICAL_DATE_PLUS_60_BILLING, ' - ES Install')
        else concat(WAREHOUSE_PHYSICAL_DATE_PLUS_60_BILLING, ' - Self Install')
    end as WAREHOUSE_PHYSICAL_DATE_PLUS_60_BILLING_2
from
    install_billing_units_calc_4
)

, install_billing_units_calc_6 as (
-- Build third part of new terms & conditions logic statement based on install billing calculation being eligible based on terms effective date of April 4, 2026 --
select
    *,
    case
        when PHYSICAL_DATE <= '2026-04-07' then concat(WAREHOUSE_PHYSICAL_DATE_PLUS_60_BILLING_2, ' - INELIGIBLE')
        when PHYSICAL_DATE > '2026-04-07' then concat(WAREHOUSE_PHYSICAL_DATE_PLUS_60_BILLING_2, ' - ELIGIBLE')
        when WAREHOUSE_PHYSICAL_DATE_PLUS_60 is null then concat(WAREHOUSE_PHYSICAL_DATE_PLUS_60_BILLING_2, ' - INELIGIBLE')
    end as WAREHOUSE_PHYSICAL_DATE_PLUS_60_BILLING_3
from
    install_billing_units_calc_5
)

, install_billing_units_calc_7 as (
-- Based on new terms & conditions logic, assign correct bill by install value --
select
    install_billing_units_calc_6.fk_asset_id,
    install_billing_units_calc_6.fk_company_id,
    install_billing_units_calc_6.pk_assignment_id,
    install_billing_units_calc_6.asset_name,
    install_billing_units_calc_6.serial_formatted,
    install_billing_units_calc_6.device_type,
    install_billing_units_calc_6.date_installed,
    install_billing_units_calc_6.date_uninstalled,
    install_billing_units_calc_6.serial_number_install_instance,
    install_billing_units_calc_6.SHIPMENT_TYPE,
    install_billing_units_calc_6.PHYSICAL_DATE,
    install_billing_units_calc_6.WAREHOUSE_PHYSICAL_DATE_PLUS_60,
    install_billing_units_calc_6.ADJ_CURRENT_COMPANY_ID,
    install_billing_units_calc_6.COMPANY_ID,
    install_billing_units_calc_6.SALES_REF_ID,
    install_billing_units_calc_6.PRODUCT_ID,
    install_billing_units_calc_6.CONTRACT_NAME,
    install_billing_units_calc_6.LINKED_DEVICE_TYPE,
    install_billing_units_calc_6.CONTRACT_INSTALL_TYPE,
    install_billing_units_calc_6.BINARY_CUSTOMER_BILLING_DESIGNATION,
    install_billing_units_calc_6.BILL_BY_SHIPPED_UNIT,
    install_billing_units_calc_6.WAREHOUSE_PHYSICAL_DATE_PLUS_60_BILLING_3 as WAREHOUSE_PHYSICAL_DATE_PLUS_60_BILLING,
    install_billing_units_calc_6.CONTRACT_UNIT_COST,
    case
        when install_billing_units_calc_6.WAREHOUSE_PHYSICAL_DATE_PLUS_60_BILLING_3 = '60 DAY PERIOD - ES Install - INELIGIBLE' then install_billing_units_calc_6.BILL_BY_INSTALL_UNIT_3
        when install_billing_units_calc_6.WAREHOUSE_PHYSICAL_DATE_PLUS_60_BILLING_3 = '60 DAY PERIOD - ES Install - ELIGIBLE' then install_billing_units_calc_6.BILL_BY_INSTALL_UNIT_3
        when install_billing_units_calc_6.WAREHOUSE_PHYSICAL_DATE_PLUS_60_BILLING_3 = '60 DAY PERIOD - Self Install - INELIGIBLE' then install_billing_units_calc_6.BILL_BY_INSTALL_UNIT_3
        when install_billing_units_calc_6.WAREHOUSE_PHYSICAL_DATE_PLUS_60_BILLING_3 = '60 DAY PERIOD - Self Install - ELIGIBLE' then 1
        when install_billing_units_calc_6.WAREHOUSE_PHYSICAL_DATE_PLUS_60_BILLING_3 = '60 DAYS EXPIRED - ES Install - INELIGIBLE' then install_billing_units_calc_6.BILL_BY_INSTALL_UNIT_3
        when install_billing_units_calc_6.WAREHOUSE_PHYSICAL_DATE_PLUS_60_BILLING_3 = '60 DAYS EXPIRED - ES Install - ELIGIBLE' then 1
        when install_billing_units_calc_6.WAREHOUSE_PHYSICAL_DATE_PLUS_60_BILLING_3 = '60 DAYS EXPIRED - Self Install - INELIGIBLE' then install_billing_units_calc_6.BILL_BY_INSTALL_UNIT_3
        when install_billing_units_calc_6.WAREHOUSE_PHYSICAL_DATE_PLUS_60_BILLING_3 = '60 DAYS EXPIRED - Self Install - ELIGIBLE' then 1
    end as BILL_BY_INSTALL_UNIT,
from
    install_billing_units_calc_6
)

, install_billing_units_bundled_device_relationships_contracted_trackers_and_cameras as (
select
    FK_ASSET_ID,
    FK_COMPANY_ID,
    PK_ASSIGNMENT_ID,
    SERIAL_FORMATTED,
    DEVICE_TYPE,
    BILL_BY_INSTALL_UNIT,
    COMPANY_ID,
    SALES_REF_ID
from
    install_billing_units_calc_7
where
    CONTRACT_NAME LIKE '%&%'
    and CONTRACT_NAME LIKE '%CAMERA%'
    and DEVICE_TYPE = 'Tracker'
)

, install_billing_units_bundled_device_relationships_contracted_trackers_and_keypads as (
select
    FK_ASSET_ID,
    FK_COMPANY_ID,
    PK_ASSIGNMENT_ID,
    SERIAL_FORMATTED,
    DEVICE_TYPE,
    BILL_BY_INSTALL_UNIT,
    COMPANY_ID,
    SALES_REF_ID
from
    install_billing_units_calc_7
where
    CONTRACT_NAME LIKE '%&%'
    and CONTRACT_NAME LIKE '%KEYPAD%'
    and DEVICE_TYPE = 'Tracker'
)

, install_billing_units_bundled_device_relationships_cameras_min as (
select
    FK_ASSET_ID,
    CONCAT('ACA', MIN(REGEXP_REPLACE(PK_ASSIGNMENT_ID, '[^0-9]', ''))) as MIN_ATTACHMENT_ASSIGNMENT_ID
from
    install_billing_units_calc_7
where
    CONTRACT_NAME LIKE '%&%'
    and CONTRACT_NAME LIKE '%CAMERA%'
    and DEVICE_TYPE = 'Camera'
group by
    FK_ASSET_ID
)

, install_billing_units_bundled_device_relationships_cameras as (
select
    install_billing_units_calc_7.FK_ASSET_ID,
    install_billing_units_calc_7.FK_COMPANY_ID,
    install_billing_units_calc_7.PK_ASSIGNMENT_ID,
    install_billing_units_calc_7.SERIAL_FORMATTED,
    install_billing_units_calc_7.DEVICE_TYPE,
    install_billing_units_calc_7.BILL_BY_INSTALL_UNIT,
    install_billing_units_calc_7.COMPANY_ID,
    install_billing_units_calc_7.SALES_REF_ID
from
    install_billing_units_calc_7
join
    install_billing_units_bundled_device_relationships_cameras_min
    on install_billing_units_calc_7.PK_ASSIGNMENT_ID = MIN_ATTACHMENT_ASSIGNMENT_ID
where
    install_billing_units_calc_7.CONTRACT_NAME LIKE '%&%'
    and install_billing_units_calc_7.CONTRACT_NAME LIKE '%CAMERA%'
    and install_billing_units_calc_7.DEVICE_TYPE = 'Camera'
)

, install_billing_units_bundled_device_relationships_keypads_min as (
select
    FK_ASSET_ID,
    CONCAT('AKA', MIN(REGEXP_REPLACE(PK_ASSIGNMENT_ID, '[^0-9]', ''))) as MIN_ATTACHMENT_ASSIGNMENT_ID
from
    install_billing_units_calc_7
where
    CONTRACT_NAME LIKE '%&%'
    and CONTRACT_NAME LIKE '%KEYPAD%'
    and DEVICE_TYPE = 'Keypad'
group by
    FK_ASSET_ID
)

, install_billing_units_bundled_device_relationships_keypads as (
select
    install_billing_units_calc_7.FK_ASSET_ID,
    install_billing_units_calc_7.FK_COMPANY_ID,
    install_billing_units_calc_7.PK_ASSIGNMENT_ID,
    install_billing_units_calc_7.SERIAL_FORMATTED,
    install_billing_units_calc_7.DEVICE_TYPE,
    install_billing_units_calc_7.BILL_BY_INSTALL_UNIT,
    install_billing_units_calc_7.COMPANY_ID,
    install_billing_units_calc_7.SALES_REF_ID
from
    install_billing_units_calc_7
join
    install_billing_units_bundled_device_relationships_cameras_min
    on install_billing_units_calc_7.PK_ASSIGNMENT_ID = MIN_ATTACHMENT_ASSIGNMENT_ID
where
    install_billing_units_calc_7.CONTRACT_NAME LIKE '%&%'
    and install_billing_units_calc_7.CONTRACT_NAME LIKE '%KEYPAD%'
    and install_billing_units_calc_7.DEVICE_TYPE = 'Keypad'
)

, install_billing_units_bundled_device_relationships_trackers_and_cameras as (
select
    install_billing_units_bundled_device_relationships_contracted_trackers_and_cameras.*,
    install_billing_units_bundled_device_relationships_cameras.DEVICE_TYPE as BUNDLED_DEVICE_TYPE,
    install_billing_units_bundled_device_relationships_cameras.SERIAL_FORMATTED as BUNDLED_DEVICE_FIRST_MARRIED_SERIAL_FORMATTED,
    case
        when install_billing_units_bundled_device_relationships_cameras.SERIAL_FORMATTED is not null then 'BUNDLED AGREEMENT - TRACKER & CAMERA INSTALLED'
        when install_billing_units_bundled_device_relationships_cameras.SERIAL_FORMATTED is null then 'BUNDLED AGREEMENT - TRACKER ONLY INSTALLED'
    end as BUNDLED_DEVICE_INSTALL_RELATIONSHIP
from
    install_billing_units_bundled_device_relationships_contracted_trackers_and_cameras
left join
    install_billing_units_bundled_device_relationships_cameras
    on install_billing_units_bundled_device_relationships_contracted_trackers_and_cameras.fk_asset_id = install_billing_units_bundled_device_relationships_cameras.fk_asset_id
)

, install_billing_units_bundled_device_relationships_trackers_and_keypads as (
select
    install_billing_units_bundled_device_relationships_contracted_trackers_and_keypads.*,
    install_billing_units_bundled_device_relationships_keypads.DEVICE_TYPE as BUNDLED_DEVICE_TYPE,
    install_billing_units_bundled_device_relationships_keypads.SERIAL_FORMATTED as BUNDLED_DEVICE_FIRST_MARRIED_SERIAL_FORMATTED,
    case
        when install_billing_units_bundled_device_relationships_keypads.SERIAL_FORMATTED is not null then 'BUNDLED AGREEMENT - TRACKER & KEYPAD INSTALLED'
        when install_billing_units_bundled_device_relationships_keypads.SERIAL_FORMATTED is null then 'BUNDLED AGREEMENT - TRACKER ONLY INSTALLED'
    end as BUNDLED_DEVICE_INSTALL_RELATIONSHIP
from
    install_billing_units_bundled_device_relationships_contracted_trackers_and_keypads
left join
    install_billing_units_bundled_device_relationships_keypads
    on install_billing_units_bundled_device_relationships_contracted_trackers_and_keypads.fk_asset_id = install_billing_units_bundled_device_relationships_keypads.fk_asset_id
)

, install_billing_units_bundled_device_relationships as (
select
    *
from
    install_billing_units_bundled_device_relationships_trackers_and_cameras
union
select
    *
from
    install_billing_units_bundled_device_relationships_trackers_and_keypads
)

, install_billing_units_calc_final as (
select
    install_billing_units_calc_7.*,
    install_billing_units_bundled_device_relationships.BUNDLED_DEVICE_FIRST_MARRIED_SERIAL_FORMATTED,
    install_billing_units_bundled_device_relationships.BUNDLED_DEVICE_INSTALL_RELATIONSHIP,
from
    install_billing_units_calc_7
left join
    install_billing_units_bundled_device_relationships
    on install_billing_units_calc_7.SERIAL_FORMATTED = install_billing_units_bundled_device_relationships.SERIAL_FORMATTED
    and install_billing_units_calc_7.PK_ASSIGNMENT_ID = install_billing_units_bundled_device_relationships.PK_ASSIGNMENT_ID
)

, install_billing_units_calc_final_with_deacts as (
-- Apply deacts to Bill by Install and Bill by Shipped Counts --
select
    concat(install_billing_units_calc_final.SERIAL_FORMATTED, ' - ', install_billing_units_calc_final.COMPANY_ID) as UNIQUE_IDENTIFIER,
    install_billing_units_calc_final.SHIPMENT_TYPE,
    install_billing_units_calc_final.PHYSICAL_DATE,
    install_billing_units_calc_final.WAREHOUSE_PHYSICAL_DATE_PLUS_60,
    install_billing_units_calc_final.ADJ_CURRENT_COMPANY_ID,
    install_billing_units_calc_final.COMPANY_ID,
    install_billing_units_calc_final.SALES_REF_ID,
    install_billing_units_calc_final.PRODUCT_ID,
    install_billing_units_calc_final.CONTRACT_NAME,
    install_billing_units_calc_final.LINKED_DEVICE_TYPE,
    install_billing_units_calc_final.CONTRACT_INSTALL_TYPE,
    install_billing_units_calc_final.SERIAL_FORMATTED as DEVICE_SERIAL,
    first_adjustment_metadata.ID as FIRST_ADJUSTMENT_ID,
    first_adjustment_metadata.ADJUSTMENT_TYPE as FIRST_ADJUSTMENT_TYPE,
    first_adjustment_metadata.ADJUSTMENT_DATE as FIRST_ADJUSTMENT_DATE,
    first_adjustment_metadata.FIRST_ADJUSTMENT_METADATA,
    install_billing_units_calc_final.fk_company_id as FIRST_INSTALL_COMPANY_ID,
    install_billing_units_calc_final.fk_asset_id as FIRST_INSTALL_ASSET_ID,
    install_billing_units_calc_final.pk_assignment_id as FIRST_INSTALL_ASSIGNMENT_ID,
    install_billing_units_calc_final.date_installed as IN_SERVICE_DATE,
    install_billing_units_calc_final.BUNDLED_DEVICE_FIRST_MARRIED_SERIAL_FORMATTED,
    install_billing_units_calc_final.BUNDLED_DEVICE_INSTALL_RELATIONSHIP,
    asset_customer_last_associations.fk_company_id as LAST_INSTALL_COMPANY_ID,
    asset_customer_last_associations.fk_asset_id as LAST_INSTALL_ASSET_ID,
    asset_customer_last_associations.pk_assignment_id as LAST_INSTALL_ASSIGNMENT_ID,
    asset_customer_last_associations.date_uninstalled as END_SERVICE_DATE,
    deactivations.DEACTIVATION_DATE::DATE as DEACTIVATION_DATE,
    deactivations.DEACTIVATION_TICKET_ID::TEXT as DEACTIVATION_TICKET_ID,
    deactivations.DEACTIVATION_TYPE::TEXT as DEACTIVATION_TYPE,
    install_billing_units_calc_final.BINARY_CUSTOMER_BILLING_DESIGNATION,
    install_billing_units_calc_final.WAREHOUSE_PHYSICAL_DATE_PLUS_60_BILLING,
    install_billing_units_calc_final.CONTRACT_UNIT_COST,
    case
        when deactivations.DEACTIVATION_DATE is not null then 0
        when deactivations.DEACTIVATION_DATE is null then BILL_BY_INSTALL_UNIT
        when first_adjustment_metadata.ADJUSTMENT_TYPE in ('RMA', 'TRANSFER') then BILL_BY_SHIPPED_UNIT
    end as BILL_BY_INSTALL_UNIT,
    case
        when deactivations.DEACTIVATION_DATE is not null then 0
        when deactivations.DEACTIVATION_DATE is null then BILL_BY_SHIPPED_UNIT
    end as BILL_BY_SHIPPED_UNIT,
    case
        when deactivations.DEACTIVATION_DATE is not null then 1
        when deactivations.DEACTIVATION_DATE is null then 0
    end as DEACTIVATED_UNIT
from
    install_billing_units_calc_final
left join
    asset_customer_last_associations
    on install_billing_units_calc_final.SERIAL_FORMATTED = asset_customer_last_associations.SERIAL_FORMATTED
    and install_billing_units_calc_final.fk_company_id = asset_customer_last_associations.FK_COMPANY_ID
left join
    first_adjustment_metadata
    on install_billing_units_calc_final.SERIAL_FORMATTED = first_adjustment_metadata.NEW_SERIAL_NUMBER_FORMATTED
    and install_billing_units_calc_final.COMPANY_ID = first_adjustment_metadata.NEW_COMPANY_ID
left join
    deactivations
    on install_billing_units_calc_final.SERIAL_FORMATTED = deactivations.SERIAL_FORMATTED
    and install_billing_units_calc_final.SALES_REF_ID = deactivations.SALES_REF_ID
    and install_billing_units_calc_final.LINKED_DEVICE_TYPE = deactivations.DEVICE_TYPE
    and install_billing_units_calc_final.CONTRACT_NAME = deactivations.BUNDLE_TYPE
    and install_billing_units_calc_final.COMPANY_ID = deactivations.COMPANY_ID
)

, in_service_inventory_adj as (
select
    *,
    case
        when BINARY_CUSTOMER_BILLING_DESIGNATION = 'Invoice Shipped Units' then BILL_BY_SHIPPED_UNIT
        when BINARY_CUSTOMER_BILLING_DESIGNATION = 'Invoice Installed Units' then BILL_BY_INSTALL_UNIT
    end as BINARY_BILLING_UNIT
from
    install_billing_units_calc_final_with_deacts
)
-- END IN_SERVICE_INVENTORY with Install Billing LOGIC --

-- START BILLING SHEET LOGIC --
, non_serialized_contracts_in_service_inventory_adj as (
select
    null as UNIQUE_IDENTIFIER,
    null as SHIPMENT_TYPE,
    CONTRACT_CLOSE_DATE as PHYSICAL_DATE,
    null as WAREHOUSE_PHYSICAL_DATE_PLUS_60,
    TRUNC(COMPANY_ID) as ADJ_CURRENT_COMPANY_ID,
    TRUNC(COMPANY_ID) as COMPANY_ID,
    SALES_REF_ID,
    PRODUCT_ID,
    CONTRACT_NAME,
    LINKED_DEVICE_TYPE,
    CONTRACT_INSTALL_TYPE,
    null as DEVICE_SERIAL,
    FIRST_ADJUSTMENT_ID,
    null as FIRST_ADJUSTMENT_TYPE,
    FIRST_ADJUSTMENT_DATE,
    null as FIRST_ADJUSTMENT_METADATA,
    null as FIRST_INSTALL_COMPANY_ID,
    null as FIRST_INSTALL_ASSET_ID,
    null as FIRST_INSTALL_ASSIGNMENT_ID,
    null as IN_SERVICE_DATE,
    null as BUNDLED_DEVICE_FIRST_MARRIED_SERIAL_FORMATTED,
    null as BUNDLED_DEVICE_INSTALL_RELATIONSHIP,
    null as LAST_INSTALL_COMPANY_ID,
    null as LAST_INSTALL_ASSET_ID,
    null as LAST_INSTALL_ASSIGNMENT_ID,
    null as END_SERVICE_DATE,
    null as DEACTIVATION_DATE,
    null as DEACTIVATION_TICKET_ID,
    null as DEACTIVATION_TYPE,
    BINARY_CUSTOMER_BILLING_DESIGNATION,
    null as WAREHOUSE_PHYSICAL_DATE_PLUS_60_BILLING,
    CONTRACT_UNIT_COST,
    0 as BILL_BY_INSTALL_UNIT,
    CONTRACT_QUANTITY as BILL_BY_SHIPPED_UNIT,
    1 as BINARY_BILLING_UNIT,
    0 as DEACTIVATED_UNIT
from
    hubspot_contract_data_adj
where
    CONTRACT_NAME like '%UPGRADE'
)

, in_service_inventory_adj_plus_non_serialized_contracts as (
select
    *
from
    in_service_inventory_adj
union
select
    *
from
    non_serialized_contracts_in_service_inventory_adj
)


, billing_sheet_sums as (
select
    COMPANY_ID,
    null as COMPANY_NAME,
    null as AUTO_BILLING_STATUS,
    null as CUSTOMER_BILLING_STATUS,
    null as SHIP_TO_LOCATION_ID,
    CONTRACT_NAME,
    CONTRACT_UNIT_COST,
    BINARY_CUSTOMER_BILLING_DESIGNATION as SUBSCRIPTION_AGREEMENT,
    sum(BILL_BY_SHIPPED_UNIT) as SHIPPED_UNITS,
    sum(BILL_BY_INSTALL_UNIT) as INSTALLED_UNITS,
    sum(BINARY_BILLING_UNIT) as BILLING_UNITS
from
    in_service_inventory_adj_plus_non_serialized_contracts
group by
    COMPANY_ID,
    CONTRACT_NAME,
    CONTRACT_UNIT_COST,
    BINARY_CUSTOMER_BILLING_DESIGNATION
)

, billing_sheet_MRR as (
select
    billing_sheet_sums.COMPANY_ID,
    customer_master.COMPANY_NAME,
    customer_master.AUTO_BILLING_STATUS,
    customer_master.CUSTOMER_BILLING_STATUS,
    customer_master.FK_SHIP_TO_LOCATION_ID,
    billing_sheet_sums.CONTRACT_NAME,
    billing_sheet_sums.CONTRACT_UNIT_COST,
    billing_sheet_sums.SUBSCRIPTION_AGREEMENT,
    billing_sheet_sums.SHIPPED_UNITS,
    billing_sheet_sums.INSTALLED_UNITS,
    billing_sheet_sums.BILLING_UNITS
from
    billing_sheet_sums
left join
    financial_systems.t3_saas_gold.customer_master
    on billing_sheet_sums.COMPANY_ID = customer_master.PK_COMPANY_ID
)

-- , billing_sheet_adj as (
-- take billing_sheet_MRR and plug in revenue schedules
-- )
-- END BILLING_SHEET LOGIC --

-- START TRACKER_REPORT_V2 LOGIC --
, hubspot_deal_to_company as (
select distinct
    SALES_REF_ID::TEXT as SALES_REF_ID,
    COMPANY_ID,
    CONTRACT_CLOSE_DATE
from
    hubspot_contract_data_adj
)

, hubspot_deal_to_company_deal_instance as (
select
    hubspot_deal_to_company.*,
    row_number()
            over (partition by COMPANY_ID order by CONTRACT_CLOSE_DATE)
            as DEAL_INSTANCE
from
    hubspot_deal_to_company
)

, shipment_to_contract_mapping_adj_with_company as (
select
    shipment_to_contract_mapping_adj.*,
    hubspot_deal_to_company_deal_instance.COMPANY_ID,
    hubspot_deal_to_company_deal_instance.DEAL_INSTANCE
from
    shipment_to_contract_mapping_adj
left join
    hubspot_deal_to_company_deal_instance
    on shipment_to_contract_mapping_adj.SALES_REF_ID = hubspot_deal_to_company_deal_instance.SALES_REF_ID
)

, legacy_tracker_report_dups as (
select
    legacy_tracker_report.DEVICE_SERIAL as LTR_DEVICE_SERIAL,
    shipment_to_contract_mapping_adj_with_company.*
from
    legacy_tracker_report
left join
    shipment_to_contract_mapping_adj_with_company
    on legacy_tracker_report.DEVICE_SERIAL = shipment_to_contract_mapping_adj_with_company.SHIPPED_SERIAL_FORMATTED
    and legacy_tracker_report.COMPANY_ID = shipment_to_contract_mapping_adj_with_company.COMPANY_ID
where
    legacy_tracker_report.COMPANY_ID <> '1854'
)

, legacy_tracker_report_dup_max_instance as (
select
    LTR_DEVICE_SERIAL,
    max(DEAL_INSTANCE) as MAX_DEAL_INSTANCE
from
    legacy_tracker_report_dups
group by
    LTR_DEVICE_SERIAL
)

, legacy_tracker_report_v2_mapping as (
select
    legacy_tracker_report_dups.LTR_DEVICE_SERIAL,
    legacy_tracker_report_dups.SALES_REF_ID,
    legacy_tracker_report_dups.SHIPPED_SERIAL_FORMATTED,
    legacy_tracker_report_dups.CONTRACT_NAME,
    legacy_tracker_report_dups.LINKED_DEVICE_TYPE,
    legacy_tracker_report_dups.PRODUCT_ID,
    legacy_tracker_report_dups.COMPANY_ID,
    legacy_tracker_report_dups.DEAL_INSTANCE
from
    legacy_tracker_report_dups
join
    legacy_tracker_report_dup_max_instance
    on legacy_tracker_report_dups.LTR_DEVICE_SERIAL = legacy_tracker_report_dup_max_instance.LTR_DEVICE_SERIAL
    and legacy_tracker_report_dups.DEAL_INSTANCE = legacy_tracker_report_dup_max_instance.MAX_DEAL_INSTANCE
)

, legacy_tracker_report_mapped as (
select
    legacy_tracker_report.DEVICE_SERIAL,
    legacy_tracker_report.VENDOR,
    legacy_tracker_report.CONFIG,
    legacy_tracker_report.STATUS,
    legacy_tracker_report.VERSION,
    legacy_tracker_report.TRACKER_PHONE,
    legacy_tracker_report.ASSET_NAME,
    legacy_tracker_report.COMPANY_ID,
    legacy_tracker_report.COMPANY,
    legacy_tracker_report.EMAIL,
    legacy_tracker_report.OWNER,
    legacy_tracker_report.PHONE,
    legacy_tracker_report.FIRMWARE,
    legacy_tracker_report.ASSET_TYPE,
    legacy_tracker_report.KEYPAD_SERIAL,
    legacy_tracker_report.CAMERA_SERIAL,
    legacy_tracker_report.CAMERA_VENDOR,
    legacy_tracker_report_v2_mapping.SALES_REF_ID,
    legacy_tracker_report_v2_mapping.SHIPPED_SERIAL_FORMATTED,
    legacy_tracker_report_v2_mapping.LINKED_DEVICE_TYPE,
    legacy_tracker_report_v2_mapping.CONTRACT_NAME,
    legacy_tracker_report_v2_mapping.PRODUCT_ID
from
    legacy_tracker_report
left join
    legacy_tracker_report_v2_mapping
    on legacy_tracker_report.DEVICE_SERIAL = legacy_tracker_report_v2_mapping.LTR_DEVICE_SERIAL
)

, legacy_tracker_report_v2 as (
select distinct
    legacy_tracker_report_mapped.DEVICE_SERIAL,
    legacy_tracker_report_mapped.VENDOR,
    legacy_tracker_report_mapped.CONFIG,
    legacy_tracker_report_mapped.STATUS,
    legacy_tracker_report_mapped.VERSION,
    legacy_tracker_report_mapped.TRACKER_PHONE,
    legacy_tracker_report_mapped.ASSET_NAME,
    legacy_tracker_report_mapped.COMPANY_ID,
    legacy_tracker_report_mapped.COMPANY,
    legacy_tracker_report_mapped.EMAIL,
    legacy_tracker_report_mapped.OWNER,
    legacy_tracker_report_mapped.PHONE,
    legacy_tracker_report_mapped.FIRMWARE,
    legacy_tracker_report_mapped.ASSET_TYPE,
    legacy_tracker_report_mapped.KEYPAD_SERIAL,
    legacy_tracker_report_mapped.CAMERA_SERIAL,
    legacy_tracker_report_mapped.CAMERA_VENDOR,
    legacy_tracker_report_mapped.SALES_REF_ID,
    legacy_tracker_report_mapped.SHIPPED_SERIAL_FORMATTED,
    legacy_tracker_report_mapped.LINKED_DEVICE_TYPE,
    legacy_tracker_report_mapped.CONTRACT_NAME,
    legacy_tracker_report_mapped.PRODUCT_ID,
    hubspot_contract_data_adj.CONTRACT_UNIT_COST,
    hubspot_contract_data_adj.CONTRACT_CLOSE_DATE
from
    legacy_tracker_report_mapped
left join
    hubspot_contract_data_adj
    on legacy_tracker_report_mapped.SALES_REF_ID = hubspot_contract_data_adj.SALES_REF_ID
    and legacy_tracker_report_mapped.PRODUCT_ID = hubspot_contract_data_adj.PRODUCT_ID
    and legacy_tracker_report_mapped.CONTRACT_NAME = hubspot_contract_data_adj.CONTRACT_NAME
    and legacy_tracker_report_mapped.LINKED_DEVICE_TYPE = hubspot_contract_data_adj.LINKED_DEVICE_TYPE
    and legacy_tracker_report_mapped.COMPANY_ID = hubspot_contract_data_adj.COMPANY_ID
)
-- END TRACKER_REPORT_V2 LOGIC --


-- Looker: in_service_inventory_adj
select
    UNIQUE_IDENTIFIER,
    SHIPMENT_TYPE,
    PHYSICAL_DATE,
    WAREHOUSE_PHYSICAL_DATE_PLUS_60,
    ADJ_CURRENT_COMPANY_ID,
    COMPANY_ID,
    SALES_REF_ID,
    PRODUCT_ID,
    CONTRACT_NAME,
    LINKED_DEVICE_TYPE,
    CONTRACT_INSTALL_TYPE,
    DEVICE_SERIAL,
    FIRST_ADJUSTMENT_ID,
    FIRST_ADJUSTMENT_TYPE,
    FIRST_ADJUSTMENT_DATE,
    FIRST_ADJUSTMENT_METADATA,
    FIRST_INSTALL_COMPANY_ID,
    FIRST_INSTALL_ASSET_ID,
    FIRST_INSTALL_ASSIGNMENT_ID,
    IN_SERVICE_DATE,
    BUNDLED_DEVICE_FIRST_MARRIED_SERIAL_FORMATTED,
    BUNDLED_DEVICE_INSTALL_RELATIONSHIP,
    LAST_INSTALL_COMPANY_ID,
    LAST_INSTALL_ASSET_ID,
    LAST_INSTALL_ASSIGNMENT_ID,
    END_SERVICE_DATE,
    DEACTIVATION_DATE,
    DEACTIVATION_TICKET_ID,
    DEACTIVATION_TYPE,
    BINARY_CUSTOMER_BILLING_DESIGNATION,
    WAREHOUSE_PHYSICAL_DATE_PLUS_60_BILLING,
    CONTRACT_UNIT_COST,
    BILL_BY_INSTALL_UNIT,
    BILL_BY_SHIPPED_UNIT,
    DEACTIVATED_UNIT,
    BINARY_BILLING_UNIT
from
    in_service_inventory_adj

      ;;
  }

  dimension: UNIQUE_IDENTIFIER {
    type: string
    sql: ${TABLE}.UNIQUE_IDENTIFIER ;;
    primary_key: yes
  }

  dimension: DEVICE_SERIAL {
    type: string
    sql: ${TABLE}.DEVICE_SERIAL ;;
  }

  dimension: DEVICE_TYPE {
    type: string
    sql: ${TABLE}.LINKED_DEVICE_TYPE  ;;
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

  dimension: DEACTIVATION_TICKET_ID {
    type: string
    sql: ${TABLE}.DEACTIVATION_TICKET_ID  ;;
  }

  dimension: DEACTIVATION_TYPE {
    type: string
    sql: ${TABLE}.DEACTIVATION_TYPE  ;;
  }

  dimension: DEACTIVATION_DATE {
    type: date
    sql: ${TABLE}.DEACTIVATION_DATE  ;;
  }

  dimension: BILL_BY_INSTALL_UNIT {
    type: number
    sql: ${TABLE}.BILL_BY_INSTALL_UNIT  ;;
  }

  dimension: WAREHOUSE_PHYSICAL_DATE_PLUS_60_BILLING {
    type: string
    sql: ${TABLE}.WAREHOUSE_PHYSICAL_DATE_PLUS_60_BILLING  ;;
  }

  dimension: BINARY_CUSTOMER_BILLING_DESIGNATION {
    type: string
    sql: ${TABLE}.BINARY_CUSTOMER_BILLING_DESIGNATION  ;;
  }

  dimension: SHIPMENT_TYPE {
    type: string
    sql: ${TABLE}.SHIPMENT_TYPE  ;;
  }

  dimension: PHYSICAL_DATE {
    type: date
    sql: ${TABLE}.PHYSICAL_DATE  ;;
  }

  dimension: WAREHOUSE_PHYSICAL_DATE_PLUS_60 {
    type: date
    sql: ${TABLE}.WAREHOUSE_PHYSICAL_DATE_PLUS_60  ;;
  }

  dimension: ADJ_CURRENT_COMPANY_ID {
    type: string
    sql: ${TABLE}.ADJ_CURRENT_COMPANY_ID  ;;
  }

  dimension: COMPANY_ID {
    type: string
    sql: ${TABLE}.COMPANY_ID  ;;
  }

  dimension: SALES_REF_ID {
    type: string
    sql: ${TABLE}.SALES_REF_ID  ;;
  }

  dimension: PRODUCT_ID {
    type: string
    sql: ${TABLE}.PRODUCT_ID  ;;
  }

  dimension: CONTRACT_NAME {
    type: string
    sql: ${TABLE}.CONTRACT_NAME  ;;
  }

  dimension: CONTRACT_INSTALL_TYPE {
    type: string
    sql: ${TABLE}.CONTRACT_INSTALL_TYPE  ;;
  }

  dimension: FIRST_ADJUSTMENT_ID {
    type: string
    sql: ${TABLE}.FIRST_ADJUSTMENT_ID  ;;
  }

  dimension: FIRST_ADJUSTMENT_TYPE {
    type: string
    sql: ${TABLE}.FIRST_ADJUSTMENT_TYPE  ;;
  }

  dimension: FIRST_ADJUSTMENT_DATE {
    type: date
    sql: ${TABLE}.FIRST_ADJUSTMENT_DATE  ;;
  }

  dimension: FIRST_ADJUSTMENT_METADATA {
    type: string
    sql: ${TABLE}.FIRST_ADJUSTMENT_METADATA  ;;
  }

  dimension: BUNDLED_DEVICE_FIRST_MARRIED_SERIAL_FORMATTED {
    type: string
    sql: ${TABLE}.BUNDLED_DEVICE_FIRST_MARRIED_SERIAL_FORMATTED  ;;
  }

  dimension: BUNDLED_DEVICE_INSTALL_RELATIONSHIP {
    type: string
    sql: ${TABLE}.BUNDLED_DEVICE_INSTALL_RELATIONSHIP  ;;
  }

  dimension: CONTRACT_UNIT_COST {
    type: number
    sql: ${TABLE}.CONTRACT_UNIT_COST  ;;
  }

  dimension: BILL_BY_SHIPPED_UNIT {
    type: number
    sql: ${TABLE}.BILL_BY_SHIPPED_UNIT  ;;
  }

  dimension: DEACTIVATED_UNIT {
    type: number
    sql: ${TABLE}.DEACTIVATED_UNIT  ;;
  }

  dimension: BINARY_BILLING_UNIT {
    type: number
    sql: ${TABLE}.BINARY_BILLING_UNIT  ;;
  }

}
