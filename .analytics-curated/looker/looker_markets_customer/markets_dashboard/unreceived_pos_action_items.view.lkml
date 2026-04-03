view: unreceived_pos_action_items {
  derived_table: {
    sql:
          with t3_POs as (SELECT VEND.EXTERNAL_ERP_VENDOR_REF                                             AS "Vendor_ID",
                             VENDINT.NAME,
                             POH.PURCHASE_ORDER_NUMBER                                                AS "PO_Number",
                             POH.PURCHASE_ORDER_ID                                                    AS "PO_ID",
                             POH.DATE_CREATED                                                         AS "PO_Date",
                             BERP1.INTACCT_DEPARTMENT_ID                                              AS "Requesting_Branch",
                             BERP2.INTACCT_DEPARTMENT_ID                                              AS "Deliver_To_Branch",
                             CONCAT(POH.CREATED_BY_ID, ' - ', USER1.FIRST_NAME, ' ', USER1.LAST_NAME) AS "Created_By",
                             USER1.EMAIL_ADDRESS                                                      AS "Email_Address",
                             ITM.ITEM_TYPE                                                            AS "Item_Type",
                             NII.NAME                                                                 AS "Item_Name",
                             PA.PART_NUMBER                                                           AS "Part_Number",
                             POL.DESCRIPTION                                                          AS "Description",
                             POL.MEMO                                                                 AS "Memo",
                             POL.QUANTITY                                                             AS "Quantity_Ordered",
                             PORL.ACCEPTED_QUANTITY                                                   AS "Accepted_Quantity",
                             PORL.REJECTED_QUANTITY                                                   AS "Rejected_Quantity",
                             POL.PRICE_PER_UNIT                                                       AS "Price_Per_Unit",
                             POH.STATUS                                                               AS "PO_Status",
                             POH.AMOUNT_APPROVED                                                      AS "Amount"

      FROM "PROCUREMENT"."PUBLIC"."PURCHASE_ORDERS" POH
      LEFT JOIN "ES_WAREHOUSE"."PURCHASES"."ENTITY_VENDOR_SETTINGS" VEND
      ON POH.VENDOR_ID = VEND.ENTITY_ID
      LEFT JOIN "ANALYTICS"."INTACCT"."VENDOR" VENDINT
      ON VEND.EXTERNAL_ERP_VENDOR_REF = VENDINT.VENDORID
      LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."USERS" USER1 ON POH.CREATED_BY_ID = USER1.USER_ID
      LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."BRANCH_ERP_REFS" BERP1
      ON POH.REQUESTING_BRANCH_ID = BERP1.BRANCH_ID
      LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."BRANCH_ERP_REFS" BERP2
      ON POH.DELIVER_TO_ID = BERP2.BRANCH_ID
      LEFT JOIN "PROCUREMENT"."PUBLIC"."PURCHASE_ORDER_LINE_ITEMS" POL
      ON POH.PURCHASE_ORDER_ID = POL.PURCHASE_ORDER_ID
      LEFT JOIN "PROCUREMENT"."PUBLIC"."ITEMS" ITM ON POL.ITEM_ID = ITM.ITEM_ID
      LEFT JOIN "ES_WAREHOUSE"."INVENTORY"."PARTS" PA ON POL.ITEM_ID = PA.ITEM_ID
      LEFT JOIN "PROCUREMENT"."PUBLIC"."NON_INVENTORY_ITEMS" NII ON POL.ITEM_ID = NII.ITEM_ID
      LEFT JOIN "PROCUREMENT"."PUBLIC"."PURCHASE_ORDER_RECEIVER_ITEMS" PORL
      ON POL.PURCHASE_ORDER_LINE_ITEM_ID = PORL.PURCHASE_ORDER_LINE_ITEM_ID
      WHERE POH.STATUS = 'OPEN')
      --    select * from t3_POs;

      , PO_receipt_quantities as(
      select "PO_Number", sum("Accepted_Quantity") as Accepted_Quantity
      from t3_POs
      group by "PO_Number")

      , with_partial_receipts as (
        select p."PO_Number"
      , p."Requesting_Branch"
      , xw.market_name as "Requesting_Branch_Name"
      , xw.district as "Requesting_District"
      , xw.region_name as "Requesting_Region_Name"
      , p."PO_Status"
      , case when sum(coalesce(r.Accepted_Quantity, 0)) = 0 then false
              else true end as some_acceptance
      from t3_POs p
      left join PO_receipt_quantities r on p."PO_Number" = r."PO_Number"
      left join analytics.public.market_region_xwalk xw on p."Requesting_Branch" = xw.market_id
      group by p."PO_Number", p."Requesting_Branch", p."PO_Status", xw.market_name, xw.district, xw.region_name
      HAVING sum(coalesce(r.Accepted_Quantity, 0)) = 0
      )

      , inventory_amount as (
      select "PO_Number"
      , sum("Quantity_Ordered") as amount
      from t3_POs
      where "Item_Type" = 'INVENTORY'
      group by "PO_Number")


      select pr."PO_Number"
      , i.PK_INVOICE_HEADER_ID
      , i.FK_SAGE_BILL_HEADER_ID
      , i.FK_SAGE_ALT_BILL_HEADER_ID
      , i.FK_SAGE_INVOICE_HEADER_ID
      , i.FK_SAGE_ALT_INVOICE_HEADER_ID
      , i.ID_VENDOR
      , i.NAME_VENDOR
      , i.INVOICE_NUMBER
      , i.PO_NUMBER
      , i.DATE_GL
      , i.DATE_DUE
      , i.STATUS_BILL
      , i.STATUS_PAYMENT
      , i.AMOUNT_TOTAL
      , i.AMOUNT_SUM
      , i.AMOUNT_WITHOUT_TAX
      , i.AMOUNT_NET
      , i.AMOUNT_FREIGHT
      , i.AMOUNT_TAX
      , i.PAYMENT_TERM_COUNT
      , i.PAYMENT_TERM_UNIT
      , i.CODE_CURRENCY
      , i.NOTES
      , i.TYPE_TRANSACTION
      , i.DESCRIPTION
      , i.POSTING_ERROR
      , i.URL_SOURCE_PO
      , i.URL_VIC_PO
      , i.URL_INVOICE
      , i.URL_INVOICE_IMAGE
      , i.URL_SAGE_BILL
      , i.URL_SAGE_INVOICE
      , i.URL_SAGE_ALT_BILL
      , i.URL_SAGE_ALT_INVOICE
      , i.FK_VIC_VENDOR_ID
      , i.FK_VIC_PAYMENT_TERM_ID
      , i.DATE_SERVICE_PERIOD_START
      , i.DATE_SERVICE_PERIOD_END
      , i.LINE_ITEMS
      , i.NAME_ENVIRONMENT
      , i.NAME_ENVIRONMENT_ALIAS
      , i.FK_COMPANY_ID_NUMERIC
      , i.FK_COMPANY_ID_UUID
      , i.TIMESTAMP_CREATED
      , i.TIMESTAMP_MODIFIED
      , i.TIMESTAMP_POSTED_SAGE
      , i.TIMESTAMP_LOADED
      , ia.amount                                        as inventory_amount
      , case when ia.amount > 0 then true else false end as inventory_po
      , pr."Requesting_Branch"
      , pr."Requesting_Branch_Name"
      , pr."Requesting_District"
      , pr."Requesting_Region_Name"
      , id.MAX_INVOICE_DATE
      from with_partial_receipts pr
      left join FINANCIAL_SYSTEMS.VIC_GOLD.VIC__INVOICE_HEADERS i
      on pr."PO_Number"::STRING = i.PO_NUMBER::STRING
      left join inventory_amount ia
      on pr."PO_Number" = ia."PO_Number"
      left join
        (select ID_VENDOR, INVOICE_NUMBER, max(DATE_GL::DATE) as MAX_INVOICE_DATE
          from FINANCIAL_SYSTEMS.VIC_GOLD.VIC__INVOICE_HEADERS
          group by ID_VENDOR, INVOICE_NUMBER) id on i.INVOICE_NUMBER = id.INVOICE_NUMBER and i.ID_VENDOR = id.ID_VENDOR
      where pr.some_acceptance = false
      and i.PO_NUMBER is not null
      qualify row_number() over (
          partition by i.PK_INVOICE_HEADER_ID
          order by i.TIMESTAMP_CREATED desc
      ) = 1
      ;;
  }

  measure: count {
    type: count
  }

  measure: operations_count {
    type: count
  }

  dimension: invoice_link {
    type: string
    sql: ${pk_invoice_header_id} ;;
    html: <a href="{{ url_invoice_image._value }}" style="color: blue;" target="_blank">Invoice PDF</a> ;;
  }

  dimension: po_number {
    type: number
    sql: ${TABLE}."PO_Number" ;;
  }

  dimension: pk_invoice_header_id {
    type: string
    sql: ${TABLE}."PK_INVOICE_HEADER_ID" ;;
  }

  dimension: id_vendor {
    label: "Vendor ID"
    type: string
    sql: ${TABLE}."ID_VENDOR" ;;

  }

  dimension: is_url_null {
    hidden: yes
    type: string
    sql: COALESCE(${url_invoice_image},'abc') ;;
  }

  dimension: invoice_number {
    type: string
    sql: ${TABLE}."INVOICE_NUMBER" ;;
    html:
    {% if url_invoice_image._value %}
    <a href="{{ url_invoice_image._value }}" target="_blank" style="color: blue;">
    {{ value }} ➔
    </a>
    {% endif %};;
  }

  dimension: invoice_number_new {
    type: string
    sql: ${TABLE}."INVOICE_NUMBER" ;;
    link: {
      label: "Open Image"
      url: "{{ url_invoice_image._value }}"
    }
  }

  dimension: invoice_date {
    type: date
    sql: ${TABLE}."DATE_GL" ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
  }

  dimension: purchase_order_number {
    type: string
    sql: ${TABLE}."PO_NUMBER" ;;
  }

  dimension: request_total {
    label: "Invoice Total"
    type: number
    sql: ${TABLE}."AMOUNT_TOTAL" ;;
    value_format_name: usd
  }

  dimension: shipping_amt {
    label: "Freight Amount"
    type: number
    sql: ${TABLE}."AMOUNT_FREIGHT" ;;
    value_format_name: usd
  }

  dimension: tax_amt {
    label: "Tax Amount"
    type: number
    sql: ${TABLE}."AMOUNT_TAX" ;;
    value_format_name: usd
  }

  dimension: status_bill{
    label: "Bill Status"
    type: string
    sql: ${TABLE}."STATUS_BILL" ;;
  }

  dimension: payment_status {
    type: string
    sql: ${TABLE}."STATUS_PAYMENT" ;;
  }

  dimension: created_date {
    type: date
    sql: ${TABLE}."TIMESTAMP_CREATED"::DATE ;;
  }

  dimension_group: _es_update_timestamp {
    type: time
    sql: ${TABLE}."TIMESTAMP_MODIFIED" ;;
  }

  dimension: inventory_amount {
    type: number
    sql: ${TABLE}."INVENTORY_AMOUNT" ;;
  }

  dimension: inventory_po {
    type: yesno
    sql: ${TABLE}."INVENTORY_PO" ;;
  }

  dimension: requesting_branch {
    type: string
    sql: ${TABLE}."Requesting_Branch" ;;
  }

  dimension: requesting_branch_name {
    label: "Market"
    type: string
    sql: ${TABLE}."Requesting_Branch_Name" ;;
  }

  dimension: requesting_district {
    label: "District"
    type: string
    sql: ${TABLE}."Requesting_District" ;;
  }

  dimension: requesting_region_name {
    label: "Region"
    type: string
    sql: ${TABLE}."Requesting_Region_Name" ;;
  }

  dimension: max_invoice_date {
    type: date
    sql: ${TABLE}."MAX_INVOICE_DATE" ;;
  }

  # ── Sage Foreign Keys ────────────────────────────────────────────────────────

  dimension: fk_sage_bill_header_id {
    label: "Sage Bill Header ID"
    type: string
    sql: ${TABLE}."FK_SAGE_BILL_HEADER_ID" ;;
  }

  dimension: fk_sage_alt_bill_header_id {
    label: "Sage Alt Bill Header ID"
    type: string
    sql: ${TABLE}."FK_SAGE_ALT_BILL_HEADER_ID" ;;
  }

  dimension: fk_sage_invoice_header_id {
    label: "Sage Invoice Header ID"
    type: number
    sql: ${TABLE}."FK_SAGE_INVOICE_HEADER_ID" ;;
  }

  dimension: fk_sage_alt_invoice_header_id {
    label: "Sage Alt Invoice Header ID"
    type: number
    sql: ${TABLE}."FK_SAGE_ALT_INVOICE_HEADER_ID" ;;
  }

  # ── Vendor ───────────────────────────────────────────────────────────────────

  dimension: name_vendor {
    label: "Vendor Name"
    type: string
    sql: ${TABLE}."NAME_VENDOR" ;;
    html: <font color="#000000">
    {{name_vendor._value}} </a>
    <br />
    <font style="color: #8C8C8C; text-align: right;">Vendor ID: {{id_vendor._rendered_value }} </font>;;

  }

  # ── Dates ────────────────────────────────────────────────────────────────────

  dimension: date_due {
    label: "Due Date"
    type: date
    sql: ${TABLE}."DATE_DUE" ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
  }

  dimension: date_service_period_start {
    label: "Service Period Start"
    type: date
    sql: ${TABLE}."DATE_SERVICE_PERIOD_START" ;;
  }

  dimension: date_service_period_end {
    label: "Service Period End"
    type: date
    sql: ${TABLE}."DATE_SERVICE_PERIOD_END" ;;
  }

  # ── Amounts ──────────────────────────────────────────────────────────────────

  dimension: amount_sum {
    label: "Amount Sum (Lines)"
    type: number
    sql: ${TABLE}."AMOUNT_SUM" ;;
    value_format_name: usd
  }

  dimension: amount_without_tax {
    label: "Amount (Excl. Tax)"
    type: number
    sql: ${TABLE}."AMOUNT_WITHOUT_TAX" ;;
    value_format_name: usd
  }

  dimension: amount_net {
    label: "Net Amount"
    type: number
    sql: ${TABLE}."AMOUNT_NET" ;;
    value_format_name: usd
  }

  # ── Payment Terms ─────────────────────────────────────────────────────────────

  dimension: payment_term_count {
    label: "Payment Term (Count)"
    type: number
    sql: ${TABLE}."PAYMENT_TERM_COUNT" ;;
  }

  dimension: payment_term_unit {
    label: "Payment Term (Unit)"
    type: string
    sql: ${TABLE}."PAYMENT_TERM_UNIT" ;;
  }

  dimension: code_currency {
    label: "Currency Code"
    type: string
    sql: ${TABLE}."CODE_CURRENCY" ;;
  }

  # ── Text / Metadata ───────────────────────────────────────────────────────────

  dimension: notes {
    type: string
    sql: ${TABLE}."NOTES" ;;
  }

  dimension: type_transaction {
    label: "Transaction Type"
    type: string
    sql: ${TABLE}."TYPE_TRANSACTION" ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension: posting_error {
    label: "Posting Error"
    type: string
    sql: ${TABLE}."POSTING_ERROR" ;;
  }

  dimension: name_environment {
    label: "Environment"
    type: string
    sql: ${TABLE}."NAME_ENVIRONMENT" ;;
  }

  dimension: name_environment_alias {
    label: "Environment Alias"
    type: string
    sql: ${TABLE}."NAME_ENVIRONMENT_ALIAS" ;;
  }

  dimension: line_items {
    label: "Line Items"
    type: string
    sql: ${TABLE}."LINE_ITEMS"::STRING ;;
  }

  # ── URLs ─────────────────────────────────────────────────────────────────────

  dimension: url_invoice_image {
    label: "Invoice Image URL"
    type: string
    sql: ${TABLE}."URL_INVOICE_IMAGE" ;;
  }

  dimension: url_invoice {
    label: "Vic Invoice URL"
    type: string
    sql: ${TABLE}."URL_INVOICE" ;;
  }

  dimension: url_source_po {
    label: "Source PO URL"
    type: string
    sql: ${TABLE}."URL_SOURCE_PO" ;;
  }

  dimension: url_vic_po {
    label: "Vic PO URL"
    type: string
    sql: ${TABLE}."URL_VIC_PO" ;;
  }

  dimension: url_sage_bill {
    label: "Sage Bill URL"
    type: string
    sql: ${TABLE}."URL_SAGE_BILL" ;;
  }

  dimension: url_sage_invoice {
    label: "Sage Invoice URL"
    type: string
    sql: ${TABLE}."URL_SAGE_INVOICE" ;;
  }

  dimension: url_sage_alt_bill {
    label: "Sage Alt Bill URL"
    type: string
    sql: ${TABLE}."URL_SAGE_ALT_BILL" ;;
  }

  dimension: url_sage_alt_invoice {
    label: "Sage Alt Invoice URL"
    type: string
    sql: ${TABLE}."URL_SAGE_ALT_INVOICE" ;;
  }

  # ── Vic Foreign Keys ──────────────────────────────────────────────────────────

  dimension: fk_vic_vendor_id {
    label: "Vic Vendor ID"
    type: number
    sql: ${TABLE}."FK_VIC_VENDOR_ID" ;;
  }

  dimension: fk_vic_payment_term_id {
    label: "Vic Payment Term ID"
    type: string
    sql: ${TABLE}."FK_VIC_PAYMENT_TERM_ID" ;;
  }

  dimension: fk_company_id_numeric {
    label: "Company ID (Numeric)"
    type: string
    sql: ${TABLE}."FK_COMPANY_ID_NUMERIC" ;;
  }

  dimension: fk_company_id_uuid {
    label: "Company ID (UUID)"
    type: string
    sql: ${TABLE}."FK_COMPANY_ID_UUID" ;;
  }

  # ── Timestamps ────────────────────────────────────────────────────────────────

  dimension_group: timestamp_posted_sage {
    label: "Posted to Sage"
    type: time
    sql: ${TABLE}."TIMESTAMP_POSTED_SAGE" ;;
  }

  dimension_group: timestamp_loaded {
    label: "Loaded to Snowflake"
    type: time
    sql: ${TABLE}."TIMESTAMP_LOADED" ;;
  }
}
