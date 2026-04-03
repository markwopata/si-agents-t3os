view: construction_po_detail {

  derived_table: {
    sql:
      -- BvA PO Detail
      with po_union as (
        select
          market_id,
          market_name,
          document_type,
          document_number,
          line_description,
          project_id,
          project_code,
          division_code,
          division_name,
          account_number,
          account_name,
          entry_date as gl_date,
          'Paid' as po_status,
          actual_amount,
          0 as committed_amount
        from analytics.intacct_models.int_cip_actuals

      union all

      select
      market_id,
      department_name as market_name,
      document_type,
      document_number,
      line_description,
      -1 as project_id,
      'NO PROJECT' as project_code,
      division_code,
      division_name,
      account_number,
      account_name,
      gl_date,
      'Committed' as po_status,
      0 as actual_amount,
      committed_amount
      from analytics.intacct_models.int_cip_committed
      )

      select
      po.market_id,
      m.market_name,
      po.document_type,
      po.document_number,
      po.line_description,
      coalesce(po.project_id, -1) as project_id,
      coalesce(po.project_code, 'NO PROJECT') as project_code,
      po.division_code,
      po.division_name,
      po.account_number,
      po.account_name,
      po.gl_date,
      date_trunc('month', po.gl_date) as gl_month,
      to_char(po.gl_date, 'MMMM YYYY') as gl_month_label,
      po.po_status,
      po.actual_amount,
      po.committed_amount,
      coalesce(bu.budget_amount, 0) as budget_amount,
      coalesce(cd.nickname, cd.full_name) as cpm_name,
      cd.work_email as cpm_email
      from po_union po
      left join analytics.intacct_models.stg_es_warehouse_public__markets m
      on po.market_id = m.market_id
      left join analytics.intacct_models.int_cip_budgets bu
      on po.market_id   = bu.market_id
      and po.division_code = bu.division_code
      and po.project_id = bu.project_id
      left join analytics.intacct_models.stg_analytics_retool__cip_projects cp
      on po.project_id = cp.project_id
      left join analytics.payroll.stg_analytics_payroll__company_directory cd
      on cp.construction_project_manager_employee_id = cd.employee_id
      ;;
  }

  # =========================
  # Dimensions
  # =========================

  dimension: market_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.market_id ;;
    link: {
      label: "Budget vs Actual Detail"
      url: "@{db_construction_budget}?Market%20Name={{ market_name._filterable_value | url_encode }}"
    }
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}.market_name ;;
    link: {
      label: "Budget vs Actual Detail"
      url: "@{db_construction_budget}?Market%20Name={{ market_name._filterable_value | url_encode }}"
    }
  }

  dimension: document_type {
    type: string
    sql: ${TABLE}.document_type ;;
  }

  dimension: document_number {
    type: string
    sql: ${TABLE}.document_number ;;
  }

  dimension: line_description {
    type: string
    sql: ${TABLE}.line_description ;;
  }

  dimension: project_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.project_id ;;
  }

  dimension: project_code {
    type: string
    sql: ${TABLE}.project_code ;;
    link: {
      label: "Budget vs Actual Detail"
      url: "@{db_construction_budget}?Project%20Code={{ project_code._filterable_value | url_encode }}"
    }
  }

  dimension: division_code {
    type: string
    sql: ${TABLE}.division_code ;;
  }

  dimension: division_name {
    type: string
    sql: ${TABLE}.division_name ;;
    html: {% if value == 'UNCLASSIFIED' %} <span style="color: red;">{{ value }}</span> {% else %} {{ value }} {% endif %} ;;
  }

  dimension: account_number {
    type: string
    sql: ${TABLE}.account_number ;;
  }

  dimension: account_name {
    type: string
    sql: ${TABLE}.account_name ;;
  }

  dimension: po_status {
    type: string
    sql: ${TABLE}.po_status ;;
  }

  dimension: gl_date {
    type: date
    sql: ${TABLE}.gl_date ;;
  }

  dimension: gl_month {
    type: date
    label: "GL Month Raw"
    sql: ${TABLE}.gl_month ;;
  }

  dimension: gl_month_sort_desc {
    hidden: yes
    type: number
    sql: -1 * EXTRACT(EPOCH FROM ${TABLE}.gl_month) ;;
  }

  dimension: gl_month_label {
    type: string
    order_by_field: gl_month_sort_desc
    label: "GL Month"
    sql: ${TABLE}.gl_month_label ;;
  }

  dimension: cpm_name {
    type: string
    label: "CPM"
    sql: ${TABLE}.cpm_name ;;
  }

  dimension: cpm_email {
    type: string
    label: "CPM Email"
    sql: ${TABLE}.cpm_email ;;
  }


  dimension: actual_amount {
    type: number
    value_format: "$#,##0.00;($#,##0.00)"
    sql: ${TABLE}.actual_amount ;;
  }

  dimension: committed_amount {
    type: number
    value_format: "$#,##0.00;($#,##0.00)"
    sql: ${TABLE}.committed_amount ;;
  }

  dimension: budget_amount {
    type: number
    value_format: "$#,##0.00;($#,##0.00)"
    sql: ${TABLE}.budget_amount ;;
  }



  # =========================
  # Measures
  # =========================

  measure: spend_total {
    type: number
    sql: coalesce(${actual_amount} + ${committed_amount}, 0) ;;
    value_format: "$#,##0.00;($#,##0.00)"
  }

  measure: delta_to_budget {
    type: number
    label: "Delta (Budget - Spend)"
    sql: round(coalesce(${budget_amount} - ${spend_total}, 0), 2) ;;
    value_format: "$#,##0.00;($#,##0.00)"
  }

  # Convenience filtered measures
  measure: paid_actual_only {
    type: sum
    sql: coalesce(${TABLE}.actual_amount, 0) ;;
    value_format: "$#,##0.00;($#,##0.00)"
    filters: [po_status: "Paid"]
  }

  measure: committed_only {
    type: sum
    sql: coalesce(${TABLE}.committed_amount, 0) ;;
    value_format: "$#,##0.00;($#,##0.00)"
    filters: [po_status: "Committed"]
  }

  # Actuals by document type
  measure: actuals_po_only {
    type: sum
    label: "Actuals - Purchase Order"
    sql: coalesce(${TABLE}.actual_amount, 0) ;;
    value_format: "$#,##0.00;($#,##0.00)"
    filters: [document_type: "Purchase Order"]
  }

  measure: actuals_je_only {
    type: sum
    label: "Actuals - Journal Entry"
    sql: coalesce(${TABLE}.actual_amount, 0) ;;
    value_format: "$#,##0.00;($#,##0.00)"
    filters: [document_type: "Journal Entry"]
  }



}
