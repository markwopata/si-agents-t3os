view: wos_within_24hrs_of_delivery_variable_date {
  # Testing paramaters PB 2022-02-24

    derived_table: {
      sql: with deliveries as (select d.asset_id,
                           d.DELIVERY_ID,
                           d.RENTAL_ID,
                           d.delivery_status_id,
                           ds.name,
                           d.completed_date as delivery_date,
                           r.START_DATE     as rental_start,
                           r.end_date       as rental_end
                    from es_warehouse.public.deliveries d
                             inner join es_warehouse.public.delivery_statuses ds
                                        on d.delivery_status_id = ds.delivery_status_id
                             left outer join es_warehouse.public.locations l
                                             on d.ORIGIN_LOCATION_ID = l.LOCATION_ID
                             left outer join es_warehouse.public.rentals r
                                             on r.RENTAL_ID = d.RENTAL_ID

                    where d.completed_date between
                              --Since beginning of last year
                            dateadd('YEAR', -1, DATE_TRUNC('YEAR', current_timestamp))
                            and current_timestamp

                      and d.asset_id is not null
                      and l.COMPANY_ID = 1854
                      and d.delivery_status_id = 3),

     wos as (
         select wo.DATE_CREATED        as wo_date,
                wo.WORK_ORDER_ID,
                wo.ASSET_ID,
                wo.WORK_ORDER_STATUS_NAME,
                wo.WORK_ORDER_TYPE_NAME,
                wo.ARCHIVED_DATE,
                wo.DESCRIPTION,
                wo.branch_id,
                LISTAGG(ct.name, ', ') as tags
         from ES_WAREHOUSE.work_orders.work_orders wo
                  left outer join es_warehouse.work_orders.WORK_ORDER_COMPANY_TAGS tag
                                  on wo.WORK_ORDER_ID = tag.WORK_ORDER_ID
                                  and tag.deleted_on is null
                  left outer join es_warehouse.work_orders.company_tags ct
                                  on tag.COMPANY_TAG_ID = ct.COMPANY_TAG_ID
                  left outer join es_warehouse.work_orders.WORK_ORDER_ORIGINATORS o
                                    on wo.work_order_id = o.WORK_ORDER_ID
         where wo.DATE_CREATED between
                    --Since beginning of last year
                    dateadd('YEAR', -1, DATE_TRUNC('YEAR', current_timestamp)) and current_timestamp
                    and wo.WORK_ORDER_TYPE_NAME <> 'Inspection'
                    and o.originator_type_id <> 3 -- Maintenance Group Interval, system created
                    and tag.company_tag_id not in (980, 888, 393, 486, 400, 401, 856, 1396, 1209)
                        -- take out Equipment Transfer and anything to do with trackers
                    and wo.ARCHIVED_DATE is NULL
         group by wo.DATE_CREATED, wo.WORK_ORDER_ID, wo.ASSET_ID, wo.WORK_ORDER_STATUS_NAME, wo.WORK_ORDER_TYPE_NAME,
                  wo.ARCHIVED_DATE, wo.DESCRIPTION, wo.BRANCH_ID
     )


select d.asset_id,
       wos.DESCRIPTION,
       wos.TAGS,
       d.DELIVERY_ID,
       d.RENTAL_ID,
       wos.WORK_ORDER_ID,
       wos.WORK_ORDER_TYPE_NAME,
       wos.WORK_ORDER_STATUS_NAME,
       d.DELIVERY_DATE,
       wos.WO_DATE,
       wos.BRANCH_ID,
       d.RENTAL_START,
       d.RENTAL_END,
      CASE WHEN wos.wo_date between d.delivery_date and dateadd('hours', 24, d.delivery_date)
        THEN 'WO Within 24Hr'
        ELSE 'No WO Within 24Hr'
        END as WO_WITHIN_24HR
from deliveries d
         inner join wos
                    on d.ASSET_ID = wos.asset_id
                        --and wos.wo_date between d.delivery_date and dateadd('hours', 24, d.delivery_date)
         inner join es_warehouse.PUBLIC.ASSETS_AGGREGATE aa
                    on wos.ASSET_ID = aa.ASSET_ID

where  d.DELIVERY_DATE between
                          {% if history_duration._parameter_value    == "'Last 30 Days'"%}
                            dateadd('days', -30, current_timestamp) and current_timestamp

                          {% elsif history_duration._parameter_value == "'This Quarter'"%}
                            date_trunc('QUARTER', current_timestamp) and current_timestamp

                          {% elsif history_duration._parameter_value == "'Last Quarter'"%}
                              --Beginning of last quarter
                            dateadd('QUARTER', -1, DATE_TRUNC('QUARTER', current_timestamp))
                              --End of last quarter
                            and dateadd('day',-1,DATE_TRUNC('qtr', current_date))

                          {% elsif history_duration._parameter_value == "'This Year'"%}
                            DATE_TRUNC('YEAR', current_timestamp) and current_timestamp

                          {% elsif history_duration._parameter_value == "'Last Year'"%}
                              --Beginning of last year
                            dateadd('YEAR', -1, DATE_TRUNC('YEAR', current_timestamp))
                              --End of last year
                            and dateadd('day',-1,DATE_TRUNC('YEAR', current_date))

                          {% elsif history_duration._parameter_value == "'Last 12 Months'"%}
                            dateadd('days', -365, current_timestamp) and current_timestamp

                          {% else %}
                              --Default to the last 30 days
                            dateadd('days', -30, current_timestamp) and current_timestamp

                          {% endif %}

                          and aa.COMPANY_ID = 1854
                          and aa.ASSET_TYPE_ID = 1
                          and aa.RENTAL_BRANCH_ID is not null
                          and d.delivery_date < d.rental_end
 ;;
    }

    dimension: asset_id {
      type: number
      value_format_name: id
      sql: ${TABLE}."ASSET_ID" ;;
    }

    dimension: wo_description {
      type: string
      sql: ${TABLE}."DESCRIPTION" ;;
    }

    dimension: wo_tags {
      type: string
      sql: ${TABLE}."TAGS" ;;
    }

    dimension: delivery_id {
      type: number
      value_format_name: id
      sql: ${TABLE}."DELIVERY_ID" ;;
    }

    dimension: rental_id {
      type: number
      value_format_name: id
      sql: ${TABLE}."RENTAL_ID" ;;
    }

    dimension: work_order_id {
      type: number
      value_format_name: id
      sql: ${TABLE}."WORK_ORDER_ID" ;;
    }

    dimension: work_order_type_name {
      type: string
      sql: ${TABLE}."WORK_ORDER_TYPE_NAME" ;;
    }

    dimension: work_order_status_name {
      type: string
      sql: ${TABLE}."WORK_ORDER_STATUS_NAME" ;;
    }

    dimension_group: delivery_date {
      type: time
      timeframes: [date, week, time, month]
      sql: CONVERT_TIMEZONE('America/Chicago', ${TABLE}."DELIVERY_DATE") ;;
    }

    dimension_group: work_order_date {
      type: time
      timeframes: [date, week, time, month]
      sql: CONVERT_TIMEZONE('America/Chicago', ${TABLE}."WO_DATE") ;;
    }

    dimension: work_order_branch_id {
      type: number
      value_format_name: id
      sql: ${TABLE}."BRANCH_ID" ;;
    }

    dimension_group: rental_start {
      type: time
      timeframes: [date, time, week, month]
      sql: CONVERT_TIMEZONE('America/Chicago', ${TABLE}."RENTAL_START") ;;
    }

    dimension_group: rental_end {
      type: time
      timeframes: [date, week, time, month]
      sql: CONVERT_TIMEZONE('America/Chicago', ${TABLE}."RENTAL_END") ;;
    }

  dimension: wo_within_24hr_flag {
    type: string
    value_format_name: id
    sql: ${TABLE}."WO_WITHIN_24HR" ;;
  }

# - - - - - MEASURES - - - - -

    measure: count {
      type: count_distinct
      drill_fields: [wo_detail*]
      sql: ${work_order_id} ;;
    }

  measure: wo_within_24hr {
    type: count
    filters: [wo_within_24hr_flag: "WO Within 24Hr"]
  }

  measure: no_wo_within_24hr {
    type: count
    filters: [wo_within_24hr_flag: "No WO Within 24Hr"]
  }

  measure: percent_within_24hr {
    type: number
    value_format_name: percent_2
    sql: ${wo_within_24hr} / (${wo_within_24hr} + ${no_wo_within_24hr}) ;;
  }

  measure: filtered_count {
    type: count_distinct
    drill_fields: [wo_detail*]
    sql: ${work_order_id} ;;
  }

    parameter: history_duration {
      type:  string
      allowed_value: { value: "Last 30 Days"}
      allowed_value: { value: "This Quarter"}
      allowed_value: { value: "Last Quarter"}
      allowed_value: { value: "This Year"}
      allowed_value: { value: "Last Year"}
      allowed_value: { value: "Last 12 Months"}
    }

# - - - - - SETS - - - - -

    set: wo_detail {
      fields: [
        work_orders.work_order_id_with_link_to_work_order,
        wo_description,
        wo_tags,
        asset_id,
        markets.name,
        work_order_status_name,
        work_order_type_name,
        delivery_date_time,
        work_order_date_time,
        rental_start_time,
        rental_end_time]
    }
  }
