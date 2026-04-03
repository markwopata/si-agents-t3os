view: beta_ccc_clustering {
  derived_table: {
    sql:
with ccc_date as (
select
    ccl.work_order_id,
    ccl.description,
    ccsl.cluster_label_id,
    ccsl.cluster_label,
    ccsl.cluster_group
from data_science.wokb.ccc_cluster_labels ccl
join data_science.wokb.ccc_cluster_string_labels ccsl
    on ccl.cluster_label_id = ccsl.cluster_label_id and ccl.model_version = ccsl.model_version and ccl.description = ccsl.description
where ccl.model_version = (select max(model_version) from data_science.wokb.ccc_cluster_labels)
)

select wo.work_order_id
    --complaint
    , cpt.cluster_label_id as complaint_cluster_label_id
    , cpt.cluster_group as complaint_group
    --cause
    , cause.cluster_label_id as cause_cluster_label_id
    , cause.cluster_group as cause_group
    --correction
    , cor.cluster_label_id as correction_cluster_label_id
    , cor.cluster_group as correction_group
from ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS wo
left join ccc_date cpt
    on cpt.work_order_id = wo.work_order_id
        and cpt.description = 'complaint'
left join ccc_date cause
    on cause.work_order_id = wo.work_order_id
        and cause.description = 'cause'
left join ccc_date cor
    on cor.work_order_id = wo.work_order_id
        and cor.description = 'correction'
where coalesce(coalesce(cpt.work_order_id, cause.work_order_id), cor.work_order_id) is not null ;;
  }

dimension: work_order_id {
  type: number
  value_format_name: id
  primary_key: yes
  sql: ${TABLE}.work_order_id ;;
}

dimension: complaint_group {
  type: string
  sql: ${TABLE}.complaint_group ;;
}

dimension: cause_group {
  type: string
  sql: ${TABLE}.cause_group ;;
}

dimension: correction_group {
  type: string
  sql: ${TABLE}.correction_group ;;
}
}
