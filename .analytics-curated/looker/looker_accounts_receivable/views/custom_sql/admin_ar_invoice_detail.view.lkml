view: admin_ar_invoice_detail {
  derived_table: {
    sql: SELECT
          INVH.COMPANY_ID AS "Customer_ID",
          COMP.NAME AS "Customer_Name",
          LOCATE.STREET_1 AS "Customer_Address_1", -- ADD THIS LINE
          LOCATE.STREET_2 AS "Customer_Address_2", -- ADD THIS LINE
          LOCATE.CITY AS "Customer_City", -- ADD THIS LINE
          STATE.ABBREVIATION AS "Customer_State", -- ADD THIS LINE
          LOCATE.ZIP_CODE AS "Customer_Zip", -- ADD THIS LINE
          TERM.NAME AS "Terms",
          CAST(CONVERT_TIMEZONE('America/Chicago',INVH.INVOICE_DATE) AS DATE) AS "Invoice_Date",
          CAST(CONVERT_TIMEZONE('America/Chicago',INVH.DUE_DATE) AS DATE) AS "Due_Date",
          INVH.INVOICE_NO AS "Invoice_Number",
          INVH.ORDER_ID AS "Order_ID",
          INVH.TAX_AMOUNT AS "Total_Sales_Tax_",
          INVH.SALESPERSON_USER_ID AS "Sales_Rep_ID",
          INVH.ORDERED_BY_USER_ID AS "Ordered_By_ID",
          COALESCE(CONCAT(ORDUSR.FIRST_NAME,' ',ORDUSR.LAST_NAME),'-') AS "Ordered_By_Name",
          CAST(CONVERT_TIMEZONE('America/Chicago',INVH.START_DATE) AS DATETIME) AS "Date_Out_1", -- ADD THIS LINE
          CAST(CONVERT_TIMEZONE('America/Chicago',INVH.END_DATE) AS DATETIME) AS "Billed_Through_1", -- ADD THIS LINE
          INVH.BILLING_APPROVED AS "Approved",
          INVH.ARE_TAX_CALS_MISSING AS "Tax_Calc_Flag",
          COALESCE(CONCAT(USR.FIRST_NAME,' ',USR.LAST_NAME),'-') AS "Sales_Rep_Name",
          CONCAT(INVH.COMPANY_ID,'-',INVH.SALESPERSON_USER_ID) AS "Cust_Sales_Rep",
          INVH.CREATED_BY_USER_ID AS "Invoiced_By_ID",
          COALESCE(CONCAT(CREATEUSR.FIRST_NAME,' ',CREATEUSR.LAST_NAME),'-') AS "Invoiced_By_Name",
          PO.NAME AS "Purchase_Order_Number",
          INVH.PUBLIC_NOTE AS "Invoice_Memo",
          INVD.RENTAL_ID AS "Rental_ID",
          INVD.DESCRIPTION AS "Description",
          INVD.BRANCH_ID AS "Branch",
          MKT.NAME AS "Branch_Name",
          INVD.ASSET_ID AS "Asset_ID",
          CONCAT(ASST.MAKE,' ',ASST.MODEL,' ID:',ASST.ASSET_ID,', Serial:',SERIAL_NUMBER) AS "Equipment", -- ADD THIS LINE
          ASST.CUSTOM_NAME AS "Asset_Name",
          ASST.ASSET_CLASS AS "Asset_Class",
          ASST.MAKE AS "Asset_Make",
          ASST.MODEL AS "Asset_Model",
          ASST.SERIAL_NUMBER AS "Serial",
          INVD.PART_ID AS "Part_ID",
          INVD.NUMBER_OF_UNITS AS "QTY",
          INVD.PRICE_PER_UNIT AS "Unit_Price",
          INVD.AMOUNT AS "Amount",
          LIT.NAME AS "Line_Item_Type_Name",
          LITERP.INTACCT_GL_ACCOUNT_NO AS "GL_Account",
          INVH.SHIP_TO:nickname::string as "Job_Name",
          INVH.SHIP_TO:address.street_1::string as "Job_Address",
          INVH.SHIP_TO:address.city::string as "Job_City",
          INVH.SHIP_TO:address.state_abbreviation::string as "Job_State",
          INVH.SHIP_TO:address.zip_code::string as "Job_Zip",
          INVH.SHIP_TO:address.country::string as "Job_Country",
          INVH.SHIP_TO:address.latitude::string as "Job_Lat",
          INVH.SHIP_TO:address.longitude::string as "Job_Long"
      FROM
          "ES_WAREHOUSE"."PUBLIC"."INVOICES" INVH
          LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."COMPANIES" COMP ON INVH.COMPANY_ID = COMP.COMPANY_ID
          LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."PURCHASE_ORDERS" PO ON INVH.PURCHASE_ORDER_ID = PO.PURCHASE_ORDER_ID AND INVH.COMPANY_ID = PO.COMPANY_ID
          LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."USERS" USR ON INVH.SALESPERSON_USER_ID = USR.USER_ID
          LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."LINE_ITEMS" INVD ON INVH.INVOICE_ID = INVD.INVOICE_ID
          LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."LINE_ITEM_TYPES" LIT ON INVD.LINE_ITEM_TYPE_ID = LIT.LINE_ITEM_TYPE_ID
          LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."LINE_ITEM_TYPE_ERP_REFS" LITERP ON INVD.LINE_ITEM_TYPE_ID = LITERP.LINE_ITEM_TYPE_ID
          LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."NET_TERMS" TERM ON COMP.NET_TERMS_ID = TERM.NET_TERMS_ID
          LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."ASSETS" ASST ON INVD.ASSET_ID = ASST.ASSET_ID
          LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."USERS" ORDUSR ON INVH.ORDERED_BY_USER_ID = ORDUSR.USER_ID
          LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."MARKETS" MKT ON INVD.BRANCH_ID = MKT.MARKET_ID
          LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."USERS" CREATEUSR ON INVH.CREATED_BY_USER_ID = CREATEUSR.USER_ID
          LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."LOCATIONS" LOCATE ON COMP.BILLING_LOCATION_ID = LOCATE.LOCATION_ID -- ADD THIS LINE
          LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."STATES" STATE ON LOCATE.STATE_ID = STATE.STATE_ID -- ADD THIS LINE
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: customer_id {
    type: number
    sql: ${TABLE}."Customer_ID" ;;
  }

  dimension: customer_name {
    type: string
    sql: ${TABLE}."Customer_Name" ;;
  }

  dimension: customer_address_1 {
    type: string
    sql: ${TABLE}."Customer_Address_1" ;;
  }

  dimension: customer_address_2 {
    type: string
    sql: ${TABLE}."Customer_Address_2" ;;
  }

  dimension: customer_city {
    type: string
    sql: ${TABLE}."Customer_City" ;;
  }

  dimension: customer_state {
    type: string
    sql: ${TABLE}."Customer_State" ;;
  }

  dimension: customer_zip {
    type: number
    sql: ${TABLE}."Customer_Zip" ;;
  }

  dimension: ordered_by_id {
    type: number
    sql: ${TABLE}."Ordered_By_ID" ;;
  }

  dimension: ordered_by_name {
    type: string
    sql: ${TABLE}."Ordered_By_Name" ;;
  }

  dimension: date_out_1 {
    type: string
    sql: ${TABLE}."Date_Out_1" ;;
  }

  dimension: billed_through_1 {
    type: string
    sql: ${TABLE}."Billed_Through_1" ;;
  }

  dimension: invoiced_by_id {
    type: number
    sql: ${TABLE}."Invoiced_By_ID" ;;
  }

  dimension: invoiced_by_name {
    type: string
    sql: ${TABLE}."Invoiced_By_Name" ;;
  }

  dimension: terms {
    type: string
    sql: ${TABLE}."Terms" ;;
  }

  dimension: invoice_date {
    type: date
    sql: ${TABLE}."Invoice_Date" ;;
  }

  dimension: due_date {
    type: date
    sql: ${TABLE}."Due_Date" ;;
  }

  dimension: invoice_number {
    type: string
    sql: ${TABLE}."Invoice_Number" ;;
  }

  dimension: order_id {
    type: number
    sql: ${TABLE}."Order_ID" ;;
  }

  dimension: total_sales_tax_ {
    type: number
    sql: ${TABLE}."Total_Sales_Tax_" ;;
  }

  dimension: sales_rep_id {
    type: number
    sql: ${TABLE}."Sales_Rep_ID" ;;
  }

  dimension: approved {
    type: string
    sql: ${TABLE}."Approved" ;;
  }

  dimension: tax_calc_flag {
    type: string
    sql: ${TABLE}."Tax_Calc_Flag" ;;
  }

  dimension: sales_rep_name {
    type: string
    sql: ${TABLE}."Sales_Rep_Name" ;;
  }

  dimension: cust_sales_rep {
    type: string
    sql: ${TABLE}."Cust_Sales_Rep" ;;
  }

  dimension: purchase_order_number {
    type: string
    sql: ${TABLE}."Purchase_Order_Number" ;;
  }

  dimension: invoice_memo {
    type: string
    sql: ${TABLE}."Invoice_Memo" ;;
  }

  dimension: rental_id {
    type: number
    sql: ${TABLE}."Rental_ID" ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."Description" ;;
  }

  dimension: branch {
    type: number
    sql: ${TABLE}."Branch" ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."Asset_ID" ;;
  }

  dimension: equipment {
    type: number
    sql: ${TABLE}."Equipment" ;;
  }

  dimension: asset_name {
    type: string
    sql: ${TABLE}."Asset_Name" ;;
  }

  dimension: asset_class {
    type: string
    sql: ${TABLE}."Asset_Class" ;;
  }

  dimension: branch_name {
    type: string
    sql: ${TABLE}."Branch_Name" ;;
  }

  dimension: asset_make {
    type: string
    sql: ${TABLE}."Asset_Make" ;;
  }

  dimension: asset_model {
    type: string
    sql: ${TABLE}."Asset_Model" ;;
  }

  dimension: serial {
    type: string
    sql: ${TABLE}."Serial" ;;
  }

  dimension: part_id {
    type: number
    sql: ${TABLE}."Part_ID" ;;
  }

  dimension: qty {
    type: number
    sql: ${TABLE}."QTY" ;;
  }

  dimension: unit_price {
    type: number
    sql: ${TABLE}."Unit_Price" ;;
  }

  dimension: amount {
    type: number
    sql: ${TABLE}."Amount" ;;
  }

  dimension: line_item_type_name {
    type: string
    sql: ${TABLE}."Line_Item_Type_Name" ;;
  }

  dimension: gl_account {
    type: string
    sql: ${TABLE}."GL_Account" ;;
  }

  dimension: job_name {
    type: string
    sql: ${TABLE}."Job_Name" ;;
  }

  dimension: job_address {
    type: string
    sql: ${TABLE}."Job_Address" ;;
  }

  dimension: job_city {
    type: string
    sql: ${TABLE}."Job_City" ;;
  }

  dimension: job_state {
    type: string
    sql: ${TABLE}."Job_State" ;;
  }

  dimension: job_zip {
    type: string
    sql: ${TABLE}."Job_Zip" ;;
  }

  dimension: job_country {
    type: string
    sql: ${TABLE}."Job_Country" ;;
  }

  dimension: job_lat {
    type: string
    sql: ${TABLE}."Job_Lat" ;;
  }

  dimension: job_long {
    type: string
    sql: ${TABLE}."Job_Long" ;;
  }

  set: detail {
    fields: [
      customer_id,
      customer_name,
      customer_address_1,
      customer_address_2,
      customer_city,
      customer_state,
      customer_zip,
      ordered_by_id,
      ordered_by_name,
      date_out_1,
      billed_through_1,
      invoiced_by_id,
      invoiced_by_name,
      terms,
      invoice_date,
      due_date,
      invoice_number,
      order_id,
      total_sales_tax_,
      sales_rep_id,
      approved,
      tax_calc_flag,
      sales_rep_name,
      cust_sales_rep,
      purchase_order_number,
      invoice_memo,
      rental_id,
      description,
      branch,
      branch_name,
      asset_id,
      equipment,
      asset_name,
      asset_class,
      asset_make,
      asset_model,
      serial,
      part_id,
      qty,
      unit_price,
      amount,
      line_item_type_name,
      gl_account,
      job_name,
      job_address,
      job_city,
      job_state,
      job_zip,
      job_country,
      job_lat,
      job_long
    ]
  }
}
