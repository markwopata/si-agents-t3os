
view: unapproved_branch_invoices_action_items {
  derived_table: {
    sql: select i.INVOICE_NO,
                i.DATE_CREATED as invoice_created_date,
                i.SALESPERSON_USER_ID,
                coalesce(case when position(' ',coalesce(cd.NICKNAME,cd.FIRST_NAME)) = 0 then concat(coalesce(cd.NICKNAME,cd.FIRST_NAME), ' ', cd.LAST_NAME)
                      else concat(coalesce(cd.NICKNAME,concat(cd.FIRST_NAME, ' ',cd.LAST_NAME))) end, concat(u.first_name,' ',u.last_name)) as salesperson_full_name,
                o.MARKET_ID,
                xw.MARKET_NAME,
                xw.DISTRICT,
                xw.REGION_NAME
            from ES_WAREHOUSE.PUBLIC.INVOICES i
                 left join ES_WAREHOUSE.PUBLIC.ORDERS o on i.ORDER_ID = o.ORDER_ID
                 left join ES_WAREHOUSE.PUBLIC.USERS u on i.SALESPERSON_USER_ID = u.USER_ID
                 left join ANALYTICS.PAYROLL.COMPANY_DIRECTORY cd on u.EMAIL_ADDRESS = cd.WORK_EMAIL
                 left join ANALYTICS.PUBLIC.MARKET_REGION_XWALK xw on o.MARKET_ID = xw.MARKET_ID
            where BILLING_APPROVED = false
            AND i.EXTENDED_DATA IS NULL OR i.EXTENDED_DATA = '{}';;
  }

  measure: count {
    type: count
  }

  dimension: invoice_number {
    type: string
    sql: ${TABLE}."INVOICE_NO" ;;
    html: <font color="0063f3 "><u><a href="https://admin.equipmentshare.com/#/home/transactions/invoices/search?query={{invoice_number}}" target="_blank">{{ invoice_number._value }}</a></font></u> ;;
  }

  dimension_group: invoice_created {
    type: time
    sql: ${TABLE}."INVOICE_CREATED_DATE" ;;
  }

  dimension: salesperson_user_id {
    type: number
    sql: ${TABLE}."SALESPERSON_USER_ID" ;;
  }

  dimension: salesperson {
    type: string
    sql: ${TABLE}."SALESPERSON_FULL_NAME" ;;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: region {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }
}
