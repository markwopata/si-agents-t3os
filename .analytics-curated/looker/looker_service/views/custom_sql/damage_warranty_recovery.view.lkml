view: damage_warranty_recovery {
  derived_table: {
    sql:    with invoice_amt as (
    select
    v.invoice_id,
    v.line_item_type_id,
    max(v.branch_id) as branch_id,
    sum(v.amount) as total_amt
    from ANALYTICS.PUBLIC.v_line_items v
    join "ES_WAREHOUSE"."PUBLIC"."INVOICES" i
        on v.invoice_id=i.invoice_id
    left join analytics.public.es_companies es
        on i.company_id=es.company_id
    where i.billing_approved_date is not null
    and es.company_id is null
    group by
    v.invoice_id, v.line_item_type_id
    )

    ,invoice_asset_info as (
    select
    invoice_id,
    max(asset_id) as asset_id
    from
    ES_WAREHOUSE.PUBLIC.line_items li
    where
    asset_id is not null
    group by
    invoice_id
    )

    ,invoice_credited as (
    select
    invoice_id,
    invoice_no,
    paid,
    date_created
    from
    ES_WAREHOUSE.PUBLIC.invoices i
    where
    billing_approved_date is not null
    )

    , customer_charge_detail as( select
    ia.invoice_id,
    ia.branch_id,
    ia.total_amt,
    ic.invoice_no,
    ic.paid,
    ic.date_created
    from
    invoice_amt ia
    left join invoice_credited ic on ia.invoice_id = ic.invoice_id
    where
    line_item_type_id in (11,13,25,26)
                )
     , customer_30_market as(
       select  branch_id
       ,round(sum(total_amt),2) customer_charge_recovery
        from customer_charge_detail
        where date_created>= current_date-30
        group by branch_id
     )
       ,rental_revenue_detail as(select invoice_id
       , rental_id
       , branch_id
       , asset_id
       , description
       , amount
       from ANALYTICS.PUBLIC.V_LINE_ITEMS
       where GL_BILLING_APPROVED_DATE>= current_date-30
       and line_item_type_id in(8, 6, 108, 109)
       )
      , rev_30_market as(
         select branch_id
       ,round(sum(amount),2) rental_revenue
       from rental_revenue_detail
       group by branch_id
       )
       , invoice_amt_w as (
        select
          li.invoice_id,
          max(branch_id) as branch_id,
          sum(amount) as total_amt,
          max(li.date_created) as date_created
        from
          ES_WAREHOUSE.PUBLIC.line_items li
        JOIN ES_Warehouse.PUBLIC.Invoices i
          ON li.invoice_id = i.invoice_id
        where i.date_created>= current_date-30
         AND line_item_type_id in (22,23)
        AND i.COMPANY_ID NOT IN (SELECT COMPANY_ID
                                         FROM ES_WAREHOUSE.public.companies
                                         WHERE name REGEXP 'IES\\d+ .*'
                                            OR COMPANY_ID = 420           -- Demo Units
                                            OR COMPANY_ID = 62875         -- ES Owned special events - still owned by us
                                            OR COMPANY_ID IN (1854, 1855) -- ES Owned
                                            OR COMPANY_ID = 61036 -- Trekker)
                                        )
        group by
          li.invoice_id
        )
       ,
        invoice_asset_info_w as (
        select
          invoice_id,
          max(asset_id) as asset_id
        from
          ES_WAREHOUSE.PUBLIC.line_items li
        where
          asset_id is not null
        group by
          invoice_id
        ),
        credit_payments as (
        select
        p.invoice_id
          --, d.invoice_no --remove after testing
        --, d.billing_approved_date
        , sum(amount) as credit_amt
        , DENIED_AMOUNT as denied_amt
        from
          ES_WAREHOUSE.PUBLIC.payment_applications p
        LEFT JOIN (SELECT
                        SUM(PAY_APPLY.AMOUNT)    AS DENIED_AMOUNT
                        , ADMINV.INVOICE_NO
                        , ADMINV.INVOICE_ID
                  FROM ES_WAREHOUSE.PUBLIC.PAYMENTS ARPAY
                  LEFT JOIN ES_WAREHOUSE.PUBLIC.BANK_ACCOUNT_ERP_REFS BANK_ERP ON ARPAY.BANK_ACCOUNT_ID = BANK_ERP.BANK_ACCOUNT_ID
                  LEFT JOIN ES_WAREHOUSE.PUBLIC.PAYMENT_APPLICATIONS PAY_APPLY ON ARPAY.PAYMENT_ID = PAY_APPLY.PAYMENT_ID
                  LEFT JOIN ES_WAREHOUSE.PUBLIC.INVOICES ADMINV ON PAY_APPLY.INVOICE_ID = ADMINV.INVOICE_ID
                  LEFT JOIN(SELECT DISTINCT
                                            SUBSTR(APR.DOCNUMBER, 12, 100) AS PAYMENT_ID
                            FROM ANALYTICS.INTACCT.APRECORD APR
                            WHERE APR.RECORDTYPE = 'apbill'
                              AND APR.DOCNUMBER LIKE ('WTY_PMT_ID:%')) PMT_ID_SYNCED
                            ON TO_VARCHAR(ARPAY.PAYMENT_ID) = PMT_ID_SYNCED.PAYMENT_ID
                  WHERE BANK_ERP.INTACCT_UNDEPFUNDSACCT IN ('5316', '1212')
                    AND ARPAY.STATUS != 1 --PAYMENT NOT REVERSED
                    AND ADMINV.COMPANY_ID NOT IN (SELECT COMPANY_ID
                           FROM ES_WAREHOUSE.public.companies
                           WHERE name REGEXP 'IES\\d+ .*'
                              OR COMPANY_ID = 420           -- Demo Units
                              OR COMPANY_ID = 62875         -- ES Owned special events - still owned by us
                              OR COMPANY_ID IN (1854, 1855) -- ES Owned
                              OR COMPANY_ID = 61036 -- Trekker)
                                                  )
                  GROUP BY ADMINV.INVOICE_NO
                          , ADMINV.INVOICE_ID
                          ) d
          ON p.invoice_id = d.invoice_id
          GROUP BY p.INVOICE_ID
                   , d.denied_amount
                  --, d.invoice_no --remove after testing
          )
        ,credit_memo as(SELECT
                          ARH.CUSTOMERID   AS CUSTOMER_ID,
                          --ARH.RECORDID     AS CM_NUMBER,
                          ARH.DOCNUMBER    AS INVOICE_NO,
                          I.INVOICE_ID,
                          --ARD.ACCOUNTNO    AS GL_ACCOUNT,
                          --ARD.DEPARTMENTID AS BRANCH_ID,
                          SUM(ARD.AMOUNT)       AS CM_AMOUNT
                      FROM ANALYTICS.INTACCT.ARRECORD ARH
                      LEFT JOIN ANALYTICS.INTACCT.ARDETAIL ARD ON ARH.RECORDNO = ARD.RECORDKEY
                      LEFT JOIN ES_WAREHOUSE.Public.Invoices I
                            ON ARH.DOCNUMBER = I.INVOICE_NO
                      WHERE
                            ARH.RECORDTYPE = 'aradjustment'
                        AND ARD.AMOUNT != 0
                        --AND ARH.RecordID = 'CR-1622300077'
                        AND i.COMPANY_ID NOT IN (SELECT COMPANY_ID
                           FROM ES_WAREHOUSE.public.companies
                           WHERE name REGEXP 'IES\\d+ .*'
                              OR COMPANY_ID = 420           -- Demo Units
                              OR COMPANY_ID = 62875         -- ES Owned special events - still owned by us
                              OR COMPANY_ID IN (1854, 1855) -- ES Owned
                              OR COMPANY_ID = 61036 -- Trekker)
                                                 )
                      GROUP BY ARH.CUSTOMERID
                              , ARH.DOCNUMBER
                              , I.Invoice_ID
        ),
        invoice_credited_w as (
        select
        invoice_id,
        invoice_no,
        billing_approved_date,
        paid
        from
        ES_WAREHOUSE.PUBLIC.invoices i
        where
          billing_approved_date is not null
        )
        ,

        warranty_labor_requested as (
        select
        invoice_id,
        sum(number_of_units*price_per_unit) as warranty_labor_requested
        from
        ES_WAREHOUSE.PUBLIC.line_items
        where line_item_type_id = 22
        group by invoice_id
        ),
        warranty_parts_requested as (
        select
        invoice_id,
        sum(number_of_units*price_per_unit) as warranty_parts_requested
        from
        ES_WAREHOUSE.PUBLIC.line_items
        where line_item_type_id = 23
        group by invoice_id
        )

      ,warranty_detail as(
        select
          ia.invoice_id,
          ia.branch_id,
          ia.date_created,
          ai.asset_id,
          ia.total_amt,
          case when ic.paid = 'No' or ic.paid is null then ia.total_amt
          else 0
          END AS Pending_amt,
          CASE when ic.paid = 'Yes' and (cp.denied_amt > 0 OR ABS(cm.cm_amount) > 0) then IFNULL(cp.denied_amt,0) + IFNULL(ABS(cm.cm_amount),0)
               else 0
          END AS Denied_amt,
          CASE when ic.paid = 'Yes' THEN ia.total_amt - IFNULL(cp.denied_amt,0) - IFNULL(ABS(cm.cm_amount),0)
          ELSE 0
          END AS Paid_amt,
          case when ic.paid = 'No' or ic.paid is null then 'Pending'
          when ic.paid = 'Yes' and cp.credit_amt is null then 'Denied'
          ELSE 'Paid'
          END AS warranty_status,
          cp.credit_amt,
          ic.invoice_no,
          ic.paid,
          ic.billing_approved_date,
          pr.warranty_parts_requested,
          lr.warranty_labor_requested
        from invoice_amt_w ia
          left join invoice_asset_info_w ai on ia.invoice_id = ai.invoice_id
          left join credit_payments cp on ia.invoice_id = cp.invoice_id
          left join invoice_credited_w ic on ia.invoice_id = ic.invoice_id
          left join warranty_parts_requested pr on pr.invoice_id = ia.invoice_id
          left join warranty_labor_requested lr on lr.invoice_id = ia.invoice_id
          left join credit_memo cm on ia.invoice_id = cm.invoice_id
        )
        , warranty_30_market as (
          select branch_id
        ,round(sum(total_amt),2) warranty_recovery
        from warranty_detail
        where warranty_status='Paid'
        group by branch_id
          )
        , pending_30_market as(
        select branch_id
        , round(sum(total_amt),2) pending_recovery
        from warranty_detail
        where warranty_status='Pending'
        group by branch_id
        )
            select m.market_id
          , warranty_recovery
          , pending_recovery
          , rental_revenue
          , customer_charge_recovery
          from "ANALYTICS"."PUBLIC"."MARKET_REGION_XWALK" m
          join "ES_WAREHOUSE"."PUBLIC"."MARKETS" c
            on m.market_id=c.market_id
          left join rev_30_market r
            on m.market_id=r.branch_id
          left join warranty_30_market w
          on m.market_id=w.branch_id
          left join pending_30_market p
          on m.market_id=p.branch_id
          left join customer_30_market cr
          on m.market_id=cr.branch_id
       where company_id =1854 ;;
  }
  dimension: market_id {
    type:  number
    sql: ${TABLE}.market_id ;;
  }

  dimension: warranty_recovery_30 {
    type: number
    sql: ${TABLE}.warranty_recovery ;;
  }
  measure: sum_warranty_recovery_30 {
    type: sum
    link: {label: "Warranty Dashboard"
      url: "https://equipmentshare.looker.com/dashboards/222?Vendor=&Abbreviation=&Date=after+2023%2F01%2F01&District=&Region=&Market=&Max+Rank=10"}
  sql: ${TABLE}.warranty_recovery ;;
  }
  measure: sum_pending_recovery_30 {
    type: sum
    link: {label: "Warranty Dashboard"
      url: "https://equipmentshare.looker.com/dashboards/222?Vendor=&Abbreviation=&Date=after+2023%2F01%2F01&District=&Region=&Market=&Max+Rank=10"}
    sql: ${TABLE}.pending_recovery ;;
  }
  dimension: rental_revenue_30 {
    type:  number
    sql: ${TABLE}.rental_revenue ;;
  }
measure: sum_rental_revenue_30 {
  type: sum
  link: {label: "Markets Dashboard"
    url:"https://equipmentshare.looker.com/dashboards/30?Market=&Region=&District=&Market+Type="}
  sql: ${TABLE}.rental_revenue ;;
}

  dimension: customer_damage_recovery_30 {
    label: "Customer Charge Recovery 30"
    type: number
    sql: ${TABLE}.customer_charge_recovery ;;
  }
measure: sum_customer_damage_recovery_30 {
  label: "Sum Customer Charge Recovery 30"
  type: sum
  link: {label: "Service Dashboard"
    url:"https://equipmentshare.looker.com/dashboards/49?Market=&Region=&District=&Market%20Type="}
  sql: ${TABLE}.customer_charge_recovery ;;
}
  # dimension: customer_repair_recovery_30 {
  #   type: number
  #   sql: ${TABLE}.customer_repair_recovery ;;
  # }
  # measure: sum_customer_repair_recovery_30 {
  #   type: sum
  #   link: {label: "Service Dashboard"
  #     url:"https://equipmentshare.looker.com/dashboards/49?Market=&Region=&District=&Market%20Type="}
  #   sql: ${TABLE}.customer_repair_recovery ;;
  # }
  }
