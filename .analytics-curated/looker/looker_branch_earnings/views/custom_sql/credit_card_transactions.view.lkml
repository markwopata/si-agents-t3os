view: credit_card_transactions {
  derived_table: {
    sql:
      /*select cfs.transaction_id,
             coalesce(cfs.card_type,'CAN''T GET TRANSACTION DETAIL') card_type,
             beds.mkt_id market_id,
             beds.descr entry_name,
             beds.gl_date,
             beds.amt gl_amount,
             beds.acctno accountno,
             beds.gl_acct gl_account,
             gle.description,
             cfs.full_name card_holder,
             cfs.transaction_date,
             cfs.transaction_amount,
             cfs.merchant_name,
             cfs.mcc
      from analytics.public.BRANCH_EARNINGS_DDS_SNAP beds
               join analytics.intacct.glentry gle
                    on split_part(pk, 'GL', 2) = gle.recordno::text
               left join analytics.public.CC_AND_FUEL_SPEND_ALL cfs
                    on case
                         when gle.batchtitle like '%Central CC%'
                             then split_part(replace(gle.description, '''', ''), ';', 3)
                         when gle.batchtitle like '%AMEX%' then
                             split_part(replace(gle.description, '''', ''), ';', 4) end = cfs.TRANSACTION_ID
      where (beds.descr like '%AMEX%'
         or beds.descr like '%Central CC%')
         and beds.amt <> 0
        */
-- Temporary fix until transaction id for central bank cc matches the entries
-- 12/18/25 - the params and missing_txn ctes are temporary. As of 12/18 there are are transactions in glentry that are not in gl_detail. Total impact is around -$316k. These CTEs can be removed once data gets reloaded into gl_detail. Issue is stemming from a dds issue.
      with params AS (
    SELECT
        '2025-11-01'::date AS month_start,
        '12646606'         AS journal_or_batch
),

/* Find transaction_ids that exist in GLENTRY but not in GL_DETAIL */
missing_txn AS (
    SELECT
        g.department_id,
        g.transaction_id
    FROM (
        SELECT
            gle.department                                         AS department_id,
            /* mirror your parsing logic, but handle AMEX vs non-AMEX */
            NULLIF(
                TRIM(
                    CASE
                        WHEN gle.batchtitle ILIKE '%AMEX%'
                            THEN SPLIT_PART(REPLACE(gle.description, '''', ''), ';', 4)
                        ELSE SPLIT_PART(REPLACE(gle.description, '''', ''), ';', 3)
                    END
                ),
                ''
            )                                                      AS transaction_id
        FROM analytics.intacct.glentry gle
        CROSS JOIN params p
        WHERE DATE_TRUNC('month', gle.entry_date) = p.month_start
          AND gle.batchno = p.journal_or_batch
        GROUP BY 1,2
    ) g
    LEFT JOIN (
        SELECT
            gd.department_id                                       AS department_id,
            /* match your GL_DETAIL transaction_id behavior (AMEX may have trailing .0) */
            NULLIF(
                TRIM(
                    IFF(
                        SPLIT_PART(gd.entry_description, ';', 1) = 'Amex',
                        REGEXP_REPLACE(SPLIT_PART(gd.entry_description, ';', 3), '.0$', ''),
                        SPLIT_PART(gd.entry_description, ';', 3)
                    )
                ),
                ''
            )                                                      AS transaction_id
        FROM analytics.intacct_models.gl_detail gd
        CROSS JOIN params p
        WHERE DATE_TRUNC('month', gd.entry_date) = p.month_start
          AND gd.fk_journal_id = p.journal_or_batch
        GROUP BY 1,2
    ) d
        ON g.department_id  = d.department_id
       AND g.transaction_id = d.transaction_id
    WHERE d.transaction_id IS NULL
      AND g.transaction_id IS NOT NULL
),

      final_cte as (
      select coalesce(cfs.transaction_id, case
                                              when gle.batchtitle like '%Central CC%'
                                                  then split_part(replace(gle.description, '''', ''), ';', 3) end)         transaction_id,
             coalesce(cfs.card_type, case
                                         when gle.batchtitle like '%Central CC%' and
                                              split_part(replace(gle.description, '''', ''), ';', 3) is not null
                                             then 'central_bank' end,
                      'CAN''T GET TRANSACTION DETAIL')                                                                     card_type,
             beds.mkt_id                                                                                                   market_id,
             beds.descr                                                                                                    entry_name,
             beds.gl_date,
             beds.amt                                                                                                      gl_amount,
             beds.acctno                                                                                                   accountno,
             beds.gl_acct                                                                                                  gl_account,
             gle.description,
             coalesce(cfs.full_name, cd.first_name || ' ' || cd.last_name, case
                                              when gle.batchtitle like '%Central CC%'
                                                  then split_part(replace(gle.description, '''', ''), ';', 4) end)                                                 card_holder,
             coalesce(cfs.transaction_date, case
                                                when gle.batchtitle like '%Central CC%'
                                                    then try_to_date(split_part(replace(gle.description, '''', ''), ';', 1), 'mm/dd/yy') end) transaction_date,
             cfs.transaction_amount,
             coalesce(cfs.merchant_name, case
                                             when gle.batchtitle like '%Central CC%'
                                                 then split_part(replace(gle.description, '''', ''), ';', 5) end)          merchant_name,
             cfs.mcc,
             null alloc_to,
             null receipt_url
      from analytics.public.BRANCH_EARNINGS_DDS_SNAP beds
               join analytics.intacct.glentry gle
                    on split_part(pk, 'GL', 2) = gle.recordno::text
               left join analytics.public.CC_AND_FUEL_SPEND_ALL cfs
                         on case
                                when gle.batchtitle like '%Central CC%'
                                    then split_part(replace(gle.description, '''', ''), ';', 3)
                                when gle.batchtitle like '%AMEX%' then
                                    split_part(replace(gle.description, '''', ''), ';', 4) end = cfs.TRANSACTION_ID
               left join analytics.payroll.company_directory cd
                         on cd.employee_id::text = case
                                                 when gle.batchtitle like '%Central CC%'
                                                     then try_to_number(split_part(replace(gle.description, '''', ''), ';', 2))::text end
      where (beds.descr like '%AMEX%'
          or beds.descr like '%Central CC%')
        and beds.amt <> 0
        and GL_DATE < '2022-04-30'

      union all

select
          split_part(GLE.ENTRY_DESCRIPTION, ';',3) transaction_id,
          case
              when split_part(GLE.ENTRY_DESCRIPTION,';',1) = 'Fuel' then 'fuel_card'
              when split_part(GLE.ENTRY_DESCRIPTION,';',1) = 'Central' then 'central_bank'
              when split_part(GLE.ENTRY_DESCRIPTION,';',1) = 'Amex' then 'amex'
              when split_part(GLE.ENTRY_DESCRIPTION,';',1) = 'Citi' then 'citi'
              when split_part(GLE.ENTRY_DESCRIPTION,';',1) = 'Navan' then 'navan'
              end card_type,
          BEDS.MKT_ID market_id,
          BEDS.DESCR entry_name,
          BEDS.GL_DATE,
          BEDS.AMT gl_amount,
          BEDS.ACCTNO accountno,
          BEDS.GL_ACCT gl_account,
          GLE.ENTRY_DESCRIPTION,
          upper(split_part(GLE.ENTRY_DESCRIPTION,';',4)) card_holder,
          try_to_date(split_part(GLE.ENTRY_DESCRIPTION,';',2)) transaction_date,
          case when card_type in ('fuel_card','central_bank','amex','citi') then CFS.TRANSACTION_AMOUNT
               when split_part(GLE.ENTRY_DESCRIPTION,';',1) = 'Navan'
                and split_part(GLE.ENTRY_DESCRIPTION,';',6) = 'Navan Booking Fee' then B.TRIP_FEE
               when split_part(GLE.ENTRY_DESCRIPTION,';',1) = 'Navan'
                and split_part(GLE.ENTRY_DESCRIPTION,';',6) != 'Navan Booking Fee' then B.TRAVEL_SPEND
               else 0
               end transaction_amount,
          split_part(GLE.ENTRY_DESCRIPTION,';',6) merchant_name,
          CFS.MCC,
          split_part(GLE.ENTRY_DESCRIPTION,';',5) alloc_to,
          tv.UPLOAD_URL receipt_url
      from ANALYTICS.PUBLIC.BRANCH_EARNINGS_DDS_SNAP BEDS
      join ANALYTICS.INTACCT_MODELS.GL_DETAIL GLE
          on split_part(BEDS.PK, 'GL', 2) = GLE.FK_GL_ENTRY_ID::varchar
      left join ANALYTICS.PUBLIC.CC_AND_FUEL_SPEND_ALL CFS
          on iff(split_part(GLE.ENTRY_DESCRIPTION,';',1) = 'Amex',
              regexp_replace(split_part(GLE.ENTRY_DESCRIPTION, ';',3),'.0$',''),
              split_part(GLE.ENTRY_DESCRIPTION,';',3)) = CFS.TRANSACTION_ID
          and case
                  when split_part(GLE.ENTRY_DESCRIPTION,';',1) = 'Fuel' then 'fuel_card'
                  when split_part(GLE.ENTRY_DESCRIPTION,';',1) = 'Central' then 'central_bank'
                  when split_part(GLE.ENTRY_DESCRIPTION,';',1) = 'Amex' then 'amex'
                  when split_part(GLE.ENTRY_DESCRIPTION,';',1) = 'Citi' then 'citi'
                  when split_part(GLE.ENTRY_DESCRIPTION,';',1) = 'Navan' then 'navan'
                  end = CFS.CARD_TYPE
      left join ANALYTICS.CREDIT_CARD.TRANSACTION_VERIFICATION tv
          on CFS.TRANSACTION_ID = tv.TRANSACTION_ID
      left join ANALYTICS.NAVAN.BOOKING b
          on upper(split_part(GLE.ENTRY_DESCRIPTION,';',3)) = upper(B.BOOKING_ID)
      where BEDS.DESCR regexp '(1009 - Fuel CC|1009 - Central Bank|1009 - AMEX|1009 - Citi Bank) allocation entry .+'
        or BEDS.DESCR regexp '(Fuel CC|Central Bank|AMEX|Citi Bank) allocation entry .+'
        or BEDS.DESCR regexp '(1099 - Citi CC Allocation - Correcting) .+'
        or BEDS.DESCR regexp '(1009 - Fuel CC|1009 - Central Bank|1009 - AMEX|1009 - Citi Bank) Allocation Entry .+'
        or BEDS.DESCR regexp '(1009 - Fuel CC|1009 - Central Bank|1009 - AMEX|1009 - Citi Bank) Allocation .+'
        or BEDS.DESCR regexp '(1009 - Fuel CC|1009 - Central Bank|1009 - AMEX|1009 - Citi Bank) CC Allocation .+'
        or BEDS.DESCR regexp '(1009 - AMEX Corp) CC Allocation .+'
        or BEDS.DESCR regexp '(1009 - Navan Allocation) .+'

UNION ALL

    /* =========================
       NEW BLOCK #3: MISSING TXNS - can be dropped when dds resumes
       (GLENTRY rows that don't exist in GL_DETAIL)
       Output matches the exact final_cte column order
       ========================= */
    SELECT
        mt.transaction_id                                               AS transaction_id,
        COALESCE(
            cfs.card_type,
            CASE
                WHEN gle.batchtitle ILIKE '%Fuel%'        THEN 'fuel_card'
                WHEN gle.batchtitle ILIKE '%Central%'     THEN 'central_bank'
                WHEN gle.batchtitle ILIKE '%Central CC%'  THEN 'central_bank'
                WHEN gle.batchtitle ILIKE '%AMEX%'        THEN 'amex'
                WHEN gle.batchtitle ILIKE '%Citi%'        THEN 'citi'
                WHEN gle.batchtitle ILIKE '%Navan%'       THEN 'navan'
            END,
            'CAN''T GET TRANSACTION DETAIL'
        )                                                               AS card_type,
        beds.mkt_id                                                     AS market_id,
        beds.descr                                                      AS entry_name,
        beds.gl_date,
        beds.amt                                                        AS gl_amount,
        beds.acctno                                                     AS accountno,
        beds.gl_acct                                                    AS gl_account,
        /* keep column position consistent with the other unions */
        gle.description                                                 AS description,
        upper(split_part(GLE.DESCRIPTION,';',4))                        AS card_holder,
        COALESCE(
            cfs.transaction_date,
            /* Central CC format in GLENTRY: date tends to be part 1 (mm/dd/yy) */
            TRY_TO_DATE(SPLIT_PART(REPLACE(gle.description, '''', ''), ';', 1), 'mm/dd/yy'),
            TRY_TO_DATE(SPLIT_PART(REPLACE(gle.description, '''', ''), ';', 2))
        )                                                               AS transaction_date,
        cfs.transaction_amount                                          AS transaction_amount,
        COALESCE(
            cfs.merchant_name,
            /* Central CC format often has merchant at part 5 */
            SPLIT_PART(REPLACE(gle.description, '''', ''), ';', 5)
        )                                                               AS merchant_name,
        cfs.mcc                                                         AS mcc,
        split_part(GLE.DESCRIPTION,';',5)                               AS alloc_to,
        tv.upload_url                                                   AS receipt_url

    FROM analytics.public.branch_earnings_dds_snap beds
    JOIN analytics.intacct.glentry gle
        ON SPLIT_PART(beds.pk, 'GL', 2) = gle.recordno::text
    JOIN missing_txn mt
        ON mt.department_id = gle.department
       AND mt.transaction_id =
            NULLIF(
                TRIM(
                    CASE
                        WHEN gle.batchtitle ILIKE '%AMEX%'
                            THEN SPLIT_PART(REPLACE(gle.description, '''', ''), ';', 4)
                        ELSE SPLIT_PART(REPLACE(gle.description, '''', ''), ';', 3)
                    END
                ),
                ''
            )
    LEFT JOIN analytics.public.cc_and_fuel_spend_all cfs
        ON mt.transaction_id = cfs.transaction_id
    LEFT JOIN analytics.credit_card.transaction_verification tv
        ON cfs.transaction_id = tv.transaction_id
    LEFT JOIN analytics.payroll.company_directory cd
        ON cd.employee_id::text =
           TRY_TO_NUMBER(SPLIT_PART(REPLACE(gle.description, '''', ''), ';', 2))::text
    /* You can keep or adjust these filters; included only to avoid bringing in unrelated GLENTRY lines */
    WHERE beds.descr REGEXP '(1009 - Fuel CC|1009 - Central Bank|1009 - AMEX|1009 - Citi Bank) allocation entry .+'
       OR beds.descr REGEXP '(Fuel CC|Central Bank|AMEX|Citi Bank) allocation entry .+'
       OR beds.descr REGEXP '(1099 - Citi CC Allocation - Correcting) .+'
       OR beds.descr REGEXP '(1009 - Fuel CC|1009 - Central Bank|1009 - AMEX|1009 - Citi Bank) Allocation Entry .+'
       OR beds.descr REGEXP '(1009 - Fuel CC|1009 - Central Bank|1009 - AMEX|1009 - Citi Bank) Allocation .+'
       OR beds.descr REGEXP '(1009 - Fuel CC|1009 - Central Bank|1009 - AMEX|1009 - Citi Bank) CC Allocation .+'
       OR beds.descr REGEXP '(1009 - AMEX Corp) CC Allocation .+'
       OR beds.descr REGEXP '(1009 - Navan Allocation) .+'
)
SELECT
    ROW_NUMBER() OVER (ORDER BY fc.market_id) AS pk,
    fc.*
FROM final_cte AS fc
    ;;
  }

  dimension: pk {
    type: number
    primary_key: yes
    hidden: yes
    sql: ${TABLE}."PK" ;;
  }

  dimension: transaction_id {
    type: string
    sql: ${TABLE}."TRANSACTION_ID" ;;
  }

  dimension: card_type {
    type: string
    sql: ${TABLE}."CARD_TYPE" ;;
    suggest_persist_for: "12 hours"
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: entry_name {
    type: string
    sql: ${TABLE}."ENTRY_NAME" ;;
  }

  dimension: gl_date {
    type: date
    label: "GL Date"
    sql: ${TABLE}."GL_DATE" ;;
  }

  measure: gl_amount {
    type: sum
    label: "GL Amount"
    value_format: "#,##0.00;(#,##0.00);-"
    sql: ${TABLE}."GL_AMOUNT" ;;
  }

  dimension: gl_code {
    type: string
    label: "GL Code"
    sql: ${TABLE}."ACCOUNTNO" ;;
    suggest_explore: account_suggestions_be_snap
    suggest_dimension: account_suggestions_be_snap.account_number
    suggest_persist_for: "6 hours"
  }

  dimension: gl_account {
    type: string
    label: "GL Account"
    sql: ${TABLE}."GL_ACCOUNT" ;;
    suggest_explore: account_suggestions_be_snap
    suggest_dimension: account_suggestions_be_snap.account_name
    suggest_persist_for: "6 hours"
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension: card_holder {
    type: string
    sql: ${TABLE}."CARD_HOLDER" ;;
  }

  # dimension: alloc_to {
  #   type: string
  #   sql: ${TABLE}."ALLOC_TO";;
  # }

  dimension: alloc_to {
    type: string
    sql: case when ${TABLE}."ALLOC_TO" = '1010000' then 'R1'
              when ${TABLE}."ALLOC_TO" = '1010100' then 'D1-1'
              when ${TABLE}."ALLOC_TO" = '1010200' then 'D1-2'
              when ${TABLE}."ALLOC_TO" = '1010300' then 'D1-3'
              when ${TABLE}."ALLOC_TO" = '1010400' then 'D1-4'
              when ${TABLE}."ALLOC_TO" = '1010500' then 'D1-5'
              when ${TABLE}."ALLOC_TO" = '1020000' then 'R2'
              when ${TABLE}."ALLOC_TO" = '1020100' then 'D2-1'
              when ${TABLE}."ALLOC_TO" = '1020200' then 'D2-2'
              when ${TABLE}."ALLOC_TO" = '1020300' then 'D2-3'
              when ${TABLE}."ALLOC_TO" = '1020400' then 'D2-4'
              when ${TABLE}."ALLOC_TO" = '1020500' then 'D2-5'
              when ${TABLE}."ALLOC_TO" = '1030000' then 'R3'
              when ${TABLE}."ALLOC_TO" = '1030100' then 'D3-1'
              when ${TABLE}."ALLOC_TO" = '1030200' then 'D3-2'
              when ${TABLE}."ALLOC_TO" = '1030300' then 'D3-3'
              when ${TABLE}."ALLOC_TO" = '1030400' then 'D3-4'
              when ${TABLE}."ALLOC_TO" = '1030500' then 'D3-5'
              when ${TABLE}."ALLOC_TO" = '1030600' then 'D3-6'
              when ${TABLE}."ALLOC_TO" = '1040000' then 'R4'
              when ${TABLE}."ALLOC_TO" = '1040100' then 'D4-1'
              when ${TABLE}."ALLOC_TO" = '1040200' then 'D4-2'
              when ${TABLE}."ALLOC_TO" = '1040300' then 'D4-3'
              when ${TABLE}."ALLOC_TO" = '1040400' then 'D4-4'
              when ${TABLE}."ALLOC_TO" = '1040500' then 'D4-5'
              when ${TABLE}."ALLOC_TO" = '1040600' then 'D4-6'
              when ${TABLE}."ALLOC_TO" = '1040700' then 'D4-7'
              when ${TABLE}."ALLOC_TO" = '1040800' then 'D4-8'
              when ${TABLE}."ALLOC_TO" = '1040900' then 'D4-9'
              when ${TABLE}."ALLOC_TO" = '1050000' then 'R5'
              when ${TABLE}."ALLOC_TO" = '1050100' then 'D5-1'
              when ${TABLE}."ALLOC_TO" = '1050200' then 'D5-2'
              when ${TABLE}."ALLOC_TO" = '1050300' then 'D5-3'
              when ${TABLE}."ALLOC_TO" = '1050400' then 'D5-4'
              when ${TABLE}."ALLOC_TO" = '1050500' then 'D5-5'
              when ${TABLE}."ALLOC_TO" = '1060000' then 'R6'
              when ${TABLE}."ALLOC_TO" = '1060100' then 'D6-1'
              when ${TABLE}."ALLOC_TO" = '1060200' then 'D6-2'
              when ${TABLE}."ALLOC_TO" = '1060300' then 'D6-3'
              when ${TABLE}."ALLOC_TO" = '1060400' then 'D6-4'
              when ${TABLE}."ALLOC_TO" = '1060500' then 'D6-5'
              when ${TABLE}."ALLOC_TO" = '1070000' then 'R7'
              when ${TABLE}."ALLOC_TO" = '1070100' then 'D7-1'
              when ${TABLE}."ALLOC_TO" = '1070200' then 'D7-2'
              when ${TABLE}."ALLOC_TO" = '1070300' then 'D7-3'
              when ${TABLE}."ALLOC_TO" = '1070400' then 'D7-4'
              else ${TABLE}."ALLOC_TO" end
    ;;
  }


  dimension_group: transaction {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: coalesce(${TABLE}."TRANSACTION_DATE",${TABLE}."GL_DATE") ;;
  }

  measure: transaction_amount {
    type: sum_distinct
    value_format: "#,##0.00;(#,##0.00);-"
    sql_distinct_key: CONCAT(${transaction_id}, ${merchant_name}) ;;
    sql: -${TABLE}."TRANSACTION_AMOUNT" ;;
  }

  dimension: merchant_name {
    type: string
    sql: ${TABLE}."MERCHANT_NAME" ;;
  }

  dimension: mcc {
    type: string
    label: "MCC"
    sql: ${TABLE}."MCC" ;;
  }

  dimension: receipt_url {
    type: string
    label: "Receipt URL"
    sql: ${TABLE}."RECEIPT_URL" ;;
    html:
    {% if receipt_url._value %}
      {% assign urls = receipt_url._value | split: ',' %}
      {% for url in urls %}
        <a href='{{ url | strip }}' target='_blank' style='color:blue; text-decoration:underline;'>[Receipt {{ forloop.index }}]</a>
        {% if forloop.last == false %} {% endif %}
      {% endfor %}
    {% else %}
      No Receipts
    {% endif %}
     ;;
  }

  dimension: months_open {
    type: number
    sql: datediff(months, ${revmodel_market_rollout_conservative.branch_earnings_start_month_raw}, ${plexi_periods.date})+1 ;;
  }

  dimension: greater_twelve_months_open {
    label: "Markets Greater Than 12 Months Open?"
    type: yesno
    sql: ${months_open} > 12;;
  }
}
