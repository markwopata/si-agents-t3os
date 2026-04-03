view: company_salesperson_relationship {
  derived_table: {
    sql:
      SELECT DISTINCT
          oo.COMPANY_ID,
          o.ORDER_CREATED_DATE ,
          o.PRIMARY_SALESPERSON_USER_ID,
          mrx.MARKET_ID,
          mrx.DISTRICT,
          mrx.REGION_NAME,
          cd.WORK_EMAIL as SALESPERSON_EMAIL,
          CONCAT(TRIM(u.FIRST_NAME), ' ', TRIM(u.LAST_NAME)) AS SALESPERSON_NAME,
          cd.EMPLOYEE_TITLE,
          CONCAT(cd2.FIRST_NAME, ' ', cd2.LAST_NAME) AS MANAGER_NAME,
          cd.EMPLOYEE_STATUS
      FROM FLEET_OPTIMIZATION.GOLD.DIM_ORDERS_FLEET_OPT o
      left join ES_WAREHOUSE.PUBLIC.ORDERS as oo on oo.ORDER_ID = o.order_id
      LEFT JOIN  ES_WAREHOUSE.PUBLIC.RENTALS r ON o.order_id = r.order_id
      LEFT JOIN ES_WAREHOUSE.PUBLIC.LINE_ITEMS li ON r.RENTAL_ID = li.RENTAL_ID
      LEFT JOIN ES_WAREHOUSE.PUBLIC.INVOICES i ON li.INVOICE_ID = i.INVOICE_ID
      LEFT JOIN ANALYTICS.PUBLIC.MARKET_REGION_XWALK mrx ON mrx.MARKET_ID = oo.MARKET_ID
      LEFT JOIN ES_WAREHOUSE.PUBLIC.USERS u ON o.PRIMARY_SALESPERSON_USER_ID = u.USER_ID
      LEFT JOIN PAYROLL.COMPANY_DIRECTORY cd ON cd.WORK_EMAIL = u.EMAIL_ADDRESS AND cd.EMPLOYEE_STATUS = 'Active'
      LEFT JOIN PAYROLL.COMPANY_DIRECTORY cd2 ON cd.DIRECT_MANAGER_EMPLOYEE_ID = cd2.EMPLOYEE_ID AND cd2.EMPLOYEE_STATUS = 'Active'
      WHERE o.ORDER_CREATED_DATE >= DATEADD(year, -2, CURRENT_DATE())
      and oo.COMPANY_ID is not null
      and oo.COMPANY_ID <> 1854
      and o.PRIMARY_SALESPERSON_USER_ID is not null
      and cd.EMPLOYEE_STATUS = 'Active'
    ;;
  }

  dimension: company_salesperson_market_key {
    primary_key: yes
    type: string
    sql: CONCAT(
      CAST(${company_id} AS STRING),
      '_',
      CAST(${market_id} AS STRING),
      '_',
      CAST(${salesperson_id} AS STRING)
    ) ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}.COMPANY_ID ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}.MARKET_ID ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}.DISTRICT ;;
  }

  dimension: region_name {
    type: string
    sql: ${TABLE}.REGION_NAME ;;
  }

  dimension: salesperson_id {
    type: number
    sql: ${TABLE}.SALESPERSON_ID ;;
  }

  dimension: salesperson_email {
    type: string
    sql: ${TABLE}.SALESPERSON_EMAIL ;;
  }

  dimension: salesperson_name {
    type: string
    sql: ${TABLE}.SALESPERSON_NAME ;;
  }

  dimension: manager_name {
    type: string
    sql: ${TABLE}.MANAGER_NAME ;;
  }

  dimension: District_Region_Market_Access {
    type: yesno
    sql: ${TABLE}."DISTRICT" in ({{ _user_attributes['district'] }}) OR ${TABLE}."REGION_NAME" in ({{ _user_attributes['region'] }}) OR ${TABLE}."MARKET_ID" in ({{ _user_attributes['market_id'] }}) ;;
  }

}
