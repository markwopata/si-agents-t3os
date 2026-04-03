view: branch_addresses {
  derived_table: {
    sql: select distinct m.NAME, l.STREET_1, l.STREET_2, l.CITY, s.ABBREVIATION as STATE, l.ZIP_CODE
from ES_WAREHOUSE.PUBLIC.MARKETS m
left join ES_WAREHOUSE.PUBLIC.LOCATIONS l
on m.LOCATION_ID = l.LOCATION_ID
left join ES_WAREHOUSE.PUBLIC.STATES s
on l.STATE_ID = s.STATE_ID
where m.COMPANY_ID = 1854
and m.NAME ilike '%branch%'
or m.NAME ilike '%rent%'
and m.ACTIVE = true;;
  }
  dimension: NAME {
    type: string
    sql: ${TABLE}.NAME ;;
  }
  dimension: STREET_1 {
    type: string
    sql: ${TABLE}.STREET_1 ;;
  }
  dimension: STREET_2 {
    type: string
    sql: ${TABLE}.STREET_2 ;;
  }
  dimension: CITY {
    type: string
    sql: ${TABLE}.CITY ;;
  }
  dimension: STATE {
    type: string
    sql: ${TABLE}.STATE ;;
  }
  dimension: ZIP_CODE {
    type: string
    sql: ${TABLE}.ZIP_CODE ;;
  }

}
