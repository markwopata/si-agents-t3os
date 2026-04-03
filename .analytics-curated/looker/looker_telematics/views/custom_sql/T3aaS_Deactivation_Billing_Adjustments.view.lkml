view: T3aaS_Deactivation_Billing_Adjustments {
  derived_table: {
    sql:

with warehouse_shipment_data_dbt as (
select
    SN_UNIQUE_IDENTIFIER,
    SN_UNIQUE_IDENTIFIER as DYNAMIC_INDEX,
    LINKED_DEVICE_TYPE,
    PART_DESCRIPTION,
    SHIPPED_SERIAL_NUMBER::TEXT as SHIPPED_SERIAL_NUMBER,
    SHIPPED_SERIAL_FORMATTED::TEXT as SHIPPED_SERIAL_FORMATTED,
    WAREHOUSE_PHYSICAL_DATE,
    WAREHOUSE_REQUESTED_SHIP_DATE,
    INVOICE_LINE_SUM,
    INVOICE_SALES_PRICE,
    INVOICE_ID,
    SALES_ORDER_NUMBER,
    FK_SALES_REF_ID as SALES_REF_ID,
    TO_VARCHAR(COMPANY_NAME_WHS) as COMPANY_NAME_WHS,
    SERIAL_NUMBER_SHIPPED_INSTANCE,
    HUBSPOT_PIPELINE,
    1 as BILL_BY_SHIPPED_UNIT,
    DATE_DEACTIVATED as DEACTIVATION_DATE,
    FK_DEACTIVATION_TICKET_ID as DEACTIVATION_TICKET_ID
from
    financial_systems.t3_saas_gold.warehouse_shipment_data
)

, device_adjustments_first_instance as (
select
    ID as ID,
    'RMA' as ADJUSTMENT_TYPE,
    ORIGINAL_SERIAL_NUMBER_FORMATTED::TEXT as ORIGINAL_SERIAL_NUMBER_FORMATTED,
    NEW_SERIAL_NUMBER_FORMATTED::TEXT as NEW_SERIAL_NUMBER_FORMATTED,
    REPLACEMENT_DATE as ADJUSTMENT_DATE,
    COMPANY_ID as OLD_COMPANY_ID,
    COMPANY_ID as NEW_COMPANY_ID,
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
select
    warehouse_shipment_data_dbt.SN_UNIQUE_IDENTIFIER::TEXT as SN_UNIQUE_IDENTIFIER,
    warehouse_shipment_data_dbt.DYNAMIC_INDEX::TEXT as DYNAMIC_INDEX,
    warehouse_shipment_data_dbt.LINKED_DEVICE_TYPE,
    warehouse_shipment_data_dbt.PART_DESCRIPTION,
    warehouse_shipment_data_dbt.SHIPPED_SERIAL_NUMBER,
    warehouse_shipment_data_dbt.SHIPPED_SERIAL_FORMATTED,
    warehouse_shipment_data_dbt.WAREHOUSE_PHYSICAL_DATE,
    warehouse_shipment_data_dbt.WAREHOUSE_PHYSICAL_DATE + 60 as WAREHOUSE_PHYSICAL_DATE_PLUS_60,
    warehouse_shipment_data_dbt.WAREHOUSE_REQUESTED_SHIP_DATE,
    warehouse_shipment_data_dbt.INVOICE_LINE_SUM,
    warehouse_shipment_data_dbt.INVOICE_SALES_PRICE,
    warehouse_shipment_data_dbt.INVOICE_ID,
    warehouse_shipment_data_dbt.SALES_ORDER_NUMBER,
    warehouse_shipment_data_dbt.SALES_REF_ID,
    warehouse_shipment_data_dbt.COMPANY_NAME_WHS,
    warehouse_shipment_data_dbt.SERIAL_NUMBER_SHIPPED_INSTANCE::TEXT as HUBSPOT_PIPELINE,
    warehouse_shipment_data_dbt.HUBSPOT_PIPELINE::TEXT as HUBSPOT_PIPELINE,
    warehouse_shipment_data_dbt.BILL_BY_SHIPPED_UNIT,
    case
        when device_adjustments_first_instance.NEW_SERIAL_NUMBER_FORMATTED is not null then device_adjustments_first_instance.ADJUSTMENT_TYPE
        when device_adjustments_first_instance.NEW_SERIAL_NUMBER_FORMATTED is null then null
    end as DEVICE_FIRST_ADJUSTMENT_TYPE,
    case
        when device_adjustments_first_instance.NEW_SERIAL_NUMBER_FORMATTED is not null then device_adjustments_first_instance.ORIGINAL_SERIAL_NUMBER_FORMATTED
        when device_adjustments_first_instance.NEW_SERIAL_NUMBER_FORMATTED is null then null
    end as DEVICE_FIRST_ADJUSTMENT_OLD_SERIAL_NUMBER_FORMATTED,
    case
        when device_adjustments_first_instance.NEW_SERIAL_NUMBER_FORMATTED is not null then device_adjustments_first_instance.NEW_SERIAL_NUMBER_FORMATTED
        when device_adjustments_first_instance.NEW_SERIAL_NUMBER_FORMATTED is null then null
    end as DEVICE_FIRST_ADJUSTMENT_NEW_SERIAL_FORMATTED,
    case
        when device_adjustments_first_instance.NEW_SERIAL_NUMBER_FORMATTED is not null then device_adjustments_first_instance.OLD_COMPANY_ID
        when device_adjustments_first_instance.NEW_SERIAL_NUMBER_FORMATTED is null then null
    end as DEVICE_FIRST_ADJUSTMENT_OLD_COMPANY_ID,
    case
        when device_adjustments_first_instance.NEW_SERIAL_NUMBER_FORMATTED is not null then device_adjustments_first_instance.NEW_COMPANY_ID
        when device_adjustments_first_instance.NEW_SERIAL_NUMBER_FORMATTED is null then null
    end as DEVICE_FIRST_ADJUSTMENT_NEW_COMPANY_ID,
    case
        when device_adjustments_first_instance.NEW_SERIAL_NUMBER_FORMATTED is not null then device_adjustments_first_instance.NEW_SERIAL_NUMBER_FORMATTED
        when device_adjustments_first_instance.NEW_SERIAL_NUMBER_FORMATTED is null then null
    end as DEVICE_FIRST_ADJUSTMENT_DATE,
    case
        when device_adjustments_first_instance.NEW_SERIAL_NUMBER_FORMATTED is not null then device_adjustments_first_instance.NEW_SERIAL_NUMBER_FORMATTED
        when device_adjustments_first_instance.NEW_SERIAL_NUMBER_FORMATTED is null then warehouse_shipment_data_dbt.SHIPPED_SERIAL_FORMATTED
    end as ADJ_CURRENT_SERIAL_FORMATTED,
    case
        when device_adjustments_first_instance.NEW_COMPANY_ID is not null then device_adjustments_first_instance.NEW_COMPANY_ID
        when device_adjustments_first_instance.NEW_COMPANY_ID is null then null
    end as ADJ_CURRENT_COMPANY_ID
from
    warehouse_shipment_data_dbt
left join
    device_adjustments_first_instance
    on warehouse_shipment_data_dbt.SHIPPED_SERIAL_FORMATTED = device_adjustments_first_instance.ORIGINAL_SERIAL_NUMBER_FORMATTED
)

-- START HUBSPOT_CONTRACT_DATA PULL--
, hubspot_contract_data_adj_dbt as (
select
    FK_COMPANY_ID::TEXT as COMPANY_ID,
    TO_VARCHAR(COMPANY_NAME) as COMPANY_NAME,
    FK_SALES_REF_ID::TEXT as SALES_REF_ID,
    FK_PRODUCT_ID::TEXT as PRODUCT_ID,
    CONTRACT_NAME,
    LINKED_DEVICE_TYPE,
    QTY_CONTRACTED as QUANTITY,
    MRR_CONTRACTED as CONTRACT_MRR,
    UNIT_COST_CONTRACTED as CONTRACT_UNIT_COST,
    DATE_CONTRACT_CLOSE as CONTRACT_CLOSE_DATE,
    CONTRACT_TERMS_IN_MONTHS,
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
    BINARY_CUSTOMER_BILLING_DESIGNATION,
from
    financial_systems.t3_saas_gold.hubspot_contract_data_adj
)

-- just need transfer ins, transfer outs need to be applied as deacts on the shipment, mapping, and isi side of things
-- adj 1 date
-- adj 2 date
-- etc


, receiving_transfers_totals as (
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
select
    receiving_transfers_contracts.COMPANY_ID as COMPANY_ID,
    TO_VARCHAR(hubspot_contract_data_adj_dbt.COMPANY_NAME) as COMPANY_NAME,
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
select
    receiving_transfer_contracts_full.COMPANY_ID,
    receiving_transfer_contracts_full.SALES_REF_ID,
    receiving_transfer_contracts_full.PRODUCT_ID,
    receiving_transfer_contracts_full.CONTRACT_NAME,
    receiving_transfer_contracts_full.LINKED_DEVICE_TYPE,
    receiving_transfer_contracts_full.CONTRACT_INSTALL_TYPE,
    receiving_transfer_contracts_full.BINARY_CUSTOMER_BILLING_DESIGNATION
from
    receiving_transfer_contracts_full
union
select
    hubspot_contract_data_adj_dbt.COMPANY_ID,
    hubspot_contract_data_adj_dbt.SALES_REF_ID,
    hubspot_contract_data_adj_dbt.PRODUCT_ID,
    hubspot_contract_data_adj_dbt.CONTRACT_NAME,
    hubspot_contract_data_adj_dbt.LINKED_DEVICE_TYPE,
    hubspot_contract_data_adj_dbt.CONTRACT_INSTALL_TYPE,
    hubspot_contract_data_adj_dbt.BINARY_CUSTOMER_BILLING_DESIGNATION
from
    hubspot_contract_data_adj_dbt
)

, tracker_type_mapping as (
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
select
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
    TO_VARCHAR(legacy_tracker_report.company) as COMPANY_NAME_WHS,
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

, adj_transfer_shipment_to_contract_mapping as (
select
    hubspot_contract_data_adj.SALES_REF_ID::TEXT as SALES_REF_ID,
    warehouse_shipment_data_adj.ADJ_CURRENT_SERIAL_FORMATTED as SHIPPED_SERIAL_FORMATTED,
    hubspot_contract_data_adj.CONTRACT_NAME,
    hubspot_contract_data_adj.LINKED_DEVICE_TYPE
from
    warehouse_shipment_data_adj
left join
    hubspot_contract_data_adj
    on hubspot_contract_data_adj.SALES_REF_ID = warehouse_shipment_data_adj.SALES_REF_ID
    and hubspot_contract_data_adj.LINKED_DEVICE_TYPE = warehouse_shipment_data_adj.LINKED_DEVICE_TYPE
where
    warehouse_shipment_data_adj.DEVICE_FIRST_ADJUSTMENT_TYPE in ('RMA', 'TRANSFER')
)

, legacy_tracker_report_dummy_contract_building_1 as (
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
select
    legacy_tracker_report_dummy_contract_building_2.ADJ_CURRENT_COMPANY_ID as COMPANY_ID,
    companies.NAME as COMPANY_NAME,
    legacy_tracker_report_dummy_contract_building_2.SALES_REF_ID,
    case
        when legacy_tracker_report_dummy_contract_building_2.CONTRACT = 'TRACKER' then '152806318'
        when legacy_tracker_report_dummy_contract_building_2.CONTRACT = 'POWERED' then '533108765'
        when legacy_tracker_report_dummy_contract_building_2.CONTRACT = 'VEHICLE' then '2328556148'
        when legacy_tracker_report_dummy_contract_building_2.CONTRACT = 'NON POWERED' then '532899340'
        when legacy_tracker_report_dummy_contract_building_2.CONTRACT = 'CAMERA' then '1614591378'
    end as PRODUCT_ID,
    case
        when legacy_tracker_report_dummy_contract_building_2.CONTRACT = 'TRACKER' then 'TELEMATICS SERVICE TRACKER BUNDLE'
        when legacy_tracker_report_dummy_contract_building_2.CONTRACT = 'POWERED' then 'TELEMATICS SERVICE POWERED BUNDLE'
        when legacy_tracker_report_dummy_contract_building_2.CONTRACT = 'VEHICLE' then 'TELEMATICS SERVICE VEHICLE BUNDLE'
        when legacy_tracker_report_dummy_contract_building_2.CONTRACT = 'NON POWERED' then 'TELEMATICS SERVICE NON POWERED BUNDLE'
        when legacy_tracker_report_dummy_contract_building_2.CONTRACT = 'CAMERA' then 'TELEMATICS SERVICE CAMERA BUNDLE'
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
select
    SHIPPED_SERIAL_FORMATTED,
    case
        when PART_DESCRIPTION = 'LTR - vehicle' and LINKED_DEVICE_TYPE != 'T3Camera' then 'TELEMATICS SERVICE VEHICLE BUNDLE'
        when PART_DESCRIPTION = 'LTR - equipment' and LINKED_DEVICE_TYPE != 'T3Camera' then 'TELEMATICS SERVICE POWERED BUNDLE'
        when PART_DESCRIPTION = 'LTR - bucket' and LINKED_DEVICE_TYPE != 'T3Camera' then 'TELEMATICS SERVICE POWERED BUNDLE'
        when PART_DESCRIPTION = 'LTR - small tool' and LINKED_DEVICE_TYPE != 'T3Camera' then 'TELEMATICS SERVICE TRACKER BUNDLE'
        when PART_DESCRIPTION = 'LTR - trailer' and LINKED_DEVICE_TYPE != 'T3Camera' then 'TELEMATICS SERVICE NON POWERED BUNDLE'
        when PART_DESCRIPTION = 'LTR - attachment' and LINKED_DEVICE_TYPE != 'T3Camera' then 'TELEMATICS SERVICE NON POWERED BUNDLE'
        when LINKED_DEVICE_TYPE = 'T3Camera' then 'CAMERA'
    end as CONTRACT_NAME,
    SALES_REF_ID,
    LINKED_DEVICE_TYPE
from
    legacy_tracker_report_not_found_units_warehouse_adj_view
)

, legacy_tracker_report_not_found_units_mapping_adj_view as (
select
    legacy_tracker_report_not_found_units_warehouse_adj_view.SALES_REF_ID::TEXT as SALES_REF_ID,
    legacy_tracker_report_not_found_units_warehouse_adj_view.SHIPPED_SERIAL_FORMATTED,
    legacy_tracker_report_not_found_units_mapping.CONTRACT_NAME,
    legacy_tracker_report_not_found_units_warehouse_adj_view.LINKED_DEVICE_TYPE
from
    legacy_tracker_report_not_found_units_warehouse_adj_view
left join
    legacy_tracker_report_not_found_units_mapping
    on legacy_tracker_report_not_found_units_warehouse_adj_view.SALES_REF_ID = legacy_tracker_report_not_found_units_mapping.SALES_REF_ID
    and legacy_tracker_report_not_found_units_warehouse_adj_view.SHIPPED_SERIAL_FORMATTED = legacy_tracker_report_not_found_units_mapping.SHIPPED_SERIAL_FORMATTED
    and legacy_tracker_report_not_found_units_warehouse_adj_view.LINKED_DEVICE_TYPE = legacy_tracker_report_not_found_units_mapping.LINKED_DEVICE_TYPE
)

, shipment_to_contract_mapping as (
select
    FK_SALES_REF_ID::TEXT as SALES_REF_ID,
    SHIPPED_SERIAL_FORMATTED,
    CONTRACT_NAME,
    LINKED_DEVICE_TYPE
from
    financial_systems.t3_saas_gold.shipment_to_contract
union
select
    SALES_REF_ID::TEXT as SALES_REF_ID,
    SHIPPED_SERIAL_FORMATTED,
    CONTRACT_NAME,
    LINKED_DEVICE_TYPE
from
    adj_transfer_shipment_to_contract_mapping
union
select
    SALES_REF_ID::TEXT as SALES_REF_ID,
    SHIPPED_SERIAL_FORMATTED,
    CONTRACT_NAME,
    LINKED_DEVICE_TYPE
from
    legacy_tracker_report_not_found_units_mapping_adj_view
)

, device_transfers_to_text as (
select
    SERIAL_FORMATTED,
    ID as TRANSFER_ID,
    TO_VARCHAR(SALES_REF_ID) as SALES_REF_ID,
    LINKED_DEVICE_TYPE,
    SENDING_COMPANY_ID,
    TRANSFER_DATE
from
    ANALYTICS.T3_SAAS_BILLING.DEVICE_TRANSFERS
)

, transfer_sending_deactivations as (
select
    concat(device_transfers_to_text.SERIAL_FORMATTED,'-', device_transfers_to_text.TRANSFER_ID,'-', 'TRANSFER') as UNIQUE_IDENTIFIER,
    device_transfers_to_text.SENDING_COMPANY_ID as COMPANY_ID,
    TO_VARCHAR(companies.NAME) as COMPANY_NAME,
    shipment_to_contract_mapping.CONTRACT_NAME as BUNDLE_TYPE,
    device_transfers_to_text.SERIAL_FORMATTED,
    TO_VARCHAR(device_transfers_to_text.SALES_REF_ID) as SALES_REF_ID,
    device_transfers_to_text.TRANSFER_ID as DEACTIVATION_TICKET_ID,
    device_transfers_to_text.LINKED_DEVICE_TYPE as DEVICE_TYPE,
    'TRANSFER' as DEACTIVATION_TYPE,
    device_transfers_to_text.TRANSFER_DATE as DEACTIVATION_DATE
from
    device_transfers_to_text
left join
    shipment_to_contract_mapping
    on device_transfers_to_text.SERIAL_FORMATTED = shipment_to_contract_mapping.SHIPPED_SERIAL_FORMATTED
    and device_transfers_to_text.LINKED_DEVICE_TYPE = shipment_to_contract_mapping.LINKED_DEVICE_TYPE
    and device_transfers_to_text.SALES_REF_ID = shipment_to_contract_mapping.SALES_REF_ID
left join
    es_warehouse.public.companies companies
    on device_transfers_to_text.SENDING_COMPANY_ID = companies.COMPANY_ID
)

, deactivations_billing_adjustments as (
select
    concat(deacts.SERIAL_FORMATTED,'-', deacts.FK_DEACTIVATION_TICKET_ID,'-', deacts.DEACTIVATION_TYPE) as UNIQUE_IDENTIFIER,
    TO_VARCHAR(companies.name) as COMPANY_NAME,
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

, deactivations as (
select
    deactivations_billing_adjustments.UNIQUE_IDENTIFIER::TEXT as UNIQUE_IDENTIFIER,
    deactivations_billing_adjustments.COMPANY_ID::TEXT as COMPANY_ID,
    deactivations_billing_adjustments.COMPANY_NAME::TEXT as COMPANY_NAME,
    deactivations_billing_adjustments.BUNDLE_TYPE::TEXT as BUNDLE_TYPE,
    deactivations_billing_adjustments.SERIAL_FORMATTED::TEXT as SERIAL_FORMATTED,
    deactivations_billing_adjustments.SALES_REF_ID::TEXT as SALES_REF_ID,
    deactivations_billing_adjustments.DEACTIVATION_TICKET_ID::TEXT as DEACTIVATION_TICKET_ID,
    deactivations_billing_adjustments.DEVICE_TYPE::TEXT as DEVICE_TYPE,
    deactivations_billing_adjustments.DEACTIVATION_TYPE::TEXT as DEACTIVATION_TYPE,
    deactivations_billing_adjustments.DEACTIVATION_DATE::DATE as DEACTIVATION_DATE
from
    deactivations_billing_adjustments
union
select
    transfer_sending_deactivations.UNIQUE_IDENTIFIER::TEXT as UNIQUE_IDENTIFIER,
    transfer_sending_deactivations.COMPANY_ID::TEXT as COMPANY_ID,
    transfer_sending_deactivations.COMPANY_NAME::TEXT as COMPANY_NAME,
    transfer_sending_deactivations.BUNDLE_TYPE::TEXT as BUNDLE_TYPE,
    transfer_sending_deactivations.SERIAL_FORMATTED::TEXT as SERIAL_FORMATTED,
    transfer_sending_deactivations.SALES_REF_ID::TEXT as SALES_REF_ID,
    transfer_sending_deactivations.DEACTIVATION_TICKET_ID::TEXT as DEACTIVATION_TICKET_ID,
    transfer_sending_deactivations.DEVICE_TYPE::TEXT as DEVICE_TYPE,
    transfer_sending_deactivations.DEACTIVATION_TYPE::TEXT as DEACTIVATION_TYPE,
    transfer_sending_deactivations.DEACTIVATION_DATE::DATE as DEACTIVATION_DATE
from
    transfer_sending_deactivations
)

select * from deactivations

          ;;}

      dimension: UNIQUE_IDENTIFIER {
        type:  string
        sql: ${TABLE}.UNIQUE_IDENTIFIER ;;
      }

      dimension: COMPANY_NAME {
        type:  string
        sql:  ${TABLE}.COMPANY_NAME ;;
      }

      dimension: COMPANY_ID {
        type: string
        sql: ${TABLE}.COMPANY_ID ;;
      }

      dimension: BUNDLE_TYPE {
        type: string
        sql: ${TABLE}.BUNDLE_TYPE ;;
      }

      dimension: SERIAL_FORMATTED {
        type: string
        sql: ${TABLE}.SERIAL_FORMATTED ;;
      }

      dimension: SALES_REF_ID {
        type: string
        sql: ${TABLE}.SALES_REF_ID ;;
      }

      dimension: DEACTIVATION_TICKET_ID {
        type: string
        sql: ${TABLE}.DEACTIVATION_TICKET_ID ;;
      }

      dimension: DEVICE_TYPE {
        type: string
        sql: ${TABLE}.DEVICE_TYPE ;;
      }

      dimension: DEACTIVATION_TYPE {
        type: string
        sql: ${TABLE}.DEACTIVATION_TYPE ;;
      }

      dimension: DEACTIVATION_DATE {
        type: date
        sql: ${TABLE}.DEACTIVATION_DATE ;;
      }

    }
