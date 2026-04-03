view: qbr_financial {
    derived_table: {
      sql:
--script for combining regular oec and upfitting costs
with regular_oec as (
      SELECT
      c.company_purchase_order_id as order_number,
      eq.name class,
      po.VIN,
      --ec.equipment_class_id,
      invoice_date,
      sum(hours) as hours,
      --left(invoice_date,7) as invoice_month,
      sum(quantity) as units,
      sum(coalesce(po.NET_PRICE,0))+sum(coalesce(po.freight_cost,0)) as total_oec

      FROM  ES_WAREHOUSE.PUBLIC.assets a
      LEFT JOIN  ES_WAREHOUSE.PUBLIC.COMPANY_PURCHASE_ORDER_LINE_ITEMS po
        on po.asset_id = a.asset_id
      LEFT JOIN ES_WAREHOUSE.PUBLIC.COMPANY_PURCHASE_ORDERS c
        ON po.COMPANY_PURCHASE_ORDER_ID = c.COMPANY_PURCHASE_ORDER_ID
      LEFT JOIN ES_WAREHOUSE.PUBLIC.COMPANY_PURCHASE_ORDER_TYPES t
        ON t.COMPANY_PURCHASE_ORDER_TYPE_ID = c.COMPANY_PURCHASE_ORDER_TYPE_ID
      left join ES_WAREHOUSE.PUBLIC.EQUIPMENT_MODELS m
        on m.equipment_model_id = po.equipment_model_id
      left join ES_WAREHOUSE.PUBLIC.EQUIPMENT_CLASSES_MODELS_XREF ec
        on m.equipment_model_id = ec.equipment_model_id
      left join ES_WAREHOUSE.PUBLIC.EQUIPMENT_CLASSES eq
        on eq.equipment_class_id = ec.equipment_class_id


      WHERE (po.FINANCE_STATUS NOT LIKE '%Retail%'
      AND po.FINANCE_STATUS NOT LIKE '%Dealership%' OR po.FINANCE_STATUS IS NULL)
      AND ((TO_CHAR(TO_DATE(CONVERT_TIMEZONE('UTC', 'America/Chicago', CAST(CAST(po.DELETED_AT AS TIMESTAMP_NTZ) AS TIMESTAMP_NTZ))), 'YYYY-MM-DD')) IS NULL
      and (c.APPROVED_BY_USER_ID is not null ))
      and ec.equipment_class_id in (select distinct equipment_class_id
      from es_warehouse.public.assets_aggregate
      where asset_type_id in (2, 3)) -- 2 = vehicle 3 = trailers

      and invoice_date is not null

      group by
      order_number,
      eq.name,
      po.VIN,
      --ec.equipment_class_id,
      invoice_date
  )

, upfit_oec as (
      select
      concat(cpt.prefix, 'PO',POL.COMPANY_PURCHASE_ORDER_ID,'-',POL.COMPANY_PURCHASE_ORDER_LINE_ITEM_NUMBER) AS ORDER_NUMBER,
      --POL.YEAR,POL.FACTORY_BUILD_SPECIFICATIONS,POL.ATTACHMENTS,POL.NET_PRICE
      eq.name class,
      serial as VIN,
      invoice_date,
      --left(invoice_date,7) as invoice_month,
      sum(quantity) as units,
      sum(coalesce(POL.NET_PRICE,0))+sum(coalesce(POL.freight_cost,0)) as total_oec

      FROM  ES_WAREHOUSE.PUBLIC.COMPANY_PURCHASE_ORDER_LINE_ITEMS POL
      LEFT JOIN ES_WAREHOUSE.PUBLIC.COMPANY_PURCHASE_ORDERS AS PO
          ON POL.COMPANY_PURCHASE_ORDER_ID = PO.COMPANY_PURCHASE_ORDER_ID
      LEFT JOIN ES_WAREHOUSE.PUBLIC.COMPANY_PURCHASE_ORDER_TYPES AS CPT
          ON PO.COMPANY_PURCHASE_ORDER_TYPE_ID = CPT.COMPANY_PURCHASE_ORDER_TYPE_ID
      left join ES_WAREHOUSE.PUBLIC.EQUIPMENT_CLASSES eq
          on eq.equipment_class_id = POL.equipment_class_id

      --these filters are in the other
      WHERE (POL.FINANCE_STATUS NOT LIKE '%Retail%'
      AND POL.FINANCE_STATUS NOT LIKE '%Dealership%' OR POL.FINANCE_STATUS IS NULL)
      AND ((TO_CHAR(TO_DATE(CONVERT_TIMEZONE('UTC', 'America/Chicago', CAST(CAST(POL.DELETED_AT AS TIMESTAMP_NTZ) AS TIMESTAMP_NTZ))), 'YYYY-MM-DD')) IS NULL
      and (po.APPROVED_BY_USER_ID is not null ))
      --removed these because upfitting should not be tagged as these asset types
      --//and eq.equipment_class_id in (select distinct equipment_class_id
      --//from es_warehouse.public.assets_aggregate
      --//where asset_type_id in (2, 3)) -- 2 = vehicle 3 = trailers
      and POL.DELETED_AT IS NULL
      AND cpt.PREFIX = 'B'
      AND invoice_date is not NULL

      group by
      concat(cpt.prefix, 'PO',POL.COMPANY_PURCHASE_ORDER_ID,'-',POL.COMPANY_PURCHASE_ORDER_LINE_ITEM_NUMBER),
      eq.name,
      serial,
      invoice_date
)

--join them on VIN
select
    r.order_number, u.order_number as upfitting_order_number,
    r.class, u.class as upfitting_class,
    r.invoice_date, u.invoice_date as upfitting_invoice_date,
    sum(r.units) as regular_units, sum(u.units) as upfit_units,
    sum(r.total_oec) as regular_total_oec, sum(u.total_oec) as upfit_total_oec,
    sum(r.hours) as hours
from regular_oec r
left join upfit_oec u on r.VIN = u.VIN

group by
r.order_number, u.order_number,
    r.class, u.class,
    r.invoice_date, u.invoice_date
;;
    }

    dimension: order_number {
      type: string
      sql: ${TABLE}.order_number ;;
    }

    dimension: upfitting_order_number {
      type: string
      sql: ${TABLE}.upfitting_order_number ;;
    }

    dimension: class {
      type: string
      sql: ${TABLE}.class ;;
    }

    dimension: upfitting_class {
      type: string
      sql: ${TABLE}.upfitting_class ;;
    }

    dimension_group: invoice_date {
      type: time
      timeframes: [raw,date,time,week,month,quarter,year]
      sql:  ${TABLE}.invoice_date ;;
    }

    dimension_group: upfitting_invoice_date {
      type: time
      timeframes: [raw,date,time,week,month,quarter,year]
      sql:  ${TABLE}.upfitting_invoice_date ;;
    }

    measure: regular_units {
      type: sum
      value_format: "0"
      sql: ${TABLE}.regular_units ;;
    }

    measure: upfit_units {
      type: sum
      value_format: "0"
      sql: ${TABLE}.upfit_units ;;
    }

    measure: regular_total_oec {
      type: sum
      value_format_name:usd
      value_format: "$#,##0.00"
      sql:${TABLE}.regular_total_oec;;
    }

    measure: upfit_total_oec {
      type: sum
      value_format_name:usd
      value_format: "$#,##0.00"
      sql:${TABLE}.upfit_total_oec ;;
    }

  measure: hours {
    type: sum
    value_format: "0"
    sql:${TABLE}.hours ;;
  }

    dimension: primary_key {
      primary_key: yes
      type:  string
      sql:CAST(concat(${order_number},${upfitting_order_number},${invoice_date_date},${invoice_date_date}) as VARCHAR) ;;
    }

  }
