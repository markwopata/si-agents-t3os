view: re_rent_estimate {
  derived_table: {
    sql: with A4K_ASSET_LIST  AS
    (
    select gag1.ASS_CODE, gag1.ASSG_GRP8 as gl_account
    from ANALYTICS.ASSET4000_DBO.GL_ASSET_GRPS gag1
    join
    (select  sub_gag.ASS_CODE, max(sub_gag.ASSG_DATE) as max_date
    from ANALYTICS.ASSET4000_DBO.GL_ASSET_GRPS sub_gag
    group by sub_gag.ASS_CODE
    order by sub_gag.ASS_CODE) gag2
    on gag1.ass_code = gag2.ass_code and gag1.ASSG_DATE = gag2.max_date
    where coalesce(gag1.ASSG_GRP8,'') not in ('1508', '1518', '1619', '')
    )
,add_admin_id as (
    select gd.*,
        coalesce(try_to_number(GAD.ASS_DESC2),
        try_to_number(regexp_replace(replace(GAD.ASS_DESC2, char(160), ''), '-.+$', '')))
            as ADMIN_ASSET_ID
    from A4K_ASSET_LIST gd
    left join (
        select *
        from ANALYTICS.ASSET4000_DBO.GL_ASSET_DESCS
        where not _FIVETRAN_DELETED
    ) gad
    on gd.ASS_CODE = gad.ASS_CODE
)
    select
        AFS.ASSET_ID,
        AFS.DATE,
            aa.SERIAL_NUMBER,
            aa.VIN,
            cpoli.INVOICE_NUMBER,
            c2.NAME as vendor,
            AFS.COMPANY_ID,
            c.NAME as company_name,
            aa.CLASS,
            AFS.MAKE,
            AFS.model,
            AFS.year,
            AFS.ASSET_TYPE,
            AFS.FINANCE_STATUS,
            AFS.OEC,
            AFS.FINANCING_FACILITY_TYPE,
            AFS.MARKET_ID,
            AFS.FIRST_RENTAL,
            iff(aai.ADMIN_ASSET_ID is null,false,true) as IN_A4K_INDICATOR
     --in A4K?  TRUE/FALSE.  If in A4K but GL is null, we want the row, but we
--want this indicator to be false.  Also, FALSE if GL in (1508, 1518, 1619)
     from ANALYTICS.PUBLIC.ASSET_FINANCING_SNAPSHOTS AFS
              LEFT JOIN
          ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE aa
          on afs.ASSET_ID = aa.ASSET_ID
              left join
          ES_WAREHOUSE.PUBLIC.COMPANIES c
          on afs.COMPANY_ID = c.COMPANY_ID
     left join ES_WAREHOUSE.PUBLIC.COMPANY_PURCHASE_ORDER_LINE_ITEMS cpoli
     on afs.ASSET_ID = cpoli.ASSET_ID
                        left join
           ES_WAREHOUSE.PUBLIC.COMPANY_PURCHASE_ORDERS cpo
           on cpoli.COMPANY_PURCHASE_ORDER_ID = cpo.COMPANY_PURCHASE_ORDER_ID
     left join ES_WAREHOUSE.PUBLIC.COMPANIES c2
     on cpo.VENDOR_ID = c2.COMPANY_ID
     left join add_admin_id aai
     on afs.ASSET_ID = aai.ADMIN_ASSET_ID
     where
--     ASSET_ID = 334102 and
--          AFS.DATE = '2024-07-31' AND
        AFS.FIRST_RENTAL <=  AFS.DATE AND
        AFS.FIRST_RENTAL is not null
       and coalesce(AFS.FINANCE_STATUS, '') not ilike 'paid%in%cash%non%finance%'
       and coalesce(AFS.FINANCE_STATUS, '') not in  ('OEC Included in Prime Mover')
-- and coalesce(FINANCE_STATUS, '') ilike 'paid%in%cash%non%finance%'
       and AFS.oec is not null
       and coalesce(AFS.FINANCING_FACILITY_TYPE, '') not like 'Capital'
       and coalesce(AFS.FINANCING_FACILITY_TYPE, '') not like 'Operating'
     AND AFS.COMPANY_ID in (1854,
                           82716,
86419,
90189,
101321,
76482,
7201,
61035,
8151,
31113,
31175,
31177,
31180,
31293,
31294,
31295,
32149,
94784,
63457)
ORDER BY ASSET_ID, DATE
      ;;
  }
  dimension: asset_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."ASSET_ID" ;;
  }
  dimension: date {
    type: date
    sql: ${TABLE}."DATE" ;;
  }
  dimension: serial_number {
    type: string
    sql: ${TABLE}."SERIAL_NUMBER" ;;
  }
  dimension: vin {
    type: string
    sql: ${TABLE}."VIN" ;;
  }
  dimension: invoice_number {
    type: string
    sql: ${TABLE}."INVOICE_NUMBER" ;;
  }
  dimension: vendor {
    type: string
    sql: ${TABLE}."VENDOR" ;;
  }
  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }
  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }
  dimension: class {
    type: string
    sql: ${TABLE}."CLASS" ;;
  }
  dimension: make {
    type: string
    sql: ${TABLE}."MAKE" ;;
  }
  dimension: MODEL {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }
  dimension: YEAR {
    type: number
    sql: ${TABLE}."YEAR" ;;
  }
  dimension: ASSET_TYPE {
    type: string
    sql: ${TABLE}."ASSET_TYPE" ;;
  }
  dimension: FINANCE_STATUS {
    type: string
    sql: ${TABLE}."FINANCE_STATUS" ;;
  }
  dimension: OEC {
    type: number
    sql: ${TABLE}."OEC" ;;
  }
  dimension: FINANCING_FACILITY_TYPE {
    type: string
    sql: ${TABLE}."FINANCING_FACILITY_TYPE" ;;
  }
  dimension: MARKET_ID {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }
  dimension: FIRST_RENTAL {
    type: date
    sql: ${TABLE}."FIRST_RENTAL" ;;
  }
  dimension: IN_A4K_INDICATOR {
    type: string
    sql: ${TABLE}."IN_A4K_INDICATOR" ;;
  }
}
