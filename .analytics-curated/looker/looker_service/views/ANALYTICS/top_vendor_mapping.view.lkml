view: top_vendor_mapping {
  derived_table: {
    sql:
    select v.vendorid
      , coalesce(tvm.vendor_name, v.name) as vendor_name
      , tvm.mapped_vendor_name
      , iff(tvm.mapped_vendor_name is not null, true, false) MAPPED
      , tvm.primary_vendor
      , tvm.category
      , tvm.PREFERRED
      , tvm.vendor_type
      , tvm.vendor_type_2
      , tvm.responsible_ssm
      , v.vendor_category as sage_vendor_category
      , tvm.savings_
      , tvm.avoidance_
    from "ANALYTICS"."INTACCT"."VENDOR" v
    left join "ANALYTICS"."PARTS_INVENTORY"."TOP_VENDOR_MAPPING" tvm
      on tvm.vendorid = v.vendorid ;;
  }
  # sql_table_name: "ANALYTICS"."PARTS_INVENTORY"."TOP_VENDOR_MAPPING" ;;
  dimension: vendor_name {
    type: string
    sql: ${TABLE}."VENDOR_NAME" ;;
  }

  dimension: mapped_vendor_name {
    type: string
    sql: ${TABLE}."MAPPED_VENDOR_NAME" ;;
  }

  dimension: vendorid {
    type: string
    #primary_key: yes
    sql: ${TABLE}."VENDORID" ;;
  }

  dimension: full_vendor_name {
    type: string
    sql: concat(${vendorid}, ' ', ${vendor_name}) ;;
  }

  dimension: MAPPED {
    type: yesno
    sql: ${TABLE}.mapped ;;
  }

  dimension: primary_vendor {
    type: yesno
    sql: case
      when ${TABLE}.primary_vendor = 'YES' then true
      else false end;;
  }

  dimension: tier {
    type: string
    sql: ${TABLE}.category ;;
  }

  dimension: category {
    type: string
    sql: ${TABLE}.category ;;
  }

  dimension: preferred {
    type: string
    sql: ${TABLE}.preferred ;;
  }

  dimension: vendor_type {
    type: string
    sql: ${TABLE}.vendor_type ;;
  }

  dimension: vendor_type_2 {
    type: string
    sql: ${TABLE}.vendor_type_2 ;;
  }

  dimension: responsible_ssm {
    type: string
    sql: ${TABLE}.responsible_ssm ;;
  }

  dimension: sage_vendor_category {
    type: string
    sql: ${TABLE}.sage_vendor_category ;;
  }

  parameter: drop_down_selection {
    type: string
    allowed_value: { value: "Vendor Name"}
    allowed_value: { value: "Mapped Vendor Name"}
    allowed_value: { value: "Preferred"}
    allowed_value: { value: "Category"}
    allowed_value: { value: "Vendor Type"}
    allowed_value: { value: "Sage Vendor Category"}
    allowed_value: { value: "Responsible SSM"}
  }

  dimension: dynamic_axis {
    label_from_parameter: drop_down_selection
    sql:
    {% if drop_down_selection._parameter_value == "'Vendor Name'" %}
      ${vendor_name}
    {% elsif drop_down_selection._parameter_value == "'Mapped Vendor Name'" %}
      ${mapped_vendor_name}
    {% elsif drop_down_selection._parameter_value == "'Category'" %}
      ${category}
    {% elsif drop_down_selection._parameter_value == "'Preferred'" %}
      ${preferred}
    {% elsif drop_down_selection._parameter_value == "'Vendor Type'" %}
      ${vendor_type}
    {% elsif drop_down_selection._parameter_value == "'Sage Vendor Category'" %}
      ${sage_vendor_category}
    {% elsif drop_down_selection._parameter_value == "'Responsible SSM'" %}
      ${responsible_ssm}
    {% else %}
      NULL
    {% endif %} ;;
  }

  dimension: dynamic_axis_for_spend_chart {
    label_from_parameter: drop_down_selection
    sql:
    {% if drop_down_selection._parameter_value == "'Vendor Name'" %}
      concat(${vendorid}, ' - ', ${vendor_name})
    {% elsif drop_down_selection._parameter_value == "'Mapped Vendor Name'" %}
      ${mapped_vendor_name}
    {% elsif drop_down_selection._parameter_value == "'Category'" %}
      ${category}
    {% elsif drop_down_selection._parameter_value == "'Preferred'" %}
      ${preferred}
    {% elsif drop_down_selection._parameter_value == "'Vendor Type'" %}
      ${vendor_type}
    {% elsif drop_down_selection._parameter_value == "'Sage Vendor Category'" %}
      ${sage_vendor_category}
    {% elsif drop_down_selection._parameter_value == "'Responsible SSM'" %}
      ${responsible_ssm}
    {% else %}
      NULL
    {% endif %} ;;
  }

  dimension: dynamic_vendor_type {
    type: string
    sql:
    {% if vendor_type._in_query %}
      ${vendor_type_2}
    {% else %}
      ${vendor_type}
      {% endif %};;
  }

  dimension: savings_percentage {
    type: number
    value_format_name: percent_2
    sql: ${TABLE}.savings_ ;;
  }

  dimension: avoidance_percentage {
    type: number
    value_format_name: percent_2
    sql: ${TABLE}.avoidance_ ;;
  }
}
