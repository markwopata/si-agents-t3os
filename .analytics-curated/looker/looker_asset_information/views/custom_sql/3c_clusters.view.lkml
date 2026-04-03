view: 3c_clusters {
  # Or, you could make this view a derived table, like this:
  derived_table: {
    sql:
select wo.asset_id,
       wo.WORK_ORDER_ID,
       coalesce(act.complaint,woccc.COMPLAINT) complaint,
       coalesce(act.cause,woccc.CAUSE) cause,
       coalesce(act.correction,woccc.CORRECTION) correction,
       iff(act.work_order_id is not null, 'user_input', woccc.EXTRACTION_TYPE) extraction_type,
       iff(act.work_order_id is not null, act.created_at, woccc.EXTRACTION_DATE) extraction_date
from ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS                               as wo
left join DATA_SCIENCE.WOKB.FRESH_CCCS                                       as woccc
    on wo.WORK_ORDER_ID = woccc.WORK_ORDER_ID
    left join (select woc.work_order_id, ccc.*
from SAASY.PUBLIC.CCCS woc
join SAASY.PUBLIC.CCC_ENTRIES ccc
on woc.ccc_id=ccc.ccc_id
qualify row_number() over (partition by work_order_id order by ccc.created_at desc)=1) act
on wo.work_order_id=act.work_order_id
;;
  }

  # Define your dimensions and measures here, like this:
  dimension: work_order_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."WORK_ORDER_ID"  ;;
  }
  dimension: complaint {
    type: string
    sql: COALESCE(${TABLE}."COMPLAINT",'Not Reported') ;;
  }
  dimension: cause {
    type: string
    sql: COALESCE(${TABLE}."CAUSE",'Not Reported') ;;
  }
  dimension: correction {
    type: string
    sql: COALESCE(${TABLE}."CORRECTION",'Not Reported') ;;
  }
}
