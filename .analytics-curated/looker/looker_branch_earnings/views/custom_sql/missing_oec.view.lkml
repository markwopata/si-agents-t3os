view: missing_oec {
  derived_table: {
    sql:
    with vpp as (
    select
        asset_id,
        min(start_date)
            over (partition by asset_id, coalesce(end_date, '2099-12-31'::timestamptz)
                order by asset_id, coalesce(end_date, '2099-12-31'::timestamptz) desc)     as start_date,
        max(coalesce(end_date, '2099-12-31'::timestamptz))
            over (partition by asset_id, coalesce(end_date, '2099-12-31'::timestamptz)
                order by asset_id, coalesce(end_date, '2099-12-31'::timestamptz) desc)     as end_date,
        PAYOUT_PROGRAM_TYPE_ID,
        row_number()
            over (partition by asset_id, coalesce(end_date, '2099-12-31'::timestamptz)
                order by asset_id, coalesce(end_date, '2099-12-31'::timestamptz) desc)     as rn
    from ES_WAREHOUSE.PUBLIC.V_PAYOUT_PROGRAMS -- Contractor Owned Program
    qualify rn = 1
),
afk_oec_nbv as (
    with nbv as (
       select
        afk.ADMIN_ASSET_ID,
        afk.DEPRECIATION_DATE,
        sum(afk.NBV_ESTIMATED_BOOK_VALUE) as NBV_ESTIMATED_BOOK_VALUE
       from analytics.assets.ASSET4000_LAS_ASSETS as afk
       where date_trunc(month,afk.DEPRECIATION_DATE) = dateadd(month,-1,date_trunc(month,date_from_parts({% parameter report_year %},{% parameter report_month %},1)::date))
          and afk.SOURCE = 'Asset4000'
          and afk.ASSET_ACCOUNT != 1508 -- Telematics
       group by 1,2
    )
    select
    afk.ADMIN_ASSET_ID,
    afk.DEPRECIATION_DATE,
    aa.OEC,
    afk.NBV_ESTIMATED_BOOK_VALUE
from nbv as afk
left join ANALYTICS.ASSETS.INT_ASSETS as aa
    on afk.ADMIN_ASSET_ID = aa.ASSET_ID
order by afk.ADMIN_ASSET_ID
),
estimated_oec_nbv as (
    SELECT
        AA.ASSET_ID,
        AA.OEC,
        COALESCE(AA.OEC - LEAST(AA.OEC *
                                CASE
                                    WHEN AA.ASSET_TYPE IN ('vehicle', 'trailer')
                                        THEN .9 / (7 * 12) -- vehicle salvage = 10%, equip = 20%
                                    ELSE .8 / (10 * 12) END *
                                GREATEST(0,
                                         DATEDIFF(MONTH,
                                                  IFF(AA.ASSET_TYPE = 'equipment', date_from_parts(
                                                          year(AA.FIRST_RENTAL),
                                                          month(AA.FIRST_RENTAL),
                                                          15),
                                                      COALESCE(date_from_parts(year(AA.PURCHASE_DATE),
                                                                               month(AA.PURCHASE_DATE),
                                                                               15),
                                                               date_from_parts(year(AA.DATE_CREATED),
                                                                               month(AA.DATE_CREATED),
                                                                               15))),
                                                  date_from_parts({% parameter report_year %},{% parameter report_month %},15))
                                    ),
                              /*Salvage Value*/AA.OEC * CASE
                                                            WHEN AA.ASSET_TYPE IN ('vehicle', 'trailer')
                                                                THEN .9
                                                            ELSE .8 END) *
                          CASE
                              WHEN AA.FIRST_RENTAL IS NULL AND AA.ASSET_TYPE = 'equipment' THEN 0
                              ELSE 1 END,
                 AA.OEC)                                                     AS NBV,
        rent.START_DATE,
        rank() over (partition by aa.ASSET_ID order by rent.START_DATE desc) as rn
    FROM ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE AS AA
        LEFT JOIN ES_WAREHOUSE.PUBLIC.RENTALS as RENT
            on aa.ASSET_ID = rent.ASSET_ID
    WHERE (rent.START_DATE < dateadd(month, 1, date_from_parts({% parameter report_year %},{% parameter report_month %},1)) or rent.START_DATE is null)
        qualify rn = 1
),
oec_nbv as (
    select
        coalesce(aon.ADMIN_ASSET_ID,eon.ASSET_ID) as asset_id,
        coalesce(aon.OEC, eon.OEC) as oec,
        coalesce(aon.NBV_ESTIMATED_BOOK_VALUE, eon.NBV) as nbv
    from estimated_oec_nbv as eon
    left join afk_oec_nbv as aon
    on eon.ASSET_ID = aon.ADMIN_ASSET_ID
),
rev as (
    select
        li.ASSET_ID,
        oec_nbv.OEC
    from ES_WAREHOUSE.PUBLIC.LINE_ITEMS as li
    left join ES_WAREHOUSE.PUBLIC.INVOICES as i
        on li.INVOICE_ID = i.INVOICE_ID
    join ANALYTICS.PUBLIC.MARKET_REGION_XWALK as xw
        on i.SHIP_FROM:branch_id = xw.MARKET_ID
    left join ANALYTICS.PUBLIC.ES_COMPANIES as ec
        on i.COMPANY_ID = ec.COMPANY_ID
    left join vpp
        on li.ASSET_ID = vpp.ASSET_ID
            and last_day(date_from_parts({% parameter report_year %},{% parameter report_month %},1)::date) between vpp.start_date and coalesce(vpp.end_date,'2099-12-31'::date)
    left join oec_nbv
        on li.ASSET_ID = oec_nbv.ASSET_ID
    where 1=1
        and date_trunc(month,i.BILLING_APPROVED_DATE) = date_from_parts({% parameter report_year %},{% parameter report_month %},1)
        and li.LINE_ITEM_TYPE_ID in (24, -- New Fleet Equipment Sales
                                     50, -- RPO Equipment Sales
                                     81, -- Used Fleet Equipment Sales
                                     110, -- Used Fleet Attachment Sales
                                     111, -- New Fleet Attachment Sales
                                     118, -- LSD Invoice
                                     147, -- In Store <$10k New Fleet Equip. Sales
                                     148, -- In Store <$10k Used Fleet Equip. Sales
                                     149, -- In Store <$10k New Attachment Sales
                                     150, -- In Store <$10k Used Attachment Sales
                                     151  -- In Store <$10k Parts Retail Sales
                                     )
        and ec.COMPANY_ID is null
        and vpp.ASSET_ID is null
        and li.AMOUNT <> 0
        and li.ASSET_ID is not null
        and (oec_nbv.OEC <= 0 or oec_nbv.OEC is null)
),
credit as (
    select
        li.ASSET_ID,
        oec_nbv.OEC
    from ES_WAREHOUSE.PUBLIC.LINE_ITEMS as li
    left join ES_WAREHOUSE.PUBLIC.INVOICES as i
        on li.INVOICE_ID = i.INVOICE_ID
    join ANALYTICS.PUBLIC.MARKET_REGION_XWALK as xw
        on i.SHIP_FROM:branch_id = xw.MARKET_ID
    left join ANALYTICS.PUBLIC.ES_COMPANIES as ec
        on i.COMPANY_ID = ec.COMPANY_ID
    left join vpp
        on li.ASSET_ID = vpp.ASSET_ID
            and last_day(date_from_parts({% parameter report_year %},{% parameter report_month %},1)::date) between vpp.start_date and coalesce(vpp.end_date,'2099-12-31'::date)
    LEFT JOIN ES_WAREHOUSE.PUBLIC.CREDIT_NOTES AS CN
        ON CN.ORIGINATING_INVOICE_ID = I.INVOICE_ID
    LEFT JOIN ANALYTICS.INTACCT.ARRECORD ARR
        ON CN.CREDIT_NOTE_NUMBER = ARR.RECORDID
            AND ARR.RECORDTYPE = 'aradjustment'
    LEFT JOIN ES_WAREHOUSE.PUBLIC.CREDIT_NOTE_LINE_ITEMS AS CNLI
        ON CN.CREDIT_NOTE_ID = CNLI.CREDIT_NOTE_ID
            AND CNLI.LINE_ITEM_ID = LI.LINE_ITEM_ID
    left join oec_nbv
        on li.ASSET_ID = oec_nbv.ASSET_ID
    where 1=1
        and date_trunc(month,arr.WHENPOSTED) = date_from_parts({% parameter report_year %},{% parameter report_month %},1)
        and li.LINE_ITEM_TYPE_ID in (24, -- New Fleet Equipment Sales
                                     50, -- RPO Equipment Sales
                                     81, -- Used Fleet Equipment Sales
                                     110, -- Used Fleet Attachment Sales
                                     111, -- New Fleet Attachment Sales
                                     118, -- LSD Invoice
                                     147, -- In Store <$10k New Fleet Equip. Sales
                                     148, -- In Store <$10k Used Fleet Equip. Sales
                                     149, -- In Store <$10k New Attachment Sales
                                     150, -- In Store <$10k Used Attachment Sales
                                     151  -- In Store <$10k Parts Retail Sales
                                     )
        and ec.COMPANY_ID is null
        and vpp.ASSET_ID is null
        and cnli.CREDIT_AMOUNT <> 0
        and li.ASSET_ID is not null
        and (oec_nbv.OEC <= 0 or oec_nbv.OEC is null)
),
combined_cte as (
select * from rev union all select * from credit)
select distinct
    aa.ASSET_ID,
    aa.SERIAL_NUMBER,
    aa.MAKE,
    aa.MODEL,
    aa.OWNER
from combined_cte
join ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE as aa
on combined_cte.ASSET_ID = aa.ASSET_ID
order by aa.ASSET_ID
    ;;
    }

  parameter: report_month {
    label: "Month"
    type: number
    default_value: "5"
    allowed_value: {
      label: "January"
      value: "1"
    }
    allowed_value: {
      label: "February"
      value: "2"
    }
    allowed_value: {
      label: "March"
      value: "3"
    }
    allowed_value: {
      label: "April"
      value: "4"
    }
    allowed_value: {
      label: "May"
      value: "5"
    }
    allowed_value: {
      label: "June"
      value: "6"
    }
    allowed_value: {
      label: "July"
      value: "7"
    }
    allowed_value: {
      label: "August"
      value: "8"
    }
    allowed_value: {
      label: "September"
      value: "9"
    }
    allowed_value: {
      label: "October"
      value: "10"
    }
    allowed_value: {
      label: "November"
      value: "11"
    }
    allowed_value: {
      label: "December"
      value: "12"
    }
  }

  parameter: report_year {
    label: "Year"
    type: number
    default_value: "2024"
  }

  dimension: asset_id {
    type: number
    value_format: ""
    label: "Asset ID"
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: serial_number {
    type: string
    label: "Serial Number"
    sql: ${TABLE}."SERIAL_NUMBER" ;;
  }

  dimension: make {
    type: string
    label: "Make"
    sql: ${TABLE}."MAKE" ;;
  }

  dimension: model {
    type: string
    label: "Model"
    sql: ${TABLE}."MODEL" ;;
  }

  dimension: owner {
    type: string
    label: "Owner"
    sql: ${TABLE}."OWNER" ;;
  }
}
