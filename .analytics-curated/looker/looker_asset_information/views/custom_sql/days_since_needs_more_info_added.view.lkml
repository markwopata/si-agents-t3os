view: days_since_needs_more_info_added {
  derived_table: {
    sql:
    select ca.parameters:work_order_id as work_order_id
      , min(datediff(day, date_created, current_date)) as days_since_added --min because needs more info can be added multiple times
    from ES_WAREHOUSE.PUBLIC.COMMAND_AUDIT ca
    where command = 'CreateAndAssociateCompanyTag'
     and ca.parameters:tag_name ilike '%Needs%More%Information%'
    group by work_order_id ;;
  }
  dimension: work_order_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.work_order_id ;;
  }

  dimension: days_since_tag_added {
    type: number
    sql: ${TABLE}.days_since_added ;;
  }
}
