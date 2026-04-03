view: t3_saas_revenue_hardware_cost_totals {

  derived_table: {
    sql:

with d365_warehouse_shipment_data as (
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
    CUSTBL.ESADMINID_CUSTOM as ADMIN_ID
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
left join
    ANALYTICS.MICROSOFT_DYNAMICS_365_FNO.salestable SALESHEADER
    on CPST.salesid = SALESHEADER.salesid
left join
    ANALYTICS.MICROSOFT_DYNAMICS_365_FNO.custtable CUSTBL
    on CUSTBL.AccountNum = SALESHEADER.CustAccount
left join
    ANALYTICS.MICROSOFT_DYNAMICS_365_FNO.custinvoicetrans CIT
    on CIT.inventtransid = ITO.inventtransid
where
    SALESHEADER.custgroup = 'T3'
and
    SALESHEADER.inventsiteid != 'MBY'
)

, d365_warehouse_shipment_data_formatted as (
select
    case
        when PART_ID = '1000720' then 'T3Camera'
        when PART_ID = '1000732' then 'ECM-01 CAN'
        when PART_ID = '1000736' then 'MC4+'
        when PART_ID = '1000737' then 'MC4+'
        when PART_ID = '1000738' then 'MC4+'
        when PART_ID = '1000743' then '730'
        when PART_ID = '1000760' then 'Queclink'
        when PART_ID = '1000763' then 'FJ2500'
        when PART_ID = '1000768' then 'MCX101'
        when PART_ID = '1000769' then 'Keypad'
        when PART_ID = '1000770' then 'Keypad'
        when PART_ID = '1000771' then 'Keypad'
        when PART_ID = '1000772' then 'Keypad'
        when PART_ID = '1005844' then 'Bluetooth'
        when PART_ID = '1006041' then 'Slap-N-Track'
        when PART_ID = '1000744S' then '2830'
        when PART_ID = '1000762' then 'FJ2500'
        when PART_ID = '1000764' then '3030'
        when PART_ID = '1000778' then 'Bluetooth'
        when PART_ID = '1000790' then 'Bluetooth'
        when PART_ID = '1000791' then 'Bluetooth'
        when PART_ID = '1000792' then 'Bluetooth'
        when PART_ID = '1000793' then 'Bluetooth'
        when PART_ID = '1000794' then 'Bluetooth'
        when PART_ID = '1000797' then 'Bluetooth'
        when PART_ID = '1005845' then 'MC4+'
        when PART_ID = '1006299' then 'MC5'
        when PART_ID = '1006587' then 'MCX101'
    else 'Attachment'
    end as WAREHOUSE_LINKED_DEVICE_TYPE,
    ADMIN_ID,
    SALES_ORDER_CUSTOMER_REF,
    PART_DESCRIPTION AS WAREHOUSE_SHIPPED_PART_DESCRIPTION,
    WAREHOUSE_SHIPPED_SERIAL,
    REPLACE(WAREHOUSE_SHIPPED_SERIAL, '-', '') AS WAREHOUSE_SHIPPED_SERIAL_FORMATTED,
    WAREHOUSE_PHYSICAL_DATE,
    WAREHOUSE_REQUESTED_SHIP_DATE,
    D365_CUST_INVOICE_LINE_SUM,
    D365_CUST_INVOICE_SALES_PRICE,
    D365_CUST_INVOICE_ID,
    D365_CUST_SALES_ORDER_NUMBER,
    ADMIN_ID as COMPANY_ID
from
    d365_warehouse_shipment_data
where
    SALES_ORDER_CUSTOMER_REF REGEXP '^[0-9]{9,12}$'
)

select
    WAREHOUSE_LINKED_DEVICE_TYPE,
    SALES_ORDER_CUSTOMER_REF,
    WAREHOUSE_PHYSICAL_DATE,
    SUM(D365_CUST_INVOICE_LINE_SUM) as HARDWARE_COST,
    COMPANY_ID
from
    d365_warehouse_shipment_data_formatted
group by
    WAREHOUSE_LINKED_DEVICE_TYPE,
    SALES_ORDER_CUSTOMER_REF,
    WAREHOUSE_PHYSICAL_DATE,
    COMPANY_ID
        ;;
  }

  dimension: WAREHOUSE_LINKED_DEVICE_TYPE {
    type: string
    sql: ${TABLE}.WAREHOUSE_LINKED_DEVICE_TYPE ;;
  }

  dimension: SALES_ORDER_CUSTOMER_REF {
    type: string
    sql: ${TABLE}.SALES_ORDER_CUSTOMER_REF ;;
  }

  dimension: WAREHOUSE_PHYSICAL_DATE {
    type: date
    sql: ${TABLE}.WAREHOUSE_PHYSICAL_DATE ;;
  }

  dimension: HARDWARE_COST {
    type:  number
    sql:${TABLE}.HARDWARE_COST ;;
  }

  dimension: COMPANY_ID {
    type:  string
    sql:${TABLE}.COMPANY_ID ;;
  }

}
