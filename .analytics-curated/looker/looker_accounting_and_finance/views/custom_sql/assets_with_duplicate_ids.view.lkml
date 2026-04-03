view: assets_with_duplicate_ids {
derived_table: {
  sql:with es_assets as (
    select *
    from ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE
    where COMPANY_ID <> 155
      and COMPANY_ID in (
        select COMPANY_ID
        from ANALYTICS.PUBLIC.ES_COMPANIES
        where OWNED = true
    )
      and coalesce(SERIAL_NUMBER, vin) is not null
)
,non_es_assets as (
    select *
from ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE
where COMPANY_ID <> 155
        and (COMPANY_ID not in (
        select COMPANY_ID
        from ANALYTICS.PUBLIC.ES_COMPANIES
        where OWNED = true
    ) or
     COMPANY_ID in (
        select COMPANY_ID
        from ANALYTICS.PUBLIC.ES_COMPANIES
        where OWNED <> true
    ))
and coalesce(SERIAL_NUMBER, vin) is not null
)
,compilation as (
    select
-- distinct coalesce(ca.serial_number,ca.vin) as serial
ca.asset_id                           ES_asset_id,
jj.asset_id                           non_es_asset_id,
ca.company_id                      as es_company_id,
jj.COMPANY_ID                      as non_es_company_id,
c.NAME as non_es_company_name,
           ca.YEAR,
           ca.MAKE,
coalesce(ca.serial_number, ca.vin) as serial_number
-- jj.first_rental                    as jj_first_rental_date
    from es_assets ca
    inner join non_es_assets jj
        on coalesce(ca.serial_number, ca.vin) = coalesce(jj.serial_number, jj.vin)
        and ca.YEAR = jj.YEAR
        and ca.MAKE = jj.MAKE
    left join ES_WAREHOUSE.PUBLIC.COMPANIES c
    on jj.COMPANY_ID = c.COMPANY_ID
    where coalesce(ca.serial_number, ca.vin) not in (
                                                     '', '-', '- -', '000000', '00000000', '1'
        )
    order by coalesce(ca.serial_number, ca.vin)
)
,list as (
    select *
    from compilation
)
select * from list;;
}

dimension: es_asset_id {
  type: number
  sql: ${TABLE}.es_asset_id;;
}
dimension: non_es_asset_id {
  type: number
  sql: ${TABLE}.non_es_asset_id;;
}
dimension: es_company_id {
  type: number
  sql: ${TABLE}.es_company_id;;
}
dimension: non_es_company_id {
    type: number
    sql: ${TABLE}.non_es_company_id;;
  }
dimension:non_es_company_name {
  type: string
  sql:${TABLE}.non_es_company_name;;
}
dimension:year {
    type: number
    sql:${TABLE}.year;;
  }
dimension:make {
    type: string
    sql:${TABLE}.make;;
  }
dimension:serial_number_vin {
    type: string
    sql:${TABLE}.SERIAL_NUMBER;;
  }
}
