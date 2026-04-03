view: incorrect_onsite_fueling_reporting {
  derived_table: {
    sql:

SELECT
    DISTINCT
INVOICE_ID
FROM ANALYTICS.PUBLIC.V_LINE_ITEMS v
WHERE v.LINE_ITEM_TYPE_ID IN (129,130,131,132,138,142)
  and v.NUMBER_OF_UNITS = 1
  and v.PRICE_PER_UNIT <=360

and Invoice_id in (
SELECT
DISTINCT INVOICE_ID
FROM ANALYTICS.PUBLIC.V_LINE_ITEMS v
WHERE v.LINE_ITEM_TYPE_ID IN (98,99,100,101,102,103,104,105))
            ;;
  }

  dimension: invoice_id {
    type: string
    sql: ${TABLE}.invoice_id ;;
  }

  }
