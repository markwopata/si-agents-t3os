include: "/_base/es_warehouse/work_orders/company_tags.view.lkml"

view: +company_tags {
  label: "Company Tags"

  measure: tags_list {
    type: list
    list_field: name #note this will include deleted tags unless they are excluded in the explore
  }
  }
