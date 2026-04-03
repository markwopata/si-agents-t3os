view: fleet_assigned_analyst {
    derived_table: {
      sql:
      with main as (
SELECT distinct PO.VENDOR_ID,
user_created.username AS created_by_username,
user_approved.username AS approved_by_username,
user_submitted.username AS submitted_by_username,
C1.NAME AS VENDOR_NAME,
CONCAT(CPT.prefix,'PO',POL.COMPANY_PURCHASE_ORDER_ID) AS ORDER_NUMBER_GROUPED,
 po.modified_at,
      po.approved_at,
CONCAT(CPT.prefix,'PO',POL.COMPANY_PURCHASE_ORDER_ID,'-',POL.COMPANY_PURCHASE_ORDER_LINE_ITEM_NUMBER) AS ORDER_NUMBER,
POL.INVOICE_NUMBER,
POL.INVOICE_DATE,
POL.RELEASE_DATE,
POL.ASSET_ID,
COALESCE(POL.SERIAL,POL.VIN) AS SERIAL_VIN,
POL.ORDER_STATUS,
POL.FINANCE_STATUS,
EMA.NAME AS EQUIPMENT_MAKE,
EMO.NAME AS EQUIPMENT_MODEL,
POL.YEAR AS MODEL_YEAR,
POL.FACTORY_BUILD_SPECIFICATIONS,
AA.COMPANY_ID AS OWNER_ID,
C2.NAME AS OWNER_NAME,
POL.NET_PRICE,
COALESCE(POL.NET_PRICE,0) + COALESCE(POL.FREIGHT_COST,0) + COALESCE(POL.SALES_TAX,0) - COALESCE(POL.REBATE,0) AS TOTAL_OEC,
COALESCE(POL.NET_PRICE,0) + COALESCE(POL.FREIGHT_COST,0) - COALESCE(POL.REBATE,0) AS OEC_LESS_TAX,
pol.due_date as new_due_date,
pol.week_to_be_paid,
pol.aftermarket_oec,
pol.attachments,
pol.freight_cost,
pol.rebate,
pol.sales_tax,
pol.reconciliation_status,

pol.note,

pol.paid_date as ft_paid_date,
nt.name as net_terms,
      nt.days as net_terms_days,
      coalesce(pol.due_date,ass.invoice_purchase_date,sets.date_created) as co_due_date,
      pol.pending_schedule,
      pol.title_status,
      pol.reconciliation_status_date,


retail_invoices_paid.paid_date as customer_paid_date,
      retail_invoices_paid.paid as customer_paid,
      vend.ft_book_of_business,
      vend.ft_category,
      vend.ft_core_designation,
      vend.ft_financing_designation,
      vend.ft_fleet_track_id,
      vend.vendorid as sage_vendor_id,
ec.name as class,
bs.name as business_segment,
pol.quantity,
pol.paid_date
--agg.class
-- V.RULE_ID,
-- V.RULE_YEAR,
-- R.RULE,
-- R.REIMBURSEMENT_RATE,
-- CASE WHEN V.RULE_ID = 1 THEN ROUND(R.REIMBURSEMENT_RATE * TOTAL_OEC,2)
-- WHEN V.RULE_ID IN (3,4) THEN ROUND(R.REIMBURSEMENT_RATE * OEC_LESS_TAX,2)
-- WHEN V.RULE_ID IN (5,6) THEN ROUND(R.REIMBURSEMENT_RATE * POL.NET_PRICE,2)
-- WHEN V.RULE_ID = 7 AND POL.ASSET_ID IS NOT NULL THEN ROUND(R.REIMBURSEMENT_RATE * POL.NET_PRICE,2)
-- WHEN V.RULE_ID = 8 THEN ROUND(POL.NET_PRICE-(POL.NET_PRICE/1.05),2)
-- ELSE 0.00 END AS REIMBURSEMENT_AMOUNT
FROM ES_WAREHOUSE.PUBLIC.COMPANY_PURCHASE_ORDER_LINE_ITEMS AS POL
LEFT JOIN ES_WAREHOUSE.PUBLIC.COMPANY_PURCHASE_ORDERS AS PO ON POL.COMPANY_PURCHASE_ORDER_ID = PO.COMPANY_PURCHASE_ORDER_ID

LEFT JOIN
    es_warehouse.public.users AS user_created
    ON PO.created_by_user_id = user_created.user_id
LEFT JOIN
    es_warehouse.public.users AS user_approved
    ON PO.approved_by_user_id = user_approved.user_id
LEFT JOIN
    es_warehouse.public.users AS user_submitted
    ON PO.submitted_by_user_id = user_submitted.user_id

LEFT JOIN ES_WAREHOUSE.PUBLIC.COMPANY_PURCHASE_ORDER_TYPES AS CPT ON PO.COMPANY_PURCHASE_ORDER_TYPE_ID = CPT.COMPANY_PURCHASE_ORDER_TYPE_ID
LEFT JOIN ES_WAREHOUSE.PUBLIC.COMPANIES AS C1 ON PO.VENDOR_ID = C1.COMPANY_ID
LEFT JOIN ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE AS AA ON POL.ASSET_ID = AA.ASSET_ID
LEFT JOIN ES_WAREHOUSE.PUBLIC.EQUIPMENT_MODELS AS EMO ON POL.EQUIPMENT_MODEL_ID = EMO.EQUIPMENT_MODEL_ID
LEFT JOIN ES_WAREHOUSE.PUBLIC.EQUIPMENT_MAKES AS EMA ON EMO.EQUIPMENT_MAKE_ID = EMA.EQUIPMENT_MAKE_ID
LEFT JOIN ES_WAREHOUSE.PUBLIC.COMPANIES AS C2 ON AA.COMPANY_ID = C2.COMPANY_ID
left join analytics.intacct.vendor as vend on po.vendor_id = vend.ft_fleet_track_id
left join ES_WAREHOUSE.PUBLIC.NET_TERMS as nt on po.NET_TERMS_ID = nt.NET_TERMS_ID
left join es_warehouse.public.asset_purchase_history ass on pol.asset_id = ass.asset_id
left join es_warehouse.public.assets sets on pol.asset_id = sets.asset_id
left join es_warehouse.public.assets_aggregate agg on pol.asset_id = agg.asset_id
--left join ES_WAREHOUSE.PUBLIC.business_segments as bs on ec.business_segment_id = bs.business_segment_id
left join ES_WAREHOUSE.PUBLIC.equipment_models models on pol.equipment_model_id = models.equipment_model_id
left join es_warehouse.public.equipment_classes_models_xref mxref on models.equipment_model_id = mxref.equipment_model_id
left join ES_WAREHOUSE.PUBLIC.equipment_classes as ec on coalesce(mxref.equipment_class_id, pol.equipment_class_id) = ec.equipment_class_id
left join ES_WAREHOUSE.PUBLIC.business_segments as bs on ec.business_segment_id = bs.business_segment_id
--select * from es_warehouse.public.assets_aggregate
--left join equipment_classes as ec on pol.equipment_class_id = ec.equipment_class_id--coalesce(equipment_classes_models_xref.equipment_class_id, company_purchase_order_line_items.equipment_class_id)
    --we need to select asset id to get the retail invoices paid and the date where paid date is true and newest while keeping 1-1 relationship to asset id
    left join --kendall added tue aug 29 2024
    (
        select
            asset_id,
            paid_date,
            paid
        from (
              select
                  asset_id,
                  invoices.paid_date,
                  invoices.paid,
                  row_number() over (partition by line_items.asset_id order by invoices.paid_date desc) as rn
              from
                  es_warehouse.public.line_items
              left join es_warehouse.public.invoices on line_items.invoice_id = invoices.invoice_id
              where
                  invoices.paid = true
                  --and invoices.company_id = '1854'
              and line_items.line_item_type_id = 127 --*OWN PROGRAM
             ) as ranked_payments
        where rn = 1
    ) retail_invoices_paid on pol.asset_id = retail_invoices_paid.asset_id

-- LEFT JOIN ANALYTICS.REIMBURSEMENTS.VENDOR_RULES AS V ON (PO.VENDOR_ID = V.VENDOR_ID) AND (V.RULE_YEAR = YEAR(POL.INVOICE_DATE))
-- INNER JOIN ANALYTICS.REIMBURSEMENTS.VENDOR_RULES_RATES AS R ON V.RULE_ID = R.RULE_ID
WHERE C1.SUPPLY_VENDOR = TRUE
AND POL.DELETED_AT IS NULL
--AND CPT.PREFIX IN ('S','V')
--AND POL.INVOICE_DATE >= '2024-01-01' AND POL.INVOICE_DATE < '2024-07-01'
--AND POL.FINANCE_STATUS NOT IN ('Dealership Floor Plan','Dealer Floor Plan')
)
select distinct main.*, gs_list.ASSIGNED_FLEET_ANALYST_--, gs_list.core_non_core_vehicles, gs_list.book_of_business, gs_list.category
from main
left join analytics.fleet.gs_fleet_vendor_list gs_list on main.vendor_id = gs_list.fleet_track_vendor_number
--where gs_list.fleet_track_vendor_number is not null
;;
    }


    ################# DIMENSIONS #################
  dimension: paid_date {
    type: date

    sql: ${TABLE}.ft_paid_date ;;
  }
  dimension: category {
    type: string
label: "sage_category"
    sql: ${TABLE}."FT_CATEGORY" ;;
  }
  dimension: created_by_username {
    type: string

    sql: ${TABLE}."CREATED_BY_USERNAME" ;;
  }
  dimension: approved_by_username {
    type: string

    sql: ${TABLE}."APPROVED_BY_USERNAME" ;;
  }
  dimension: submitted_by_username {
    type: string

    sql: ${TABLE}."SUBMITTED_BY_USERNAME" ;;
  }

  dimension: book_of_business {
    type: string
label: "sage_book_of_business"
    sql: ${TABLE}."FT_BOOK_OF_BUSINESS" ;;
  }
  dimension: aftermarket_oec {
    type: string

    sql: ${TABLE}."AFTERMARKET_OEC" ;;
  }

  dimension: core_non_core_vehicles {
    type: string
label: "sage_core_designation"
    sql: ${TABLE}."FT_CORE_DESIGNATION" ;;
  }

  dimension: ft_financing_designation {
    type: string
    label: "sage_financing_designation"
    sql: ${TABLE}."FT_FINANCING_DESIGNATION" ;;
  }
  dimension: assigned_fleet_analyst {
    type: string

    sql: ${TABLE}."ASSIGNED_FLEET_ANALYST_" ;;
  }
  dimension: business_segment {
    type: string

    sql: ${TABLE}."BUSINESS_SEGMENT" ;;
  }

    dimension: vendor_id {
      type: string
      sql: ${TABLE}."VENDOR_ID" ;;
    }

    dimension: vendor_name {
      type:  string
      sql: ${TABLE}."VENDOR_NAME" ;;
    }

    dimension: order_number_grouped {
      type: string
      sql: ${TABLE}."ORDER_NUMBER_GROUPED" ;;
    }

    dimension: order_number {
      type: string
      sql: ${TABLE}."ORDER_NUMBER" ;;
    }

    dimension: asset_id {
      type: string
      value_format_name: id
      sql: ${TABLE}."ASSET_ID" ;;
    }

    dimension: order_status  {
      type: string
      sql: ${TABLE}."ORDER_STATUS" ;;
    }

    dimension: finance_status {
      type: string
      sql: ${TABLE}."FINANCE_STATUS" ;;
    }

    dimension: equipment_make {
      type: string
      sql: ${TABLE}."EQUIPMENT_MAKE" ;;
    }

    dimension: equipment_model  {
      type: string
      sql: ${TABLE}."EQUIPMENT_MODEL" ;;
    }

    dimension: model_year {
      type: string

      sql: ${TABLE}."MODEL_YEAR" ;;
    }

    dimension: owner_id {
      type: string
      value_format_name: id
      sql: ${TABLE}."OWNER_ID" ;;
    }

    dimension: owner_name {
      type: string
      sql: ${TABLE}."OWNER_NAME" ;;
    }

    # dimension: rule_id {
    #   type: number
    #   value_format_name: id
    #   sql: ${TABLE}."RULE_ID" ;;
    # }

    # dimension: rule_year {
    #   type: number
    #   value_format_name: id
    #   sql: ${TABLE}."RULE_YEAR" ;;
    # }

    # dimension: rule {
    #   type: string
    #   sql: ${TABLE}."RULE" ;;
    # }

    dimension_group: invoice {
      type: time
      timeframes: [
        raw,
        time,
        date,
        week,
        month,
        quarter,
        year
      ]
      sql: ${TABLE}."INVOICE_DATE" ;;
    }

    # dimension_group: release {
    #   type: time
    #   timeframes: [
    #     raw,
    #     time,
    #     date,
    #     week,
    #     month,
    #     quarter,
    #     year
    #   ]
    #   sql: ${TABLE}."RELEASE" ;;
    # }

    dimension: reimbursement_rate {
      type: string
      value_format_name: percent_0
      sql: ${TABLE}."REIMBURSEMENT_RATE" ;;
    }

    dimension: invoice_number {
      type: string
      sql: ${TABLE}."INVOICE_NUMBER" ;;
    }

    dimension: factory_build_specifications {
      type: string
      sql: ${TABLE}."FACTORY_BUILD_SPECIFICATIONS" ;;
    }

    dimension: serial_vin {
      label: "Serial_VIN"
      type: string
      sql: ${TABLE}."SERIAL_VIN" ;;
    }

    ################# MEASURES #################

    # measure: reimbursement_amount {
    #   type: sum
    #   value_format_name: usd
    #   drill_fields: [trx_details*]
    #   sql: ${TABLE}."REIMBURSEMENT_AMOUNT" ;;
    # }
  dimension: net_price_ {
    label: "Net Price"
    type: number
    value_format_name: usd
    sql: ${TABLE}."NET_PRICE" ;;
  }
  dimension: extended_price {
    type: number
    value_format: "$#,##0.00"
    sql: ${TABLE}."NET_PRICE" * ${TABLE}."QUANTITY";;
  }
  dimension: Qty {
    type: number
    sql: ${TABLE}."QUANTITY";;
  }
  dimension: class {
    type: string
    sql: ${TABLE}."CLASS";;
  }

  dimension: reconciliation_status {
    type: string
    sql: ${TABLE}."RECONCILIATION_STATUS" ;;
  }
  dimension: recon_status_w_statment_verification {
    type: string
    sql:
    CASE
      WHEN ${reconciliation_status} IN ('Reconciled', 'Reconciled. Aftermarket in progress', 'Second Reconciliation') THEN
        CASE
          WHEN ${order_status} = 'Received' THEN '2-Reconciled and Received'
          WHEN ${order_status} = 'Shipped' THEN '4-Reconciled and Shipped'
          ELSE '6-Reconciled and Not Shipped'
        END
      WHEN ${reconciliation_status} = 'Statement Verified' THEN
        CASE
          WHEN ${order_status} = 'Received' THEN '1-Statement Verified and Received'
          WHEN ${order_status} = 'Shipped' THEN '3-Statement Verified and Shipped'
          ELSE '5-Statement Verified and Not Shipped'
        END
      ELSE '7-Unreconciled'
    END ;;
    }
    dimension: latest_modified_date {
      type: date
      sql: ${TABLE}."MODIFIED_AT";;
    }
    dimension: latest_approved_date {
      type: date
      sql: ${TABLE}."APPROVED_AT";;
    }

    dimension: approval_status {
      type: string
      sql: CASE
        WHEN ${latest_modified_date} > ${latest_approved_date} THEN 'pending_approval'
        WHEN ${latest_modified_date} < ${latest_approved_date} THEN 'approved'
        WHEN ${latest_approved_date} is not null and ${latest_modified_date} is null THEN 'approved'
        ELSE 'unknown'
       END ;;
    }
    dimension: freight_cost {
    type: number
    sql: ${TABLE}."FREIGHT_COST";;
  }
  dimension: sales_tax {
    type: number
    sql: ${TABLE}."SALES_TAX";;
  }
  dimension: note {
    type: string
    sql: ${TABLE}."NOTE";;
  }
  dimension: attachments {
    type: string
    sql: ${TABLE}."ATTACHMENTS";;
  }
  dimension: release_date {
    type: string
    sql: ${TABLE}."RELEASE_DATE";;
  }
  dimension: total_oec_ {
    label: "Total OEC"
    type: number
    drill_fields: [details*]
    value_format_name: usd
    sql: ${TABLE}."TOTAL_OEC"
      ;;
  }
  dimension: sage_vendor_id {
    label: "sage_vendor_id"
    type: string

    sql: ${TABLE}."SAGE_VENDOR_ID"
      ;;
  }
  dimension: due_date {
    type: date
    sql: ${TABLE}."CO_DUE_DATE" ;;
    #sql: add_days(${net_terms_days_to_use},${asset_purchase_created_date_snowflake.asset_purchase_created_date}) ;;
  }
  dimension: net_terms {
    type: string
    sql: ${TABLE}."NET_TERMS" ;;
  }

  dimension: net_terms_days {
    type: number
    sql: ${TABLE}."NET_TERMS_DAYS" ;;
  }
  dimension: net_terms_days_to_use {
    type: number
    sql: case when ${net_terms_days} is null then 30 else ${net_terms_days} end ;;
  }

  dimension: days_until_due {
    type: number
    #sql: DATE_PART('day', ${due_date}::timestamp - CURRENT_TIMESTAMP()::timestamp)  ;;
    #sql: datediff(day, ${due_date} , CURRENT_TIMESTAMP())  ;;
    sql: datediff(day, CURRENT_TIMESTAMP() , ${due_date})  ;;
  }
    measure: net_price {
      label: "Sum of Net Pice"
      type: sum
      value_format_name: usd
      sql: ${TABLE}."NET_PRICE" ;;
    }
  dimension: manual_overide_due_date {
    type: date
    sql: ${TABLE}."NEW_DUE_DATE";;
  }

  dimension: title_status {
    type: string
    sql: ${TABLE}."TITLE_STATUS";;
  }
  dimension: pending_schedule {
    type: string
    sql: ${TABLE}."PENDING_SCHEDULE";;
  }
    measure: total_oec {
      label: "Sum Total OEC"
      type: sum
      drill_fields: [details*]
      value_format_name: usd
      sql: ${TABLE}."TOTAL_OEC"
      ;;
    }

    measure: oec_less_tax {
      label: "OEC Less Tax"
      type: sum
      value_format_name: usd
      sql: ${TABLE}."OEC_LESS_TAX" ;;
    }
  measure: count {
    type: count
    drill_fields: [details*]
  }
################# DRILL FIELDS #################

    set: details {
      fields: [vendor_name,vendor_id,order_number,order_number_grouped,asset_id,serial_vin,invoice_number,invoice_date,
        order_status,finance_status,equipment_make,equipment_model,model_year,factory_build_specifications,owner_id,owner_name,
        net_price,total_oec, assigned_fleet_analyst, category, book_of_business, core_non_core_vehicles
      ]
    }















  }
