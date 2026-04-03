view: revmodel_market_rollout_market_age_card {
  derived_table: {
    sql:
      with revmodel as (
        select
          r.market_id,
          r.market_level,
          r.market_name,
          r.branch_earnings_start_month
        from analytics.gs.revmodel_market_rollout_conservative r
      ),
      revenue_by_month as (
        select
          coalesce(pm.parent_market_id, ir.market_id) as rollup_market_id,
          date_trunc(month, ir.gl_date::date) as revenue_month,
          sum(ir.amount) as revenue_amount
        from analytics.intacct_models.int_revenue ir
        left join analytics.branch_earnings.parent_market pm
          on ir.market_id::text = pm.market_id::text
          and date_trunc(month, ir.gl_date::date) >= date_trunc(month, pm.start_date::date)
          and date_trunc(month, ir.gl_date::date) <= coalesce(date_trunc(month, pm.end_date::date), '2099-12-31')
        where not ir.is_intercompany
          and ir.is_rental_revenue
        group by all
      ),
      goals_by_month as (
        select
          coalesce(pm.parent_market_id, mg.market_id) as rollup_market_id,
          date_trunc(month, mg.months::date) as goal_month,
          sum(mg.revenue_goals) as revenue_goal
        from analytics.public.market_goals mg
        left join analytics.branch_earnings.parent_market pm
          on mg.market_id::text = pm.market_id::text
          and date_trunc(month, mg.months::date) >= date_trunc(month, pm.start_date::date)
          and date_trunc(month, mg.months::date) <= coalesce(date_trunc(month, pm.end_date::date), '2099-12-31')
        where date_trunc(month, mg.months::date) >= date_trunc(month, mg.start_date::date)
          and date_trunc(month, mg.months::date) <= coalesce(date_trunc(month, mg.end_date::date), '2099-12-31')
        group by all
      ),
      rollup_markets as (
        select
          r.market_id,
          r.market_level,
          r.market_name,
          r.branch_earnings_start_month,
          coalesce(pm.parent_market_id, r.market_id) as rollup_market_id
        from revmodel r
        left join analytics.branch_earnings.parent_market pm
          on r.market_id::text = pm.market_id::text
          and date_trunc(month, r.branch_earnings_start_month::date) >= date_trunc(month, pm.start_date::date)
          and date_trunc(month, r.branch_earnings_start_month::date) <= coalesce(date_trunc(month, pm.end_date::date), '2099-12-31')
      )
      select
        r.market_id,
        r.market_level,
        r.market_name,
        r.branch_earnings_start_month,
        dateadd(month, 2, r.branch_earnings_start_month::date) as month_three_open_date,
        dateadd(month, 5, r.branch_earnings_start_month::date) as month_six_open_date,
        dateadd(month, 8, r.branch_earnings_start_month::date) as month_nine_open_date,
        dateadd(month, 11, r.branch_earnings_start_month::date) as month_twelve_open_date,
        case
          when max(case
            when rev.revenue_month = date_trunc(month, dateadd(month, 2, r.branch_earnings_start_month::date))
              then rev.revenue_amount
          end) is null
            or max(case
              when goal.goal_month = date_trunc(month, dateadd(month, 2, r.branch_earnings_start_month::date))
                then goal.revenue_goal
            end) is null then null
          when max(case
            when rev.revenue_month = date_trunc(month, dateadd(month, 2, r.branch_earnings_start_month::date))
              then rev.revenue_amount
          end) >= max(case
            when goal.goal_month = date_trunc(month, dateadd(month, 2, r.branch_earnings_start_month::date))
              then goal.revenue_goal
          end) then 1
          else 0
        end as goal_met_month3,
        case
          when max(case
            when rev.revenue_month = date_trunc(month, dateadd(month, 5, r.branch_earnings_start_month::date))
              then rev.revenue_amount
          end) is null
            or max(case
              when goal.goal_month = date_trunc(month, dateadd(month, 5, r.branch_earnings_start_month::date))
                then goal.revenue_goal
            end) is null then null
          when max(case
            when rev.revenue_month = date_trunc(month, dateadd(month, 5, r.branch_earnings_start_month::date))
              then rev.revenue_amount
          end) >= max(case
            when goal.goal_month = date_trunc(month, dateadd(month, 5, r.branch_earnings_start_month::date))
              then goal.revenue_goal
          end) then 1
          else 0
        end as goal_met_month6,
        case
          when max(case
            when rev.revenue_month = date_trunc(month, dateadd(month, 8, r.branch_earnings_start_month::date))
              then rev.revenue_amount
          end) is null
            or max(case
              when goal.goal_month = date_trunc(month, dateadd(month, 8, r.branch_earnings_start_month::date))
                then goal.revenue_goal
            end) is null then null
          when max(case
            when rev.revenue_month = date_trunc(month, dateadd(month, 8, r.branch_earnings_start_month::date))
              then rev.revenue_amount
          end) >= max(case
            when goal.goal_month = date_trunc(month, dateadd(month, 8, r.branch_earnings_start_month::date))
              then goal.revenue_goal
          end) then 1
          else 0
        end as goal_met_month9,
        case
          when max(case
            when rev.revenue_month = date_trunc(month, dateadd(month, 11, r.branch_earnings_start_month::date))
              then rev.revenue_amount
          end) is null
            or max(case
              when goal.goal_month = date_trunc(month, dateadd(month, 11, r.branch_earnings_start_month::date))
                then goal.revenue_goal
            end) is null then null
          when max(case
            when rev.revenue_month = date_trunc(month, dateadd(month, 11, r.branch_earnings_start_month::date))
              then rev.revenue_amount
          end) >= max(case
            when goal.goal_month = date_trunc(month, dateadd(month, 11, r.branch_earnings_start_month::date))
              then goal.revenue_goal
          end) then 1
          else 0
        end as goal_met_month12
      from rollup_markets r
      left join revenue_by_month rev
        on rev.rollup_market_id = r.rollup_market_id
      left join goals_by_month goal
        on goal.rollup_market_id = r.rollup_market_id
      group by 1, 2, 3, 4, 5, 6, 7, 8
      ;;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}.market_id ;;
    primary_key: yes
  }

  dimension: market_level {
    type: number
    sql: ${TABLE}.market_level ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}.market_name ;;
  }

  dimension_group: branch_earnings_start_month {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.branch_earnings_start_month ;;
  }

  dimension: branch_earnings_date_formatted {
    type: string
    label: "Branch Earnings Start Month"
    sql: to_char(${TABLE}.branch_earnings_start_month::date, 'MMMM yyyy') ;;
  }

  dimension: months_open {
    type: number
    sql: datediff(months, ${TABLE}.branch_earnings_start_month::date, current_date) ;;
  }

  dimension: month_three_open {
    label: "Market Month 3"
    type: string
    sql: to_char(${TABLE}.month_three_open_date::date, 'MMMM yyyy') ;;
  }

  dimension: month_six_open {
    label: "Market Month 6"
    type: string
    sql: to_char(${TABLE}.month_six_open_date::date, 'MMMM yyyy') ;;
  }

  dimension: month_nine_open {
    label: "Market Month 9"
    type: string
    sql: to_char(${TABLE}.month_nine_open_date::date, 'MMMM yyyy') ;;
  }

  dimension: month_twelve_open {
    label: "Market Month 12"
    type: string
    sql: to_char(${TABLE}.month_twelve_open_date::date, 'MMMM yyyy') ;;
  }

  dimension: month_three_open_date {
    type: date
    hidden: yes
    convert_tz: no
    sql: ${TABLE}.month_three_open_date ;;
  }

  dimension: month_six_open_date {
    type: date
    hidden: yes
    convert_tz: no
    sql: ${TABLE}.month_six_open_date ;;
  }

  dimension: month_nine_open_date {
    type: date
    hidden: yes
    convert_tz: no
    sql: ${TABLE}.month_nine_open_date ;;
  }

  dimension: month_twelve_open_date {
    type: date
    hidden: yes
    convert_tz: no
    sql: ${TABLE}.month_twelve_open_date ;;
  }

  dimension: goal_met_month3 {
    type: number
    hidden: yes
    sql: ${TABLE}.goal_met_month3 ;;
  }

  dimension: goal_met_month6 {
    type: number
    hidden: yes
    sql: ${TABLE}.goal_met_month6 ;;
  }

  dimension: goal_met_month9 {
    type: number
    hidden: yes
    sql: ${TABLE}.goal_met_month9 ;;
  }

  dimension: goal_met_month12 {
    type: number
    hidden: yes
    sql: ${TABLE}.goal_met_month12 ;;
  }

  measure: max_period {
    type: max
    sql: ${plexi_periods.date} ;;
  }

  measure: age_card {
    group_label: "Age Card"
    label: " " # Blank so that the column doesn't have a heading
    type: count_distinct
    sql: ${market_id};;
    # Build HTML for the age card. Left most, we'll have months open then market open date. Following this, we will show
    # 3, 6, 9, and 12 month milestones. Based on the selected period, we will highlight which of the milestones have
    # passed and which ones are upcoming. Grey box for passed milestones. White box for upcoming milestones. If the
    # milestone is the currently selected period, we will highlight it in green or red.

    # We will check if the revenue goals were met for each milestone. For past milestones, we will show green Goal Met
    # or red Goal Not Met. The red/green highlighting for currently selected period or next milestone will be based on
    # the revenue goals being met/not met.
    html:
    {% if value == 1 or value == "1" or value == "1.0" or value == "1.00" %}
      {% assign month3_val = month_three_open._value %}
      {% assign month6_val = month_six_open._value %}
      {% assign month9_val = month_nine_open._value %}
      {% assign month12_val = month_twelve_open._value %}

      {% assign month3_date = month_three_open_date._value %}
      {% assign month6_date = month_six_open_date._value %}
      {% assign month9_date = month_nine_open_date._value %}
      {% assign month12_date = month_twelve_open_date._value %}

      {% assign months_open_val = months_open._value %}
      {% assign market_open_date = branch_earnings_date_formatted._value %}
      {% assign market_name_val = market_name._value %}
      {% assign current_period = max_period._value %}

      {% assign next_milestone = "" %}
      {% if current_period <= month3_date %}
      {% assign next_milestone = "3" %}
      {% elsif current_period <= month6_date %}
      {% assign next_milestone = "6" %}
      {% elsif current_period <= month9_date %}
      {% assign next_milestone = "9" %}
      {% elsif current_period <= month12_date %}
      {% assign next_milestone = "12" %}
      {% endif %}

      {% assign milestones = "3,6,9,12" | split: "," %}
      <div style="padding:12px;background:#fff;border:1px solid #d1d5db;border-radius:4px;width:100%;height:100%;min-height:100px;box-sizing:border-box; vertical-align: middle;">
      <div style="text-align:center;margin-bottom:10px;">
      <div style="display:inline-block;vertical-align:middle;padding-right:16px;margin-right:16px;border-right:2px solid #e5e7eb;text-align:left;max-width:240px;">
       <div style="font-size:10px;color:#6b7280;text-transform:uppercase;letter-spacing:0.5px;margin-bottom:4px;">Market</div>
       <div style="font-size:18px;font-weight:700;color:#111827;line-height:1.1;white-space:normal;">
         {{ market_name_val }}
        </div>
      </div>
      <div style="display:inline-block;vertical-align:middle;padding-right:16px;margin-right:16px;border-right:2px solid #e5e7eb;text-align:center;">
      <div style="font-size:10px;color:#6b7280;text-transform:uppercase;letter-spacing:0.5px;margin-bottom:4px;">Months Open</div>
      <div style="font-size:36px;font-weight:700;color:#111827;line-height:1;">{{ months_open_val }}</div>
      </div>
      <div style="display:inline-block;vertical-align:middle;padding-right:16px;margin-right:16px;border-right:2px solid #e5e7eb;text-align:center;">
      <div style="font-size:10px;color:#6b7280;text-transform:uppercase;letter-spacing:0.5px;">Market Open</div>
      <div style="font-size:20px;font-weight:600;color:#111827;white-space:nowrap;margin-top:4px;">{{ market_open_date }}</div>
      </div>

      {% for milestone in milestones %}
      {% if milestone == "3" %}
      {% assign milestone_val = month3_val %}
      {% assign milestone_date = month3_date %}
      {% assign goal_met = goal_met_month3._value %}
      {% elsif milestone == "6" %}
      {% assign milestone_val = month6_val %}
      {% assign milestone_date = month6_date %}
      {% assign goal_met = goal_met_month6._value %}
      {% elsif milestone == "9" %}
      {% assign milestone_val = month9_val %}
      {% assign milestone_date = month9_date %}
      {% assign goal_met = goal_met_month9._value %}
      {% else %}
      {% assign milestone_val = month12_val %}
      {% assign milestone_date = month12_date %}
      {% assign goal_met = "" %}
      {% endif %}

      {% assign is_next = next_milestone == milestone %}
      {% assign is_done = current_period > milestone_date %}
      {% assign is_current = current_period == milestone_date %}
      {% assign is_future = current_period < milestone_date %}
      {% assign goal_met_yes = goal_met == 1 or goal_met == "1" or goal_met == "1.0" or goal_met == "1.00" %}
      {% assign goal_met_no = goal_met == 0 or goal_met == "0" or goal_met == "0.0" or goal_met == "0.00" %}

      <div style="display:inline-block;vertical-align:middle;padding:8px 12px;border-radius:4px;min-height:90px;min-width:110px;text-align:center;{% unless forloop.last %}margin-right:8px;{% endunless %}{% if is_current and goal_met_no %}background:#fee2e2;border:1px solid #f87171;{% elsif is_current and goal_met_yes %}background:#d1fae5;border:1px solid #6ee7b7;{% elsif is_next and is_future and goal_met_no %}background:#fee2e2;border:1px solid #f87171;{% elsif is_next and is_future %}background:#dbeafe;border:1px solid #93c5fd;{% elsif is_done %}background:#f3f4f6;border:1px solid #e5e7eb;{% else %}background:#fff;border:1px solid #e5e7eb;{% endif %}">
      <div style="font-size:12px;font-weight:600;color:#374151;white-space:nowrap;">Month {{ milestone }}{% if is_next %} <span style="{% if goal_met_no %}color:#b91c1c;{% elsif goal_met_yes %}color:#059669;{% elsif is_future %}color:#1d4ed8;{% else %}color:#059669;{% endif %}">• NEXT</span>{% elsif is_done %} <span style="color:#9ca3af;">✓</span>{% endif %}</div>
      <div style="font-size:15px;font-weight:600;{% if is_done %}color:#9ca3af;{% else %}color:#111827;{% endif %}white-space:nowrap;margin-top:2px;">{{ milestone_val }}</div>
      {% if goal_met_yes %}
      <div style="font-size:10px;color:#059669;margin-top:2px;">Goal Met</div>
      {% elsif goal_met_no %}
      <div style="font-size:10px;color:#b91c1c;margin-top:2px;">Goal Not Met</div>
      {% endif %}
      </div>
      {% endfor %}
      </div>
      </div>
      {% else %}
      <div style="display:flex;align-items:center;justify-content:center;padding:12px 16px;background:#fff;border:1px solid #d1d5db;border-radius:4px;">
      <div style="font-size:12px;font-weight:600;color:#6b7280;">Select One Market</div>
      </div>
      {% endif %}
      ;;
  }

  measure: count {
    type: count
    drill_fields: [market_name]
  }
}
