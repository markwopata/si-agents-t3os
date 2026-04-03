view: consumables {
  derived_table: {
    sql:
      select i.INVOICE_DATE as INVOICE_DATE,
       c.COMPANY_ID,
       c.NAME                                   as COMPANY_NAME,
       m.MARKET_ID,
       m.NAME                                   as MARKET_NAME,
       i.INVOICE_ID,
       li.LINE_ITEM_ID,
       concat(u.FIRST_NAME, ' ', u.LAST_NAME)   as ORDERED_BY_USER,
       li.AMOUNT,
       li.EXTENDED_DATA:part_id                 as PART_ID,
       li.EXTENDED_DATA:part_number             as PART_NUMBER,
       p.SEARCH,
       i.BILLING_APPROVED,
       li.NUMBER_OF_UNITS,
       sp.MIN,
       sp.MAX,
       sp.AVAILABLE_QUANTITY,
      concat(u2.FIRST_NAME, ' ', u2.LAST_NAME) as SCAN_USER,
      i.ORDERED_BY_USER_ID
from ES_WAREHOUSE.PUBLIC.INVOICES i
         join ES_WAREHOUSE.PUBLIC.LINE_ITEMS li
              on i.INVOICE_ID = li.INVOICE_ID
         join ES_WAREHOUSE.PUBLIC.COMPANIES c
              on i.COMPANY_ID = c.COMPANY_ID
         join ES_WAREHOUSE.PUBLIC.MARKETS m
              on i.SHIP_FROM:branch_id = m.MARKET_ID
         left join ES_WAREHOUSE.PUBLIC.USERS u
                   on i.ORDERED_BY_USER_ID = u.USER_ID
         left join ES_WAREHOUSE.PUBLIC.USERS u2
                   on i.CREATED_BY_USER_ID = u2.USER_ID
         left join ES_WAREHOUSE.INVENTORY.PARTS p
                   on li.EXTENDED_DATA:part_id = p.PART_ID
         left join (select STORE_PARTS.PART_ID,
                           STORES.BRANCH_ID,
                           STORE_PARTS.THRESHOLD as min,
                           STORE_PARTS.max,
                           STORE_PARTS.AVAILABLE_QUANTITY
                    from ES_WAREHOUSE.INVENTORY.STORE_PARTS
                             join ES_WAREHOUSE.INVENTORY.STORES
                                  on STORE_PARTS.STORE_ID = STORES.STORE_ID) sp
                   on li.EXTENDED_DATA:part_id = sp.PART_ID
                       and i.SHIP_FROM:branch_id = sp.BRANCH_ID
where li.LINE_ITEM_TYPE_ID = 49
;;
    }

  dimension_group: invoice_date {
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
    convert_tz: yes
  }

  dimension: invoice_date_timestamp {
    type: date_time
    sql: ${invoice_date_time}" ;;
    convert_tz: yes
  }

  dimension: company_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  dimension: market_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: invoice_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."INVOICE_ID" ;;
  }

  dimension: line_item_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."LINE_ITEM_ID" ;;
    primary_key: yes
  }

  dimension: ordered_by_user {
    type: string
    sql: ${TABLE}."ORDERED_BY_USER" ;;
  }
  dimension: user_id {
    type: string
    sql: ${TABLE}."ORDERED_BY_USER_ID" ;;
  }

  dimension: amount {
    type: number
    sql: ${TABLE}."AMOUNT" ;;
  }

  dimension: part_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."PART_ID" ;;
  }

  dimension: part_number {
    type: string
    sql: ${TABLE}."PART_NUMBER" ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."SEARCH" ;;
  }

  dimension: billing_approved {
    type: yesno
    sql: ${TABLE}."BILLING_APPROVED" ;;
  }

  dimension: number_of_units {
    type: number
    sql: ${TABLE}."NUMBER_OF_UNITS" ;;
  }

  dimension: min {
    type: number
    sql: ${TABLE}."MIN" ;;
  }

  dimension: max {
    type: number
    sql: ${TABLE}."MAX" ;;
  }

  dimension: available_quantity {
    type: number
    sql: ${TABLE}."AVAILABLE_QUANTITY" ;;
  }

  dimension: scan_user {
    type: string
    sql: ${TABLE}."SCAN_USER" ;;
  }

  }
