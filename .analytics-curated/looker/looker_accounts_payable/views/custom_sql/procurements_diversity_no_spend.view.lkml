view: procurements_diversity_no_spend {
    derived_table: {
      sql:
      with master as (SELECT
    APRH.VENDORID,
        case when aprh.vendorid in ('V27903', 'V12154', 'V12074', 'V32370', 'V12191') then 'core' else 'other' end as core_vs_other,


    APRH.prbatch,
        case when upper(APRH.prbatch) like '%FLEET%' then 'no'
        when upper(aprh.prbatch) like '%OEC%' then 'no'
        when upper(aprh.prbatch) like '%UPFIT%' then 'no'
        when upper(aprh.prbatch) like '%VEHICLE%' then 'no'
        else 'yes' end as sold_assets,
APRHPAY.paymenttype as payment_type,
    VEND.NAME,
    VEND.diversity_classification,
    VEND.VENDTYPE,
    VEND.VENDOR_CATEGORY,
    VEND.REPORTING_CATEGORY,
    VEND.TERMNAME,
    APBPMT.PAYMENTDATE,
    APRHPAY.STATE,
    APRD.ACCOUNTNO,
    COA.TITLE,
    --SUM(APBPMT.AMOUNT) AS "Amount"
    APBPMT.AMOUNT,
    aprd.ITEMID,
    aprd.asset_id,--add since account 2014 has so many that go to it
    aprh.docnumber, aprh.recordid,
    department.departmentid,
    department.department_type,
    department.state_id,
    department.title as department_title,
case
when aprd.accountno = '2014' and aprd.itemid = 'A1301' then '2014-A1301'
 when aprd.accountno = '1301' then '1301'
 else 'other'

end as is_1301_or_2014_w_A1301,



      TO_CHAR(DATE_TRUNC('MONTH', DATEADD(MONTH, -1, CURRENT_DATE())), 'YYYY-MM') AS prior_month_year,
       TO_CHAR(LAST_DAY(DATE_TRUNC('MONTH', DATEADD(MONTH, -1, CURRENT_DATE()))), 'DD') AS last_day_of_prior_month,
       CEIL(TO_NUMBER(TO_CHAR(LAST_DAY(DATE_TRUNC('MONTH', DATEADD(MONTH, -1, CURRENT_DATE()))), 'DD')) / 7) AS weeks_in_prior_month,
       WEEK(CURRENT_DATE) AS current_week_of_year,
month(DATE_TRUNC('MONTH', CURRENT_DATE) - INTERVAL '1 MONTH') AS prior_month
FROM
    "ANALYTICS"."INTACCT"."APBILLPAYMENT" APBPMT
    LEFT JOIN "ANALYTICS"."INTACCT"."APRECORD" APRH ON APBPMT.RECORDKEY = APRH.RECORDNO AND APRH.RECORDTYPE IN ('apbill','apadjustment')
    LEFT JOIN "ANALYTICS"."INTACCT"."APDETAIL" APRD ON APBPMT.PAIDITEMKEY = APRD.RECORDNO AND APRH.RECORDNO = APRD.RECORDKEY
    LEFT JOIN "ANALYTICS"."INTACCT"."VENDOR" VEND ON APRH.VENDORID = VEND.VENDORID
    LEFT JOIN "ANALYTICS"."INTACCT"."GLACCOUNT" COA ON APRD.ACCOUNTNO = COA.ACCOUNTNO
    LEFT JOIN "ANALYTICS"."INTACCT"."APRECORD" APRHPAY ON APBPMT.PAYMENTKEY = APRHPAY.RECORDNO
    left join analytics.intacct.department on aprd.departmentid = department.departmentid
WHERE
    --APBPMT.PAYMENTDATE >= {% date_start date_filter %}
    --AND APBPMT.PAYMENTDATE <= {% date_end date_filter %}
    --AND
    APBPMT.PAYMENTKEY = APBPMT.PARENTPYMT --WHEN THESE DON'T EQUAL IT IS A CREDIT MEMO APPLICATION I THINK
    AND APRHPAY.RECORDTYPE = 'appayment'
-- GROUP BY
--     APRH.VENDORID,
--     VEND.NAME,
--     VEND.VENDTYPE,
--     VEND.VENDOR_CATEGORY,
--     VEND.REPORTING_CATEGORY,
--     VEND.TERMNAME,
--     APBPMT.PAYMENTDATE,
--     APRHPAY.STATE,
--     APRD.ACCOUNTNO,
--     COA.TITLE
--
),
div_vend as (select * from analytics.intacct.vendor where diversity_classification is not null)
select * from div_vend where div_vend.vendorid not in (select vendorid from master)


        ;;
    }



    dimension:  diversity_classification {
      type: string
      sql: ${TABLE}.diversity_classification;;
    }





    dimension: related_parties {
      type: string
      sql: CASE WHEN ${TABLE}."VENDORID" in
        ('V28634',
'V34092',
'V28378',
'V34070',
'V32244',
'V12921',
'V32329',
'V12047',
'V34067',
'V12012',
'V30253',
'V12737',
'V12803',
'V29796',
'V11807',
'V27328',
'V11839',
'V11826',
'V27270'
        ) then 'related'


        else 'other' end;;
    }


    dimension: vendor_id {
      type: string

      sql: ${TABLE}."VENDORID";;
    }

    dimension: vendor_name {
      type: string

      sql: ${TABLE}."NAME" ;;
    }

    dimension: vendor_type {
      type: string
      sql: ${TABLE}."VENDTYPE" ;;
    }

    dimension: vendor_category {
      type: string
      sql: ${TABLE}."VENDOR_CATEGORY" ;;
    }

    dimension: reporting_category {
      type: string
      sql: ${TABLE}."REPORTING_CATEGORY" ;;
    }
  dimension: new_vendor_category {
    type: string
    sql: ${TABLE}.new_vendor_category ;;
  }
  dimension: vendor_sub_category {
    type: string
    sql: ${TABLE}.vendor_sub_category ;;
  }

    set: drill_detail {
      fields: [
        vendor_id,
        vendor_name,
        vendor_type,
        vendor_category,
        reporting_category
      ]
    }



  }
