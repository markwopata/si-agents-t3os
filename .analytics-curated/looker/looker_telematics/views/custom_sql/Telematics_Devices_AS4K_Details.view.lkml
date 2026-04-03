view: Telematics_Devices_AS4K_Details {
  derived_table: {
    sql:
    with ASSET_LIST  AS (
select gag1.ASS_CODE, gag1.ASSG_GRP8 as gl_account
from ANALYTICS.ASSET4000_DBO.GL_ASSET_GRPS gag1
join
(select  sub_gag.ASS_CODE, max(sub_gag.ASSG_DATE) as max_date
from ANALYTICS.ASSET4000_DBO.GL_ASSET_GRPS sub_gag
group by sub_gag.ASS_CODE
order by sub_gag.ASS_CODE) gag2
on gag1.ass_code = gag2.ass_code and gag1.ASSG_DATE = gag2.max_date
where coalesce(gag1.ASSG_GRP8,'') = '1508'
-- where coalesce(gag1.ASSG_GRP8,'') not in ('1508', '1518', '1619', '')
)
--       select * from ASSET_LIST where ASS_CODE like '%943896%';
,add_admin_id as (
select gd.*,
coalesce(try_to_number(GAD.ASS_DESC2),
try_to_number(regexp_replace(replace(GAD.ASS_DESC2, char(160), ''), '-.+$', '')))
as ADMIN_ASSET_ID,
gad.ASS_DESC3 as serial_number
from ASSET_LIST gd
left join (
select *
from ANALYTICS.ASSET4000_DBO.GL_ASSET_DESCS
where not _FIVETRAN_DELETED
) gad
on gd.ASS_CODE = gad.ASS_CODE
)
--       select * from add_admin_id where ASS_CODE = '943896';
,GET_NBV AS
(
select
aai.*,
last_day(date_from_parts(c.COST_YEAR, c.COST_PERSEQ, 1), month)::date DEPRECIATION_DATE,
c.COST_NBV AS NBV,
c.COST_GBV as OEC
from
add_admin_id aai
left join
ANALYTICS.ASSET4000_DBO.FA_COSTS c
on aai.ASS_CODE = c.ASS_CODE
join ANALYTICS.ASSET4000_DBO.FA_TRANSFERS T
on C.ASS_CODE = T.ASS_CODE
and C.TFR_YEAR = T.TFR_YEAR
and C.TFR_PERSEQ = T.TFR_PERSEQ
and not T._FIVETRAN_DELETED
where c.ASS_CODE in (select ASSET_LIST.ASS_CODE from ASSET_LIST)
and not c._FIVETRAN_DELETED
and c.BOOK_CODE = 'GAAP'
and (c.COST_GBV != 0 or c.COST_NBV != 0 or c.COST_PERDEP != 0)
order by DEPRECIATION_DATE
)
select gn.ASS_CODE, gl_account, serial_number,
DEPRECIATION_DATE, NBV, OEC from GET_NBV gn
where serial_number is not null
-- ('1445465776',
-- '1387995524',
-- '1419940785',
-- '1346002384',
-- '1345980606'
-- )
and DEPRECIATION_DATE = '2025-12-31'
order by serial_number, DEPRECIATION_DATE
      ;;
  }


  dimension: ASS_CODE {
    type: string
    sql: ${TABLE}.ASS_CODE ;;
  }

  dimension: GL_ACCOUNT {
    type: string
    sql: ${TABLE}.GL_ACCOUNT ;;
  }

  dimension: SERIAL_NUMBER {
    type: string
    sql: ${TABLE}.SERIAL_NUMBER ;;
  }

  dimension: DEPRECIATION_DATE {
    type: date
    sql: ${TABLE}.DEPRECIATION_DATE ;;
  }

  dimension: NBV {
    type: number
    sql: ${TABLE}.NBV ;;
  }

  dimension: OEC {
    type: number
    sql: ${TABLE}.OEC ;;
  }

}
