view: sales_goals_rental {
  derived_table: {
    sql:
    WITH tam_goals AS (
    SELECT g.year,
        g.month,
        g.tam_user_id,
        concat(u.first_name,' ',u.last_name,' - ',cd.employee_id) as territory_account_manager,
        u.email_address as tam_email,
        split_part(cd.DEFAULT_COST_CENTERS_FULL_PATH, '/', 3) as tam_district,
        COALESCE(tgc.monthly_rental_revenue, 0) as monthly_rental_revenue,
        COALESCE(tgc.last_MTD_rental_revenue, 0) as last_MTD_rental_revenue,
        g.tam_goal_id,
        DATE_TRUNC('day', CONVERT_TIMEZONE('America/Chicago', g.date_created) ) AS date_goal_created,
        g.revenue_goal,


        FROM analytics.bi_ops.tam_goals g
        left join es_warehouse.public.users u on u.user_id = g.tam_user_id
        left join analytics.payroll.COMPANY_DIRECTORY cd on lower(cd.WORK_EMAIL) = lower(u.EMAIL_ADDRESS)
        left join analytics.bi_ops.tam_goals_current tgc ON tgc.tam_user_id = g.tam_user_id
        WHERE g.year <= YEAR(CONVERT_TIMEZONE('America/Chicago', CURRENT_TIMESTAMP()))
           AND g.month <= MONTH(CONVERT_TIMEZONE('America/Chicago', CURRENT_TIMESTAMP()))
        QUALIFY ROW_NUMBER() OVER(PARTITION BY g.tam_user_id ORDER BY g.date_created desc) = 1 )
    select *
    from tam_goals
    WHERE
           (
            ('salesperson' = {{ _user_attributes['department'] }} AND tam_email ILIKE '{{ _user_attributes['email'] }}')
           )
           OR
           (
            ('salesperson' != {{ _user_attributes['department'] }}
             AND
             ('developer' = {{ _user_attributes['department'] }}
              OR 'god view' = {{ _user_attributes['department'] }}
              OR 'managers' = {{ _user_attributes['department'] }}
              OR 'finance' = {{ _user_attributes['department'] }}
             )
            )
           );;
  }

    measure: count {
      type: count
      drill_fields: [detail*]
    }

   dimension: pk {
     type: string
     primary_key: yes
     sql: CONCAT(${tam_user_id},'-',${year},'-',${month});;
   }

    dimension: tgc_id {
      type: number
      sql: ${TABLE}."TGC_ID" ;;
    }

    dimension: tam_goal_id {
      type: number
      sql: ${TABLE}."TAM_GOAL_ID" ;;
    }

    dimension_group: date_goal_created {
      type: time
      sql: ${TABLE}."DATE_GOAL_CREATED" ;;
    }

    dimension: year {
      type: number
      sql: ${TABLE}."YEAR" ;;
    }

    dimension: month {
      type: number
      sql: ${TABLE}."MONTH" ;;
    }

    dimension: tam_user_id {
      type: number
      sql: ${TABLE}."TAM_USER_ID" ;;
    }

    dimension: territory_account_manager {
      type: string
      sql: ${TABLE}."TERRITORY_ACCOUNT_MANAGER" ;;
    }

    dimension: tam_name_user_id {
      type: string
      sql: CONCAT(LEFT(${territory_account_manager}, LEN(${territory_account_manager}) - CHARINDEX('-', REVERSE(${territory_account_manager}))), '- ', ${tam_user_id});;
    }

    dimension: tam_email {
      type: string
      sql: ${TABLE}."TAM_EMAIL" ;;
    }

    dimension: revenue_goal {
      type: number
      sql: ${TABLE}."REVENUE_GOAL" ;;
    }

    dimension: tam_district {
      type: string
      sql: ${TABLE}."TAM_DISTRICT";;
    }

    dimension: monthly_rental_revenue {
      type: number
      sql: ${TABLE}."MONTHLY_RENTAL_REVENUE" ;;
    }

    dimension: last_MTD_rental_revenue {
      type: number
      sql: ${TABLE}."LAST_MTD_RENTAL_REVENUE" ;;
    }

    measure: goal {
      type: sum
      value_format_name: usd_0
      sql: ${revenue_goal} ;;
    }

   measure: rental_revenue {
     type: sum
     value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
     sql: ${monthly_rental_revenue} ;;
   }

    measure: rental_revenue_kpi {
      type: number
      value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
      sql: ${rental_revenue} ;;
      html:
      <div style="border-radius: 5px;">
        <div style="display: inline-block; padding-bottom: 20px;">
          <a href="#drillmenu" target="_self"><font color="#000000">
            <p style="font-size: 1.25rem;">MTD Rental Revenue</p>
            <p style="font-size: 2rem;">{{rendered_value}}</p>
          </a>
        </div>
        <div style="display: inline-block; border-left: .5px solid #DCDCDC; padding-left: 10px;">
          <p style="font-size: 1.25rem;">vs Last Year MTD </p>
          <p style="font-size: 2rem;">
            {% if last_year_MTD_rental_revenue._value >= 1000000 %}
              <font color="#00CB86">
              <strong>↑{{last_year_MTD_rental_revenue_M._rendered_value}}</strong></font>
            {% elsif last_year_MTD_rental_revenue._value >= 1000 %}
              <font color="#00CB86">
              <strong>↑{{last_year_MTD_rental_revenue_K._rendered_value}}</strong></font>
            {% elsif last_year_MTD_rental_revenue._value >= 0 %}
              <font color="#00CB86">
              <strong>↑{{last_year_MTD_rental_revenue._rendered_value}}</strong></font>
            {% elsif last_year_MTD_rental_revenue._value <= -1000000 %}
              <font color="#DA344D">
              <strong>↓{{last_year_MTD_rental_revenue_M._rendered_value}}</strong></font>
            {% elsif goal_diff._value <= -1000 %}
              <font color="#DA344D">
              <strong>↓{{last_year_MTD_rental_revenue_K._rendered_value}}</strong></font>
            {% else %}
              <font color="#DA344D">
              <strong>↓{{last_year_MTD_rental_revenue._rendered_value}}</strong></font>
            {% endif %}
          </p>
        </div>
      </div>;;
      drill_fields: [company_detail*]
    }

    measure: remaining_to_goal {
      type: number
      value_format_name: usd_0
      sql: case when ${goal} - ${rental_revenue} < 0 then null
                else ${goal} - ${rental_revenue} end;;
    }

    measure: rental_revenue_goal_met {
      type: number
      value_format_name: usd_0
      sql:  case when SUM(${revenue_goal}) IS NULL then null
                 when ${goal} - ${rental_revenue} <= 0 then ${rental_revenue}
                 else null end;;
    }

    measure: rental_revenue_goal_unmet {
      type: number
      value_format_name: usd_0
      sql:  case when SUM(${revenue_goal}) IS NULL then null
                 when  ${goal} - ${rental_revenue} > 0 then ${rental_revenue}
                 else null end;;
    }

    measure: rental_revenue_no_goal {
      type: number
      value_format_name: usd_0
      sql: case when SUM(${revenue_goal}) IS NULL then ${rental_revenue}
                else null end;;
    }

    measure: percent_of_goal {
      type: number
      value_format: "0.0%"
      sql: ${rental_revenue} / ${goal} ;;
    }

    measure: goal_diff {
      type: number
      value_format: "$0"
      sql: ${rental_revenue} - ${goal};;
    }

    measure: goal_diff_K {
      type: number
      value_format: "$0.00,\" K\""
      sql: ${rental_revenue} - ${goal};;
    }

    measure: goal_diff_M {
      type: number
      value_format: "$0.00,,\" M\""
      sql: ${rental_revenue} - ${goal};;
    }

    measure: last_year_MTD_rental_revenue {
      type: sum
      value_format_name: usd_0
      sql: ${last_MTD_rental_revenue} ;;
    }

    measure: last_year_MTD_rental_revenue_K {
      type: number
      value_format: "$0.00,\" K\""
      sql: ${last_year_MTD_rental_revenue} ;;
    }

    measure: last_year_MTD_rental_revenue_M {
      type: number
      value_format: "$0.00,,\" M\""
      sql: ${last_year_MTD_rental_revenue} ;;
    }

    measure: goal_kpi {
      type: number
      sql: ${goal};;
      value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
      html:
      <div style="border-radius: 5px;">
        <div style="display: inline-block; padding-bottom: 20px;">
            <p style="font-size: 1.25rem;">Rental Revenue Goal</p>
            <p style="font-size: 2rem;">{{rendered_value}}</p>
        </div>
        <div style="display: inline-block; border-left: .5px solid #DCDCDC; padding-left: 10px;">
            <p style="font-size: 1.25rem;">Revenue vs Goal</p>
            <p style="font-size: 2rem;">
              {% if goal_diff._value >= 1000000 %}
                <font color="#00CB86">
                <strong>↑{{goal_diff_M._rendered_value}}</strong></font>
              {% elsif goal_diff._value >= 1000 %}
                <font color="#00CB86">
                <strong>↑{{goal_diff_K._rendered_value}}</strong></font>
              {% elsif goal_diff._value >= 0 %}
                <font color="#00CB86">
                <strong>↑{{goal_diff._rendered_value}}</strong></font>
              {% elsif goal_diff._value <= -1000000 %}
                <font color="#DA344D">
                <strong>↓{{goal_diff_M._rendered_value}}</strong></font>
              {% elsif goal_diff._value <= -1000 %}
                <font color="#DA344D">
                <strong>↓{{goal_diff_K._rendered_value}}</strong></font>
              {% else %}
                <font color="#DA344D">
                <strong>↓{{goal_diff._rendered_value}}</strong></font>
              {% endif %}
            </p>
        </div>
      </div>;;
    }

    set: detail {
      fields: [
        tgc_id,
        tam_goal_id,
        date_goal_created_time,
        year,
        month,
        tam_user_id,
        territory_account_manager,
        tam_email,
        tam_district,
        revenue_goal,
        monthly_rental_revenue,
        last_year_MTD_rental_revenue
      ]
    }

  set: company_detail {
    fields: [
      territory_account_manager,
      tam_monthly_rr_by_company.company,
      tam_monthly_rr_by_company.rental_revenue_by_company
    ]
  }
  }
