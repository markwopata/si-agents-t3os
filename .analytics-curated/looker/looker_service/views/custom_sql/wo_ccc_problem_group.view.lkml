view: wo_ccc_problem_group {
  derived_table: {
    sql:
    with ccc_model_version as (
    select
        max(model_version)
    from data_science.wokb.ccc_cluster_labels
    )

    ,ccc_date as (
    select
        ccl.work_order_id,
        ccl.description,
        ccsl.cluster_label_id,
        ccsl.cluster_label,
        ccsl.cluster_group
    from data_science.wokb.ccc_cluster_labels ccl
    join data_science.wokb.ccc_cluster_string_labels ccsl
        on ccl.cluster_label_id = ccsl.cluster_label_id and ccl.model_version = ccsl.model_version and ccl.description = ccsl.description
    where ccl.model_version = (select * from ccc_model_version)
    )

    select
        wo.work_order_id,
        cd_complaint.cluster_label as complaint,
        cd_complaint.cluster_group as complaint_group,
        cd_cause.cluster_label as cause,
        cd_cause.cluster_group as cause_group,
        cd_correction.cluster_label as correction,
        cd_correction.cluster_group as correction_group,
        case
            when cause_group = correction_group then correction_group
            when cause_group = 'UNINFORMATIVE' then correction_group
            when correction_group = 'UNINFORMATIVE' then cause_group
            when correction_group ='OTHER' and cause_group not in ('OTHER','UNINFORMATIVE') and cause_group is not null then cause_group
            else coalesce(correction_group,cause_group,complaint_group)
        end as problem_group
    from es_warehouse.work_orders.work_orders wo
    left join ccc_date cd_complaint
        on wo.work_order_id = cd_complaint.work_order_id and cd_complaint.description = 'complaint'
    left join ccc_date cd_cause
        on wo.work_order_id = cd_cause.work_order_id and cd_cause.description = 'cause'
    left join ccc_date cd_correction
        on wo.work_order_id = cd_correction.work_order_id and cd_correction.description = 'correction';;
  }
  dimension: work_order_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_ID" ;;
    value_format_name: id
  }
  dimension: complaint {
    type: string
    sql: ${TABLE}."COMPLAINT" ;;
  }
  dimension: complaint_group {
    type: string
    sql: ${TABLE}."COMPLAINT_GROUP" ;;
  }
  dimension: cause {
    type: string
    sql: ${TABLE}."CAUSE" ;;
  }
  dimension: cause_group {
    type: string
    sql: ${TABLE}."CAUSE_GROUP" ;;
  }
  dimension: correction {
    type: string
    sql: ${TABLE}."CORRECTION" ;;
  }
  dimension: correction_group {
    type: string
    sql: ${TABLE}."CORRECTION_GROUP" ;;
  }
  dimension: problem_group {
    type: string
    sql: ${TABLE}."PROBLEM_GROUP" ;;
  }
}
