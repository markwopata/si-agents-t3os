include: "/_base/es_warehouse/work_orders/work_order_files.view.lkml"

view: +work_order_files {
  label: "Work Order Files"

  measure: images_attached {
    type: count_distinct
    sql: iff(${url} ilike any ('%.jpeg','%.png'),${work_order_file_id},null) ;;
  }
}
