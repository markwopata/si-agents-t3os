view: ar_transaction_recon_5000 {

  derived_table: {
    sql:
select mk.MARKET_ID,
       mk.NAME,
       c.name                                                                                        customer_name,
       c.company_id,
       i.invoice_no,
       CONVERT_TIMEZONE('UTC', 'America/Chicago',i.billing_approved_date::TIMESTAMP) AS BILLING_APPROVED_DATE,
       lit.name                                                                                      line_type,
       li.ASSET_ID                                                                                   ASSET_ID,
       sum(li.amount)                                                                                amount,
       li.rental_id,
       li.EXTENDED_DATA AS                                                                           ALL_DATA,
       'https://admin.equipmentshare.com/#/home/transactions/invoices/search?query=' || i.invoice_no url,
       'Invoices'                                                                                    source
       ,drop_off.SCHEDULED_DATE as delivery_scheduled_date,
       drop_off.COMPLETED_DATE as delivery_completed_date
       ,FR.SCHEDULED_DATE as return_scheduled_date,
       fr.COMPLETED_DATE as return_completed_date
from ES_WAREHOUSE.public.invoices i
         left join ES_WAREHOUSE.PUBLIC.MARKETS mk
                   on i.SHIP_FROM:branch_id::STRING = mk.MARKET_ID::STRING
         join es_warehouse.public.LINE_ITEMS li
              on i.INVOICE_id = li.invoice_id
         join ES_WAREHOUSE.public.LINE_ITEM_TYPES lit
              on li.LINE_ITEM_TYPE_ID = lit.LINE_ITEM_TYPE_ID
         join es_warehouse.public.companies c
              on i.COMPANY_ID = c.COMPANY_ID
         left join (select *
                    from ES_WAREHOUSE.PUBLIC.DELIVERIES
                    where DELIVERY_TYPE_ID = 1
                    and DELIVERY_STATUS_ID <> 4
                    qualify rank() over (partition by RENTAL_ID, ASSET_ID order by COMPLETED_DATE) = 1
                    ) drop_off
              on li.RENTAL_ID = drop_off.RENTAL_ID
                and li.ASSET_ID = drop_off.ASSET_ID
        left join (select *
                    from ES_WAREHOUSE.PUBLIC.DELIVERIES
                    where DELIVERY_TYPE_ID = 6
                    and DELIVERY_STATUS_ID <> 4
                    qualify rank() over (partition by RENTAL_ID, ASSET_ID order by COMPLETED_DATE desc) = 1
                    ) FR --FR: final return
              on li.RENTAL_ID = FR.RENTAL_ID
                and li.ASSET_ID = fr.ASSET_ID
where li.LINE_ITEM_TYPE_ID in (6, 8, 44, 108, 109)       -- Line items going to 5000 per Josh Bromer as of January-2022
  --and date_trunc(month, i.BILLING_APPROVED_DATE) = '2022-02-01'::date
  and i.COMPANY_ID not in (1854, 1855, 8151, 420, 61036) -- Exclude intercompany
group by i.invoice_no, CONVERT_TIMEZONE('UTC', 'America/Chicago',i.billing_approved_date::TIMESTAMP) , c.name, c.company_id, lit.name,
         'https://admin.equipmentshare.com/#/home/transactions/invoices/search?query=' || i.invoice_no, li.rental_id,
         mk.Market_ID, mk.NAME, li.ASSET_ID, ALL_DATA, drop_off.SCHEDULED_DATE, drop_off.COMPLETED_DATE,
         fr.SCHEDULED_DATE, fr.COMPLETED_DATE

union all

SELECT mk.MARKET_ID,
       mk.NAME,
       c.name                                                                                        customer_name,
       c.company_id,
       cn.credit_note_number                           invoice_no,
       CONVERT_TIMEZONE('UTC', 'America/Chicago',CN.DATE_CREATED::TIMESTAMP) AS BILLING_APPROVED_DATE,
       lit.name                                                                                      line_type,
       li.ASSET_ID                                                                                   ASSET_ID,
       sum(-cnli.credit_amount)                                                                               amount,
       NULL                           AS rental_id,
       li.EXTENDED_DATA AS                                                                           ALL_DATA,
       'https://admin.equipmentshare.com/#/home/transactions/credit-notes/search?query='
       || cn.credit_note_number     AS url,
       'Credit Notes'                                                                                    source,
       drop_off.SCHEDULED_DATE as delivery_scheduled_date,
       drop_off.COMPLETED_DATE as delivery_completed_date
       ,FR.SCHEDULED_DATE as return_scheduled_date,
       fr.COMPLETED_DATE as return_completed_date
FROM es_warehouse.public.credit_note_line_items cnli
LEFT JOIN es_warehouse.public.credit_notes cn
  ON cn.CREDIT_NOTE_ID = cnli.CREDIT_NOTE_ID
LEFT JOIN es_warehouse.public.line_items li
  ON cnli.LINE_ITEM_ID = li.LINE_ITEM_ID
LEFT JOIN es_warehouse.public.invoices i
  ON li.INVOICE_ID = i.INVOICE_ID
LEFT JOIN es_warehouse.public.markets mk
  ON cn.SHIP_FROM:branch_id::STRING = mk.MARKET_ID::STRING
JOIN es_warehouse.public.line_item_types lit
  ON cnli.LINE_ITEM_TYPE_ID = lit.LINE_ITEM_TYPE_ID
JOIN es_warehouse.public.companies c
  ON cn.COMPANY_ID = c.COMPANY_ID
LEFT JOIN (
  SELECT *
  FROM es_warehouse.public.deliveries
  WHERE delivery_type_id   = 1
    AND delivery_status_id <> 4
  QUALIFY ROW_NUMBER()
    OVER (PARTITION BY rental_id, asset_id ORDER BY completed_date) = 1
) drop_off
  ON li.rental_id = drop_off.rental_id
 AND li.asset_id  = drop_off.asset_id
LEFT JOIN (
  SELECT *
  FROM es_warehouse.public.deliveries
  WHERE delivery_type_id   = 6
    AND delivery_status_id <> 4
  QUALIFY ROW_NUMBER()
    OVER (PARTITION BY rental_id, asset_id ORDER BY completed_date DESC) = 1
) fr
  ON li.rental_id = fr.rental_id
 AND li.asset_id  = fr.asset_id
LEFT JOIN es_warehouse.public.credit_note_statuses cns
  ON cns.credit_note_status_id = cn.credit_note_status_id
WHERE cnli.line_item_type_id    IN (6, 8, 44, 108, 109)
  AND cn.company_id             NOT IN (1854, 1855, 8151, 420, 61036)
  AND cn.credit_note_status_id = 2
GROUP BY
  mk.market_id,
  mk.name,
  c.name,
  c.company_id,
  cn.credit_note_number,
  CONVERT_TIMEZONE(
    'UTC',
    'America/Chicago',
    cn.DATE_CREATED::TIMESTAMP
  ),
  lit.name,
  li.asset_id,
  li.extended_data,
  drop_off.scheduled_date,
  drop_off.completed_date,
  fr.scheduled_date,
  fr.completed_date



                         ;;
  }
  dimension: Market_ID {
    type: number
    value_format_name: id
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: Market_Name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension: customer_name {
    type: string
    sql: ${TABLE}."CUSTOMER_NAME" ;;
  }

  dimension: invoice_no {
    type: string
    sql: ${TABLE}."INVOICE_NO" ;;
  }

  dimension: billing_approved_date {
    type: date_time
    convert_tz: no
    sql: ${TABLE}."BILLING_APPROVED_DATE" ;;
  }

  dimension: ALL_DATA {
    type: string
    sql: ${TABLE}."ALL_DATA" ;;
  }

  dimension: Bill_Cycle_Start_Date {
    type: date
    datatype: timestamp
    sql: ${ALL_DATA}:rental.equipment_assignments[0].start_date;;
  }

  dimension: Bill_Cycle_End_Date {
    type: date
    datatype: timestamp
    sql: ${ALL_DATA}:rental.equipment_assignments[0].end_date;;
  }

  dimension: part_id {
    type: string
    sql: ${ALL_DATA}:part_id;;
  }

  dimension: line_type {
    type: string
    sql: ${TABLE}."LINE_TYPE" ;;
  }

  dimension: amount {
    type: number
    sql: ${TABLE}."AMOUNT" ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: rental_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."RENTAL_ID" ;;
  }

  dimension: url {
    type: string
    #html:
    #<font color="blue "><u><a href = "{{ url._value }}" target="_blank">Link to Admin</a></font></u>
       # ;;
    sql: ${TABLE}."URL" ;;
    }


  dimension: source {
    type: string
    sql: ${TABLE}."SOURCE" ;;
  }


  dimension: delivery_scheduled_date {
    type: date_time
    convert_tz: no
    sql: ${TABLE}."DELIVERY_SCHEDULED_DATE" ;;
  }

  dimension: delivery_completed_date {
    type: date_time
    convert_tz: no
    sql: ${TABLE}."DELIVERY_COMPLETED_DATE" ;;
  }

  dimension: return_scheduled_date {
    type: date_time
    convert_tz: no
    sql: ${TABLE}."RETURN_SCHEDULED_DATE" ;;
  }

  dimension: return_completed_date {
    type: date_time
    convert_tz: no
    sql: ${TABLE}."RETURN_COMPLETED_DATE" ;;
  }

  dimension: company_id {
    type: string
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  }
