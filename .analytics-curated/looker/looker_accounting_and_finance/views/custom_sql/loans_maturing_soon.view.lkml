view: loans_maturing_soon {
    derived_table: {
    sql:with first_list as (
  select
    phoenix_id,
    min(date) as first_dt
  from
    analytics.debt.TV6_XML_DEBT_TABLE_CURRENT
  where
    customType in ('Loan','Lease')
    and current_version = 'Yes'
    and gaap_non_gaap = 'Non-GAAP'
  group by phoenix_id
)
  --  select * from first_list where PHOENIX_ID = 1767;
,get_maturity_dt as (
  select DISTINCT
    a.phoenix_id,
    b.maturity_date,
    b.FINANCING_FACILITY_TYPE
  from
    first_list a
    left JOIN
    analytics.debt.TV6_XML_DEBT_TABLE_CURRENT  b
    on a.phoenix_id = b.phoenix_id and a.first_dt = b.date
  where
    b.customType in ('Loan','Lease')
    and b.current_version = 'Yes'
    and b.gaap_non_gaap = 'Non-GAAP'
)
--SELECT * FROM get_maturity_dt where phoenix_id = 1767;
,get_schedule as (
  select
    a.phoenix_id,
    b.lender,
    b.schedule,
    a.financing_facility_type,
    b.sage_loan_id,
    b.financial_schedule_id,
    a.maturity_date
  from
    get_maturity_dt a
    left join
    analytics.debt.phoenix_id_types b
    on a.phoenix_id = b.phoenix_id
)
--select * from get_schedule where financial_schedule_id = 2666;
,final_pmt_dt as (
    SELECT PHOENIX_ID, max(date) as final_pmt_dt
    FROM ANALYTICS.DEBT.TV6_XML_DEBT_TABLE_CURRENT
    WHERE
          CUSTOMTYPE = 'Payment'
      and CURRENT_VERSION = 'Yes'
      and GAAP_NON_GAAP = 'Non-GAAP'
    group by PHOENIX_ID
)
,PHID_balloon as (
    select a.PHOENIX_ID,
           --a.DATE, a.NEGATIVECF
           round(sum(a.NEGATIVECF),2) as balloon
        from ANALYTICS.DEBT.TV6_XML_DEBT_TABLE_CURRENT a,
            final_pmt_dt b
    where a.PHOENIX_ID = b.PHOENIX_ID and a.DATE = b.final_pmt_dt
    and a.CURRENT_VERSION = 'Yes' and a.GAAP_NON_GAAP = 'Non-GAAP'
    and a.CUSTOMTYPE = 'Payment'
    group by a.PHOENIX_ID
)
,FSID_balloon as (
    select b.financial_schedule_id, a.balloon
    from
         PHID_balloon a
         left join
        ANALYTICS.DEBT.PHOENIX_ID_TYPES b
    on a.PHOENIX_ID = b.PHOENIX_ID
)
, asset_count as (
    select COUNT(ASSET_ID) ASSET_COUNT, FINANCIAL_SCHEDULE_ID
from ES_WAREHOUSE.PUBLIC.ASSET_PURCHASE_HISTORY
GROUP BY FINANCIAL_SCHEDULE_ID
 )
 ,asset_lvl_nbv as (
    select A.ASSET_ID,
           A.FINANCIAL_SCHEDULE_ID,
           B.OEC,
           B.NBV,
           c.COMPANY_ID,
           case
               when c.COMPANY_ID in (1854, 1855, 31175,
              7201,32149,31293,31177,31295,31180,31294,31113,8151) then
                   B.NBV
               ELSE
                   0
               END OWNED_NBV,
           case
               when c.COMPANY_ID in (1854, 1855, 31175,
              7201,32149,31293,31177,31295,31180,31294,31113,8151) then
                   B.OEC
               ELSE
                   0
               END OWNED_OEC
    from ES_WAREHOUSE.PUBLIC.ASSET_PURCHASE_HISTORY A
             LEFT JOIN
         ANALYTICS.DEBT.ASSET_NBV_ALL_OWNERS_VIEW B
         ON A.ASSET_ID = B.ASSET_ID
             left join ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE C
                       on a.ASSET_ID = c.ASSET_ID
)
,owned_nbv as (
select FINANCIAL_SCHEDULE_ID,
       round(sum(owned_nbv),2) as owned_nbv,
       round(sum(owned_oec),2) as owned_oec
from asset_lvl_nbv
group by FINANCIAL_SCHEDULE_ID)
select a.*, b.balloon,
       case when c.ASSET_COUNT is null then
           0 else
       c.asset_count end asset_count,
       case when d.owned_nbv is null then
           0
        else
            d.owned_nbv end owned_nbv,
       case when d.owned_oec is null then
           0
        else
            d.owned_oec end owned_oec
 from get_schedule a
 left join
     FSID_balloon b
 on a.FINANCIAL_SCHEDULE_ID = b.FINANCIAL_SCHEDULE_ID
 left join asset_count c
 on a.FINANCIAL_SCHEDULE_ID = c.FINANCIAL_SCHEDULE_ID
 left join owned_nbv d
 on a.FINANCIAL_SCHEDULE_ID = d.FINANCIAL_SCHEDULE_ID
order by maturity_date
      ;;
  }
  dimension: phoenix_id {
    type: number
    sql: ${TABLE}.phoenix_id ;;
  }
  dimension: lender {
    type: string
    sql: ${TABLE}.lender ;;
  }
  dimension: schedule {
    type: string
    sql: ${TABLE}.schedule ;;
  }
  dimension: financing_facility_type {
    type: string
    sql: ${TABLE}.financing_facility_type ;;
  }
  dimension: sage_loan_id {
    type: string
    sql: ${TABLE}.sage_loan_id ;;
  }
  dimension: financial_schedule_id {
    type: number
    sql: ${TABLE}.financial_schedule_id ;;
  }
  dimension: maturity_date {
    type: date
    sql: ${TABLE}.maturity_date ;;
  }
  dimension: balloon {
    type: number
    sql: ${TABLE}.balloon ;;
  }
  dimension: asset_count {
    type: number
    sql: ${TABLE}.asset_count ;;
  }
  dimension: owned_nbv {
    type: number
    sql: ${TABLE}.owned_nbv ;;
  }
  dimension: owned_oec {
    type: number
    sql: ${TABLE}.owned_oec ;;
  }
}
