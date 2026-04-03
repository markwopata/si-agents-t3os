view: warranty_denial_rate {
  derived_table: {
    sql: with invoice_amt as (
select li.invoice_id,
    i.invoice_no,
    max(li.branch_id)       as branch_id,
    max(paid_date)       as paid_date,
    i.billing_approved_date,
    sum(amount)          as warranty_amt,
    coalesce(type_12.type_12_amt,0) as type_12_0,
    warranty_amt + type_12_0 as total_amt,
    min(i.date_created) as date_created,
    iff( --Former and current Warranty Team members as of March 14, 2024. Approved by Kaelan Jones - TA
        u.user_id in (61693 --Savannah Hatton
            , 48103 --Cheri McCleskey
            , 6659 --Lacey Dorsett
            , 15921 --Cliff Dorsett
            , 20708 --Dawn Chilton
            , 17054 --Joshua Greenwood
            , 47242 --Jenny Withrow
            , 49343 --Chase Bettis
            , 62759 --Kaelan Jones
            , 20731 --Tristen Robertson
            , 20148 --Jon Day
            , 125940 --George Molchan
            , 126240 --Brent McCleskey
            , 27185 --Charlotte Fitzgerald
            , 24662 --Adam Price
            , 187372 --Shannon Fitzgerald
            , 190426 --Lisa Monroe
            , 15919 --Aron Glass
            , 28868 --Charles Carrington
            , 28006 --Justin Fitzgerald
            , 206519 --Krystal Smith
            , 210771 --Jennifer Bradstreet
            , 210772 --Celeste Weigel
            , 108119 --Maxine Miller
            , 9774   --Sally Hand
            , 99722 --Emily Kamler
            , 56365) --Chelsea Douglas
        OR cd.employee_title ilike '%warranty%' --Back Up
        , true, false) as warranty_team_created
from ES_WAREHOUSE.PUBLIC.line_items li
         JOIN ES_Warehouse.PUBLIC.Invoices i
              ON li.invoice_id = i.invoice_id
left join (select originating_invoice_id
           from ES_WAREHOUSE.PUBLIC.CREDIT_NOTES
           where memo ilike '%wrong account%'
              or memo ilike '%incorrect vendor%id%'
              or memo ilike '%generated in error%'
              or memo ilike '%wrong location%'
              or memo ilike '%wrong branch%'
              or memo ilike '%duplicate invoice%'
              or memo ilike '%incorrect intacct%id%'
              or memo ilike '%billing error%'
              or memo ilike '%wrong intacct%id%'
            ) cn
        on li.INVOICE_ID = cn.ORIGINATING_INVOICE_ID
left join ES_WAREHOUSE.PUBLIC.USERS u
    on u.user_id = i.created_by_user_id
left join ANALYTICS.PAYROLL.COMPANY_DIRECTORY cd
    on cd.employee_id = u.employee_id
left join (
    select invoice_id
      , sum(amount + tax_amount) as type_12_amt
    from ES_WAREHOUSE.PUBLIC.LINE_ITEMS
    where line_item_type_id = 12
    group by invoice_id
    ) type_12
  on type_12.invoice_id = li.invoice_id
where line_item_type_id in (22, 23)
  AND i.COMPANY_ID NOT IN (SELECT COMPANY_ID
                           FROM ES_WAREHOUSE.public.companies
                           WHERE name REGEXP 'IES\\d+ .*'
                              OR COMPANY_ID = 420           -- Demo Units
                              OR COMPANY_ID = 62875         -- ES Owned special events - still owned by us
                              OR COMPANY_ID IN (1854, 1855) -- ES Owned
                              OR COMPANY_ID = 61036 -- Trekker)
)
  and cn.ORIGINATING_INVOICE_ID is null
group by li.invoice_id,
        i.invoice_no,
         i.billing_approved_date,
         u.user_id,
         cd.employee_title,
          type_12_0
        )

, invoice_asset_info_prep1 as (
    select invoice_id,
        max(asset_id) as li_asset_id
    from ES_WAREHOUSE.PUBLIC.line_items li
    --where asset_id is not null
    group by invoice_id
)

, invoice_asset_info_prep2 as (
    select li.invoice_id
        , coalesce(coalesce(li_asset_id,wo2.asset_id),wo1.asset_id) as asset_id_
    from invoice_asset_info_prep1 li
    join ES_WAREHOUSE.PUBLIC.INVOICES i
        on i.invoice_id = li.invoice_id
    left join ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS wo1
        on replace(i.invoice_no, '-000','') = ltrim(replace(REGEXP_REPLACE(wo1.invoice_number,'[A-z]',''),'-000',''), ':#/-_,$.* ')
    left join ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS wo2
        on i.invoice_id = wo2.invoice_id
    where asset_id_ is not null
)

, invoice_asset_info as (
    select invoice_id
        , max(asset_id_) as asset_id
    from invoice_asset_info_prep2
    group by invoice_id
)

, credit_payments as (
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
        invoice_credited as (
        select
        invoice_id,
        invoice_no,
        public_note,
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

, warranty_final as (
        select
          ia.invoice_id,
          wo.work_order_id,
          ia.branch_id,
          ia.date_created,
          ai.asset_id,
          ia.total_amt, --Amount on invoice line items
          CASE when ic.paid = 'Yes' THEN ia.total_amt - IFNULL(cp.denied_amt,0) /*Total to 5316*/ - IFNULL(ABS(cm.cm_amount),0) /*Total Credited AR Adjustment*/
            ELSE 0
            END AS Paid_amt,
          case when ic.paid = 'No' or ic.paid is null then ia.total_amt --this isn't true becuase we could be short paid and pursue more money, BUT we want pending + denied = paid amt so we should leave it as 0 and assume the customer will not pay again
            else 0
            END AS Pending_amt,
          CASE when ic.paid = 'Yes' and (cp.denied_amt /*Total to 5316*/  > 0 OR ABS(cm.cm_amount) /*Total Credited AR Adjustment*/  > 0) then IFNULL(cp.denied_amt,0) /*Total to 5316*/  + IFNULL(ABS(cm.cm_amount),0) /*Total Credited AR Adjustment*/
            else 0
            END AS total_Denied_amt,
          DATEDIFF(day, ia.billing_approved_date, ia.paid_date) as claim_closure_days,
          cp.credit_amt, --Total credited on the invoice
          ic.invoice_no,
          ic.paid,
          ic.billing_approved_date,
          pr.warranty_parts_requested,
          lr.warranty_labor_requested,
          ia.warranty_team_created,
          iff(total_Denied_amt = ia.total_amt, TRUE, FALSE) as full_denial
        from
          invoice_amt ia
          left join invoice_asset_info ai on ia.invoice_id = ai.invoice_id
          left join credit_payments cp on ia.invoice_id = cp.invoice_id
          left join invoice_credited ic on ia.invoice_id = ic.invoice_id
          left join warranty_parts_requested pr on pr.invoice_id = ia.invoice_id
          left join warranty_labor_requested lr on lr.invoice_id = ia.invoice_id
          left join credit_memo cm on ia.invoice_id = cm.invoice_id
          left join ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS wo
            on wo.invoice_id = ia.invoice_id
            --on ltrim(replace(REGEXP_REPLACE(wo.invoice_number,'[A-z]',''),'-000',''), ':#/-_,$.* ') = replace(ia.invoice_no, '-000','')
      order by ia.date_created desc
)

, wos as (
    select wo.work_order_id
    , aa.make
    , wo.date_completed::DATE as date_completed
    , coalesce(i1.invoice_id, i2.invoice_id) as invoiceid
    , coalesce(i1.billing_approved_date::DATE, i2.billing_approved_date::DATE) as bill_approved_date
    , datediff(day, wo.date_completed, bill_approved_date ) as days_to_claim
    , case
        when days_to_claim >= 1 and days_to_claim <= 30 then '1. Within 30 Days'
        when days_to_claim >= 31 and days_to_claim <= 60 then '2. Within 60 Days'
        when days_to_claim >= 61 and days_to_claim <= 90 then '3. Within 90 Days'
        when days_to_claim >= 91 and days_to_claim <= 120 then '4. Within 120 Days'
        when days_to_claim >= 121 and days_to_claim <= 150 then '5. Within 150 Days'
        when days_to_claim >= 151 and days_to_claim <= 180 then '6. Within 180 Days'
        when days_to_claim > 180 then '7. Over 180 Days'
        else null
        end as claim_bucket
    , coalesce(i1.paid_amt, i2.paid_amt) as paid_amt_
    , coalesce(i1.total_amt, i2.total_amt) as total_amt_
    , paid_amt_ / total_amt_ as recovery_percentage
    , iff(coalesce(i1.full_denial, i2.full_denial) = true, 1,0) as full_denial_count
from ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS wo
left join warranty_final  i1
    on wo.invoice_id= i1.invoice_id
left join warranty_final i2
    on ltrim(replace(REGEXP_REPLACE(wo.invoice_number,'[A-z]',''),'-000',''), ':#/-_,$.* ')  = replace(i2.invoice_no, '-000','')
join es_warehouse.public.assets_aggregate aa
    on aa.asset_id = wo.asset_id
where wo.archived_date is null
    and invoiceid is not null
    and wo.billing_type_id = 1
    and days_to_claim < 365
    and days_to_claim > -15
    and total_amt_ > 0
    and (paid_amt_ > 0 or coalesce(i1.full_denial, i2.full_denial) = true)
)

select make
    , claim_bucket
    , count(work_order_id) as claims
    , sum(full_denial_count) as denied
    , sum(paid_amt_) as paid_amt
    , sum(total_amt_) as total_amt
from wos
group by make
    , claim_bucket;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}.make ;;
  }

  dimension: days_to_claim {
    type: string
    sql: ${TABLE}.claim_bucket ;;
  }

  dimension: claims {
    type: number
    sql: ${TABLE}.claims ;;
  }

  measure: total_claims {
    type: sum
    sql: ${claims} ;;
  }

  dimension: denied {
    type: number
    sql: ${TABLE}.denied ;;
  }

  measure: total_denied {
    type: sum
    sql: ${denied} ;;
  }

  dimension: paid_amt {
    type: number
    value_format_name: usd
    sql: ${TABLE}.paid_amt ;;
  }

  measure: total_paid {
    type: sum
    value_format_name: usd
    sql: ${paid_amt} ;;
  }

  dimension: total_amt {
    type: number
    value_format_name: usd
    sql: ${TABLE}.total_amt ;;
  }

  measure: total_claim_amt {
    type: sum
    value_format_name: usd
    sql: ${total_amt} ;;
  }
  }
