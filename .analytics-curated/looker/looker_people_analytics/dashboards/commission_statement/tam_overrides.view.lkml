view: tam_overrides {

  derived_table: {
    sql: select cor.COMMISSION_OVERRIDE_REQUEST_ID,
       cor.EQUIPMENT_CLASS_ID,
       ec.NAME as equipment_class_name,
       cor.market_id,
       mrx.MARKET_NAME,
       c.NAME as company_name,
       cor.company_id,
       cor.request_user_id as requestor_user_id,
       concat(u.FIRST_NAME,' ',u.LAST_NAME) as requestor_full_name,
       u.email_address as requestor_email,
       cor.review_user_id as reviewer_user_id,
       concat(au.FIRST_NAME,' ',au.LAST_NAME) as reviewer_full_name,
       cor.REVIEW_STATUS,
       iff(cor.review_status = 'APPROVED',cor.date_created,null) as override_start_date,
       iff(cor.review_status = 'APPROVED',dateadd('days', 30, cor.DATE_CREATED),null) as override_end_date,
       iff(cor.review_status = 'APPROVED',dateadd('days', 100, cor.DATE_CREATED),null)  as invoice_end_date,
       orl.ORDER_ID as eligible_order_id,
       orl.INVOICE_ID as eligible_invoice_id,
       i.invoice_no as eligible_invoice_no
from SWORKS.COMMISSIONS.COMMISSION_OVERRIDE_REQUESTS cor
left join ANALYTICS.COMMISSION.OVERRIDE_REQUEST_LINE_ITEMS orl on cor.COMMISSION_OVERRIDE_REQUEST_ID = orl.COMMISSION_OVERRIDE_REQUEST_ID
left join ES_WAREHOUSE.PUBLIC.USERS u on cor.REQUEST_USER_ID = u.user_id
left join ES_WAREHOUSE.PUBLIC.USERS au on cor.REVIEW_USER_ID = au.USER_ID
left join ES_WAREHOUSE.PUBLIC.INVOICES i on orl.INVOICE_ID = i.INVOICE_ID
left join ANALYTICS.PUBLIC.MARKET_REGION_XWALK mrx on cor.MARKET_ID = mrx.MARKET_ID
left join ES_WAREHOUSE.PUBLIC.EQUIPMENT_CLASSES ec on cor.EQUIPMENT_CLASS_ID = ec.EQUIPMENT_CLASS_ID
left join ES_WAREHOUSE.PUBLIC.COMPANIES c on cor.COMPANY_ID = c.COMPANY_ID
      ;;
  }

  dimension: commission_override_request_id {
    description: "Unique ID for each request that is submitted"
    type: number
    sql: ${TABLE}.commission_override_request_id ;;
    value_format_name: id
  }

  dimension: equipment_class_id{
    description: "The equipment class ID from the override request"
    type: number
    sql: ${TABLE}.equipment_class_id;;
    value_format_name: id
  }

  dimension: equipment_class_name {
    description: "The equipment class name from the override request"
    type: string
    sql: ${TABLE}.equipment_class_name;;
  }

  dimension: market_id {
    description: "The market ID from the override request"
    type: number
    sql: ${TABLE}.market_id;;
    value_format_name: id
  }

  dimension: market_name {
    description: "The market name from the override request"
    type: string
    sql: ${TABLE}.market_name;;
  }

  dimension: company_id {
    description: "The company ID from the override request"
    type: number
    sql: ${TABLE}.company_id;;
    value_format_name: id
  }

  dimension: company_name {
    description: "The company name from the override request"
    type: string
    sql: ${TABLE}.company_name;;
  }

  dimension: requestor_user_id {
    description: "The user ID of the TAM that submitted the override request"
    type: number
    sql: ${TABLE}.requestor_user_id;;
    value_format_name: id
  }

  dimension: requestor_full_name {
    description: "The name of the TAM that submitted the override request"
    type: string
    sql: ${TABLE}.requestor_full_name;;
  }

  dimension: requestor_email {
    description: "The email of the TAM that submitted the override request"
    type: string
    sql: ${TABLE}.requestor_email;;
  }

  dimension: reviewer_user_id {
    description: "The user ID of the Manager that reviewed the override request"
    type: number
    sql: ${TABLE}.reviewer_user_id;;
    value_format_name: id
  }

  dimension: reviewer_full_name {
    description: "The name of the Manager that reviewed the override request"
    type: string
    sql: ${TABLE}.reviewer_full_name;;
  }

  dimension: review_status {
    description: "The status of the submitted request"
    type: string
    sql: ${TABLE}.review_status;;
  }

  dimension_group: override_start_date {
    description: "The date when the override starts based on date it was submitted"
    type: time
    timeframes: [date, week, month, year]
    sql: ${TABLE}.override_start_date ;;
  }

  dimension_group: override_end_date {
    description: "The date when the override request expires and new orders will not be eligible (30 days after submission)"
    type: time
    timeframes: [date, week, month, year]
    sql: ${TABLE}.override_end_date ;;
    html:
          {% if override_end_date_date._rendered_value < current_date_date._rendered_value %}
          <font style="color: #000000; text-align: left;">{{override_end_date_date._rendered_value}} - </font>
          <font style="color: #FF0000; text-align: left;"> EXPIRED </font>
          {% else %}
          <font style="color: #000000; text-align: left;">{{override_end_date_date._rendered_value}} </font>
          {% endif %}
          ;;
  }

  dimension_group: invoice_end_date {
    description: "The date when invoices will no longer be overriden (100 days after submission)"
    type: time
    timeframes: [date, week, month, year]
    sql: ${TABLE}.invoice_end_date ;;
    html:
    {% if invoice_end_date_date._rendered_value < current_date_date._rendered_value %}
    <font style="color: #000000; text-align: left;">{{invoice_end_date_date._rendered_value}} - </font>
    <font style="color: #FF0000; text-align: left;"> EXPIRED </font>
    {% else %}
    <font style="color: #000000; text-align: left;">{{invoice_end_date_date._rendered_value}} </font>
    {% endif %}
    ;;
  }

  dimension: eligible_order_id {
    description: "Order ID for orders eligible for the submitted override"
    type: number
    sql: ${TABLE}.eligible_order_id;;
    value_format_name: id
  }

  dimension: eligible_invoice_id {
    description: "Invoice ID for invoices eligible for the submitted override"
    type: number
    sql: ${TABLE}.eligible_invoice_id;;
    value_format_name: id
  }

  dimension: eligible_invoice_no {
    description: "Invoice number for invoices eligible for the submitted override"
    type: string
    sql: ${TABLE}.eligible_invoice_no;;
  }

  dimension_group: current_date {
    type: time
    timeframes: [date, week, month, year]
    sql: current_timestamp ;;
  }


}
