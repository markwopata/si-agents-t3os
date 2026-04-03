connection: "es_snowflake"

include: "/views/*.view.lkml"                # include all views in the views/ folder in this project
# include: "/**/*.view.lkml"                 # include all views in this project
# include: "my_dashboard.dashboard.lookml"   # include a LookML dashboard called my_dashboard

# # Select the views that should be a part of this model,
# # and define the joins that connect them together.
#

view: ar_transaction_recon_5000 {

  derived_table: {
    sql:

select mk.MARKET_ID,
       mk.NAME,
       c.name                                                                                        customer_name,
       i.invoice_no,
       CONVERT_TIMEZONE('UTC', 'America/Chicago', I.BILLING_APPROVED_DATE::TIMESTAMP) AS BILLING_APPROVED_DATE,
       lit.name                                                                                      line_type,
       li.ASSET_ID                                                                                   ASSET_ID,
       sum(li.amount)                                                                                amount,
       li.rental_id,
       'https://admin.equipmentshare.com/#/home/transactions/invoices/search?query=' || i.invoice_no url,
       'Invoices'                                                                                    source
from ES_WAREHOUSE.public.invoices i
         left join ES_WAREHOUSE.PUBLIC.MARKETS mk
                   on i.SHIP_FROM:branch_id::STRING = mk.MARKET_ID::STRING
         join es_warehouse.public.LINE_ITEMS li
              on i.INVOICE_id = li.invoice_id
         join ES_WAREHOUSE.public.LINE_ITEM_TYPES lit
              on li.LINE_ITEM_TYPE_ID = lit.LINE_ITEM_TYPE_ID
         join es_warehouse.public.companies c
              on i.COMPANY_ID = c.COMPANY_ID
where li.LINE_ITEM_TYPE_ID in (6, 8, 44, 108, 109)       -- Line items going to 5000 per Josh Bromer as of January-2022
  --and date_trunc(month, i.BILLING_APPROVED_DATE) = '2022-02-01'::date
  and i.COMPANY_ID not in (1854, 1855, 8151, 420, 61036) -- Exclude intercompany
group by i.invoice_no, CONVERT_TIMEZONE('UTC', 'America/Chicago', I.BILLING_APPROVED_DATE::TIMESTAMP), c.name, lit.name,
         'https://admin.equipmentshare.com/#/home/transactions/invoices/search?query=' || i.invoice_no, li.rental_id,
         mk.Market_ID, mk.NAME,
         li.ASSET_ID
union all
select mk.MARKET_ID,
       mk.NAME,
       c.name                                                                                                     customer_name,
       cn.credit_note_number                                                                                      invoice_no,
       CONVERT_TIMEZONE('UTC', 'America/Chicago', CN.DATE_CREATED::TIMESTAMP) AS BILLING_APPROVED_DATE,

       lit.name                                                                                                   line_type,
       li.asset_id                                                                                                ASSET_ID,
       sum(-cnli.credit_amount)                                                                                   amount,
       null                                                                                                       rental_id,
       'https://admin.equipmentshare.com/#/home/transactions/credit-notes/search?query=' || cn.credit_note_number url,
       'Credit Notes'                                                                                             source
from ES_WAREHOUSE.PUBLIC.LINE_ITEMS AS LI
         LEFT JOIN ES_WAREHOUSE.PUBLIC.INVOICES AS I
                   ON LI.INVOICE_ID = I.INVOICE_ID
         left join es_warehouse.public.CREDIT_NOTES cn
                   on CN.ORIGINATING_INVOICE_ID = I.INVOICE_ID
         left join ES_WAREHOUSE.PUBLIC.MARKETS mk
                   on cn.SHIP_FROM:branch_id::STRING = mk.MARKET_ID::STRING
         join ES_WAREHOUSE.PUBLIC.CREDIT_NOTE_LINE_ITEMS cnli
              on cn.CREDIT_NOTE_ID = cnli.CREDIT_NOTE_ID
                  and CNLI.LINE_ITEM_ID = LI.LINE_ITEM_ID
         join ES_WAREHOUSE.public.LINE_ITEM_TYPES lit
              on cnli.LINE_ITEM_TYPE_ID = lit.LINE_ITEM_TYPE_ID
         join ES_WAREHOUSE.public.companies c
              on cn.COMPANY_ID = c.COMPANY_ID
--where date_trunc(month, cn.DATE_CREATED) = '2022-02-01'::date
where cnli.LINE_ITEM_TYPE_ID in (6, 8, 44, 108, 109)
  and cn.COMPANY_ID not in (1854, 1855, 8151, 420, 61036) -- Exclude intercompany
group by c.name, cn.credit_note_number, CONVERT_TIMEZONE('UTC', 'America/Chicago', CN.DATE_CREATED::TIMESTAMP) AS BILLING_APPROVED_DATE,, lit.name,
         'https://admin.equipmentshare.com/#/home/transactions/credit-notes/search?query=' || cn.credit_note_number,
         mk.Market_ID, mk.NAME, li.ASSET_ID
order by customer_name, invoice_no, line_type
                         ;;
  }

  dimension: Market_ID {
    type: number
    value_format_name: id
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: Branch_name {
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

  dimension: line_type {
    type: string
    sql: ${TABLE}."LINE_TYPE" ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: amount {
    type: number
    sql: ${TABLE}."AMOUNT" ;;
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


  }
