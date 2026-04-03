view: asset_4000_depreciation {
  parameter: date_FILTER {
    type: date
  }
  derived_table: {
    sql: with filter_date as (
  select {% parameter date_FILTER %}::date as filter_date
)
,table_1 as
(select gag.ASS_CODE as A4K_ASSET_CODE,
       gag.ASSG_GRP9 as accum_gl,
       gag.ASSG_GRP10 as expense_gl,
       gag.ASSG_GRP3 as sage_location_id,
       coalesce(fc.COST_GBV - fc.COST_NBV,0)::NUMBER(38,2) as total_dep,
       coalesce(fc.COST_PERDEP,0)::NUMBER(38,2) as COST_PERDEP,
       fc.DEPR_DATE::date as DEPR_DATE,
       gag.ASSG_GRP5 as entity
--add entity
from
    ANALYTICS.ASSET4000_DBO.GL_ASSET_GRPS gag
   left join (
                select
                    C.ASS_CODE,
                    last_day(date_from_parts(COST_YEAR,COST_PERSEQ,1),month)::timestampntz DEPR_DATE,
                    TFR_DATE,
                    COST_GBV,
                    COST_NBV,
                    COST_PERDEP
                from ANALYTICS.ASSET4000_DBO.FA_COSTS C
                join ANALYTICS.ASSET4000_DBO.FA_TRANSFERS T
                    on C.ASS_CODE = T.ASS_CODE
                    and C.TFR_YEAR = T.TFR_YEAR
                    and C.TFR_PERSEQ = T.TFR_PERSEQ
                    and not T._FIVETRAN_DELETED
                where not C._FIVETRAN_DELETED and BOOK_CODE = 'GAAP'
                    and TFR_DATE <= (select * from filter_date)
                    and (COST_GBV != 0 or COST_NBV != 0 or COST_PERDEP != 0)
                qualify rank() over (partition by C.ASS_CODE, depr_date order by TFR_DATE desc) = 1
              ) FC
        on gag.ASS_CODE = FC.ASS_CODE
        and FC.DEPR_DATE = (select * from filter_date)
where not gag._FIVETRAN_DELETED
    and gag.ASSG_DATE <= (select * from filter_date)
and COST_PERDEP <> 0
--and gag.ASS_CODE = '157909'
qualify rank() over(partition by gag.ass_code order by gag.assg_date desc) = 1
)
   select
    *
from table_1
where accum_gl <> '8113'

      ;;
  }

  dimension: A4K_ASSET_CODE {
    type: string
    sql: ${TABLE}.a4k_asset_code ;;
  }
  dimension: accum_gl {
    type: string
    sql: ${TABLE}.accum_gl ;;
  }
  dimension: expense_gl {
    type: string
    sql: ${TABLE}.expense_gl ;;
  }
  dimension: sage_location_id {
    type: string
    sql: ${TABLE}.sage_location_id ;;
  }
  dimension: total_dep {
    type: number
    sql: ${TABLE}.total_dep ;;
  }
  dimension: COST_PERDEP {
    type: number
    sql: ${TABLE}.cost_perdep ;;
  }
  dimension: DEPR_DATE {
    type: date
    sql: ${TABLE}.DEPR_DATE ;;
  }
  dimension: entity {
    type: string
    sql: ${TABLE}.entity ;;
  }
}
