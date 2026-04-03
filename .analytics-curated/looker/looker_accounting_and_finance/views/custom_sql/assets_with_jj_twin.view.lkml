view: assets_with_jj_twin {
  derived_table: {
    sql:with current_assets as (
    select *
    from ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE
    where COMPANY_ID <> 155
      and COMPANY_ID in (
        select COMPANY_ID
        from ANALYTICS.PUBLIC.ES_COMPANIES
        where OWNED = true
    )
      and coalesce(SERIAL_NUMBER, vin) is not null
      and coalesce(serial_number, vin) not in (
                                               '', '-', '- -', '000000', '00000000', '1'
        )
)
,jj_assets as (
    select *
from ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE
where COMPANY_ID = 155
and coalesce(SERIAL_NUMBER, vin) is not null
)
select ca.asset_id es_asset_id,
       jj.asset_id jj_asset_id,
       ca.company_id es_company_id,
       coalesce(ca.serial_number,ca.vin) as serial_number,
       jj.first_rental as jj_first_rental_date
from current_assets ca
inner join jj_assets jj
on coalesce(ca.serial_number,ca.vin) = coalesce(jj.serial_number,jj.vin)
and ca.YEAR = jj.YEAR and ca.MODEL = jj.MODEL
order by coalesce(ca.serial_number,ca.vin);;
  }

  dimension: es_asset_id {
    type: number
    sql: ${TABLE}.es_asset_id;;
  }
  dimension: jj_asset_id {
    type: number
    sql: ${TABLE}.jj_asset_id;;
  }
  dimension: es_company_id {
    type: number
    sql: ${TABLE}.es_company_id;;
  }
  dimension:serial_number_vin {
    type: string
    sql:${TABLE}.SERIAL_NUMBER;;
  }
  dimension: jj_first_rental_date {
    type: date
    sql: ${TABLE}.jj_first_rental_date;;
  }

}
