view: construction_budget {
  # Or, you could make this view a derived table, like this:
  derived_table: {
    sql:
      select
        bas.pk_id,
        bas.market_id,
        bas.market_name,
        bas.description,
        bas.project_status,
        bas.address,
        bas.project_id,
        bas.project_code,
        bas.is_active_project,
        bas.launch_phase,
        bas.url_drive,
        bas.close_date,
        bas.possession_date,
        bas.days_to_open,
        bas.days_to_completion,
        bas.bor_date,
        bas.target_construction_completion_date,
        bas.cpm_project_completion_date,
        bas.cpm,
        bas.cpm_hire_date,
        bas.division_code,
        bas.division_name,
        bas.actual_amount,
        bas.budget_amount,
        bas.committed_amount,
        bas.budget_delta
      from
        analytics.intacct_models.int_cip_budget_v_actual_summary bas
      ;;
  }


  dimension: pk_id {
    label: "Project - Market - Division Code"
    type: string
    primary_key: yes
    hidden: yes
    sql: ${TABLE}.pk_id ;;
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

  dimension: market_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.market_id ;;
    link: {
      label: "Budget vs Actual Detail"
      url: "@{db_construction_budget}?Project%20Code={{ project_code._filterable_value | url_encode }}"
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

  dimension: description {
    type: string
    sql: ${TABLE}.description ;;
    link: {
      label: "Budget vs Actual Detail"
    }
  }

  dimension: project_status {
    type: string
    sql: COALESCE(${TABLE}.project_status, 'Unassigned') ;;
    link: {
      label: "Project Status"
    }
  }



  dimension: is_active_project {
    type: string
    sql: ${TABLE}.is_active_project ;;
  }

  dimension: launch_phase {
    type: string
    sql: ${TABLE}.launch_phase ;;
  }

  dimension: address {
    type: string
    sql: ${TABLE}.address ;;
  }

  dimension: close_date {
    type: date
    sql: ${TABLE}.close_date ;;
  }

  dimension: url_drive {
    type: string
    label: "Links"
    sql: ${TABLE}.url_drive ;;
    html: <a href="{{value}}" target="_blank"><img src="https://ssl.gstatic.com/docs/doclist/images/drive_2022q3_32dp.png" width="16px" height="16px" /></a>
      {% if _user_attributes['email'] == "brian.coley@equipmentshare.com"
       or _user_attributes['email'] == "lydia.freeman@equipmentshare.com"
       or _user_attributes['email'] == "kinzie.leach@equipmentshare.com"
       or _user_attributes['email'] == "tiffany.goalder@equipmentshare.com"
       or _user_attributes['email'] == "hope.vaughn@equipmentshare.com"
       or _user_attributes['email'] == "kim.misher@equipmentshare.com"
       or _user_attributes['department'] contains 'developer'
       or _user_attributes['department'] contains 'admin'
      %}
      <a href = "https://equipmentshare.retool-hosted.com/app/cip-budget/classifyExpenses?market_id={{market_id._value}}" target="_blank">
        <img src="https://cdn.brandfetch.io/id3V8wH0I2/w/400/h/400/theme/dark/icon.png?c=1dxbfHSJFAPEGdCLU4o5B" width="16" height="16">
      </a>
    {% endif %}

    ;;
  }

  dimension: cpm_project_completion_date {
    type: date
    label: "CPM Project Completion Date"
    sql: ${TABLE}.cpm_project_completion_date ;;
  }

  dimension: days_to_completion {
    type: number
    label: "Days to Completion"
    sql: ${TABLE}.days_to_completion ;;
  }

  dimension: possession_date {
    type: date
    sql: ${TABLE}.possession_date ;;
  }

  dimension: bor_date {
    type: date
    label: "BOR Date"
    sql: ${TABLE}.bor_date ;;
  }

  dimension: target_construction_completion_date {
    type: date
    sql: ${TABLE}.target_construction_completion_date ;;
  }

  dimension: days_to_open {
    type: number
    label: "Days to Open"
    sql: ${TABLE}.days_to_open ;;
  }

  dimension: cpm {
    type: string
    label: "CPM"
    sql: ${TABLE}.cpm ;;
  }

  dimension: cpm_hire_date {
    type: date
    label: "CPM Hire Date"
    sql: ${TABLE}.cpm_hire_date ;;
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

  measure: budget_amount {
    type: sum_distinct
    sql: coalesce(${TABLE}.budget_amount, 0) ;;
    value_format: "$#,##0.00;($#,##0.00)"
  }

  measure: actual_amount {
    type: sum
    sql: coalesce(${TABLE}.actual_amount, 0) ;;
    value_format: "$#,##0.00;($#,##0.00)"
    drill_fields: [cip_expense_classifications.cip_expense_line_detail*]
  }

  measure: committed_amount {
    type: sum
    sql: coalesce(${TABLE}.committed_amount, 0) ;;
    value_format: "$#,##0.00;($#,##0.00)"
  }

  measure: delta {
    type: number
    sql: round(coalesce(${budget_amount} - ${actual_amount}, 0), 2) ;;
    value_format: "$#,##0.00;($#,##0.00)"
  }

measure: percent_projects_over_budget {
  type: number
  sql: (
    COUNT(DISTINCT CASE WHEN ${TABLE}.actual_amount > ${TABLE}.budget_amount
                        THEN ${TABLE}.project_id ELSE NULL END)
    * 1.0
    / NULLIF(COUNT(DISTINCT ${TABLE}.project_id), 0)
  ) ;;
  value_format_name: percent_2
}


  measure: percent_dollars_over_budget {
    type: number
    sql:
    CASE
      WHEN NULLIF(${budget_amount}, 0) IS NULL THEN NULL
      ELSE (${actual_amount} - ${budget_amount}) / NULLIF(${budget_amount}, 0)
    END ;;
    value_format_name: percent_2
  }


  measure: agg_percent_dollars_over_budget {
    type: number
    sql:
    CASE
      WHEN SUM(${TABLE}.budget_amount) = 0 THEN 1
      ELSE (SUM(${TABLE}.actual_amount) - SUM(${TABLE}.budget_amount))
           / SUM(${TABLE}.budget_amount)
    END
  ;;
    value_format_name: percent_2
  }



}
