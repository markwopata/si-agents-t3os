view: unreceived_pos {
    derived_table: {
      sql: with t3_POs as (SELECT VEND.EXTERNAL_ERP_VENDOR_REF                                             AS "Vendor_ID",
                             VENDINT.NAME as "Vendor_Name",
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
      LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."MARKETS" BRCH1 ON POH.REQUESTING_BRANCH_ID = BRCH1.MARKET_ID
      LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."MARKETS" BRCH2 ON POH.DELIVER_TO_ID = BRCH2.MARKET_ID
      LEFT JOIN "PROCUREMENT"."PUBLIC"."PURCHASE_ORDER_LINE_ITEMS" POL
      ON POH.PURCHASE_ORDER_ID = POL.PURCHASE_ORDER_ID
      LEFT JOIN "PROCUREMENT"."PUBLIC"."ITEMS" ITM ON POL.ITEM_ID = ITM.ITEM_ID
      LEFT JOIN "ES_WAREHOUSE"."INVENTORY"."PARTS" PA ON POL.ITEM_ID = PA.ITEM_ID
      LEFT JOIN "PROCUREMENT"."PUBLIC"."NON_INVENTORY_ITEMS" NII ON POL.ITEM_ID = NII.ITEM_ID
      LEFT JOIN "PROCUREMENT"."PUBLIC"."PURCHASE_ORDER_RECEIVER_ITEMS" PORL
      ON POL.PURCHASE_ORDER_LINE_ITEM_ID = PORL.PURCHASE_ORDER_LINE_ITEM_ID
      where BRCH1.company_id = 1854)
      --    select * from t3_POs;

      , PO_receipt_quantities as (select "PO_Number", "PO_ID", sum("Accepted_Quantity") as Accepted_Quantity
      from t3_POs
      group by "PO_Number", PO_ID)
      , with_partial_receipts as (select p."Vendor_Name"
      , p."PO_Number"
      , p."Requesting_Branch"
      , p."PO_Status"
      , p.po_id
      , case
      when sum(coalesce(r.Accepted_Quantity, 0)) = 0 then false
      else true end as some_acceptance
      from t3_POs p
      left join PO_receipt_quantities r
      on p."PO_Number" = r."PO_Number"
      group by p."Vendor_Name", p."PO_Number", p."Requesting_Branch", p."PO_Status", p.po_id)
      , inventory_amount as (select "PO_Number", po_id
      , sum("Quantity_Ordered") as amount
      from t3_POs
      where "Item_Type" = 'INVENTORY'
      group by "PO_Number", po_id)
      -- select  * from with_partial_receipts
      -- where "PO_Number" = '480960';
      select pr."PO_Number"
      , pr."PO_ID"
      , pr."Vendor_Name"
      , i.* RENAME PO_NUMBER as vic_po_number
      , ia.amount                                        as inventory_amount
      , case when ia.amount > 0 then true else false end as inventory_po
      , pr."Requesting_Branch"
      , id.MAX_INVOICE_DATE
      from with_partial_receipts pr
      left join FINANCIAL_SYSTEMS.VIC_GOLD.VIC__INVOICE_HEADERS i
      on pr."PO_Number"::STring = i.PO_NUMBER::STRING
      left join inventory_amount ia
      on pr."PO_Number" = ia."PO_Number"
      left join (select ID_VENDOR, INVOICE_NUMBER, max(DATE_GL::DATE) as MAX_INVOICE_DATE
                  from FINANCIAL_SYSTEMS.VIC_GOLD.VIC__INVOICE_HEADERS
                  group by ID_VENDOR, INVOICE_NUMBER) id
          on i.INVOICE_NUMBER = id.INVOICE_NUMBER
          and i.ID_VENDOR = id.ID_VENDOR
      where pr."PO_Status" = 'OPEN'
      and pr.some_acceptance = false
      and i.PO_NUMBER is not null
      qualify row_number() over (
          partition by i.PK_INVOICE_HEADER_ID
          order by i.TIMESTAMP_CREATED desc
      ) = 1
      ;;
    }

    measure: count {
      type: count
      drill_fields: [markets_detail*]
    }

    measure: operations_count {
      type: count
    }

    dimension: invoice_link {
      type: string
      sql: ${request_id} ;;
      html: <a href="https://api.equipmentshare.com/skunkworks/invoices/request-image/{{ rendered_value }}/?redirect=1" style="color: blue;" target="_blank">Invoice PDF</a> ;;
    }

    # dimension: po_number {
    #   type: number
    #   sql: ${TABLE}."PO_Number" ;;
    # }

  dimension: po_number {
    type: number
    sql: ${TABLE}."PO_Number" ;;
    html:<font color="blue "><u><a href="https://costcapture.estrack.com/purchase-orders/{{ purchase_order_id._value }}/detail" target="_blank">{{ po_number._value }}</a></font></u>;;
  }

    dimension: request_id {
      type: string
      sql: ${TABLE}."PK_INVOICE_HEADER_ID" ;;
    }

    dimension: supplier_code {
      type: string
      sql: ${TABLE}."ID_VENDOR" ;;
    }

    dimension: invoice_number {
      type: string
      sql: ${TABLE}."INVOICE_NUMBER" ;;
    }

  dimension: url_invoice_image {
    type: string
    sql: ${TABLE}."URL_INVOICE_IMAGE" ;;
  }

    dimension: invoice_pdf_link {
      type: string
      sql: ${TABLE}."INVOICE_NUMBER" ;;
      link: {
        label: "Open Image"
        url: "{{ url_invoice_image._value }}"
      }
    }

    dimension_group: invoice_date {
      type: time
      sql: ${TABLE}."DATE_GL" ;;
      timeframes: [
        date,
        week,
        month,
        quarter,
        year
      ]
    }

    dimension: purchase_order_number {
      type: string
      sql: ${TABLE}."PO_NUMBER" ;;
    }

    # Column doesn't exist in Vic table
    # dimension: employee_email_address {
    #   type: string
    #   sql: ${TABLE}."EMPLOYEE_EMAIL_ADDRESS" ;;
    # }

    dimension: request_total {
      type: number
      sql: ${TABLE}."AMOUNT_TOTAL" ;;
    }

    dimension: shipping_amt {
      type: number
      sql: ${TABLE}."AMOUNT_FREIGHT" ;;
    }

    dimension: tax_amt {
      type: number
      sql: ${TABLE}."AMOUNT_TAX" ;;
    }

    # Column doesn't exist in Vic table
    # dimension: request_key {
    #   type: string
    #   sql: ${TABLE}."REQUEST_KEY" ;;
    # }

    # Column doesn't exist in Vic table
    # dimension: request_legacy_key {
    #   type: string
    #   sql: ${TABLE}."REQUEST_LEGACY_KEY" ;;
    # }

    dimension: approval_status {
      type: string
      sql: ${TABLE}."STATUS_BILL" ;;
    }

    dimension: payment_status {
      type: string
      sql: ${TABLE}."STATUS_PAYMENT" ;;
    }

    # Column doesn't exist in Vic table
    # dimension: exception_count {
    #   type: number
    #   sql: ${TABLE}."EXCEPTION_COUNT" ;;
    # }

    # Column doesn't exist in Vic table
    # dimension: cleared_exception_count {
    #   type: number
    #   sql: ${TABLE}."CLEARED_EXCEPTION_COUNT" ;;
    # }

    dimension: created_date {
      type: date
      sql: ${TABLE}."TIMESTAMP_CREATED" ;;
    }

    # Column doesn't exist in Vic table
    # dimension: policy {
    #   type: string
    #   sql: ${TABLE}."POLICY" ;;
    # }

    # Column doesn't exist in Vic table
    # dimension_group: _es_update_timestamp {
    #   type: time
    #   sql: ${TABLE}."_ES_UPDATE_TIMESTAMP" ;;
    # }

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

    dimension: max_invoice_date {
      type: date
      sql: ${TABLE}."MAX_INVOICE_DATE" ;;
    }

    dimension: purchase_order_id {
      type: string
      sql: ${TABLE}."PO_ID" ;;
    }
    dimension: vendor_name {
      type: string
      sql: ${TABLE}."Vendor_Name" ;;
    }

    set: markets_detail {
      fields: #Put invoice date back in
      [
        market_region_xwalk.market_name,
        vendor_name,
        #po_number,
        #request_id,
        #supplier_code,
        invoice_number,
        invoice_pdf_link,
        po_number,
        request_total,
        shipping_amt,
        #tax_amt,
        # request_key,
        # request_legacy_key,
        approval_status,
        payment_status,
        #exception_count,
        #cleared_exception_count,
        created_date,
        # policy,
        # _es_update_timestamp_time,
        inventory_amount,
        inventory_po,
        #requesting_branch,
        #max_invoice_date
      ]
    }

    set: operations_detail {
      fields: [
        market_region_xwalk.selected_hierarchy_dimension,
        market_region_xwalk.market_name,
        po_number,
        # employee_email_address,
        request_id,
        supplier_code,
        invoice_number,
        purchase_order_number,
        request_total,
        shipping_amt,
        tax_amt,
        approval_status,
        payment_status,
        created_date,
        inventory_amount,
        inventory_po,
        requesting_branch,
        max_invoice_date
      ]
    }
  }
