connection: "es_warehouse"

include: "/views/*.view.lkml"

explore: po_over_specified_amount {
  sql_always_where:
    {% if po_over_specified_amount.view_by._parameter_value == "'Date Created'" %}
      ${po_over_specified_amount.po_date_created} BETWEEN {% date_start po_over_specified_amount.date_filter %}::timestamp_ntz AND {% date_end po_over_specified_amount.date_filter %}::timestamp_ntz
    {% else %}
      ${po_over_specified_amount.date_received_date} BETWEEN {% date_start po_over_specified_amount.date_filter %}::timestamp_ntz AND {% date_end po_over_specified_amount.date_filter %}::timestamp_ntz
    {% endif %}
    AND {% condition po_over_specified_amount.cost_center_filter %} ${po_over_specified_amount.cost_center} {% endcondition %}
    AND {% condition po_over_specified_amount.region_filter %} ${po_over_specified_amount.region_name} {% endcondition %}
    -- etc.
  ;;
}

explore: category_spend_history {
  group_label: "Cost Capture"
  label: "Category Spend History"
  case_sensitive: no
  persist_for: "10 minutes"
}
