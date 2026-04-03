view: entries_live_be {
  derived_table: {
    sql:
-- **** LIVE ACTIVITY QUERY GOES HERE ****

-- *** ADD NEW CTEs HERE ***
-- LIVE BE SALES REVENUE
WITH SALES_REVENUE AS (
    SELECT
        I.INVOICE_NO,
        I.BILLING_APPROVED_DATE,
        LIT.NAME              AS LINE_ITEM_TYPE,
        STPL.STAT_ACCT        AS STAT_ACCT,
        STPL.LINE_ITEM_TYPE   AS GL_ACCT,
        STPL.REVEXP           AS REV_EXP,
        LI.ASSET_ID,
        I.SHIP_FROM:branch_id AS MARKET_ID,
        MKT.MARKET_NAME       AS MARKET_NAME,
        C.NAME                AS COMPANY_NAME,
        AA.CLASS,
        LI.AMOUNT             AS REVENUE
    FROM ES_WAREHOUSE.PUBLIC.LINE_ITEMS AS LI
    JOIN ES_WAREHOUSE.PUBLIC.INVOICES AS I
        ON LI.INVOICE_ID = I.INVOICE_ID
    JOIN ES_WAREHOUSE.PUBLIC.LINE_ITEM_TYPES AS LIT
        ON LI.LINE_ITEM_TYPE_ID = LIT.LINE_ITEM_TYPE_ID
    JOIN ANALYTICS.PUBLIC.MARKET_REGION_XWALK AS MKT
        ON I.SHIP_FROM:branch_id = MKT.MARKET_ID
    JOIN ES_WAREHOUSE.PUBLIC.COMPANIES AS C
        ON I.COMPANY_ID = C.COMPANY_ID
    JOIN ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE AS AA
        ON AA.ASSET_ID = LI.ASSET_ID
    LEFT JOIN ANALYTICS.PUBLIC.STAT_PL AS STPL
        ON LIT.NAME = STPL.LINE_ITEM_TYPE

    WHERE I.BILLING_APPROVED_DATE >= '2022-05-01' -- Change to date we go live
        AND LI.LINE_ITEM_TYPE_ID IN (24, 80, 81, 50, 110, 111)
        AND I.COMPANY_ID NOT IN (38966, 5440, 35193, 6954, 1854)
        AND MKT.MARKET_NAME IS NOT NULL
),
SALES_COGS AS (
    SELECT
        AA.ASSET_ID,
        AA.OEC,
        SR.MARKET_NAME,
        SR.BILLING_APPROVED_DATE,
        COALESCE(AA.OEC - LEAST(AA.OEC *
            CASE
                WHEN AA.ASSET_TYPE IN ('vehicle', 'trailer')
                THEN .9 / (7 * 12) -- vehicle salvage = 10%, equip = 20%
                ELSE .8 / (10 * 12) END *
            GREATEST(0,DATEDIFF(MONTH, IFF(AA.ASSET_TYPE = 'equipment',
                    date_from_parts(year(AA.FIRST_RENTAL),month(AA.FIRST_RENTAL),15),
                COALESCE(date_from_parts(year(AA.PURCHASE_DATE),month(AA.PURCHASE_DATE),15),
                date_from_parts(year(AA.DATE_CREATED),month(AA.DATE_CREATED),15))),
                date_from_parts(year(SR.BILLING_APPROVED_DATE),month(SR.BILLING_APPROVED_DATE), 15))),
            /*Salvage Value*/AA.OEC * CASE WHEN AA.ASSET_TYPE IN ('vehicle', 'trailer') THEN .9 ELSE .8 END)
            * CASE
                WHEN AA.FIRST_RENTAL IS NULL AND AA.ASSET_TYPE = 'equipment' THEN 0
            ELSE 1 END, AA.OEC) AS NBV
    FROM ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE AS AA
    JOIN SALES_REVENUE AS SR
        ON SR.ASSET_ID = AA.ASSET_ID
),
-- LIVE BE CREDIT REVENUE
CREDIT_REVENUE AS (
    SELECT
        I.INVOICE_NO,
        CN.DATE_CREATED::DATE AS CREDIT_NOTE_DATE_CREATED,
        LIT.NAME              AS LINE_ITEM_TYPE,
        STPL.STAT_ACCT        AS STAT_ACCT,
        STPL.REVEXP           AS REV_EXP,
        LI.ASSET_ID,
        I.SHIP_FROM:branch_id AS MARKET_ID,
        MKT.MARKET_NAME       AS MARKET_NAME,
        C.NAME                AS COMPANY_NAME,
        AA.CLASS,
        CN.CREDIT_NOTE_NUMBER,
        STPL.LINE_ITEM_TYPE   AS GL_ACCT,
        I.BILLING_APPROVED_DATE,
        CNLI.CREDIT_AMOUNT    AS CREDIT_REVENUE
    FROM ES_WAREHOUSE.PUBLIC.LINE_ITEMS AS LI
    JOIN ES_WAREHOUSE.PUBLIC.INVOICES AS I
        ON LI.INVOICE_ID = I.INVOICE_ID
    JOIN ES_WAREHOUSE.PUBLIC.LINE_ITEM_TYPES AS LIT
        ON LI.LINE_ITEM_TYPE_ID = LIT.LINE_ITEM_TYPE_ID
    JOIN ANALYTICS.PUBLIC.MARKET_REGION_XWALK AS MKT
        ON I.SHIP_FROM:branch_id = MKT.MARKET_ID
    JOIN ES_WAREHOUSE.PUBLIC.COMPANIES AS C
        ON I.COMPANY_ID = C.COMPANY_ID
    JOIN ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE AS AA
        ON AA.ASSET_ID = LI.ASSET_ID
    LEFT JOIN ANALYTICS.PUBLIC.STAT_PL AS STPL
        ON LIT.NAME = STPL.LINE_ITEM_TYPE
    JOIN ES_WAREHOUSE.PUBLIC.CREDIT_NOTES AS CN
        ON CN.ORIGINATING_INVOICE_ID = I.INVOICE_ID
    JOIN ES_WAREHOUSE.PUBLIC.CREDIT_NOTE_LINE_ITEMS AS CNLI
        ON CN.CREDIT_NOTE_ID = CNLI.CREDIT_NOTE_ID
        AND CNLI.LINE_ITEM_ID = LI.LINE_ITEM_ID

    WHERE CN.DATE_CREATED::DATE >= '2022-05-01' -- Change to date we go live
        AND LI.LINE_ITEM_TYPE_ID IN (24, 80, 81, 50, 110, 111)
        AND I.COMPANY_ID NOT IN (38966, 5440, 35193, 6954, 1854)
        AND MKT.MARKET_NAME IS NOT NULL
),
SALES_COGS_CREDIT AS (
    SELECT AA.ASSET_ID,
    AA.OEC,
    CR.MARKET_NAME,
    CR.BILLING_APPROVED_DATE,
    COALESCE(AA.OEC - LEAST(AA.OEC *
        CASE
            WHEN AA.ASSET_TYPE IN ('vehicle', 'trailer') THEN .9 / (7 * 12) -- vehicle salvage = 10%, equip = 20%
        ELSE .8 / (10 * 12) END *
        GREATEST(0,
            DATEDIFF(MONTH, IFF(AA.ASSET_TYPE = 'equipment',
                    date_from_parts(year(AA.FIRST_RENTAL),month(AA.FIRST_RENTAL),15),
                COALESCE(date_from_parts(year(AA.PURCHASE_DATE),month(AA.PURCHASE_DATE),15),
                date_from_parts(year(AA.DATE_CREATED),month(AA.DATE_CREATED),15))),
                date_from_parts(year(CR.BILLING_APPROVED_DATE),month(CR.BILLING_APPROVED_DATE),15))),
        /*Salvage Value*/AA.OEC * CASE WHEN AA.ASSET_TYPE IN ('vehicle', 'trailer') THEN .9 ELSE .8 END)
        * CASE
            WHEN AA.FIRST_RENTAL IS NULL AND AA.ASSET_TYPE = 'equipment' THEN 0
        ELSE 1 END, AA.OEC) AS NBV
    FROM ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE AS AA
    JOIN CREDIT_REVENUE AS CR
        ON CR.ASSET_ID = AA.ASSET_ID
),
-- LIVE CC ALLOCATION
cc_unposted_trans as (
    select
        CCA.EMPLOYEE_NUMBER,
        CCA.TRANSACTION_DATE,
        CCA.TRANSACTION_ID,
        CCA.MCC_CODE,
        CCA.MERCHANT_NAME,
        CCA.TRANSACTION_AMOUNT,
        CCA.CARD_TYPE
    from ANALYTICS.PUBLIC.CC_AND_FUEL_SPEND_ALL CCA
    left join (     -- List of all transaction IDs posted to Intacct since BA took over
        select
        decode(
            split_part(DESCRIPTION,';',1),
            'Fuel','fuel_card',
            'Central','central_bank',
            'Amex','amex') card_type,
        iff(try_to_number(split_part(DESCRIPTION,';',3)) is not null,
            try_to_number(split_part(DESCRIPTION,';',3))::int::varchar, -- Clean up for integers posted with '.0'
            split_part(DESCRIPTION,';',3)) transaction_id
    from ANALYTICS.INTACCT.GLENTRY
    where BATCHTITLE like any ('Fuel CC allocation entry%','Central Bank allocation entry%','AMEX allocation entry%')
        and transaction_id is not null
    ) posted_transactions
        on CCA.CARD_TYPE = posted_transactions.card_type
        and CCA.TRANSACTION_ID = posted_transactions.transaction_id
    where CCA.TRANSACTION_DATE > '2022-03-31'   -- Posting to GL by transaction ID began 4/1
        and posted_transactions.transaction_id is null
),
cc_employee_cost as (    -- Employee cost center code adapted from CC allocation script
    select
        CD.EMPLOYEE_ID glentry_employeeid,
        CD.WORK_EMAIL,
        FD.DRIVER_ID::int driver_id,
        concat(coalesce(CD.NICKNAME,CD.FIRST_NAME),' ',CD.LAST_NAME) ee_name,
        CD.DATE_TERMINATED,
        coalesce(EC.default_cost_center,CD.DEFAULT_COST_CENTERS_FULL_PATH) cost_center,
        split_part(cost_center,'/',1) region,
        split_part(cost_center,'/',2) district,
        case
            when region in ('Corp','Tele') and
                (CD.MARKET_ID = 1000000 or CD.MARKET_ID is null or EC.MARKET_ID_ = '1000000') then 'CORP1'
            else coalesce(EC.MARKET_ID_,CD.MARKET_ID::varchar) end market,
        DATE_FROM,
        DATE_TO
    from ANALYTICS.PAYROLL.COMPANY_DIRECTORY CD
    left join (select * from ANALYTICS.PAYROLL.EMPLOYEE_COSTCENTER_CHRONOLOGY) EC
        on CD.EMPLOYEE_ID = EC.ee_id
    left join ANALYTICS.PUBLIC.FUEL_CARD_DRIVERS FD
        on lower(FD.EMAIL_ADDRESS) = lower(CD.WORK_EMAIL)
        or lower(FD.EMAIL_ADDRESS) = lower(CD.PERSONAL_EMAIL)
        or (FD.DRIVER_FIRST_NAME = upper(CD.FIRST_NAME)
            and FD.DRIVER_LAST_NAME = upper(CD.LAST_NAME))
    where cost_center is not null
),
cc_alloc_basis as (    -- Region/district allocation code adapted from CC allocation script
    select
        XW.MARKET_ID::varchar dept_id,
        gl_mo,
        XW.DISTRICT,
        rev.market_rev / sum(rev.market_rev) over (partition by XW.DISTRICT) market_pct_district,
        concat('R',XW.REGION) region,
        rev.market_rev / sum(rev.market_rev) over (partition by XW.REGION) market_pct_region
    from ANALYTICS.PUBLIC.MARKET_REGION_XWALK XW
    join (
            select
                DEPARTMENT,
                date_trunc(month, ENTRY_DATE) gl_mo,
                round(sum(AMOUNT*-TR_TYPE),2) market_rev
            from ANALYTICS.INTACCT.GLENTRY
            where STATE = 'Posted'
                and ACCOUNTNO = '5000'
            group by DEPARTMENT, gl_mo
        ) rev
        on XW.MARKET_ID::varchar = rev.DEPARTMENT
),
cc_final as (
    select
        iff(cc_employee_cost.DATE_TERMINATED < date_trunc(month, cc_unposted_trans.TRANSACTION_DATE),
            'CORP1',coalesce(cc_employee_cost.market, cc_alloc_basis.dept_id)) market_id,
        coalesce(mcc.INTACCT_ACCOUNT,7409) accountno,
        concat(decode(cc_unposted_trans.CARD_TYPE,
                'fuel_card','Fuel',
                'central_bank','Central',
                'amex','Amex'),';',
            cc_unposted_trans.TRANSACTION_DATE::date,';',
            cc_unposted_trans.TRANSACTION_ID,';',
            concat(cc_employee_cost.ee_name,
                iff(cc_employee_cost.DATE_TERMINATED < date_trunc(month, cc_unposted_trans.TRANSACTION_DATE)
                    ,' TERMINATED', '')),';',
            coalesce(concat('M',cc_employee_cost.market), cc_employee_cost.district, cc_employee_cost.region),';',
            cc_unposted_trans.MERCHANT_NAME) descr,
        cc_unposted_trans.TRANSACTION_DATE gl_date,
        cc_unposted_trans.TRANSACTION_AMOUNT * case
            when cc_employee_cost.market is not null then 1
            when cc_employee_cost.district is not null then cc_alloc_basis.market_pct_district
            when cc_employee_cost.region is not null then cc_alloc_basis.market_pct_region end amt,
        cc_unposted_trans.TRANSACTION_ID
    from cc_unposted_trans
    left join cc_employee_cost
        on cc_unposted_trans.EMPLOYEE_NUMBER = cc_employee_cost.glentry_employeeid
        and cc_unposted_trans.TRANSACTION_DATE between cc_employee_cost.DATE_FROM and cc_employee_cost.DATE_TO
    left join cc_alloc_basis
        on date_trunc(month, cc_unposted_trans.TRANSACTION_DATE) = cc_alloc_basis.gl_mo
        and cc_employee_cost.market is null
        and 1 = case
            when cc_employee_cost.district = cc_alloc_basis.district then 1
            when cc_employee_cost.region = cc_alloc_basis.region then 1 end
    left join ANALYTICS.GS.MCC mcc
        on cc_unposted_trans.MCC_CODE = mcc.MCC_NO_
),
-- CONTRACTOR PAYOUTS
payout_agg as (
    select
        MARKET_ID::varchar market_id,
        'FLEX' type,
        ASSET_ID,
        COMPANY_ID,
        PAYOUT_MONTH payout_date,
        ASSET_PAYOUT_AMOUNT
    from ANALYTICS.CONTRACTOR_PAYOUTS.FLEX_PAYOUT_OUTPUT
    where ASSET_PAYOUT_AMOUNT != 0

    union all

    select
        RENTAL_BRANCH_ID::varchar market_id,
        'PLUS' type,
        ASSET_ID,
        COMPANY_ID,
        DTE payout_date,
        PAYMENT_AMT asset_payout_amount
    from ANALYTICS.CONTRACTOR_PAYOUTS.PLUS_PAYOUT_OUTPUT
    where PAYMENT_AMT != 0

    union all

    select
        MARKET_ID::varchar market_id,
        'Tracker' type,
        TBO.ASSET_ID,
        COMPANY_ID,
        DTE payout_date,
        -COST asset_payout_amount
    from ANALYTICS.CONTRACTOR_PAYOUTS.TRACKER_BILLING_OUTPUT TBO
    left join ANALYTICS.PUBLIC.HISTORICAL_ASSET_MARKET HAM
        on TBO.ASSET_ID = HAM.ASSET_ID
        and DTE = HAM.DATE
    where COST != 0
),
-- *** ADD NEW LIVE ACTIVITY QUERIES TO UNION_CTE ***
union_cte as (

-- Rental Revenue
SELECT
    X.MARKET_ID,
    X.MARKET_NAME,
    'Rental Revenues'                                                                              AS TYPE,
    'REVrent'                                                                                      AS CODE,
    'REV'                                                                                          AS REVEXP,
    'rent'                                                                                         AS DEPT,
    NULL                                                                                           AS PR_TYPE,
    'ES-Owned Equipment Rental Revenue'                                                            AS GL_ACCT,
    '5000'                                                                                         AS ACCTNO, -- Placeholder until stat account is created
    IFF(LI.CREDIT_NOTE_ID IS NULL, 'Invoice', 'Credit')                                            AS AR_TYPE,
    LI.DESCRIPTION                                                                                 AS DESCRIPTION,
    LI.GL_BILLING_APPROVED_DATE::DATE                                                              AS GL_DATE,
--     MONTHNAME(LI.GL_BILLING_APPROVED_DATE::DATE) || '-' || YEAR(LI.GL_BILLING_APPROVED_DATE::DATE) AS PERIOD,
--     DAY(LAST_DAY(LI.GL_BILLING_APPROVED_DATE::DATE))                                               AS DAYS_IN_MONTH,
    '26'                                                                                           AS DOC_NO,
    CONCAT(X.MARKET_ID, '-', ACCTNO, '-', 26)                                                      AS PK,
    NULL                                                                                           AS URL_SAGE,
    NULL                                                                                           AS URL_YOOZ,
    IFF(LI.CREDIT_NOTE_ID IS NOT NULL,
        'https://admin.equipmentshare.com/#/home/transactions/credit-notes/' || LI.CREDIT_NOTE_ID,
        'https://admin.equipmentshare.com/#/home/transactions/invoices/' || LI.INVOICE_ID)                                                                                 AS URL_ADMIN,
    NULL                                                                                           AS URL_TRACK,
    SUM(LI.AMOUNT)                                                                                 AS AMOUNT
FROM ES_WAREHOUSE.PUBLIC.ORDERS AS O
JOIN ES_WAREHOUSE.PUBLIC.ORDER_SALESPERSONS AS OS
    ON OS.ORDER_ID = O.ORDER_ID
JOIN ES_WAREHOUSE.PUBLIC.INVOICES AS I
    ON I.ORDER_ID = O.ORDER_ID
JOIN ANALYTICS.PUBLIC.V_LINE_ITEMS AS LI
    ON LI.INVOICE_ID = I.INVOICE_ID
LEFT JOIN ANALYTICS.PUBLIC.MARKET_REGION_XWALK AS X
    ON I.SHIP_FROM:branch_id::number = X.MARKET_ID
LEFT JOIN ANALYTICS.PUBLIC.MARKET_GOALS AS MG
    ON MG.MARKET_ID = X.MARKET_ID
    AND (TO_CHAR(DATE_TRUNC('month', MG.MONTHS), 'YYYY-MM')) =
        (TO_CHAR(DATE_TRUNC('month', CAST(LI."GL_BILLING_APPROVED_DATE" AS TIMESTAMP_NTZ)),'YYYY-MM'))
    AND (TO_CHAR(DATE_TRUNC('month', MG."END_DATE"), 'YYYY-MM')) is null
JOIN ES_WAREHOUSE.PUBLIC.LINE_ITEM_TYPES AS LIT
    ON LI.LINE_ITEM_TYPE_ID = LIT.LINE_ITEM_TYPE_ID

WHERE OS.SALESPERSON_TYPE_ID = 1
    AND DATE_TRUNC(MONTH, LI.GL_BILLING_APPROVED_DATE) >= '2022-05-01'
    AND LI.LINE_ITEM_TYPE_ID IN (6, 8, 108, 109, 44, 43, 45, 9, 16, 11, 25, 28, 49) -- Exclude 44 to match Market Dashboard
    AND ((X."DISTRICT" in ('0')
            OR (X."REGION_NAME") in ('Midwest', 'Southeast', 'Pacific', 'Mountain West', 'Southwest', 'Northeast', 'Industrial')
            OR (X."MARKET_ID") in ('0'))
        and (I."INVOICE_ID") != 724307)
GROUP BY X.MARKET_ID, X.MARKET_NAME, LI.CREDIT_NOTE_ID, LI.DESCRIPTION, LI.GL_BILLING_APPROVED_DATE::DATE, LI.INVOICE_ID

UNION ALL

-- Amortization
select
    HAM.MARKET_ID                                                              AS MARKET_ID,
    M.NAME                                                                     AS MARKET_NAME,
    'Amortization Expenses'                                                  AS TYPE,
    'EXPrent'                                                                  AS CODE,
    'EXP'                                                                      AS REVEXP,
    'rent'                                                                     as DEPT,
    NULL                                                                       AS PR_TYPE,
    'Equipment Amortization'                                                   as GL_ACCT,
    'IBAB'                                                                     AS ACCTNO,
    NULL                                                                       AS AR_TYPE,
    concat('Equipment Payment - Asset ID: ', A.ASSET_ID)                       AS DESCRIPTION,
    current_timestamp::date                                                    AS GL_DATE,
--     MONTHNAME(current_timestamp::date) || '-' || YEAR(current_timestamp::date) AS PERIOD,
--     day(last_day(current_timestamp::date))                                     as DAYS_IN_MONTH,
    '1'                                                                        AS DOC_NO,
    concat(ham.market_id, '-', acctno, '-', 1)                                 AS PK,
    NULL                                                                       AS URL_SAGE,
    NULL                                                                       AS URL_YOOZ,
    NULL                                                                       AS URL_ADMIN,
    NULL                                                                       AS URL_TRACK,
    (-coalesce(APH.OEC, APH.PURCHASE_PRICE) * (0.014849 / day(last_day(current_timestamp::date))) *
        day(current_timestamp::date))::INT                                     AS AMOUNT
from ES_WAREHOUSE.PUBLIC.ASSETS A
join ES_WAREHOUSE.PUBLIC.ASSET_PURCHASE_HISTORY APH
    on A.ASSET_ID = APH.ASSET_ID
join ANALYTICS.PUBLIC.HISTORICAL_ASSET_MARKET HAM
    on A.ASSET_ID = HAM.ASSET_ID
join ES_WAREHOUSE.PUBLIC.MARKETS M
    on HAM.MARKET_ID = M.MARKET_ID
join es_warehouse.scd.SCD_ASSET_COMPANY sac
    on a.ASSET_ID = sac.ASSET_ID
    and (current_timestamp::date || ' 23:59:59.999') between sac.DATE_START and coalesce(sac.DATE_END, '2099-12-31'::date)

where sac.COMPANY_ID in (1854, 1855, 8151, 6954, 61036)
    and HAM.DATE::date = current_timestamp::date
    and HAM.MARKET_ID not in (13481, 1491, 5229, 6729, 7836)

UNION ALL

-- Delivery Revenue
SELECT
    X.MARKET_ID,
    X.MARKET_NAME,
    'Delivery Revenues'                                                                            AS TYPE,
    'REVdel'                                                                                       AS CODE,
    'REV'                                                                                          AS REVEXP,
    'del'                                                                                          AS DEPT,
    NULL                                                                                           AS PR_TYPE,
    'Delivery & Pickup Revenue - Operations'                                                       AS GL_ACCT,
    '5009'                                                                                         AS ACCTNO,
    IFF(LI.CREDIT_NOTE_ID IS NULL, 'Invoice', 'Credit')                                            AS AR_TYPE,
    LI.DESCRIPTION                                                                                 AS DESCRIPTION,
    LI.GL_BILLING_APPROVED_DATE::DATE                                                              AS GL_DATE,
--     MONTHNAME(LI.GL_BILLING_APPROVED_DATE::DATE) || '-' || YEAR(LI.GL_BILLING_APPROVED_DATE::DATE) AS PERIOD,
--     DAY(LAST_DAY(LI.GL_BILLING_APPROVED_DATE::DATE))                                               AS DAYS_IN_MONTH,
    '30'                                                                                           AS DOC_NO,
    CONCAT(X.MARKET_ID, '-', ACCTNO, '-', 30)                                                      AS PK,
    NULL                                                                                           AS URL_SAGE,
    NULL                                                                                           AS URL_YOOZ,
    IFF(LI.CREDIT_NOTE_ID IS NOT NULL,
        'https://admin.equipmentshare.com/#/home/transactions/credit-notes/' || LI.CREDIT_NOTE_ID,
        'https://admin.equipmentshare.com/#/home/transactions/invoices/' || LI.INVOICE_ID)         AS URL_ADMIN,
    NULL                                                                                           AS URL_TRACK,
    SUM(LI.AMOUNT)                                                                                 AS AMOUNT
FROM ES_WAREHOUSE.PUBLIC.ORDERS AS O
JOIN ES_WAREHOUSE.PUBLIC.ORDER_SALESPERSONS AS OS
    ON OS.ORDER_ID = O.ORDER_ID
JOIN ES_WAREHOUSE.PUBLIC.INVOICES AS I
    ON I.ORDER_ID = O.ORDER_ID
JOIN ANALYTICS.PUBLIC.V_LINE_ITEMS AS LI
    ON LI.INVOICE_ID = I.INVOICE_ID
JOIN ANALYTICS.PUBLIC.MARKET_REGION_XWALK AS X
    ON I.SHIP_FROM:branch_id::number = X.MARKET_ID
LEFT JOIN ANALYTICS.PUBLIC.MARKET_GOALS AS MG
    ON MG.MARKET_ID = X.MARKET_ID
    AND (TO_CHAR(DATE_TRUNC('month', MG.MONTHS), 'YYYY-MM')) =
        (TO_CHAR(DATE_TRUNC('month', CAST(LI."GL_BILLING_APPROVED_DATE" AS TIMESTAMP_NTZ)), 'YYYY-MM'))
    AND (TO_CHAR(DATE_TRUNC('month', MG."END_DATE"), 'YYYY-MM')) is null
JOIN ES_WAREHOUSE.PUBLIC.LINE_ITEM_TYPES AS LIT
    ON LI.LINE_ITEM_TYPE_ID = LIT.LINE_ITEM_TYPE_ID

WHERE OS.SALESPERSON_TYPE_ID = 1
    AND DATE_TRUNC(MONTH, LI.GL_BILLING_APPROVED_DATE) >= '2022-05-01'
    AND LI.LINE_ITEM_TYPE_ID = 5
    AND (((X."DISTRICT") in ('0')
            OR (X."REGION_NAME") in ('Midwest', 'Southeast', 'Pacific', 'Mountain West', 'Southwest', 'Northeast', 'Industrial')
            OR (X."MARKET_ID") in ('0'))
        AND (I."INVOICE_ID") <> 724307)
GROUP BY X.MARKET_ID, X.MARKET_NAME, LI.CREDIT_NOTE_ID, LI.DESCRIPTION, LI.GL_BILLING_APPROVED_DATE::DATE, LI.INVOICE_ID

UNION ALL

-- Outside Hauling
SELECT
    X.MARKET_ID,
    X.MARKET_NAME,
    IFF(GLE.ACCOUNTNO::VARCHAR = '6014', 'Cost of Rental Revenues', 'Cost of Delivery Revenues') AS TYPE,
    IFF(GLE.ACCOUNTNO::VARCHAR = '6014', 'EXPrent', 'EXPdel')                                    AS CODE,
    'EXP'                                                                                        AS REVEXP,
    IFF(GLE.ACCOUNTNO::VARCHAR = '6014', 'rent', 'del')                                          AS DEPT,
    NULL                                                                                         AS PR_TYPE,
    GLA.TITLE                                                                                    AS GL_ACCT,
    gle.ACCOUNTNO::varchar                                                                       AS ACCTNO,
    NULL                                                                                         AS AR_TYPE,
    gle.DESCRIPTION                                                                              AS DESCRIPTION,
    GLE.ENTRY_DATE::DATE                                                                            GL_DATE,
--     MONTHNAME(GLE.ENTRY_DATE::DATE) || '-' || YEAR(GLE.ENTRY_DATE::DATE)                         AS PERIOD,
--     DAY(LAST_DAY(GLE.ENTRY_DATE::DATE))                                                          AS DAYS_IN_MONTH,
    '31'                                                                                         AS DOC_NO,
    CONCAT(X.MARKET_ID, '-', ACCTNO, '-', 31)                                                    AS PK,
    NULL                                                                                         AS URL_SAGE,
    NULL                                                                                         AS URL_YOOZ,
    NULL                                                                                         AS URL_ADMIN,
    NULL                                                                                         AS URL_TRACK,
    -gle.TR_TYPE * gle.AMOUNT                                                                    AS AMOUNT
from analytics.INTACCT.GLENTRY as gle
left join analytics.INTACCT.GLACCOUNT as gla
    on gle.ACCOUNTNO::varchar = gla.ACCOUNTNO::varchar
left join analytics.PUBLIC.MARKET_REGION_XWALK as x
    on gle.DEPARTMENT::varchar = x.MARKET_ID::varchar
where date_trunc(month, GLE.ENTRY_DATE) >= '2022-05-01'
    and upper(gle.BATCHTITLE) not like 'REVERSED%AP%ACCRUAL%'
    and gle.ACCOUNTNO::varchar in ('6014', '6031')

UNION ALL

-- SALES REVENUE WITH ASSET_ID
SELECT
    SR.MARKET_ID,
    SR.MARKET_NAME,
    'Sales Revenues'                                                                         as TYPE,
    'REVsale'                                                                                as CODE,
    'REV'                                                                                    as REVEXP,
    'sale'                                                                                   as DEPT,
    null                                                                                     as PR_TYPE,
    SR.GL_ACCT                                                                               as GL_ACCT,
    SR.STAT_ACCT                                                                             AS ACCT_NO,
    null                                                                                     as AR_TYPE,
    CASE
        WHEN SR.ASSET_ID IS NULL THEN 'Asset ID: ' || ' || Invoice #: ' || SR.INVOICE_NO
        ELSE 'Asset ID: ' || SR.ASSET_ID || ' || Invoice #: ' || SR.INVOICE_NO END           AS DESCRIPTION,
    SR.BILLING_APPROVED_DATE                                                                 as GL_DATE,
--     MONTHNAME(SR.BILLING_APPROVED_DATE::DATE) || '-' || YEAR(SR.BILLING_APPROVED_DATE::DATE) AS PERIOD,
--     DAY(LAST_DAY(SR.BILLING_APPROVED_DATE::DATE))                                            AS DAYS_IN_MONTH,
    '11'                                                                                     as DOC_NO,
    SR.MARKET_ID || '-' || SR.STAT_ACCT || '-11'                                             as PK,
    null                                                                                     as URL_SAGE,
    null                                                                                     as URL_YOOZ,
    null                                                                                     as URL_ADMIN,
    null                                                                                     as URL_TRACK,
    SR.REVENUE                                                                               as AMOUNT
FROM SALES_REVENUE AS SR
JOIN SALES_COGS AS SG
    ON SR.ASSET_ID = SG.ASSET_ID
    AND SR.MARKET_NAME = SG.MARKET_NAME
    AND SR.BILLING_APPROVED_DATE = SG.BILLING_APPROVED_DATE
WHERE SR.REVENUE <> 0
    AND SR.REV_EXP = 'REV'
    AND SR.ASSET_ID IS NOT NULL

UNION ALL

-- SALES REVENUE WITHOUT ASSET_ID
SELECT
    SR.MARKET_ID,
    SR.MARKET_NAME,
    'Sales Revenues'                                                                         as TYPE,
    'REVsale'                                                                                as CODE,
    'REV'                                                                                    as REVEXP,
    'sale'                                                                                   as DEPT,
    null                                                                                     as PR_TYPE,
    SR.GL_ACCT                                                                               as GL_ACCT,
    SR.STAT_ACCT                                                                             AS ACCT_NO,
    null                                                                                     as AR_TYPE,
    CASE
        WHEN SR.ASSET_ID IS NULL THEN 'Asset ID: ' || ' || Invoice #: ' || SR.INVOICE_NO
        ELSE 'Asset ID: ' || SR.ASSET_ID || ' || Invoice #: ' || SR.INVOICE_NO END           AS DESCRIPTION,
    SR.BILLING_APPROVED_DATE                                                                 as GL_DATE,
--     MONTHNAME(SR.BILLING_APPROVED_DATE::DATE) || '-' || YEAR(SR.BILLING_APPROVED_DATE::DATE) AS PERIOD,
--     DAY(LAST_DAY(SR.BILLING_APPROVED_DATE::DATE))                                            AS DAYS_IN_MONTH,
    '11'                                                                                     as DOC_NO,
    SR.MARKET_ID || '-' || SR.STAT_ACCT || '-11'                                             as PK,
    null                                                                                     as URL_SAGE,
    null                                                                                     as URL_YOOZ,
    null                                                                                     as URL_ADMIN,
    null                                                                                     as URL_TRACK,
    SR.REVENUE                                                                               as AMOUNT
FROM SALES_REVENUE AS SR
WHERE SR.REVENUE <> 0
    AND SR.REV_EXP = 'REV'
    AND SR.ASSET_ID IS NULL

UNION ALL

-- SALES COGS
SELECT
    SR.MARKET_ID,
    SR.MARKET_NAME,
    'Cost of Sales Revenues'                                                                 as TYPE,
    'EXPsale'                                                                                as CODE,
    'EXP'                                                                                    as REVEXP,
    'sale'                                                                                   as DEPT,
    null                                                                                     as PR_TYPE,
    STPL.LINE_ITEM_TYPE                                                                      as GL_ACCT,
    REPLACE(SR.STAT_ACCT, 'F', 'G')                                                          AS ACCT_NO,
    null                                                                                     as AR_TYPE,
    CASE
        WHEN SR.ASSET_ID IS NULL THEN 'Asset ID: ' || ' || Invoice #: ' || SR.INVOICE_NO
        ELSE 'Asset ID: ' || SR.ASSET_ID || ' || Invoice #: ' || SR.INVOICE_NO END           AS DESCRIPTION,
    SR.BILLING_APPROVED_DATE                                                                 as GL_DATE,
--     MONTHNAME(SR.BILLING_APPROVED_DATE::DATE) || '-' || YEAR(SR.BILLING_APPROVED_DATE::DATE) AS PERIOD,
--     DAY(LAST_DAY(SR.BILLING_APPROVED_DATE::DATE))                                            AS DAYS_IN_MONTH,
    '12'                                                                                     as DOC_NO,
    SR.MARKET_ID || '-' || SR.STAT_ACCT || '-12'                                             as PK,
    null                                                                                     as URL_SAGE,
    null                                                                                     as URL_YOOZ,
    null                                                                                     as URL_ADMIN,
    null                                                                                     as URL_TRACK,
    -NBV                                                                                     as AMOUNT
FROM SALES_REVENUE AS SR
JOIN SALES_COGS AS SG
    ON (SR.ASSET_ID = SG.ASSET_ID)
           AND SR.MARKET_NAME = SG.MARKET_NAME
           AND SR.BILLING_APPROVED_DATE = SG.BILLING_APPROVED_DATE
LEFT JOIN ANALYTICS.PUBLIC.STAT_PL AS STPL
    ON REPLACE(SR.STAT_ACCT, 'F', 'G') = STPL.STAT_ACCT
WHERE SG.NBV != 0

UNION ALL

-- CREDIT REVENUE WITH ASSET_ID
SELECT
    CR.MARKET_ID,
    CR.MARKET_NAME,
    'Sales Revenues'                                                                               as TYPE,
    'REVsale'                                                                                      as CODE,
    'REV'                                                                                          as REVEXP,
    'sale'                                                                                         as DEPT,
    null                                                                                           as PR_TYPE,
    CR.GL_ACCT                                                                                     as GL_ACCT,
    CR.STAT_ACCT                                                                                   AS ACCT_NO,
    null                                                                                           as AR_TYPE,
    CASE
        WHEN CR.ASSET_ID IS NULL THEN 'Asset ID: ' || ' || Credit Note #: ' || CR.CREDIT_NOTE_NUMBER
        ELSE 'Asset ID: ' || CR.ASSET_ID || ' || Credit Note #: ' || CR.CREDIT_NOTE_NUMBER END     AS DESCRIPTION,
    CR.CREDIT_NOTE_DATE_CREATED                                                                    as GL_DATE,
--     MONTHNAME(CR.CREDIT_NOTE_DATE_CREATED::DATE) || '-' || YEAR(CR.CREDIT_NOTE_DATE_CREATED::DATE) AS PERIOD,
--     DAY(LAST_DAY(CR.CREDIT_NOTE_DATE_CREATED::DATE))                                               AS DAYS_IN_MONTH,
    '11'                                                                                           as DOC_NO,
    CR.MARKET_ID || '-' || CR.STAT_ACCT || '-11'                                                   as PK,
    null                                                                                           as URL_SAGE,
    null                                                                                           as URL_YOOZ,
    null                                                                                           as URL_ADMIN,
    null                                                                                           as URL_TRACK,
    -CR.CREDIT_REVENUE                                                                             as AMOUNT
FROM CREDIT_REVENUE AS CR
JOIN SALES_COGS_CREDIT AS SGC
    ON CR.ASSET_ID = SGC.ASSET_ID
    AND CR.MARKET_NAME = SGC.MARKET_NAME
    AND CR.BILLING_APPROVED_DATE = SGC.BILLING_APPROVED_DATE
WHERE CR.CREDIT_REVENUE <> 0
    AND CR.ASSET_ID IS NOT NULL
    AND CR.REV_EXP = 'REV'

UNION ALL

-- CREDIT REVENUE WITHOUT ASSET_ID
SELECT
    CR.MARKET_ID,
    CR.MARKET_NAME,
    'Sales Revenues'                                                                               as TYPE,
    'REVsale'                                                                                      as CODE,
    'REV'                                                                                          as REVEXP,
    'sale'                                                                                         as DEPT,
    null                                                                                           as PR_TYPE,
    CR.GL_ACCT                                                                                     as GL_ACCT,
    CR.STAT_ACCT                                                                                   AS ACCT_NO,
    null                                                                                           as AR_TYPE,
    CASE
        WHEN CR.ASSET_ID IS NULL THEN 'Asset ID: ' || ' || Credit Note #: ' || CR.CREDIT_NOTE_NUMBER
        ELSE 'Asset ID: ' || CR.ASSET_ID || ' || Credit Note #: ' || CR.CREDIT_NOTE_NUMBER END     AS DESCRIPTION,
    CR.CREDIT_NOTE_DATE_CREATED                                                                    as GL_DATE,
--     MONTHNAME(CR.CREDIT_NOTE_DATE_CREATED::DATE) || '-' || YEAR(CR.CREDIT_NOTE_DATE_CREATED::DATE) AS PERIOD,
--     DAY(LAST_DAY(CR.CREDIT_NOTE_DATE_CREATED::DATE))                                               AS DAYS_IN_MONTH,
    '11'                                                                                           as DOC_NO,
    CR.MARKET_ID || '-' || CR.STAT_ACCT || '-11'                                                   as PK,
    null                                                                                           as URL_SAGE,
    null                                                                                           as URL_YOOZ,
    null                                                                                           as URL_ADMIN,
    null                                                                                           as URL_TRACK,
    -CR.CREDIT_REVENUE                                                                             as AMOUNT
FROM CREDIT_REVENUE AS CR
WHERE CR.CREDIT_REVENUE <> 0
    AND CR.ASSET_ID IS NULL
    AND CR.REV_EXP = 'REV'

UNION ALL

-- SALES COGS CREDIT
SELECT
    CR.MARKET_ID,
    CR.MARKET_NAME,
    'Cost of Sales Revenues'                                                                       as TYPE,
    'EXPsale'                                                                                      as CODE,
    'EXP'                                                                                          as REVEXP,
    'sale'                                                                                         as DEPT,
    null                                                                                           as PR_TYPE,
    STPL.LINE_ITEM_TYPE                                                                            as GL_ACCT,
    REPLACE(CR.STAT_ACCT, 'F', 'G')                                                                AS ACCT_NO,
    null                                                                                           as AR_TYPE,
    CASE
        WHEN CR.ASSET_ID IS NULL THEN 'Asset ID: ' || ' || Credit Note #: ' || CR.CREDIT_NOTE_NUMBER
        ELSE 'Asset ID: ' || CR.ASSET_ID || ' || Credit Note #: ' || CR.CREDIT_NOTE_NUMBER END     AS DESCRIPTION,
    CR.CREDIT_NOTE_DATE_CREATED                                                                    as GL_DATE,
--     MONTHNAME(CR.CREDIT_NOTE_DATE_CREATED::DATE) || '-' || YEAR(CR.CREDIT_NOTE_DATE_CREATED::DATE) AS PERIOD,
--     DAY(LAST_DAY(CR.CREDIT_NOTE_DATE_CREATED::DATE))                                               AS DAYS_IN_MONTH,
    '12'                                                                                           as DOC_NO,
    CR.MARKET_ID || '-' || CR.STAT_ACCT || '-12'                                                   as PK,
    null                                                                                           as URL_SAGE,
    null                                                                                           as URL_YOOZ,
    null                                                                                           as URL_ADMIN,
    null                                                                                           as URL_TRACK,
    LEAST(SGC.NBV, CR.CREDIT_REVENUE)                                                              as AMOUNT
FROM CREDIT_REVENUE AS CR
JOIN SALES_COGS_CREDIT AS SGC
    ON CR.ASSET_ID = SGC.ASSET_ID
    AND CR.MARKET_NAME = SGC.MARKET_NAME
    AND CR.BILLING_APPROVED_DATE = SGC.BILLING_APPROVED_DATE
LEFT JOIN ANALYTICS.PUBLIC.STAT_PL AS STPL
    ON REPLACE(CR.STAT_ACCT, 'F', 'G') = STPL.STAT_ACCT
WHERE AMOUNT != 0

UNION ALL

-- CC Allocation
select
    try_to_number(F.market_id) mkt_id,
    M.NAME mkt_name,
    B.DISPLAY_NAME type,
    B."GROUP" code,
    iff(code = 'interco', 'EXP', left(code, 3)) revexp,
    iff(code = 'interco', code, right(code, length(code) - 3)) dept,
    null pr_type,
    coalesce(B.SAGE_NAME, GLA.TITLE) gl_acct,
    F.accountno acctno,
    null ar_type,
    F.descr,
    F.gl_date,
    F.TRANSACTION_ID doc_no,
    concat(F.market_id,'-',F.accountno,'-',F.TRANSACTION_ID) pk,
    null url_sage,
    null url_yooz,
    null url_admin,
    null url_track,
    F.amt
from cc_final F
left join ANALYTICS.GS.PLEXI_BUCKET_MAPPING B
    on F.accountno::varchar = B.SAGE_GL
left join ANALYTICS.INTACCT.GLACCOUNT GLA
    on F.accountno::varchar = GLA.ACCOUNTNO
join ES_WAREHOUSE.PUBLIC.MARKETS M
    on F.market_id = M.MARKET_ID::varchar

where mkt_id is not null

UNION ALL

-- Contractor payouts
select
    try_to_number(PA.market_id) mkt_id,
    M.NAME                      mkt_name,
    B.DISPLAY_NAME              type,
    B."GROUP"                   code,
    left(B."GROUP",3)           revexp,
    right(B."GROUP",len(B."GROUP")-3) dept,
    null                        pr_type,
    B.SAGE_NAME                 gl_acct,
    'GAAG'                      acctno,
    null                        ar_type,
    concat(B.SAGE_NAME,' - ',
        PA.type,' - Asset ID: ',
        PA.ASSET_ID::varchar,' - Owner: ',
        C.NAME)                 descr,
    PA.payout_date              gl_date,
    '6'                         doc_no,
    concat(mkt_id,'-',acctno,'-',doc_no)    pk,
    null                        url_sage,
    null                        url_yooz,
    null                        url_admin,
    null                        url_track,
    PA.ASSET_PAYOUT_AMOUNT      amt
from payout_agg PA
join ES_WAREHOUSE.PUBLIC.MARKETS M
    on PA.market_id = M.MARKET_ID
join ES_WAREHOUSE.PUBLIC.COMPANIES C
    on PA.COMPANY_ID = C.COMPANY_ID
join ANALYTICS.GS.PLEXI_BUCKET_MAPPING B
    on 'GAAG' = B.SAGE_GL
where PA.COMPANY_ID not in (6954,1854) -- EZ, ES
    and mkt_id is not null

UNION ALL

-- Real property tax
select
    try_to_number(T.MARKET_ID) MKT_ID,
    M.NAME MKT_NAME,
    'Facilities Expenses' TYPE,
    'EXPfac' CODE,
    'EXP' REVEXP,
    'fac' DEPT,
    NULL PR_TYPE,
    'Real Property Tax' GL_ACCT,
    'HIAC' ACCTNO,
    NULL AR_TYPE,
    concat('Real property tax LIVE ',to_varchar(current_date,'MMMM YYYY')) DESCR,
    current_date GL_DATE,
    '5' DOC_NO,
    concat(mkt_id, '-', acctno, '-', 5) PK,
    NULL URL_SAGE,
    NULL URL_YOOZ,
    NULL URL_ADMIN,
    NULL URL_TRACK,
    -round(T.ESTIMATE,2) AMT
from ANALYTICS.GS.TAX_ACCRUAL T
join ES_WAREHOUSE.PUBLIC.MARKETS M
    on T.MARKET_ID = M.MARKET_ID
where try_to_number(T.MARKET_ID) is not null
    and T.MARKET_ID not in (13481,1491,5229,6729,7836)

),
final as (
    select
        MARKET_ID,
        MARKET_NAME,
        TYPE,
        date_trunc(month, GL_DATE) gl_month,
        sum(AMOUNT) ttl_amoount
    from union_cte
    group by MARKET_ID, MARKET_NAME, TYPE, gl_month
),

-- **** END LIVE ACTIVITY QUERY ****

-- **** LIVE BUDGET QUERY GOES HERE ****

live_budget as (

    select
        MARKET_ID,
        MONTHS,
        sum(REVENUE_GOALS) as GOAL,
        to_varchar(MONTHS, 'mmmm yyyy') AS PERIOD,
        MARKET_ID||'-'||MONTHS::Date AS MKT_MONTHS,
        'Rental Revenues' as TYPE
    from analytics.PUBLIC.MARKET_GOALS

    where (START_DATE is null or START_DATE <= MONTHS)
        and END_DATE is null
    group by MARKET_ID, MONTHS,PERIOD,MKT_MONTHS, TYPE

    union all

    select
        mkt_id AS MARKET_ID,
        add_months(date_trunc(month,beds.GL_DATE::date),2) AS MONTHS,
        sum(amt) AS GOAL,
        to_varchar(MONTHS, 'mmmm yyyy') AS PERIOD,
        MARKET_ID||'-'||MONTHS::date AS MKT_MONTHS,
        BEDS.TYPE as TYPE
    from analytics.public.BRANCH_EARNINGS_DDS_SNAP beds

    where ACCTNO != '5000'
        and beds.dept != 'sale'
    group by MARKET_ID, months,period,mkt_months, TYPE
)

-- **** END LIVE BUDGET QUERY ----


select
    coalesce(final.MARKET_ID,budget.MARKET_ID) mkt_id,
    M.NAME mkt_name,
    coalesce(final.TYPE, budget.TYPE) type_,
    coalesce(date_trunc(month, final.gl_month), budget.MONTHS) period_,
    coalesce(round(ttl_amoount,2),0) amount_,
    coalesce(round(ttl_goal,2),0) goal_
from final
full outer join (select MARKET_ID, TYPE, MONTHS, sum(goal) ttl_goal
                 from live_budget
                 group by MARKET_ID, TYPE, MONTHS) budget
    on final.MARKET_ID = budget.MARKET_ID
    and final.TYPE = budget.TYPE
    and final.gl_month = budget.MONTHS

join ES_WAREHOUSE.PUBLIC.MARKETS M
    on try_to_number(coalesce(final.MARKET_ID,budget.MARKET_ID)) = M.MARKET_ID


where period_ > '2022-03-31'
;;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}."MKT_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MKT_NAME" ;;
  }

  dimension: type {
    type: string
    order_by_field: bucket_order
    sql: ${TABLE}."TYPE_" ;;
  }

  # dimension: code {
  #   type: string
  #   sql: ${TABLE}."CODE" ;;
  # }

  # dimension: revexp {
  #   type: string
  #   sql: ${TABLE}."REVEXP" ;;
  # }

  # dimension: dept {
  #   type: string
  #   sql: ${TABLE}."DEPT" ;;
  # }

  # dimension: pr_type {
  #   type: string
  #   sql: ${TABLE}."PR_TYPE" ;;
  # }

  # dimension: gl_acct {
  #   type: string
  #   sql: ${TABLE}."GL_ACCT" ;;
  # }

  # dimension: acctno {
  #   type: string
  #   sql: ${TABLE}."ACCTNO" ;;
  # }

  # dimension: ar_type {
  #   type: string
  #   sql: ${TABLE}."AR_TYPE" ;;
  # }

  # dimension: description {
  #   type: string
  #   sql: ${TABLE}."DESCRIPTION" ;;
  # }

  dimension: gl_date {
    type: date
    sql: ${TABLE}."PERIOD_" ;;
  }

  dimension: period {
    type: string
    sql: to_varchar(${TABLE}."PERIOD_", 'mmmm yyyy') ;;
  }

  dimension: days_in_month {
    type: number
    sql: day(last_day(${TABLE}."PERIOD_",month)) ;;
  }

  dimension: current_days {
    type: number
    sql: day(CURRENT_TIMESTAMP) ;;
  }

  # dimension: pk {
  #   type: string
  #   sql: ${TABLE}."PK" ;;
  # }

  # dimension: url_sage {
  #   type: string
  #   sql: ${TABLE}."URL_SAGE" ;;
  # }

  # dimension: url_yooz {
  #   type: string
  #   sql: ${TABLE}."URL_YOOZ" ;;
  # }

  # dimension: url_admin {
  #   type: string
  #   html: <a style="color:rgb(26, 115, 232)" href="{{value}}" target="_blank">{{value}}</a> ;;
  #   sql: ${TABLE}."URL_ADMIN" ;;
  # }

  # dimension: url_track {
  #   type: string
  #   sql: ${TABLE}."URL_TRACK" ;;
  # }

  dimension: bucket_order {
    type: number
    sql: case when ${type} = 'Rental Revenues'                    then 1
              when ${type} = 'Sales Revenues'                     then 2
              when ${type} = 'Delivery Revenues'                  then 3
              when ${type} = 'Service Revenues'                   then 4
              when ${type} = 'Miscellaneous Revenues'             then 5
              when ${type} = 'Bad Debt'                           then 6
              when ${type} = 'Cost of Rental Revenues'            then 7
              when ${type} = 'Cost of Sales Revenues'             then 8
              when ${type} = 'Cost of Delivery Revenues'          then 9
              when ${type} = 'Cost of Service Revenues'           then 10
              when ${type} = 'Cost of Miscellaneous Revenues'     then 11
              when ${type} = 'Employee Benefits Expenses'         then 12
              when ${type} = 'Facilities Expenses'                then 13
              when ${type} = 'General Expenses'                   then 14
              when ${type} = 'Overhead Expenses'                  then 15
              when ${type} = 'Intercompany Transactions'          then 16
              end ;;
  }

  # dimension: dept_order {
  #   type: number
  #   sql: case when ${dept} = 'Rental'                   then 1
  #             when ${dept} = 'Sales'                    then 2
  #             when ${dept} = 'Delivery'                 then 3
  #             when ${dept} = 'Service'                  then 4
  #             when ${dept} = 'Miscellaneous'            then 5
  #             when ${dept} = 'Bad Debt'                 then 6
  #             when ${dept} = 'Employee Benefits'        then 7
  #             when ${dept} = 'Facilities'               then 8
  #             when ${dept} = 'General Administrative'   then 9
  #             when ${dept} = 'Overhead'                 then 10
  #       end ;;
  # }

   measure: amount {
    type: sum
    value_format: "$#.00;($#.00)"
    sql: ${TABLE}."AMOUNT_" ;;
  }

  measure: amount_link {
    type: sum
    value_format: "$#.00;($#.00)"
    sql: ${TABLE}."AMOUNT_" ;;
    link: {
      label: "Detail View"
      url: "@{db_entries_live_be_detail}?Period={{ _filters['entries_live_be.period'] | url_encode }}&Market%20Name={{ _filters['entries_live_be.market_name']  | url_encode }}&Type={{ entries_live_be.type._filterable_value  | url_encode }}&toggle=det"
    }
  }

  measure:  goal {
    type:  sum
    value_format: "$#.00;($#.00)"
    sql: ${TABLE}."GOAL_" ;;
  }

  }
