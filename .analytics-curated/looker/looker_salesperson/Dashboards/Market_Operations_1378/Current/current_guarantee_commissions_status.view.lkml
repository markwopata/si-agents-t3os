view: current_guarantee_commissions_status {
    derived_table: {
      sql: select * from analytics.bi_ops.guarantees_commissions_status
        where row_num = 1 and direct_manager IS NOT NULL ;;
    }

    measure: count {
      type: count
      drill_fields: [detail*]
    }

    dimension: salesperson_user_id {
      type: string
      sql: ${TABLE}."SALESPERSON_USER_ID" ;;
    }

    dimension: name {
      type: string
      sql: ${TABLE}."NAME" ;;
    }

    dimension: rep {
      type: string
      sql: ${TABLE}."REP" ;;
    }

    dimension: direct_manager {
      type: string
      sql: ${TABLE}."DIRECT_MANAGER" ;;
    }

    dimension: current_home_market {
      type: string
      sql: ${TABLE}."CURRENT_HOME_MARKET" ;;
    }

    dimension: current_home_market_id {
      type: string
      sql: ${TABLE}."CURRENT_HOME_MARKET_ID" ;;
    }

    dimension: new_sp_flag_current {
      type: string
      sql: ${TABLE}."NEW_SP_FLAG_CURRENT" ;;
    }

    dimension: commission_type {

      type: string
      sql: ${TABLE}."COMMISSION_TYPE" ;;
    }

    dimension: guarantee_amount {
      type: number
      sql: ${TABLE}."GUARANTEE_AMOUNT" ;;
      value_format_name: usd_0
    }

    dimension_group: guarantee_start_date {
      type: time
      sql: ${TABLE}."GUARANTEE_START_DATE" ;;
    }

    dimension_group: guarantee_end_date {
      type: time
      sql: ${TABLE}."GUARANTEE_END_DATE" ;;
    }

    dimension_group: g_end {
      type: time
      sql: ${TABLE}."G_END" ;;
    }

    dimension: contract_months_of_guarantee {
      type: number
      sql: ${TABLE}."CONTRACT_MONTHS_OF_GUARANTEE" ;;
    }

    dimension: current_months_of_guarantee {
      type: number
      sql: ${TABLE}."CURRENT_MONTHS_OF_GUARANTEE" ;;
    }


    dimension: current_guarantee_status {
      group_label: "Guarantee Info"
      type: string
      sql: ${TABLE}."CURRENT_GUARANTEE_STATUS" ;;
      html:
          {% if value == 'Commission' %}
          <font color="#000000 "> {{rendered_value}}
           {% elsif value == 'On Guarantee' %}
           <font color="#000000"><strong>{{rendered_value}}</strong></font>
          {% endif %}
          <br />
          <font style="color: #8C8C8C; text-align: right;">Commission Start Date: {{ commission_start_date_date._rendered_value }} </font>
        ;;
    }

    dimension: guarantee_status {
      group_label: "Guarantee Info"
      type: string
      sql: ${TABLE}."CURRENT_GUARANTEE_STATUS" ;;
      html:
          {% if value == 'Commission' %}
          <font color="#000000 "> {{rendered_value}}
          {% elsif value == 'On Guarantee' %}
          <font color="#000000"><strong>{{rendered_value}}</strong></font>
          {% endif %};;
    }


    dimension_group: commission_start_date {
      type: time
      sql: ${TABLE}."COMMISSION_START_DATE" ;;
    }

    dimension_group: commission_end_date {
      type: time
      sql: ${TABLE}."COMMISSION_END_DATE" ;;
    }

    dimension_group: payroll_guarantee_end_date {
      type: time
      sql: ${TABLE}."PAYROLL_GUARANTEE_END_DATE" ;;
    }

    dimension_group: payroll_commission_start_date {
      type: time
      sql: ${TABLE}."PAYROLL_COMMISSION_START_DATE" ;;
    }


    dimension: employee_title {
      type: string
      sql: ${TABLE}."EMPLOYEE_TITLE" ;;
    }

    dimension: terminated_date {
      type: string
      sql: ${TABLE}."TERMINATED_DATE" ;;
    }

    dimension: hire_rehire_date {
      type: string
      sql: ${TABLE}."HIRE_REHIRE_DATE" ;;
    }

    dimension: sp_first_name {
      hidden: yes
      sql: LEFT(${name}, POSITION(' ' IN ${name}) - 1);;
    }
    dimension: sp_last_name {
      hidden: yes
      sql: TRIM(SUBSTRING(${name}, POSITION(' ' IN ${name}) + 1)) ;;
    }

    dimension: lifetime_guarantee_months {
      type: number
      sql: ${TABLE}."LIFETIME_GUARANTEE_MONTHS" ;;
    }


    set: detail {
      fields: [
        salesperson_user_id,
        name,
        rep,
        direct_manager,
        current_home_market,
        current_home_market_id,
        new_sp_flag_current,
        commission_type,
        guarantee_amount
      ]
    }
  }
