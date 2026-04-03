view: D365_Kit_Totals_OEM {

  derived_table: {
    sql:

      with t3_saas_inventtrans_d365 as (
    select
        CPST.ITEMID as PART_ID,
        CPST.NAME as PART_DESCRIPTION,
        ID.inventserialid as WAREHOUSE_SHIPPED_SERIAL,
        IT.DATEPHYSICAL as WAREHOUSE_PHYSICAL_DATE,
        SALESHEADER.SHIPPINGDATEREQUESTED as WAREHOUSE_REQUESTED_SHIP_DATE,
        case
            when ID.INVENTSERIALID is null then IT.QTY * -1
            when ID.INVENTSERIALID is not null then 1
        end as IT_QTY,
        case
            when ID.INVENTSERIALID is null then CIT.LINEAMOUNT
            when ID.INVENTSERIALID is not null then CIT.salesprice
        end as D365_CUST_INVOICE_LINE_SUM,
        CIT.lineamount as D365_CUST_INVOICE_LINE_AMOUNT,
        CIT.salesprice as D365_CUST_INVOICE_SALES_PRICE,
        CIT.invoiceid as D365_CUST_INVOICE_ID,
        CIT.origsalesid as D365_CUST_SALES_ORDER_NUMBER,
        SALESHEADER.customerref as SALES_ORDER_CUSTOMER_REF,
        GAB.NAME as D365_CUSTOMER_NAME,
        CT.ACCOUNTNUM as D365_CUSTOMER_ACCOUNTNUM
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
        SALESHEADER.custgroup = 'OEM'
        and CIT.origsalesid is not null
    and
        SALESHEADER.inventsiteid != 'MBY'
    order by
        CIT.origsalesid
)

, OEM_totals as (
    select
        PART_ID,
        PART_DESCRIPTION,
        SUM(IT_QTY) as IT_QTY_SUM,
        SUM(D365_CUST_INVOICE_LINE_SUM) as D365_CUST_INVOICE_LINE_SUM,
        WAREHOUSE_PHYSICAL_DATE,
        D365_CUST_INVOICE_ID,
        D365_CUST_SALES_ORDER_NUMBER,
        SALES_ORDER_CUSTOMER_REF,
        D365_CUSTOMER_NAME,
        D365_CUSTOMER_ACCOUNTNUM
    from
        t3_saas_inventtrans_d365
    group by
        PART_ID,
        PART_DESCRIPTION,
        WAREHOUSE_PHYSICAL_DATE,
        D365_CUST_INVOICE_ID,
        D365_CUST_SALES_ORDER_NUMBER,
        SALES_ORDER_CUSTOMER_REF,
        D365_CUSTOMER_NAME,
        D365_CUSTOMER_ACCOUNTNUM
)

, SO_Kits as (
select
    PART_ID,
    IT_QTY_SUM,
    D365_CUST_SALES_ORDER_NUMBER,
    D365_CUSTOMER_ACCOUNTNUM
from
    OEM_totals
)

, SO_Kits_Unit as (
select
    MIN(IT_QTY_SUM) as KIT_ORDER_QUANTITY,
    D365_CUST_SALES_ORDER_NUMBER,
from
    SO_Kits
group by
    D365_CUST_SALES_ORDER_NUMBER
)

, SO_Kits_Breakdown as (
select
    SO_Kits.PART_ID as PART_ID,
    LEFT(SO_Kits.PART_ID, 7) as PART_ID_COMP,
    DIV0NULL(SO_Kits.IT_QTY_SUM, SO_Kits_Unit.KIT_ORDER_QUANTITY) as KIT_UNIT,
    SO_Kits.D365_CUST_SALES_ORDER_NUMBER as D365_CUST_SALES_ORDER_NUMBER,
    SO_Kits.D365_CUSTOMER_ACCOUNTNUM as D365_CUSTOMER_ACCOUNTNUM,
    SO_Kits_Unit.KIT_ORDER_QUANTITY as KIT_ORDER_QUANTITY
from
    SO_Kits
left join
    SO_Kits_Unit
    on SO_Kits.D365_CUST_SALES_ORDER_NUMBER = SO_Kits_Unit.D365_CUST_SALES_ORDER_NUMBER
)

, SO_Kit_BOM as (
select
    PART_ID,
    PART_ID_COMP,
    KIT_UNIT,
    D365_CUST_SALES_ORDER_NUMBER
from
    SO_Kits_Breakdown

)

, ExpandedSales AS (
    SELECT
        s.D365_CUST_SALES_ORDER_NUMBER,
        s.PART_ID as Component_Part_ID,
        s.KIT_UNIT,
        b.PART_ID_COMP,
        b.KIT_UNIT AS Total_Component_Qty,
        ROW_NUMBER() OVER (
            PARTITION BY s.D365_CUST_SALES_ORDER_NUMBER
            ORDER BY b.PART_ID_COMP ASC
        ) AS Part_Rank
    FROM SO_Kits_Breakdown s
    LEFT JOIN SO_Kit_BOM b
        ON s.PART_ID = b.PART_ID
        and s.D365_CUST_SALES_ORDER_NUMBER = b.D365_CUST_SALES_ORDER_NUMBER
)

, SALES_KIT_BOM_ORDER as (SELECT
    D365_CUST_SALES_ORDER_NUMBER,
    MAX(CASE WHEN Part_Rank = 1 THEN Component_Part_ID END) AS PART_ITEM_ID_1,
    MAX(CASE WHEN Part_Rank = 1 THEN Total_Component_Qty END) AS PART_ITEM_ID_1_QTY,
    MAX(CASE WHEN Part_Rank = 2 THEN Component_Part_ID END) AS PART_ITEM_ID_2,
    MAX(CASE WHEN Part_Rank = 2 THEN Total_Component_Qty END) AS PART_ITEM_ID_2_QTY,
    MAX(CASE WHEN Part_Rank = 3 THEN Component_Part_ID END) AS PART_ITEM_ID_3,
    MAX(CASE WHEN Part_Rank = 3 THEN Total_Component_Qty END) AS PART_ITEM_ID_3_QTY,
    MAX(CASE WHEN Part_Rank = 4 THEN Component_Part_ID END) AS PART_ITEM_ID_4,
    MAX(CASE WHEN Part_Rank = 4 THEN Total_Component_Qty END) AS PART_ITEM_ID_4_QTY,
    MAX(CASE WHEN Part_Rank = 5 THEN Component_Part_ID END) AS PART_ITEM_ID_5,
    MAX(CASE WHEN Part_Rank = 5 THEN Total_Component_Qty END) AS PART_ITEM_ID_5_QTY,
    MAX(CASE WHEN Part_Rank = 6 THEN Component_Part_ID END) AS PART_ITEM_ID_6,
    MAX(CASE WHEN Part_Rank = 6 THEN Total_Component_Qty END) AS PART_ITEM_ID_6_QTY,
    MAX(CASE WHEN Part_Rank = 7 THEN Component_Part_ID END) AS PART_ITEM_ID_7,
    MAX(CASE WHEN Part_Rank = 7 THEN Total_Component_Qty END) AS PART_ITEM_ID_7_QTY,
    MAX(CASE WHEN Part_Rank = 8 THEN Component_Part_ID END) AS PART_ITEM_ID_8,
    MAX(CASE WHEN Part_Rank = 8 THEN Total_Component_Qty END) AS PART_ITEM_ID_8_QTY,
    MAX(CASE WHEN Part_Rank = 9 THEN Component_Part_ID END) AS PART_ITEM_ID_9,
    MAX(CASE WHEN Part_Rank = 9 THEN Total_Component_Qty END) AS PART_ITEM_ID_9_QTY,
    MAX(CASE WHEN Part_Rank = 10 THEN Component_Part_ID END) AS PART_ITEM_ID_10,
    MAX(CASE WHEN Part_Rank = 10 THEN Total_Component_Qty END) AS PART_ITEM_ID_10_QTY,
    MAX(CASE WHEN Part_Rank = 11 THEN Component_Part_ID END) AS PART_ITEM_ID_11,
    MAX(CASE WHEN Part_Rank = 11 THEN Total_Component_Qty END) AS PART_ITEM_ID_11_QTY,
    MAX(CASE WHEN Part_Rank = 12 THEN Component_Part_ID END) AS PART_ITEM_ID_12,
    MAX(CASE WHEN Part_Rank = 12 THEN Total_Component_Qty END) AS PART_ITEM_ID_12_QTY,
    MAX(CASE WHEN Part_Rank = 13 THEN Component_Part_ID END) AS PART_ITEM_ID_13,
    MAX(CASE WHEN Part_Rank = 13 THEN Total_Component_Qty END) AS PART_ITEM_ID_13_QTY,
    MAX(CASE WHEN Part_Rank = 14 THEN Component_Part_ID END) AS PART_ITEM_ID_14,
    MAX(CASE WHEN Part_Rank = 14 THEN Total_Component_Qty END) AS PART_ITEM_ID_14_QTY,
    MAX(CASE WHEN Part_Rank = 15 THEN Component_Part_ID END) AS PART_ITEM_ID_15,
    MAX(CASE WHEN Part_Rank = 15 THEN Total_Component_Qty END) AS PART_ITEM_ID_15_QTY,
    MAX(CASE WHEN Part_Rank = 16 THEN Component_Part_ID END) AS PART_ITEM_ID_16,
    MAX(CASE WHEN Part_Rank = 16 THEN Total_Component_Qty END) AS PART_ITEM_ID_16_QTY,
FROM ExpandedSales
GROUP BY D365_CUST_SALES_ORDER_NUMBER
ORDER BY D365_CUST_SALES_ORDER_NUMBER desc)

, SALES_KIT_BOM as (
select
    D365_CUST_SALES_ORDER_NUMBER,
       case when PART_ITEM_ID_1 is null then 'NO PART' else PART_ITEM_ID_1 end as PART_ITEM_ID_1,
       case when PART_ITEM_ID_1_QTY is null then 0 else PART_ITEM_ID_1_QTY end as PART_ITEM_ID_1_QTY,
       case when PART_ITEM_ID_2 is null then 'NO PART' else PART_ITEM_ID_2 end as PART_ITEM_ID_2,
       case when PART_ITEM_ID_2_QTY is null then 0 else PART_ITEM_ID_2_QTY end as PART_ITEM_ID_2_QTY,
       case when PART_ITEM_ID_3 is null then 'NO PART' else PART_ITEM_ID_3 end as PART_ITEM_ID_3,
       case when PART_ITEM_ID_3_QTY is null then 0 else PART_ITEM_ID_3_QTY end as PART_ITEM_ID_3_QTY,
       case when PART_ITEM_ID_4 is null then 'NO PART' else PART_ITEM_ID_4 end as PART_ITEM_ID_4,
       case when PART_ITEM_ID_4_QTY is null then 0 else PART_ITEM_ID_4_QTY end as PART_ITEM_ID_4_QTY,
       case when PART_ITEM_ID_5 is null then 'NO PART' else PART_ITEM_ID_5 end as PART_ITEM_ID_5,
       case when PART_ITEM_ID_5_QTY is null then 0 else PART_ITEM_ID_5_QTY end as PART_ITEM_ID_5_QTY,
       case when PART_ITEM_ID_6 is null then 'NO PART' else PART_ITEM_ID_6 end as PART_ITEM_ID_6,
       case when PART_ITEM_ID_6_QTY is null then 0 else PART_ITEM_ID_6_QTY end as PART_ITEM_ID_6_QTY,
       case when PART_ITEM_ID_7 is null then 'NO PART' else PART_ITEM_ID_7 end as PART_ITEM_ID_7,
       case when PART_ITEM_ID_7_QTY is null then 0 else PART_ITEM_ID_7_QTY end as PART_ITEM_ID_7_QTY,
       case when PART_ITEM_ID_8 is null then 'NO PART' else PART_ITEM_ID_8 end as PART_ITEM_ID_8,
       case when PART_ITEM_ID_8_QTY is null then 0 else PART_ITEM_ID_8_QTY end as PART_ITEM_ID_8_QTY,
       case when PART_ITEM_ID_9 is null then 'NO PART' else PART_ITEM_ID_9 end as PART_ITEM_ID_9,
       case when PART_ITEM_ID_9_QTY is null then 0 else PART_ITEM_ID_9_QTY end as PART_ITEM_ID_9_QTY,
       case when PART_ITEM_ID_10 is null then 'NO PART' else PART_ITEM_ID_10 end as PART_ITEM_ID_10,
       case when PART_ITEM_ID_10_QTY is null then 0 else PART_ITEM_ID_10_QTY end as PART_ITEM_ID_10_QTY,
       case when PART_ITEM_ID_11 is null then 'NO PART' else PART_ITEM_ID_11 end as PART_ITEM_ID_11,
       case when PART_ITEM_ID_11_QTY is null then 0 else PART_ITEM_ID_11_QTY end as PART_ITEM_ID_11_QTY,
       case when PART_ITEM_ID_12 is null then 'NO PART' else PART_ITEM_ID_12 end as PART_ITEM_ID_12,
       case when PART_ITEM_ID_12_QTY is null then 0 else PART_ITEM_ID_12_QTY end as PART_ITEM_ID_12_QTY,
       case when PART_ITEM_ID_13 is null then 'NO PART' else PART_ITEM_ID_13 end as PART_ITEM_ID_13,
       case when PART_ITEM_ID_13_QTY is null then 0 else PART_ITEM_ID_13_QTY end as PART_ITEM_ID_13_QTY,
       case when PART_ITEM_ID_14 is null then 'NO PART' else PART_ITEM_ID_14 end as PART_ITEM_ID_14,
       case when PART_ITEM_ID_14_QTY is null then 0 else PART_ITEM_ID_14_QTY end as PART_ITEM_ID_14_QTY,
       case when PART_ITEM_ID_15 is null then 'NO PART' else PART_ITEM_ID_15 end as PART_ITEM_ID_15,
       case when PART_ITEM_ID_15_QTY is null then 0 else PART_ITEM_ID_15_QTY end as PART_ITEM_ID_15_QTY,
       case when PART_ITEM_ID_16 is null then 'NO PART' else PART_ITEM_ID_16 end as PART_ITEM_ID_16,
       case when PART_ITEM_ID_16_QTY is null then 0 else PART_ITEM_ID_16_QTY end as PART_ITEM_ID_16_QTY
from
    SALES_KIT_BOM_ORDER
)

, OEM_KITS_BOM as (
select
        KIT_ITEM_ID,
        case when PART_ITEM_ID_1 is null then 'NO PART' else PART_ITEM_ID_1 end as PART_ITEM_ID_1,
       case when PART_ITEM_ID_1_QTY is null then 0 else PART_ITEM_ID_1_QTY end as PART_ITEM_ID_1_QTY,
       case when PART_ITEM_ID_2 is null then 'NO PART' else PART_ITEM_ID_2 end as PART_ITEM_ID_2,
       case when PART_ITEM_ID_2_QTY is null then 0 else PART_ITEM_ID_2_QTY end as PART_ITEM_ID_2_QTY,
       case when PART_ITEM_ID_3 is null then 'NO PART' else PART_ITEM_ID_3 end as PART_ITEM_ID_3,
       case when PART_ITEM_ID_3_QTY is null then 0 else PART_ITEM_ID_3_QTY end as PART_ITEM_ID_3_QTY,
       case when PART_ITEM_ID_4 is null then 'NO PART' else PART_ITEM_ID_4 end as PART_ITEM_ID_4,
       case when PART_ITEM_ID_4_QTY is null then 0 else PART_ITEM_ID_4_QTY end as PART_ITEM_ID_4_QTY,
       case when PART_ITEM_ID_5 is null then 'NO PART' else PART_ITEM_ID_5 end as PART_ITEM_ID_5,
       case when PART_ITEM_ID_5_QTY is null then 0 else PART_ITEM_ID_5_QTY end as PART_ITEM_ID_5_QTY,
       case when PART_ITEM_ID_6 is null then 'NO PART' else PART_ITEM_ID_6 end as PART_ITEM_ID_6,
       case when PART_ITEM_ID_6_QTY is null then 0 else PART_ITEM_ID_6_QTY end as PART_ITEM_ID_6_QTY,
       case when PART_ITEM_ID_7 is null then 'NO PART' else PART_ITEM_ID_7 end as PART_ITEM_ID_7,
       case when PART_ITEM_ID_7_QTY is null then 0 else PART_ITEM_ID_7_QTY end as PART_ITEM_ID_7_QTY,
       case when PART_ITEM_ID_8 is null then 'NO PART' else PART_ITEM_ID_8 end as PART_ITEM_ID_8,
       case when PART_ITEM_ID_8_QTY is null then 0 else PART_ITEM_ID_8_QTY end as PART_ITEM_ID_8_QTY,
       case when PART_ITEM_ID_9 is null then 'NO PART' else PART_ITEM_ID_9 end as PART_ITEM_ID_9,
       case when PART_ITEM_ID_9_QTY is null then 0 else PART_ITEM_ID_9_QTY end as PART_ITEM_ID_9_QTY,
       case when PART_ITEM_ID_10 is null then 'NO PART' else PART_ITEM_ID_10 end as PART_ITEM_ID_10,
       case when PART_ITEM_ID_10_QTY is null then 0 else PART_ITEM_ID_10_QTY end as PART_ITEM_ID_10_QTY,
       case when PART_ITEM_ID_11 is null then 'NO PART' else PART_ITEM_ID_11 end as PART_ITEM_ID_11,
       case when PART_ITEM_ID_11_QTY is null then 0 else PART_ITEM_ID_11_QTY end as PART_ITEM_ID_11_QTY,
       case when PART_ITEM_ID_12 is null then 'NO PART' else PART_ITEM_ID_12 end as PART_ITEM_ID_12,
       case when PART_ITEM_ID_12_QTY is null then 0 else PART_ITEM_ID_12_QTY end as PART_ITEM_ID_12_QTY,
       case when PART_ITEM_ID_13 is null then 'NO PART' else PART_ITEM_ID_13 end as PART_ITEM_ID_13,
       case when PART_ITEM_ID_13_QTY is null then 0 else PART_ITEM_ID_13_QTY end as PART_ITEM_ID_13_QTY,
       case when PART_ITEM_ID_14 is null then 'NO PART' else PART_ITEM_ID_14 end as PART_ITEM_ID_14,
       case when PART_ITEM_ID_14_QTY is null then 0 else PART_ITEM_ID_14_QTY end as PART_ITEM_ID_14_QTY,
       case when PART_ITEM_ID_15 is null then 'NO PART' else PART_ITEM_ID_15 end as PART_ITEM_ID_15,
       case when PART_ITEM_ID_15_QTY is null then 0 else PART_ITEM_ID_15_QTY end as PART_ITEM_ID_15_QTY,
       case when PART_ITEM_ID_16 is null then 'NO PART' else PART_ITEM_ID_16 end as PART_ITEM_ID_16,
       case when PART_ITEM_ID_16_QTY is null then 0 else PART_ITEM_ID_16_QTY end as PART_ITEM_ID_16_QTY

from
    ANALYTICS.T3_SAAS_BILLING.OEM_KITS_BOM
)

, SALESORDER_TO_KITITEMID_1 as (
select
    SALES_KIT_BOM.D365_CUST_SALES_ORDER_NUMBER as D365_CUST_SALES_ORDER_NUMBER,
    OEM_KITS_BOM.KIT_ITEM_ID as KIT_ITEM_ID
from
    SALES_KIT_BOM
left join
    OEM_KITS_BOM
    on SALES_KIT_BOM.PART_ITEM_ID_1 = OEM_KITS_BOM.PART_ITEM_ID_1
    and SALES_KIT_BOM.PART_ITEM_ID_2 = OEM_KITS_BOM.PART_ITEM_ID_2
    and SALES_KIT_BOM.PART_ITEM_ID_3 = OEM_KITS_BOM.PART_ITEM_ID_3
    and SALES_KIT_BOM.PART_ITEM_ID_4 = OEM_KITS_BOM.PART_ITEM_ID_4
    and SALES_KIT_BOM.PART_ITEM_ID_5 = OEM_KITS_BOM.PART_ITEM_ID_5
    and SALES_KIT_BOM.PART_ITEM_ID_6 = OEM_KITS_BOM.PART_ITEM_ID_6
    and SALES_KIT_BOM.PART_ITEM_ID_7 = OEM_KITS_BOM.PART_ITEM_ID_7
    and SALES_KIT_BOM.PART_ITEM_ID_8 = OEM_KITS_BOM.PART_ITEM_ID_8
    and SALES_KIT_BOM.PART_ITEM_ID_9 = OEM_KITS_BOM.PART_ITEM_ID_9
    and SALES_KIT_BOM.PART_ITEM_ID_10 = OEM_KITS_BOM.PART_ITEM_ID_10
    and SALES_KIT_BOM.PART_ITEM_ID_11 = OEM_KITS_BOM.PART_ITEM_ID_11
    and SALES_KIT_BOM.PART_ITEM_ID_12 = OEM_KITS_BOM.PART_ITEM_ID_12
    and SALES_KIT_BOM.PART_ITEM_ID_13 = OEM_KITS_BOM.PART_ITEM_ID_13
    and SALES_KIT_BOM.PART_ITEM_ID_14 = OEM_KITS_BOM.PART_ITEM_ID_14
    and SALES_KIT_BOM.PART_ITEM_ID_15 = OEM_KITS_BOM.PART_ITEM_ID_15
    and SALES_KIT_BOM.PART_ITEM_ID_16 = OEM_KITS_BOM.PART_ITEM_ID_16
)

, SALESORDER_TO_KITITEMID_2 as (
select
    D365_CUST_SALES_ORDER_NUMBER,
    case
        when D365_CUST_SALES_ORDER_NUMBER = 'SOv003882' then '1005923'
        else KIT_ITEM_ID
    end as KIT_ITEM_ID
from
    SALESORDER_TO_KITITEMID_1
)

, SALESORDER_TO_KITITEMID as (
select distinct * from SALESORDER_TO_KITITEMID_2
)

, OEM_sum_invoiced as (
select
    SUM(D365_CUST_INVOICE_LINE_SUM) as D365_CUST_INVOICE_LINE_SUM,
    D365_CUST_SALES_ORDER_NUMBER as D365_CUST_SALES_ORDER_NUMBER
from
    OEM_totals
group by
    D365_CUST_SALES_ORDER_NUMBER
)


, OEM_cust_details_1 as (
select
    OEM_totals.D365_CUSTOMER_NAME,
    OEM_totals.D365_CUSTOMER_ACCOUNTNUM,
    OEM_totals.D365_CUST_SALES_ORDER_NUMBER,
    OEM_sum_invoiced.D365_CUST_INVOICE_LINE_SUM
from
    OEM_totals
left join
    OEM_sum_invoiced
    on OEM_sum_invoiced.D365_CUST_SALES_ORDER_NUMBER = OEM_totals.D365_CUST_SALES_ORDER_NUMBER
)

, OEM_cust_details as (
select distinct
    *
from
    OEM_cust_details_1
)

select OEM_cust_details.*,
SALESORDER_TO_KITITEMID.KIT_ITEM_ID,
case
    when SALESORDER_TO_KITITEMID.KIT_ITEM_ID is not null then SO_Kits_Unit.KIT_ORDER_QUANTITY
    else null
end as KIT_ORDER_QUANTITY
from
    SALESORDER_TO_KITITEMID
left join
    SO_Kits_Unit
    on SALESORDER_TO_KITITEMID.D365_CUST_SALES_ORDER_NUMBER = SO_Kits_Unit.D365_CUST_SALES_ORDER_NUMBER
left join
    OEM_cust_details
    on SALESORDER_TO_KITITEMID.D365_CUST_SALES_ORDER_NUMBER = OEM_cust_details.D365_CUST_SALES_ORDER_NUMBER
      ;;
  }

  dimension: D365_CUST_INVOICE_LINE_SUM {
    type:  number
    sql:${TABLE}.D365_CUST_INVOICE_LINE_SUM ;;
  }

  dimension: D365_CUST_SALES_ORDER_NUMBER {
    type: string
    sql: ${TABLE}.D365_CUST_SALES_ORDER_NUMBER ;;
  }

  dimension: D365_CUSTOMER_NAME {
    type: string
    sql: ${TABLE}.D365_CUSTOMER_NAME ;;
  }

  dimension: D365_CUSTOMER_ACCOUNTNUM {
    type: string
    sql: ${TABLE}.D365_CUSTOMER_ACCOUNTNUM ;;
  }

  dimension: KIT_ITEM_ID {
    type:  string
    sql: ${TABLE}.KIT_ITEM_ID ;;
  }

  dimension: KIT_ORDER_QUANTITY {
    type:  number
    sql: ${TABLE}.KIT_ORDER_QUANTITY ;;
  }
}
