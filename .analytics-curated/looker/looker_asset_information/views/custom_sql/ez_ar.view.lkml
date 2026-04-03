view: ez_ar {
  derived_table: {
    sql:
  with main_query as (
select i.COMPANY_ID, a.asset_id, li.invoice_id, sum(coalesce(aph.oec,aph.PURCHASE_PRICE)) as OEC,
sum(i.OWED_AMOUNT) as INVOICE_AMT, 'Y' as is_ez
from ES_WAREHOUSE.PUBLIC.INVOICES i
inner join (select distinct ASSET_ID, description, INVOICE_ID, line_item_type_id from ES_WAREHOUSE.PUBLIC.LINE_ITEMS) as li
on i.INVOICE_ID = li.INVOICE_ID
inner join ACCOUNT_MAPPING.LINE_ITEM_TYPES_MAPPING as litm
on li.LINE_ITEM_TYPE_ID = litm.LINE_ITEM_TYPE_ID and litm.DIVISION = 'own'
inner join ES_WAREHOUSE.PUBLIC.ASSETS as a
on coalesce(li.ASSET_ID,regexp_substr(li.description,'Asset: (\\d{1,})', 1, 1, 'e')::int) = a.ASSET_ID
inner join ES_WAREHOUSE.PUBLIC.ASSET_PURCHASE_HISTORY as aph
on a.ASSET_ID = aph.ASSET_ID
where i.BILLING_APPROVED
and i.COMPANY_ID in (6954, 3133, 5440)
and i.OWED_AMOUNT > 0
group by i.COMPANY_ID, a.ASSET_ID, li.invoice_id, aph.oec),
invoice_oec_query as (
select INVOICE_ID, sum(oec) as invoice_oec
from main_query as mq
group by INVOICE_ID
    )
select mq.*, io.invoice_oec, mq.OEC/io.INVOICE_oec as pct_oec, pct_oec*mq.INVOICE_AMT as asset_invoice_amt
from main_query as mq
left join invoice_oec_query as io
on mq.INVOICE_ID = io.INVOICE_ID    ;;
  }


  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: asset_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: invoice_id {
    type: number
    sql: ${TABLE}."INVOICE_ID" ;;
  }

  dimension: invoice_amt {
    type: number
    sql: ${TABLE}."INVOICE_AMT" ;;
  }

  dimension: is_ez {
    type: string
    sql: ${TABLE}."IS_EZ"  ;;
  }

  measure: oec {
    type: number
    sql: ${TABLE}."OEC"  ;;
  }

  measure: invoice_oec {
    type: number
    sql: ${TABLE}."INVOICE_OEC"  ;;
  }

  measure: pct_oec {
    type: number
    sql: ${TABLE}."PCT_OEC"  ;;
  }

  measure: asset_invoice_amount {
    type: sum
    sql: ${TABLE}."ASSET_INVOICE_AMT"  ;;
  }

  measure: total_asset_invoice_amount {
    type: sum
    drill_fields: [fleet_details*]
    sql: ${TABLE}."ASSET_INVOICE_AMT"  ;;
  }

  set: fleet_details {
    fields: [ez_ar.asset_id,ez_ar.company_id,asset_purchase_history.finance_status,asset_purchase_history.financial_schedule_id,
      asset_purchase_history.order_number_fleet,assets.asset_class,assets.year,assets.make,assets.model,assets.serial_number_vin,
      asset_purchase_history.invoice_number_fleet,markets.location, assets.factory_build_specs,
      asset_purchase_history.total_purchase_price,assets.purchase_created_date,net_terms_finance_status.due_date,net_terms_finance_status.days_until_due,
      asset_purchase_history.purchase_order_number,asset_purchase_history.pending_schedule, aph_vendor.vendor_id, aph_vendor.vendor_name,ez_ar.asset_invoice_amount]
  }

  }
