view: tech_wos_completed {
    derived_table:{
      sql:  select c.user_id,
        wo.*
        from "ES_WAREHOUSE"."WORK_ORDERS"."WORK_ORDERS" wo
        inner join  ES_WAREHOUSE.PUBLIC.COMMAND_AUDIT C --may need to adjust this due to WOs opening/closing repeatedly, WO date_completed= CA update?
        on wo.work_order_id=c.parameters:work_order_id
        and to_date(wo.date_completed)=to_date(c.date_created)
        where C.COMMAND ='CloseWorkOrder'
        group by c.user_id
        ;;

    }
    drill_fields: []

 dimension: tech_id {
   type: string
  sql: ${TABLE}.user_id ;;
 }
   # dimension: wo_id {
    #  type: string
     # sql: ${TABLE}.work_order_id ;;
    #}

   # dimension: severity {
     # type: string
     # sql: ${TABLE}.severity_level_name ;;
    #}
   # dimension: description {
    #  type: string
     # sql: ${TABLE}.description ;;
    #}
   # dimension_group: completed {
    #  type: time
     # timeframes: [date,week, month,year]
     # sql: convert_timezone('America/Chicago',${TABLE}.date_completed);;
    #}
    measure: wo_closures {
      type: count_distinct
      sql: ${TABLE}.work_order_id ;;
    }

    set: detail {
      fields: []
    }
  }
