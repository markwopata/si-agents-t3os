view: sales_cogs_report_revised {
  derived_table: {
    sql:
with full_table as
         (
with COGS1 as (
    select LI.ASSET_ID,
           LI.DESCRIPTION                                                                          sales_inv_descr,
           LI.AMOUNT                                                                               sales_price,
           I.INVOICE_NO                                                                            sales_doc,
           I.PUBLIC_NOTE                                                                           curr_note,
           NH.public_note                                                                          prev_note,
           LIE.INTACCT_GL_ACCOUNT_NO                                                               rev_acct,
           LI.BRANCH_ID                                                                            location,
           C.NAME                                                                                  cust_name,
           O.NAME                                                                                  owner_name,
           --I.BILLING_APPROVED_DATE::date sales_doc_date,
           CAST(CONVERT_TIMEZONE('America/Chicago', I.BILLING_APPROVED_DATE::DATETIME) AS DATE) AS sales_doc_date,
           coalesce(A.VIN, A.SERIAL_NUMBER)                                                        admin_sn,
           coalesce(APH.PURCHASE_PRICE, APH.OEC)                                                   admin_oec,
           APH.INVOICE_NUMBER                                                                      admin_vendor_inv_no,
           FT.SERIAL                                                                               fleet_track_sn,
           FT.NET_PRICE + coalesce(FT.FREIGHT_COST, 0)                                             fleet_track_oec,
           FT.INVOICE_NUMBER                                                                       fleet_track_vendor_inv_no
            ,concat(u.FIRST_NAME, ' ', u.LAST_NAME) as submitter
            ,concat(u2.FIRST_NAME, ' ', u2.LAST_NAME) as approver
    from ES_WAREHOUSE.PUBLIC.LINE_ITEMS LI
             join ES_WAREHOUSE.PUBLIC.LINE_ITEM_TYPE_ERP_REFS LIE
                  on LI.LINE_ITEM_TYPE_ID = LIE.LINE_ITEM_TYPE_ID
             join ES_WAREHOUSE.PUBLIC.INVOICES I
                  on LI.INVOICE_ID = I.INVOICE_ID
             left join (
        select PARAMETERS:invoice_id                               invoice_id,
               replace(PARAMETERS:changes:public_note, '\\n', ' ') public_note
        from ES_WAREHOUSE.PUBLIC.COMMAND_AUDIT CA
                 join ES_WAREHOUSE.PUBLIC.INVOICES I
                      on CA.PARAMETERS:invoice_id = I.INVOICE_ID
                          and CA.DATE_CREATED >= I.BILLING_APPROVED_DATE
        where COMMAND = 'UpdateInvoice'
          and PARAMETERS like '%public_note%'
            qualify rank() over (partition by invoice_id order by CA.DATE_CREATED desc) = 1
    ) NH
                       on I.INVOICE_ID = NH.invoice_id
             left join ES_WAREHOUSE.PUBLIC.COMPANIES C
                       on I.COMPANY_ID = C.COMPANY_ID
             left join ES_WAREHOUSE.SCD.SCD_ASSET_COMPANY SCD
                       on LI.ASSET_ID = SCD.ASSET_ID
                           and I.BILLING_APPROVED_DATE::date - 2 between SCD.DATE_START and SCD.DATE_END
             left join ES_WAREHOUSE.PUBLIC.COMPANIES O
                       on SCD.COMPANY_ID = O.COMPANY_ID
             left join ES_WAREHOUSE.PUBLIC.ASSETS A
                       on LI.ASSET_ID = A.ASSET_ID
             left join ES_WAREHOUSE.PUBLIC.ASSET_PURCHASE_HISTORY APH
                       on LI.ASSET_ID = APH.ASSET_ID
             left join ES_WAREHOUSE.PUBLIC.COMPANY_PURCHASE_ORDER_LINE_ITEMS FT
                       on LI.ASSET_ID = FT.ASSET_ID
                           and ORDER_STATUS = 'Received'
            left join ES_WAREHOUSE.PUBLIC.USERS u
                    on i.CREATED_BY_USER_ID = u.USER_ID
            left join ES_WAREHOUSE.PUBLIC.USERS u2
             on i.BILLING_APPROVED_BY_USER_ID = u2.USER_ID
    where LI.LINE_ITEM_TYPE_ID in (24, 50, 80, 81, 110, 111, 118, 120, 123, 125, 126, 127, 141, 147, 148, 150, 152, 153, 163)
    and I.BILLING_APPROVED
    and ft.DELETED_AT is null
)
--    SELECT * FROM COGS1;
,asset_list as (
    select distinct ASSET_ID
    from cogs1
    where ASSET_ID is not null
)
,es_purch_invoice as (
select sub.asset_id,
       trim(ltrim(C.value, 0))::string as Invoice_Number,
       sub.INVOICE_DATE,
       sub.cost
from (SELECT al.asset_id,
             company_purchase_order_id,
             cpoli.INVOICE_DATE,
             REPLACE(cpoli.invoice_number, ' ',
                     '')                          AS "NSINVOICE_NUMBER",
             coalesce(cpoli.NET_PRICE,0) + coalesce(cpoli.FREIGHT_COST,0) as cost
      FROM asset_list al
               left join
           ES_WAREHOUSE.PUBLIC.COMPANY_PURCHASE_ORDER_LINE_ITEMS cpoli
           on al.asset_id = cpoli.ASSET_ID
          where cpoli.DELETED_AT is null
          ) sub
   , lateral flatten(input =>split(NSINVOICE_NUMBER, '/')) C)
-- select * from es_purch_invoice
,get_vendor as (
    select cpoli.ASSET_ID,
             v.VENDORID
      from ES_WAREHOUSE.PUBLIC.COMPANY_PURCHASE_ORDER_LINE_ITEMS cpoli
               left join
           ES_WAREHOUSE.PUBLIC.COMPANY_PURCHASE_ORDERS cpo
           on cpoli.COMPANY_PURCHASE_ORDER_ID = cpo.COMPANY_PURCHASE_ORDER_ID
               left join
           ANALYTICS.INTACCT.company_to_sage_vendor_xwalk v
           on cpo.VENDOR_ID = v.COMPANY_ID
          where cpoli.DELETED_AT is null
)
-- select * from get_vendor where ASSET_ID = 285088
,get_ach1 as (
    select epi.asset_id,
           apb1.PAYMENTDATE as WHENPAID
    from es_purch_invoice epi
             left join get_vendor gv
                       on epi.asset_id = gv.ASSET_ID
             left join
         ANALYTICS.INTACCT.APRECORD ap
         on trim(LTRIM(epi.Invoice_Number, '0')) = trim(LTRIM(ap.RECORDID, '0'))
             and gv.VENDORID = ap.VENDORID
             and epi.cost = ap.TOTALPAID
             ----------------------------------------------
             left join ANALYTICS.INTACCT.APRECORD ap2
                       on ap.DOCNUMBER = ap2.DOCNUMBER and ap.VENDORID = ap2.VENDORID and
                          ap.BILLTOPAYTOKEY = ap2.BILLTOPAYTOKEY
             inner join
         ANALYTICS.INTACCT.APBILLPAYMENT apb1
         on ap2.RECORDNO = apb1.RECORDKEY and ap2.TOTALPAID = apb1.AMOUNT
)
,get_ach2 as (
    select epi.asset_id,
           apb.PAYMENTDATE as WHENPAID
    from es_purch_invoice epi
             left join get_vendor gv
                       on epi.asset_id = gv.ASSET_ID
             left join ANALYTICS.INTACCT.APRECORD apr2
                       on trim(LTRIM(epi.Invoice_Number, '0')) =
                          trim(ltrim(left(apr2.RECORDID, len(trim(apr2.RECORDID)) - 1), '0'))
                           and epi.cost = apr2.TOTALPAID
             left join ANALYTICS.INTACCT.APRECORD apr3
                       on apr2.DOCNUMBER = apr3.DOCNUMBER and apr2.VENDORID = apr3.VENDORID and
                          apr2.BILLTOPAYTOKEY = apr3.BILLTOPAYTOKEY
             inner join
         ANALYTICS.INTACCT.APBILLPAYMENT apb
         on apr3.RECORDNO = apb.RECORDKEY and apr3.TOTALPAID = apb.AMOUNT
)
,get_ap_wp as (
        select epi.asset_id,
           ap.WHENPAID
    from es_purch_invoice epi
             left join get_vendor gv
                       on epi.asset_id = gv.ASSET_ID
             left join
         ANALYTICS.INTACCT.APRECORD ap
         on trim(LTRIM(epi.Invoice_Number, '0')) = trim(LTRIM(ap.RECORDID, '0'))
             and gv.VENDORID = ap.VENDORID
)
   ,use_sage_record_id as (
    select al.ASSET_ID, WHENPAID
    from asset_list al
    left join ES_WAREHOUSE.PUBLIC.COMPANY_PURCHASE_ORDER_LINE_ITEMS cpoli
    on al.asset_id = cpoli.ASSET_ID
    left join ANALYTICS.INTACCT.APRECORD ap
    on cpoli.SAGE_RECORD_ID = ap.RECORDNO
    where cpoli.DELETED_AT is null
)
,whenpaid as (
select al.asset_id,
    coalesce(usri.WHENPAID, a1.WHENPAID, a2.WHENPAID, wp.WHENPAID) as WHENPAID
from asset_list al
left join get_ach1 a1
on al.asset_id = a1.asset_id
left join get_ach2 a2
on al.asset_id = a2.asset_id
left join get_ap_wp wp
on al.asset_id = wp.asset_id
        left join use_sage_record_id usri
    on al.asset_id = usri.asset_id
    )
   , get_mfscd as (
    select al1.asset_id,
           get_ES_owner.es_admin_owner,
           scd.name as current_owner,
           iff(gfsid.ASSET_ID is null, 'no', 'yes') as ever_financed,
           aph.FINANCE_STATUS                       as current_finance_status,
--            wp.Invoice_Number,
--            lfscd.last_finance_status_change_date::date as last_finance_status_change_date,
           wp.WHENPAID,
           aa.make                                  as oem
    from asset_list al1
        left join
        (select *
            from ES_WAREHOUSE.SCD.SCD_ASSET_COMPANY scd1
        left join ES_WAREHOUSE.PUBLIC.COMPANIES c
        on scd1.COMPANY_ID = c.COMPANY_ID
            where CURRENT_FLAG = 1) scd
        on al1.asset_id = scd.ASSET_ID
             left join (
        select AL.ASSET_ID,
               max(DATE_GENERATED) as last_finance_status_change_date
        from asset_list al
                 left join
             ES_WAREHOUSE.PUBLIC.ASSET_PURCHASE_HISTORY_LOGS APHL
             on al.asset_id = aphl.ASSET_ID
        where
--           ASSET_ID = 136415
--       and
array_contains('finance_status'::variant, change_list)
        group by al.ASSET_ID
    ) lfscd
                       on al1.asset_id = lfscd.asset_id
             left join
         ES_WAREHOUSE.PUBLIC.ASSET_PURCHASE_HISTORY aph
         on al1.asset_id = aph.ASSET_ID
             left join
         (select distinct aphl.ASSET_ID
          from asset_list al2
                   left join
               ES_WAREHOUSE.PUBLIC.ASSET_PURCHASE_HISTORY_LOGS aphl
               on al2.asset_id = aphl.ASSET_ID
                   left join
               ES_WAREHOUSE.PUBLIC.FINANCIAL_SCHEDULES fs
               on aphl.FINANCIAL_SCHEDULE_ID = fs.FINANCIAL_SCHEDULE_ID
          where fs.FINANCIAL_SCHEDULE_ID is not null
            and fs.FINANCIAL_SCHEDULE_ID <> 1539
            and fs.FINANCIAL_SCHEDULE_ID <> 2097
            and fs.FINANCIAL_SCHEDULE_ID <> 2769
            and fs.FINANCIAL_SCHEDULE_ID <> 2736
            and fs.FINANCIAL_SCHEDULE_ID <> 1343
            and fs.FINANCIAL_SCHEDULE_ID <> 1612
            and fs.FINANCIAL_SCHEDULE_ID <> 1358
            and fs.FINANCIAL_SCHEDULE_ID <> 5080
            and fs.FINANCIAL_SCHEDULE_ID <> 5246
            and fs.FINANCIAL_SCHEDULE_ID <> 4948
            and fs.FINANCIAL_SCHEDULE_ID <> 2770
         ) gfsid
         on al1.asset_id = gfsid.ASSET_ID
             left join
         ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE aa
         on al1.asset_id = aa.ASSET_ID
             left join
         whenpaid wp
         on al1.asset_id = wp.asset_id
             left join
         (select sac.ASSET_ID,
                 c.NAME as es_admin_owner
          from ES_WAREHOUSE.SCD.SCD_ASSET_COMPANY sac
                   right join
               (
                   select ASSET_ID,
                          max(DATE_end) as max_date
                   from ES_WAREHOUSE.SCD.SCD_ASSET_COMPANY
                   where CURRENT_FLAG <> 1
                     and COMPANY_ID in (
                       select ES_COMPANIES.COMPANY_ID
                       from ANALYTICS.PUBLIC.ES_COMPANIES
                   )
                     and ASSET_ID in (select *
                                      from asset_list)
                   group by ASSET_ID
               ) sac2
               on sac.ASSET_ID = sac2.ASSET_ID and sac.DATE_END = sac2.max_date
                   left join
               ES_WAREHOUSE.PUBLIC.COMPANIES c
               on sac.COMPANY_ID = c.COMPANY_ID) get_ES_owner
         on al1.asset_id = get_ES_owner.asset_id
)
--    select * from get_mfscd where asset_id = 309008;
   , get_sales_invoice_data as (
    select distinct gm.asset_id,
                    gm.es_admin_owner,
                    gm.current_owner,
                    gm.ever_financed,
                    gm.current_finance_status,
                    i.INVOICE_NO,
                    i.BILLING_APPROVED_DATE::date as invoice_date,
                    gm.WHENPAID,
                    gm.oem,
                    lit.name                      as sales_invoice_type
    from get_mfscd gm
             left join
         (select *
          from ES_WAREHOUSE.PUBLIC.LINE_ITEMS
          where LINE_ITEM_TYPE_ID in (24, 50, 80, 81, 110, 111, 118, 120, 123, 125, 126, 127, 141, 147, 148, 150, 152, 153, 163)) LI
         on gm.asset_id = li.ASSET_ID
             left join
         ES_WAREHOUSE.PUBLIC.INVOICES I
         on li.INVOICE_ID = i.INVOICE_ID
             left join
         ES_WAREHOUSE.PUBLIC.LINE_ITEM_TYPES LIT
         on li.LINE_ITEM_TYPE_ID = lit.LINE_ITEM_TYPE_ID
)
--    select * from get_sales_invoice_data where asset_id = 309008;
   , get_newest_date as (
    select *
    from get_sales_invoice_data
        qualify rank() over (partition by ASSET_ID
            order by invoice_date desc) = 1
)
--    select * from get_newest_date where asset_id = 309008;
   , get_newest_invoice_num as (
    select *
    from get_newest_date
        qualify rank() over (partition by asset_id
            order by INVOICE_NO desc) = 1
)
-- select * from get_newest_invoice_num where asset_id = 309008;
,final_cte1 as (
    select *
    from get_newest_invoice_num
-- where asset_id = 578
        qualify rank() over (partition by asset_id order by WHENPAID asc) = 1
)
,pva1 as (
    select fc.asset_id,
           es_admin_owner,
            current_owner,
           ever_financed,
           current_finance_status,
           INVOICE_NO,
           fc.invoice_date,
           WHENPAID,
           oem,
           sales_invoice_type,
           epi.INVOICE_DATE as fleet_track_inv_date
    from final_cte1 fc
             left join
         es_purch_invoice epi
         on fc.asset_id = epi.asset_id
)
select c.ASSET_ID, sales_inv_descr, sales_price, sales_doc,
       curr_note, prev_note, rev_acct, location, cust_name, owner_name,
       sales_doc_date, admin_sn, admin_oec, admin_vendor_inv_no, fleet_track_sn,
       fleet_track_oec, fleet_track_vendor_inv_no, fleet_track_inv_date,
       es_admin_owner, current_owner, ever_financed, current_finance_status,
       INVOICE_NO, invoice_date, WHENPAID, oem, sales_invoice_type, submitter,
       approver
from cogs1 c
left join pva1 p
on c.ASSET_ID = p.ASSET_ID

union
select *
from (
         with cogs2 as (
             select LI.ASSET_ID,
                    LI.DESCRIPTION                                                                  sales_inv_descr,
                    -CNLI.CREDIT_AMOUNT                                                             sales_price,
                    concat(CN.CREDIT_NOTE_NUMBER, ' from Inv# ', I.INVOICE_NO)                      sales_doc,
                    CN.MEMO                                                                         curr_note,
                    null                                                                            prev_note,
                    LIE.INTACCT_GL_ACCOUNT_NO                                                       rev_acct,
                    LI.BRANCH_ID                                                                    location,
                    C.NAME                                                                          cust_name,
                    O.NAME                                                                          owner_name,
                    --CN.DATE_CREATED::date sales_doc_date,
                    CAST(CONVERT_TIMEZONE('America/Chicago', CN.DATE_CREATED::DATETIME) AS DATE) AS sales_doc_date,
                    coalesce(A.VIN, A.SERIAL_NUMBER)                                                admin_sn,
                    coalesce(APH.PURCHASE_PRICE, APH.OEC)                                           admin_oec,
                    APH.INVOICE_NUMBER                                                              admin_vendor_inv_no,
                    FT.SERIAL                                                                       fleet_track_sn,
                    FT.NET_PRICE + coalesce(FT.FREIGHT_COST, 0)                                     fleet_track_oec,
                    FT.INVOICE_NUMBER                                                               fleet_track_vendor_inv_no
                    ,concat(u.FIRST_NAME, ' ', u.LAST_NAME) as submitter
                    ,concat(u2.FIRST_NAME, ' ', u2.LAST_NAME) as approver
             from ES_WAREHOUSE.PUBLIC.CREDIT_NOTE_LINE_ITEMS CNLI
                      join ES_WAREHOUSE.PUBLIC.LINE_ITEM_TYPE_ERP_REFS LIE
                           on CNLI.LINE_ITEM_TYPE_ID = LIE.LINE_ITEM_TYPE_ID
                      join ES_WAREHOUSE.PUBLIC.CREDIT_NOTES CN
                           on CNLI.CREDIT_NOTE_ID = CN.CREDIT_NOTE_ID
                      left join ES_WAREHOUSE.PUBLIC.INVOICES I
                                on CN.ORIGINATING_INVOICE_ID = I.INVOICE_ID
                      left join ES_WAREHOUSE.PUBLIC.COMPANIES C
                                on I.COMPANY_ID = C.COMPANY_ID
                      left join ES_WAREHOUSE.PUBLIC.LINE_ITEMS LI
                                on CNLI.LINE_ITEM_ID = LI.LINE_ITEM_ID
                      left join ES_WAREHOUSE.SCD.SCD_ASSET_COMPANY SCD
                                on LI.ASSET_ID = SCD.ASSET_ID
                                    and I.BILLING_APPROVED_DATE::date - 2 between SCD.DATE_START and SCD.DATE_END
                      left join ES_WAREHOUSE.PUBLIC.COMPANIES O
                                on SCD.COMPANY_ID = O.COMPANY_ID
                      left join ES_WAREHOUSE.PUBLIC.ASSETS A
                                on LI.ASSET_ID = A.ASSET_ID
                      left join ES_WAREHOUSE.PUBLIC.ASSET_PURCHASE_HISTORY APH
                                on LI.ASSET_ID = APH.ASSET_ID
                      left join ES_WAREHOUSE.PUBLIC.COMPANY_PURCHASE_ORDER_LINE_ITEMS FT
                                on LI.ASSET_ID = FT.ASSET_ID
                      left join ES_WAREHOUSE.PUBLIC.USERS u
                         on i.CREATED_BY_USER_ID = u.USER_ID
                    left join ES_WAREHOUSE.PUBLIC.USERS u2
                         on i.BILLING_APPROVED_BY_USER_ID = u2.USER_ID
             where LI.LINE_ITEM_TYPE_ID in (24, 50, 80, 81, 110, 111, 118, 120, 123, 125, 126, 127, 141, 147, 148, 150, 152, 153, 163)
            and I.BILLING_APPROVED
            and ft.DELETED_AT is null
            and cn.CREDIT_NOTE_STATUS_ID not in (1,3,4)
         )
            , asset_list as (
             select distinct ASSET_ID
             from cogs2
             where ASSET_ID is not null
         )
            , es_purch_invoice as (
select sub.asset_id,
       trim(ltrim(C.value, 0))::string as Invoice_Number,
       sub.INVOICE_DATE,
       sub.cost
from (SELECT al.asset_id,
             company_purchase_order_id,
             cpoli.INVOICE_DATE,
             REPLACE(cpoli.invoice_number, ' ',
                     '')                          AS "NSINVOICE_NUMBER",
             coalesce(cpoli.NET_PRICE,0) + coalesce(cpoli.FREIGHT_COST,0) as cost
      FROM asset_list al
               left join
           ES_WAREHOUSE.PUBLIC.COMPANY_PURCHASE_ORDER_LINE_ITEMS cpoli
           on al.asset_id = cpoli.ASSET_ID
          where cpoli.DELETED_AT is null
          ) sub
   , lateral flatten(input =>split(NSINVOICE_NUMBER, '/')) C)
-- select * from es_purch_invoice
            , get_vendor as (
             select cpoli.ASSET_ID,
                    v.VENDORID
             from ES_WAREHOUSE.PUBLIC.COMPANY_PURCHASE_ORDER_LINE_ITEMS cpoli
                      left join
                  ES_WAREHOUSE.PUBLIC.COMPANY_PURCHASE_ORDERS cpo
                  on cpoli.COMPANY_PURCHASE_ORDER_ID = cpo.COMPANY_PURCHASE_ORDER_ID
                      left join
                  ANALYTICS.INTACCT.company_to_sage_vendor_xwalk v
                  on cpo.VENDOR_ID = v.COMPANY_ID
                  where cpoli.DELETED_AT is null
         )
-- select * from get_vendor where ASSET_ID = 285088
            , get_ach1 as (
             select epi.asset_id,
                    apb1.PAYMENTDATE as WHENPAID
             from es_purch_invoice epi
                      left join get_vendor gv
                                on epi.asset_id = gv.ASSET_ID
                      left join
                  ANALYTICS.INTACCT.APRECORD ap
                  on trim(LTRIM(epi.Invoice_Number, '0')) = trim(LTRIM(ap.RECORDID, '0'))
                      and gv.VENDORID = ap.VENDORID
                      and epi.cost = ap.TOTALPAID
                      ----------------------------------------------
                      left join ANALYTICS.INTACCT.APRECORD ap2
                                on ap.DOCNUMBER = ap2.DOCNUMBER and ap.VENDORID = ap2.VENDORID and
                                   ap.BILLTOPAYTOKEY = ap2.BILLTOPAYTOKEY
                      inner join
                  ANALYTICS.INTACCT.APBILLPAYMENT apb1
                  on ap2.RECORDNO = apb1.RECORDKEY and ap2.TOTALPAID = apb1.AMOUNT
         )
            , get_ach2 as (
             select epi.asset_id,
                    apb.PAYMENTDATE as WHENPAID
             from es_purch_invoice epi
                      left join get_vendor gv
                                on epi.asset_id = gv.ASSET_ID
                      left join ANALYTICS.INTACCT.APRECORD apr2
                                on trim(LTRIM(epi.Invoice_Number, '0')) =
                                   trim(ltrim(left(apr2.RECORDID, len(trim(apr2.RECORDID)) - 1), '0'))
                                    and epi.cost = apr2.TOTALPAID
                      left join ANALYTICS.INTACCT.APRECORD apr3
                                on apr2.DOCNUMBER = apr3.DOCNUMBER and apr2.VENDORID = apr3.VENDORID and
                                   apr2.BILLTOPAYTOKEY = apr3.BILLTOPAYTOKEY
                      inner join
                  ANALYTICS.INTACCT.APBILLPAYMENT apb
                  on apr3.RECORDNO = apb.RECORDKEY and apr3.TOTALPAID = apb.AMOUNT
         )
            , get_ap_wp as (
             select epi.asset_id,
                    ap.WHENPAID
             from es_purch_invoice epi
                      left join get_vendor gv
                                on epi.asset_id = gv.ASSET_ID
                      left join
                  ANALYTICS.INTACCT.APRECORD ap
                  on trim(LTRIM(epi.Invoice_Number, '0')) = trim(LTRIM(ap.RECORDID, '0'))
                      and gv.VENDORID = ap.VENDORID
         )
            ,use_sage_record_id as (
    select al.ASSET_ID, WHENPAID
    from asset_list al
    left join ES_WAREHOUSE.PUBLIC.COMPANY_PURCHASE_ORDER_LINE_ITEMS cpoli
    on al.asset_id = cpoli.ASSET_ID
    left join ANALYTICS.INTACCT.APRECORD ap
    on cpoli.SAGE_RECORD_ID = ap.RECORDNO
    where cpoli.DELETED_AT is null
)
            , whenpaid as (
             select al.asset_id,
                    coalesce(usri.WHENPAID, a1.WHENPAID, a2.WHENPAID, wp.WHENPAID) as WHENPAID
             from asset_list al
                      left join get_ach1 a1
                                on al.asset_id = a1.asset_id
                      left join get_ach2 a2
                                on al.asset_id = a2.asset_id
                      left join get_ap_wp wp
                                on al.asset_id = wp.asset_id
                    left join use_sage_record_id usri
    on al.asset_id = usri.asset_id
         )
            , get_mfscd as (
             select al1.asset_id,
                    get_ES_owner.es_admin_owner,
                    scd.name                                 as current_owner,
                    iff(gfsid.ASSET_ID is null, 'no', 'yes') as ever_financed,
                    aph.FINANCE_STATUS                       as current_finance_status,
--            wp.Invoice_Number,
--            lfscd.last_finance_status_change_date::date as last_finance_status_change_date,
                    wp.WHENPAID,
                    aa.make                                  as oem
             from asset_list al1
                      left join
                  (select *
                   from ES_WAREHOUSE.SCD.SCD_ASSET_COMPANY scd1
                            left join ES_WAREHOUSE.PUBLIC.COMPANIES c
                                      on scd1.COMPANY_ID = c.COMPANY_ID
                   where CURRENT_FLAG = 1) scd
                  on al1.asset_id = scd.ASSET_ID
                      left join (
                 select AL.ASSET_ID,
                        max(DATE_GENERATED) as last_finance_status_change_date
                 from asset_list al
                          left join
                      ES_WAREHOUSE.PUBLIC.ASSET_PURCHASE_HISTORY_LOGS APHL
                      on al.asset_id = aphl.ASSET_ID
                 where
--           ASSET_ID = 136415
--       and
array_contains('finance_status'::variant, change_list)
                 group by al.ASSET_ID
             ) lfscd
                                on al1.asset_id = lfscd.asset_id
                      left join
                  ES_WAREHOUSE.PUBLIC.ASSET_PURCHASE_HISTORY aph
                  on al1.asset_id = aph.ASSET_ID
                      left join
                  (select distinct aphl.ASSET_ID
                   from asset_list al2
                            left join
                        ES_WAREHOUSE.PUBLIC.ASSET_PURCHASE_HISTORY_LOGS aphl
                        on al2.asset_id = aphl.ASSET_ID
                            left join
                        ES_WAREHOUSE.PUBLIC.FINANCIAL_SCHEDULES fs
                        on aphl.FINANCIAL_SCHEDULE_ID = fs.FINANCIAL_SCHEDULE_ID
                   where fs.FINANCIAL_SCHEDULE_ID is not null
                     and fs.FINANCIAL_SCHEDULE_ID <> 1539
                     and fs.FINANCIAL_SCHEDULE_ID <> 2097
                     and fs.FINANCIAL_SCHEDULE_ID <> 2769
                     and fs.FINANCIAL_SCHEDULE_ID <> 2736
                     and fs.FINANCIAL_SCHEDULE_ID <> 1343
                     and fs.FINANCIAL_SCHEDULE_ID <> 1612
                     and fs.FINANCIAL_SCHEDULE_ID <> 1358
                    and fs.FINANCIAL_SCHEDULE_ID <> 5080
                    and fs.FINANCIAL_SCHEDULE_ID <> 5246
                    and fs.FINANCIAL_SCHEDULE_ID <> 4948
                    and fs.FINANCIAL_SCHEDULE_ID <> 2770
                  ) gfsid
                  on al1.asset_id = gfsid.ASSET_ID
                      left join
                  ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE aa
                  on al1.asset_id = aa.ASSET_ID
                      left join
                  whenpaid wp
                  on al1.asset_id = wp.asset_id
                      left join
                  (select sac.ASSET_ID,
                          c.NAME as es_admin_owner
                   from ES_WAREHOUSE.SCD.SCD_ASSET_COMPANY sac
                            right join
                        (
                            select ASSET_ID,
                                   max(DATE_end) as max_date
                            from ES_WAREHOUSE.SCD.SCD_ASSET_COMPANY
                            where CURRENT_FLAG <> 1
                              and COMPANY_ID in (
                                select ES_COMPANIES.COMPANY_ID
                                from ANALYTICS.PUBLIC.ES_COMPANIES
                            )
                              and ASSET_ID in (select *
                                               from asset_list)
                            group by ASSET_ID
                        ) sac2
                        on sac.ASSET_ID = sac2.ASSET_ID and sac.DATE_END = sac2.max_date
                            left join
                        ES_WAREHOUSE.PUBLIC.COMPANIES c
                        on sac.COMPANY_ID = c.COMPANY_ID) get_ES_owner
                  on al1.asset_id = get_ES_owner.asset_id
         )
--    select * from get_mfscd where asset_id = 309008;
            , get_sales_invoice_data as (
             select distinct gm.asset_id,
                             gm.es_admin_owner       ,
                             gm.current_owner,
                             gm.ever_financed,
                             gm.current_finance_status,
                             i.INVOICE_NO,
                             i.BILLING_APPROVED_DATE::date as invoice_date,
                             gm.WHENPAID,
                             gm.oem,
                             lit.name                      as sales_invoice_type
             from get_mfscd gm
                      left join
                  (select *
                   from ES_WAREHOUSE.PUBLIC.LINE_ITEMS
                   where LINE_ITEM_TYPE_ID in (24, 50, 80, 81, 110, 111, 118, 120, 123, 125, 126, 127, 141, 147, 148, 150, 152, 153, 163)) LI
                  on gm.asset_id = li.ASSET_ID
                      left join
                  ES_WAREHOUSE.PUBLIC.INVOICES I
                  on li.INVOICE_ID = i.INVOICE_ID
                      left join
                  ES_WAREHOUSE.PUBLIC.LINE_ITEM_TYPES LIT
                  on li.LINE_ITEM_TYPE_ID = lit.LINE_ITEM_TYPE_ID
         )
--    select * from get_sales_invoice_data where asset_id = 309008;
            , get_newest_date as (
             select *
             from get_sales_invoice_data
                 qualify rank() over (partition by ASSET_ID
                     order by invoice_date desc) = 1
         )
--    select * from get_newest_date where asset_id = 309008;
            , get_newest_invoice_num as (
             select *
             from get_newest_date
                 qualify rank() over (partition by asset_id
                     order by INVOICE_NO desc) = 1
         )
-- select * from get_newest_invoice_num where asset_id = 309008;
,final_cte2 as (
    select *
    from get_newest_invoice_num
-- where asset_id = 578
        qualify rank() over (partition by asset_id order by WHENPAID asc) = 1
)
,pva2 as (
    select fc.asset_id,
           es_admin_owner,
           current_owner,
           ever_financed,
           current_finance_status,
           INVOICE_NO,
           fc.invoice_date,
           WHENPAID,
           oem,
           sales_invoice_type,
           epi.INVOICE_DATE as fleet_track_inv_date
    from final_cte2 fc
             left join
         es_purch_invoice epi
         on fc.asset_id = epi.asset_id
)
         select c.ASSET_ID,
                sales_inv_descr,
                sales_price,
                sales_doc,
                curr_note,
                prev_note,
                rev_acct,
                location,
                cust_name,
                owner_name,
                sales_doc_date,
                admin_sn,
                admin_oec,
                admin_vendor_inv_no,
                fleet_track_sn,
                fleet_track_oec,
                fleet_track_vendor_inv_no,
                fleet_track_inv_date,
                es_admin_owner,
                current_owner,
                ever_financed,
                current_finance_status,
                INVOICE_NO,
                invoice_date,
                WHENPAID,
                oem,
                sales_invoice_type,
                submitter,
                approver
         from cogs2 c
                  left join pva2 p
                            on c.ASSET_ID = p.ASSET_ID
                            where sales_price <> 0
     ))
select
    ft.ASSET_ID, sales_inv_descr, sales_price, sales_doc, curr_note,
    prev_note, rev_acct, location, cust_name, owner_name, sales_doc_date,
    admin_sn, admin_oec, admin_vendor_inv_no, fleet_track_sn, fleet_track_oec,
    fleet_track_vendor_inv_no, fleet_track_inv_date, es_admin_owner, current_owner,
    iff(c.IS_ELIGIBLE_FOR_PAYOUTS,true,false) as OWN,
    ever_financed, current_finance_status, INVOICE_NO, invoice_date, WHENPAID,
    oem, sales_invoice_type, submitter, approver
from full_table ft
left join
    ES_WAREHOUSE.PUBLIC.COMPANIES c
on ft.current_owner = c.NAME
      ;;
  }


  dimension: asset_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: sales_inv_descr {
    type: string
    sql: ${TABLE}."SALES_INV_DESCR" ;;
  }

  dimension: sales_price {
    type: number
    value_format: "#,##0_);(#,##0);-"
    sql: ${TABLE}."SALES_PRICE" ;;
  }

  dimension: sales_doc {
    type: string
    sql: ${TABLE}."SALES_DOC" ;;
  }

  dimension: current_memo {
    type: string
    sql: ${TABLE}."CURR_NOTE" ;;
  }

  dimension: previous_memo {
    type: string
    sql: ${TABLE}."PREV_NOTE" ;;
  }

  dimension: rev_acct {
    type: string
    sql: ${TABLE}."REV_ACCT" ;;
  }

  dimension: location {
    type: number
    value_format_name: id
    sql: ${TABLE}."LOCATION" ;;
  }

  dimension: cust_name {
    type: string
    sql: ${TABLE}."CUST_NAME" ;;
  }

  dimension: owner_name {
    type: string
    sql: ${TABLE}."OWNER_NAME" ;;
  }

  dimension: sales_doc_date {
    type: date
    sql: ${TABLE}."SALES_DOC_DATE" ;;
  }

  dimension: admin_sn {
    type: string
    sql: ${TABLE}."ADMIN_SN" ;;
  }

  dimension: admin_oec {
    type: number
    value_format_name: usd
    sql: ${TABLE}."ADMIN_OEC" ;;
  }

  dimension: admin_vendor_inv_no {
    type: string
    sql: ${TABLE}."ADMIN_VENDOR_INV_NO" ;;
  }

  dimension: fleet_track_sn {
    type: string
    sql: ${TABLE}."FLEET_TRACK_SN" ;;
  }

  dimension: fleet_track_oec {
    type: number
    value_format_name: usd
    sql: ${TABLE}."FLEET_TRACK_OEC" ;;
  }

  dimension: fleet_track_vendor_inv_no {
    type: string
    sql: ${TABLE}."FLEET_TRACK_VENDOR_INV_NO" ;;
  }

  dimension: fleet_track_inv_date {
    type: string
    sql: ${TABLE}."FLEET_TRACK_INV_DATE" ;;
  }

  dimension: owner_before_sale {
    type: string
    sql: ${TABLE}."ES_ADMIN_OWNER" ;;
  }

  dimension: current_owner {
    type: string
    sql: ${TABLE}."CURRENT_OWNER" ;;
  }

  dimension: own {
    type: string
    sql: ${TABLE}."OWN" ;;
  }

  dimension: ever_financed {
    type: string
    sql: ${TABLE}."EVER_FINANCED" ;;
  }

  dimension: current_finance_status {
    type: string
    sql: ${TABLE}."CURRENT_FINANCE_STATUS" ;;
  }

  dimension: invoice_no {
    type: string
    sql: ${TABLE}."INVOICE_NO" ;;
  }

  dimension: invoice_date {
    type: date
    sql: ${TABLE}."INVOICE_DATE" ;;
  }

  dimension: sage_paid_date {
    type: date
    sql: ${TABLE}."WHENPAID" ;;
  }

  dimension: oem {
    type: string
    sql: ${TABLE}."OEM" ;;
  }

  dimension: sales_invoice_type {
    type: string
    sql: ${TABLE}."SALES_INVOICE_TYPE" ;;
  }
  dimension: submitter {
    type: string
    sql: ${TABLE}."SUBMITTER" ;;
  }
  dimension: approver {
    type: string
    sql: ${TABLE}."APPROVER" ;;
  }
}
