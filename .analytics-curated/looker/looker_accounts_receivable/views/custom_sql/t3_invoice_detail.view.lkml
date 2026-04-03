
view: t3_invoice_detail {
  derived_table: {
    sql: SELECT COMPANIES.NAME AS Customer_Name,
      LOCATIONS.STREET_1 AS Customer_Billing_Address_Street_Line_1,
      LOCATIONS.STREET_2 AS Customer_Billing_Address_Street_Line_2,
      LOCATIONS.CITY AS Customer_Billing_Address_City,
      LOCATIONS.ZIP_CODE AS Customer_Billing_Address_Zip_Code,
      STATES.ABBREVIATION AS Customer_Billing_Address_State,
      INVOICES.COMPANY_ID AS Admin_ID_Intacct_ID_Company_ID,
      INVOICES.INVOICE_DATE AS Invoice_Date,
      NET_TERMS.NAME AS Payment_Terms,
      PURCHASE_ORDERS.NAME AS POReference,
      INVOICES.SHIP_FROM AS Origin_Shpping_Address,
      INVOICES.SHIP_TO AS Customer_Shipping_Address,
      LINE_ITEMS.DESCRIPTION AS Description_of_Line_Item,
      LINE_ITEMS.RENTAL_ID AS Rental_ID,
      LINE_ITEMS.NUMBER_OF_UNITS AS Quantity,
      LINE_ITEMS.PRICE_PER_UNIT AS Unit_Price,
      LINE_ITEMS.TAX_RATE_PERCENTAGE AS Tax_Rate,
      LINE_ITEMS.TAX_AMOUNT AS Tax_Amount,
      LINE_ITEMS.AMOUNT AS Total_Amount_per_Line_Item,
      INVOICES.INVOICE_NO AS Invoice_Number,
      INVOICES.ORDER_ID AS Order_Number,
      LINE_ITEMS.BRANCH_ID AS Branch_ID
      FROM ES_WAREHOUSE.PUBLIC.LINE_ITEMS AS LINE_ITEMS
      LEFT JOIN ES_WAREHOUSE.PUBLIC.INVOICES AS INVOICES ON LINE_ITEMS.INVOICE_ID = INVOICES.INVOICE_ID
      INNER JOIN ES_WAREHOUSE.PUBLIC.PURCHASE_ORDERS AS PURCHASE_ORDERS ON INVOICES.PURCHASE_ORDER_ID = PURCHASE_ORDERS.PURCHASE_ORDER_ID
      INNER JOIN ES_WAREHOUSE.PUBLIC.COMPANIES AS COMPANIES ON INVOICES.COMPANY_ID = COMPANIES.COMPANY_ID
      INNER JOIN ES_WAREHOUSE.PUBLIC.NET_TERMS AS NET_TERMS ON COMPANIES.NET_TERMS_ID = NET_TERMS.NET_TERMS_ID
      INNER JOIN ES_WAREHOUSE.PUBLIC.LOCATIONS AS LOCATIONS ON COMPANIES.BILLING_LOCATION_ID = LOCATIONS.LOCATION_ID
      INNER JOIN ES_WAREHOUSE.PUBLIC.STATES AS STATES ON LOCATIONS.STATE_ID = STATES.STATE_ID
      WHERE PURCHASE_ORDERS.NAME LIKE 'T3_TECH___________'
      ORDER BY INVOICES.DATE_CREATED DESC ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: customer_name {
    type: string
    sql: ${TABLE}."CUSTOMER_NAME" ;;
  }

  dimension: customer_billing_address_street_line_1 {
    type: string
    sql: ${TABLE}."CUSTOMER_BILLING_ADDRESS_STREET_LINE_1" ;;
  }

  dimension: customer_billing_address_street_line_2 {
    type: string
    sql: ${TABLE}."CUSTOMER_BILLING_ADDRESS_STREET_LINE_2" ;;
  }

  dimension: customer_billing_address_city {
    type: string
    sql: ${TABLE}."CUSTOMER_BILLING_ADDRESS_CITY" ;;
  }

  dimension: customer_billing_address_zip_code {
    type: string
    sql: ${TABLE}."CUSTOMER_BILLING_ADDRESS_ZIP_CODE" ;;
  }

  dimension: customer_billing_address_state {
    type: string
    sql: ${TABLE}."CUSTOMER_BILLING_ADDRESS_STATE" ;;
  }

  dimension: admin_id_intacct_id_company_id {
    type: number
    sql: ${TABLE}."ADMIN_ID_INTACCT_ID_COMPANY_ID" ;;
  }

  dimension_group: invoice_date {
    type: time
    sql: ${TABLE}."INVOICE_DATE" ;;
  }

  dimension: payment_terms {
    type: string
    sql: ${TABLE}."PAYMENT_TERMS" ;;
  }

  dimension: poreference {
    type: string
    sql: ${TABLE}."POREFERENCE" ;;
  }

  dimension: origin_shpping_address {
    type: string
    sql: ${TABLE}."ORIGIN_SHPPING_ADDRESS" ;;
  }

  dimension: customer_shipping_address {
    type: string
    sql: ${TABLE}."CUSTOMER_SHIPPING_ADDRESS" ;;
  }

  dimension: description_of_line_item {
    type: string
    sql: ${TABLE}."DESCRIPTION_OF_LINE_ITEM" ;;
  }

  dimension: rental_id {
    type: number
    sql: ${TABLE}."RENTAL_ID" ;;
  }

  dimension: quantity {
    type: number
    sql: ${TABLE}."QUANTITY" ;;
  }

  dimension: unit_price {
    type: number
    sql: ${TABLE}."UNIT_PRICE" ;;
  }

  dimension: tax_rate {
    type: number
    sql: ${TABLE}."TAX_RATE" ;;
  }

  dimension: tax_amount {
    type: number
    sql: ${TABLE}."TAX_AMOUNT" ;;
  }

  dimension: total_amount_per_line_item {
    type: number
    sql: ${TABLE}."TOTAL_AMOUNT_PER_LINE_ITEM" ;;
  }

  dimension: invoice_number {
    type: string
    sql: ${TABLE}."INVOICE_NUMBER" ;;
  }

  dimension: order_number {
    type: number
    sql: ${TABLE}."ORDER_NUMBER" ;;
  }

  dimension: branch_id {
    type: number
    sql: ${TABLE}."BRANCH_ID" ;;
  }

  set: detail {
    fields: [
        customer_name,
	customer_billing_address_street_line_1,
	customer_billing_address_street_line_2,
	customer_billing_address_city,
	customer_billing_address_zip_code,
	customer_billing_address_state,
	admin_id_intacct_id_company_id,
	invoice_date_time,
	payment_terms,
	poreference,
	origin_shpping_address,
	customer_shipping_address,
	description_of_line_item,
	rental_id,
	quantity,
	unit_price,
	tax_rate,
	tax_amount,
	total_amount_per_line_item,
	invoice_number,
	order_number,
	branch_id
    ]
  }
}
