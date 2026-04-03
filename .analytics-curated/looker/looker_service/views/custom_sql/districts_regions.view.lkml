view: districts_regions {

  derived_table: {
    sql: SELECT d.district_ID
              , d.name AS DISTRICT_NAME
              , d.region_ID
              , r.name AS REGION_NAME
        FROM ES_WAREHOUSE.public.districts d
        JOIN ES_WAREHOUSE.public.regions r
          ON d.region_ID = r.region_ID
        WHERE d.name <>''
      ;;
 }
}
