view: collector_directory {
  derived_table: {
    sql:
    select distinct
      cca.market_collector as collector,
      left(cd.work_phone,3) || '-' || substr(cd.work_phone,4,3) || '-' || right(cd.work_phone,4) as phone_number,
      x.market_name,
      x.abbreviation as abbreviation,
      x.region_district as district,
      x.region as region_id,
      cca.market_id,
      x.region_name ,
      cd.direct_manager_name as collection_manager
    from analytics.gs.collector_customer_assignments as cca
    left join analytics.bi_ops.collectors as c on cca.market_collector = c.display_name
    left join es_warehouse.public.users as u on c.user_id = u.user_id
    left join analytics.public.market_region_xwalk as x on cca.market_id = x.market_id
    left join analytics.payroll.company_directory as cd on u.employee_id::varchar = cd.employee_id::varchar
    where x.market_name is not null
    order by cca.market_collector
    ;;
  }

  dimension: collector {
    type: string
    sql: ${TABLE}.COLLECTOR ;;
  }

  dimension: phone_number   {
    type: string
    sql: ${TABLE}.PHONE_NUMBER ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}.MARKET_NAME ;;
  }

  dimension: abbreviation {
    type: string
    sql: ${TABLE}.ABBREVIATION ;;
  }
  dimension: district {
    type: string
    sql: ${TABLE}.DISTRICT ;;
  }

  dimension: region_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.REGION_ID ;;
  }

  dimension: market_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.MARKET_ID ;;
  }

  dimension: region_name {
    type: string
    sql: ${TABLE}.REGION_NAME ;;
  }

  dimension: collection_manager {
    type: string
    sql: ${TABLE}.COLLECTION_MANAGER ;;
  }

  }
