include: "/_standard/custom_sql/hiring_update_table.view.lkml"
include: "/_standard/custom_sql/hiring_update_table_oe_oa_goals.view.lkml"

view: +hiring_update_table {

  dimension: top_focus_order {
    type: number
    sql:CASE WHEN ${top_focus} = 'Territory Account Managers' then 1
          WHEN ${top_focus} = 'District Sales Managers' then 2
          WHEN ${top_focus} = 'General Managers' then 3
          WHEN ${top_focus} = 'Service Managers' then 4
          WHEN ${top_focus} = 'Techs' then 5
          WHEN ${top_focus} = 'CDL Delivery Drivers' then 6
          ELSE null END ;;
  }

  dimension: starts_mom_final {
    hidden: yes
    type: string
    sql:
    CASE
      WHEN ${starts_last_month} < ${starts_two_months_ago} THEN concat(${starts_last_month},' (',${starts_mom_perc_change}, ')▼')
      WHEN ${starts_last_month} = ${starts_two_months_ago} THEN concat(${starts_last_month},' (',${starts_mom_perc_change}, ')▶')
      ELSE concat(${starts_last_month},' (',${starts_mom_perc_change}, ')▲')
    END ;;
  }

  dimension: starts_yoy_final {
    hidden: yes
    type: string
    sql: case
          when ${starts_ytd} < ${starts_last_year_ytd}
            then concat(${starts_ytd}, ' (', ${starts_yoy_perc_change}, ')▼')
          when ${starts_ytd} = ${starts_last_year_ytd}
            then concat(${starts_ytd}, ' (', ${starts_yoy_perc_change}, ')▶︎')
          else
            concat(${starts_ytd},' (',${yoy_hc_perc_change}, ')▲')
        end ;;
  }

  dimension: starts_q1_final {
    hidden: yes
    type: string
    sql: case
          when ${starts_q1_current_year} < ${starts_q1_last_year}
            then concat(${starts_q1_current_year}, ' (', ${starts_q1_perc_change}, ')▼')
          when ${starts_q1_current_year} = ${starts_q1_last_year}
            then concat(${starts_q1_current_year}, ' (', ${starts_q1_perc_change}, ')▶︎')
          else
            concat(${starts_q1_current_year},' (',${starts_q1_perc_change}, ')▲')
        end ;;
  }

  dimension: headcount_mom_final {
    hidden: yes
    type: string
    sql:
    CASE
      WHEN ${headcount_last_month} < ${headcount_2_months_ago} THEN concat(${mom_hc_perc_change}, '▼')
      WHEN ${headcount_last_month} = ${headcount_2_months_ago} THEN concat(${mom_hc_perc_change}, '►')
      ELSE concat(${mom_hc_perc_change}, '▲')
    END ;;
  }

  dimension: headcount_yoy_final {
    hidden: yes
    type: string
    sql: case
          when ${headcount_last_month} < ${headcount_one_year_and_one_month_ago}
            then concat(${net_headcount_yoy}, ' (', ${yoy_hc_perc_change}, ')▼')
          when ${headcount_last_month} = ${headcount_one_year_and_one_month_ago}
            then concat(${net_headcount_yoy}, ' (', ${mom_hc_perc_change}, ')▶︎')
          else
            concat(${yoy_hc_perc_change}, '▲')
        end ;;
  }

  dimension: headcount_q1_final {
    hidden: yes
    type: string
    sql: case
          when ${headcount_q1_current_year} < ${headcount_q1_last_year}
            then concat(${headcount_q1_current_year}, ' (', ${hc_q1_perc_change}, ')▼')
          when ${headcount_q1_current_year} = ${headcount_q1_last_year}
            then concat(${headcount_q1_current_year}, ' (', ${hc_q1_perc_change}, ')▶︎')
          else
            concat(${headcount_q1_current_year},' (',${hc_q1_perc_change}, ')▲')
        end ;;
  }


  dimension: turnover_mom_final {
    hidden: yes
    type: string
    sql: case when ${turnover} < ${turnover_2_months_ago} then concat(${turnover},' (',${turnover_mom_perc_change},')▼')
          when ${turnover} = ${turnover_2_months_ago} then concat(${turnover},' (',${turnover_mom_perc_change},')▶︎')
          else concat(${turnover},' (',${turnover_mom_perc_change},')▲') end;;
  }

  dimension: turnover_yoy_final {
    hidden: yes
    type: string
    sql: case when ${turnover_ytd} < ${turnover_last_year_ytd} then concat(${turnover_ytd},' (',${turnover_yoy_perc_change},')▼')
          when ${turnover_ytd} = ${turnover_last_year_ytd} then concat(${turnover_ytd},' (',${turnover_yoy_perc_change},')▶︎')
          else concat(${turnover_ytd},' (',${turnover_yoy_perc_change},')▲') end;;
  }

  dimension: turnover_q1_final {
    hidden: yes
    type: string
    sql: case
          when ${turnover_q1_current_year} < ${turnover_q1_last_year}
            then concat(${turnover_q1_current_year}, ' (', ${turnover_q1_perc_change}, ')▼')
          when ${turnover_q1_current_year} = ${turnover_q1_last_year}
            then concat(${turnover_q1_current_year}, ' (', ${turnover_q1_perc_change}, ')▶︎')
          else
            concat(${turnover_q1_current_year},' (',${turnover_q1_perc_change}, ')▲')
        end ;;
  }

  dimension: offers_extended_mom_final {
    hidden: yes
    type: string
    sql: case when ${offers_extended_last_month} < ${offers_extended_2_months_ago} then concat(${offers_extended_last_month},' (',${offers_extended_mom_perc_change},')▼')
          when ${offers_extended_last_month} = ${offers_extended_2_months_ago} then concat(${offers_extended_last_month},' (',${offers_extended_mom_perc_change},')▶︎')
          else concat(${offers_extended_last_month},' (',${offers_extended_mom_perc_change},')▲') end;;
  }

  dimension: offers_extended_yoy_final {
    hidden: yes
    type: string
    sql: case when ${offers_extended_ytd} < ${offers_extended_last_year_ytd} then concat(${offers_extended_ytd},' (',${offers_extended_yoy_perc_change},')▼')
          when ${offers_extended_ytd} = ${offers_extended_last_year_ytd} then concat(${offers_extended_ytd},' (',${offers_extended_yoy_perc_change},')▶︎')
          else concat(${offers_extended_ytd},' (',${offers_extended_yoy_perc_change},')▲') end;;
  }

  dimension: offers_extended_q1_final {
    hidden: yes
    type: string
    sql: case
          when ${offers_extended_q1_current_year} < ${offers_extended_q1_last_year}
            then concat(${offers_extended_q1_current_year}, ' (', ${offers_extended_q1_perc_change}, ')▼')
          when ${offers_extended_q1_current_year} = ${offers_extended_q1_last_year}
            then concat(${offers_extended_q1_current_year}, ' (', ${offers_extended_q1_perc_change}, ')▶︎')
          else
            concat(${offers_extended_q1_current_year},' (',${offers_extended_q1_perc_change}, ')▲')
        end ;;
  }

  dimension: offers_accepted_mom_final {
    hidden: yes
    type: string
    sql: case when ${offers_accepted_last_month} < ${offers_accepted_2_months_ago} then concat(${offers_accepted_last_month},' (',${offers_accepted_mom_perc_change},')▼')
          when ${offers_accepted_last_month} = ${offers_accepted_2_months_ago} then concat(${offers_accepted_last_month},' (',${offers_accepted_mom_perc_change},')▶︎')
          else concat(${offers_accepted_last_month},' (',${offers_extended_mom_perc_change},')▲') end;;
  }

  dimension: offers_accepted_yoy_final {
    hidden: yes
    type: string
    sql: case when ${offers_accepted_ytd} < ${offers_accepted_last_year_ytd} then concat(${offers_accepted_ytd},' (',${offers_accepted_yoy_perc_change},')▼')
          when ${offers_accepted_ytd} = ${offers_accepted_last_year_ytd} then concat(${offers_accepted_ytd},' (',${offers_accepted_yoy_perc_change},')▶︎')
          else concat(${offers_accepted_ytd},' (',${offers_extended_yoy_perc_change},')▲') end;;
  }

  dimension: offers_accepted_q1_final {
    hidden: yes
    type: string
    sql: case
          when ${offers_accepted_q1_current_year} < ${offers_accepted_q1_last_year}
            then concat(${offers_accepted_q1_current_year}, ' (', ${offers_accepted_q1_perc_change}, ')▼')
          when ${offers_accepted_q1_current_year} = ${offers_accepted_q1_last_year}
            then concat(${offers_accepted_q1_current_year}, ' (', ${offers_accepted_q1_perc_change}, ')▶︎')
          else
            concat(${offers_accepted_q1_current_year},' (',${offers_accepted_q1_perc_change}, ')▲')
        end ;;
  }

  parameter: date_parameter {
    type: unquoted
    default_value: "1"
    allowed_value: {
      value: "1"
      label: "MoM"
    }
    allowed_value: {
      value: "2"
      label: "YTD"
    }
    allowed_value: {
      value: "3"
      label: "Q1 Current Year"
    }
  }

  dimension: turnover_mom_yoy_filterable {
    type: string
    sql:
    case
    when {{ date_parameter._parameter_value }} = 1 then ${turnover_mom_final}
    when {{ date_parameter._parameter_value }} = 2 then ${turnover_yoy_final}
    else ${turnover_q1_final}
    end;;
    html:{% assign parts = value | split: " " %}
          {% assign number_part = parts[0] %}
          {% assign percent_part = parts[1] %}
          {% if  date_parameter._parameter_value == '2' and turnover_ytd._value < turnover_last_year_ytd._value %}
          <p style="color: black;">{{ number_part }} <span style="color: green;">{{ percent_part }}</span></p>
          {% elsif date_parameter._parameter_value == '2' and turnover_ytd._value == turnover_last_year_ytd._value %}
          <p style="color: black;">{{ number_part }} <span style="color: #D4B200;">{{ percent_part }}</span></p>
          {% elsif date_parameter._parameter_value == '2' and turnover_ytd._value > turnover_last_year_ytd._value %}
          <p style="color: black;">{{ number_part }} <span style="color: red;">{{ percent_part }}</span></p>
          {% elsif date_parameter._parameter_value == '1' and turnover._value < turnover_2_months_ago._value %}
          <p style="color: black;">{{ number_part }} <span style="color: green;">{{ percent_part }}</span></p>
          {% elsif date_parameter._parameter_value == '1' and turnover._value == turnover_2_months_ago._value %}
          <p style="color: black;">{{ number_part }} <span style="color: #D4B200;">{{ percent_part }}</span></p>
          {% elsif date_parameter._parameter_value == '1' and turnover._value > turnover_2_months_ago._value %}
          <p style="color: black;">{{ number_part }} <span style="color: red;">{{ percent_part }}</span></p>
          {% elsif date_parameter._parameter_value == '3' and turnover_q1_current_year._value < turnover_q1_last_year._value %}
          <p style="color: black;">{{ number_part }} <span style="color: green;">{{ percent_part }}</span></p>
          {% elsif date_parameter._parameter_value == '3' and turnover_q1_current_year._value == turnover_q1_last_year._value %}
          <p style="color: black;">{{ number_part }} <span style="color: #D4B200;">{{ percent_part }}</span></p>
          {% elsif date_parameter._parameter_value == '3' and turnover_q1_current_year._value > turnover_q1_last_year._value %}
          <p style="color: black;">{{ number_part }} <span style="color: red;">{{ percent_part }}</span></p>
          {% else %}
          <p style="color: black;">{{ number_part }} <span style="background-color: white;">{{ percent_part }}</span></p>
          {% endif %}
            ;;
  }

  dimension: headcount_mom_yoy_filterable {
    type: string
    sql:
    case
    when {{ date_parameter._parameter_value }} = 1 then ${headcount_mom_final}
    when {{ date_parameter._parameter_value }} = 2 then ${headcount_yoy_final}
    else ${headcount_q1_final}
    end;;
    html:{% if date_parameter._parameter_value == '1' and headcount_last_month._value > headcount_2_months_ago._value %}
      <span style="color: green;">{{ value }}</span>
    {% elsif date_parameter._parameter_value == '1' and headcount_last_month._value == headcount_2_months_ago._value %}
      <span style="color: #D4B200;">{{ value }}</span>
    {% elsif date_parameter._parameter_value == '2' and headcount_last_month._value > headcount_one_year_and_one_month_ago._value %}
      <span style="color: green;">{{ value }}</span>
    {% elsif date_parameter._parameter_value == '2' and headcount_last_month._value == headcount_one_year_and_one_month_ago._value %}
      <span style="color: #D4B200;">{{ value }}</span>
    {% elsif date_parameter._parameter_value == '3' and headcount_q1_current_year._value > headcount_q1_last_year._value %}
      <span style="color: green;">{{ value }}</span>
    {% elsif date_parameter._parameter_value == '3' and headcount_q1_current_year._value == headcount_q1_last_year._value %}
      <span style="color: #D4B200;">{{ value }}</span>
    {% else %}
      <span style="color: red;">{{ value }}</span>
    {% endif %} ;;
  }

  dimension: starts_mom_yoy_filterable {
    type: string
    sql:
    case
    when {{ date_parameter._parameter_value }} = 1 then ${starts_mom_final}
    else ${starts_yoy_final}
    end;;
    html:{% assign parts = value | split: " " %}
          {% assign number_part = parts[0] %}
          {% assign percent_part = parts[1] %}
          {% if date_parameter._parameter_value == '1' and starts_last_month._value < starts_two_months_ago._value %}
          <p style="color: black;">{{ number_part }} <span style="color: red;">{{ percent_part }}</span></p>
          {% elsif date_parameter._parameter_value == '1' and starts_last_month._value == starts_two_months_ago._value %}
          <p style="color: black;">{{ number_part }} <span style="color: #D4B200;">{{ percent_part }}</span></p>
          {% elsif date_parameter._parameter_value == '1' and starts_last_month._value > starts_two_months_ago._value %}
          <p style="color: black;">{{ number_part }} <span style="color: green;">{{ percent_part }}</span></p>
          {% elsif date_parameter._parameter_value == '2' and starts_ytd._value < starts_last_year_ytd._value %}
          <p style="color: black;">{{ number_part }} <span style="color: red;">{{ percent_part }}</span></p>
          {% elsif date_parameter._parameter_value == '2' and starts_ytd._value == starts_last_year_ytd._value %}
          <p style="color: black;">{{ number_part }} <span style="color: #D4B200;">{{ percent_part }}</span></p>
          {% elsif date_parameter._parameter_value == '2' and starts_ytd._value > starts_last_year_ytd._value %}
          <p style="color: black;">{{ number_part }} <span style="color: green;">{{ percent_part }}</span></p>
          {% elsif date_parameter._parameter_value == '3' and starts_q1_current_year._value < starts_q1_last_year._value %}
          <p style="color: black;">{{ number_part }} <span style="color: red;">{{ percent_part }}</span></p>
          {% elsif date_parameter._parameter_value == '3' and starts_q1_current_year._value == starts_q1_last_year._value %}
          <p style="color: black;">{{ number_part }} <span style="color: #D4B200;">{{ percent_part }}</span></p>
          {% elsif date_parameter._parameter_value == '3' and starts_q1_current_year._value > starts_q1_last_year._value %}
          <p style="color: black;">{{ number_part }} <span style="color: green;">{{ percent_part }}</span></p>
          {% else %}
          <p style="color: black;">{{ number_part }} <span style="background-color: white;">{{ percent_part }}</span></p>
          {% endif %};;
  }

  dimension: offers_extended_mom_yoy_filterable {
    type: string
    sql:
    case
    when {{ date_parameter._parameter_value }} = 1 then ${offers_extended_mom_final}
    else ${offers_extended_yoy_final}
    end;;
    html:{% assign parts = value | split: " " %}
          {% assign number_part = parts[0] %}
          {% assign percent_part = parts[1] %}
          {% if date_parameter._parameter_value == '1' and offers_extended_last_month._value < offers_extended_2_months_ago._value %}
          <p style="color: black;">{{ number_part }} <span style="color: red;">{{ percent_part }}</span></p>
          {% elsif date_parameter._parameter_value == '1' and offers_extended_last_month._value == offers_extended_2_months_ago._value %}
          <p style="color: black;">{{ number_part }} <span style="color: #D4B200;">{{ percent_part }}</span></p>
          {% elsif date_parameter._parameter_value == '1' and offers_extended_last_month._value > offers_extended_2_months_ago._value %}
          <p style="color: black;">{{ number_part }} <span style="color: green;">{{ percent_part }}</span></p>
          {% elsif date_parameter._parameter_value == '2' and offers_extended_ytd._value < offers_extended_last_year_ytd._value %}
          <p style="color: black;">{{ number_part }} <span style="color: red;">{{ percent_part }}</span></p>
          {% elsif date_parameter._parameter_value == '2' and offers_extended_ytd._value == offers_extended_last_year_ytd._value %}
          <p style="color: black;">{{ number_part }} <span style="color: #D4B200;">{{ percent_part }}</span></p>
          {% elsif date_parameter._parameter_value == '2' and offers_extended_ytd._value > offers_extended_last_year_ytd._value %}
          <p style="color: black;">{{ number_part }} <span style="color: green;">{{ percent_part }}</span></p>
          {% elsif date_parameter._parameter_value == '3' and offers_extended_q1_current_year._value < offers_extended_q1_last_year._value %}
          <p style="color: black;">{{ number_part }} <span style="color: red;">{{ percent_part }}</span></p>
          {% elsif date_parameter._parameter_value == '3' and offers_extended_q1_current_year._value == offers_extended_q1_last_year._value %}
          <p style="color: black;">{{ number_part }} <span style="color: #D4B200;">{{ percent_part }}</span></p>
          {% elsif date_parameter._parameter_value == '3' and offers_extended_q1_current_year._value > offers_extended_q1_last_year._value %}
          <p style="color: black;">{{ number_part }} <span style="color: green;">{{ percent_part }}</span></p>
          {% else %}
          <p style="color: black;">{{ number_part }} <span style="background-color: white;">{{ percent_part }}</span></p>
          {% endif %} ;;
  }

  dimension: offers_accepted_mom_yoy_filterable {
    type: string
    sql:
    case
    when {{ date_parameter._parameter_value }} = 1 then ${offers_accepted_mom_final}
    else ${offers_accepted_yoy_final}
    end;;
    html:{% assign parts = value | split: " " %}
          {% assign number_part = parts[0] %}
          {% assign percent_part = parts[1] %}
          {% if date_parameter._parameter_value == '1' and offers_accepted_last_month._value < offers_accepted_2_months_ago._value %}
          <p style="color: black;">{{ number_part }} <span style="color: red;">{{ percent_part }}</span></p>
          {% elsif date_parameter._parameter_value == '1' and offers_accepted_last_month._value == offers_accepted_2_months_ago._value %}
          <p style="color: black;">{{ number_part }} <span style="color: #D4B200;">{{ percent_part }}</span></p>
          {% elsif date_parameter._parameter_value == '1' and offers_accepted_last_month._value > offers_accepted_2_months_ago._value %}
          <p style="color: black;">{{ number_part }} <span style="color: green;">{{ percent_part }}</span></p>
          {% elsif date_parameter._parameter_value == '2' and offers_accepted_ytd._value < offers_accepted_last_year_ytd._value %}
          <p style="color: black;">{{ number_part }} <span style="color: red;">{{ percent_part }}</span></p>
          {% elsif date_parameter._parameter_value == '2' and offers_accepted_ytd._value == offers_accepted_last_year_ytd._value %}
          <p style="color: black;">{{ number_part }} <span style="color: #D4B200;">{{ percent_part }}</span></p>
          {% elsif date_parameter._parameter_value == '2' and offers_accepted_ytd._value > offers_accepted_last_year_ytd._value %}
          <p style="color: black;">{{ number_part }} <span style="color: green;">{{ percent_part }}</span></p>
          {% elsif date_parameter._parameter_value == '3' and offers_accepted_q1_current_year._value < offers_accepted_q1_last_year._value %}
          <p style="color: black;">{{ number_part }} <span style="color: red;">{{ percent_part }}</span></p>
          {% elsif date_parameter._parameter_value == '3' and offers_accepted_q1_current_year._value == offers_accepted_q1_last_year._value %}
          <p style="color: black;">{{ number_part }} <span style="color: #D4B200;">{{ percent_part }}</span></p>
          {% elsif date_parameter._parameter_value == '3' and offers_accepted_q1_current_year._value > offers_accepted_q1_last_year._value %}
          <p style="color: black;">{{ number_part }} <span style="color: green;">{{ percent_part }}</span></p>
          {% else %}
          <p style="color: black;">{{ number_part }} <span style="background-color: white;">{{ percent_part }}</span></p>
          {% endif %} ;;
  }

  dimension: last_month_name{
    hidden: yes
    type: date_month_name
    sql: dateadd(month, -1, date_trunc(month, current_date)) ;;
  }

  dimension: current_year_name{
    hidden: yes
    type: date_year
    sql: current_date ;;
  }


  dimension: title_last_month {
    hidden: yes
    type: string
    sql: concat(${last_month_name}, ' Hiring Update') ;;
  }

  dimension: title_ytd {
    hidden: yes
    type: string
    sql: concat(${current_year_name}, ' Hiring Update YTD') ;;
  }

  dimension: title_q1 {
    hidden: yes
    type: string
    sql: concat('Q1 ',${current_year_name}, ' Hiring Update') ;;
  }

  measure: title_fin {
    type: string
    sql:
    CASE
      WHEN {{ date_parameter._parameter_value }} = 1 THEN 'last_month'
      WHEN {{ date_parameter._parameter_value }} = 2 THEN 'ytd'
      ELSE 'q1'
    END ;;

    html:
          {% if value == 'last_month' %}
            <div style="line-height:1.2; font-size:27px;">{{ title_last_month._value }}</div>
            <div style="font-size:17px; color:gray;">
              Values reflect totals from the month; % change compares the difference from the previous month to this month
            </div>
          {% elsif value == 'ytd' %}
            <div style="line-height:1.2; font-size:27px;">{{ title_ytd._value }}</div>
            <div style="font-size:17px; color:gray;">
              Values reflect total year to date performance; % change compares the same year to date range from last year to this year
            </div>
          {% else %}
            <div style="line-height:1.2; font-size:27px;">{{ title_q1._value }}</div>
            <div style="font-size:17px; color:gray;">
              Values reflect totals from Q1; % change compares Q1 of last year to Q1 of this year
            </div>
          {% endif %}
        ;;
  }


  dimension: subtitle_fin {
    type: string
    sql: case
          when {{ date_parameter._parameter_value }} = 1 then 'Values are as of the last day of the most recently completed month; % change reflects the difference between two months prior and the most recent month.'
          when {{ date_parameter._parameter_value }} = 2 then 'Values reflect year-to-date performance from January 1 to the last day of the most recently completed month; % change compares the same period from the prior year to the current year.'
          else 'Values reflect Q1 2025 performance from January 1 to the last day of March; % change compares the same period from the prior year to the current year.'
          end;;
    html: <span style='font-size: 15px;'>{{ value }}</span>;;
  }

  measure: top_focus_month_goal {
    type:  number
    sql: CASE
        WHEN {{ date_parameter._parameter_value }} = 1 and ${top_focus} = 'Territory Account Managers' THEN MAX(${tam_month_goal})
        WHEN {{ date_parameter._parameter_value }} = 2 and ${top_focus} = 'Territory Account Managers' THEN MAX(${tam_month_goal})
        WHEN {{ date_parameter._parameter_value }} = 3 and ${top_focus} = 'Territory Account Managers' THEN MAX(${tam_q1_goal})
        WHEN {{ date_parameter._parameter_value }} = 1 and ${top_focus} = 'General Managers' THEN MAX(${gm_month_goal})
        WHEN {{ date_parameter._parameter_value }} = 2 and ${top_focus} = 'General Managers' THEN MAX(${gm_month_goal})
        WHEN {{ date_parameter._parameter_value }} = 3 and ${top_focus} = 'General Managers' THEN MAX(${gm_q1_goal})
        WHEN {{ date_parameter._parameter_value }} = 1 and ${top_focus} = 'District Sales Managers' THEN MAX(${dsm_month_goal})
        WHEN {{ date_parameter._parameter_value }} = 2 and ${top_focus} = 'District Sales Managers' THEN MAX(${dsm_month_goal})
        WHEN {{ date_parameter._parameter_value }} = 3 and ${top_focus} = 'District Sales Managers' THEN MAX(${dsm_q1_goal})
        WHEN {{ date_parameter._parameter_value }} = 1 and ${top_focus} = 'CDL Delivery Drivers' THEN MAX(${cdl_month_goal})
        WHEN {{ date_parameter._parameter_value }} = 2 and ${top_focus} = 'CDL Delivery Drivers' THEN MAX(${cdl_month_goal})
        WHEN {{ date_parameter._parameter_value }} = 3 and ${top_focus} = 'CDL Delivery Drivers' THEN MAX(${cdl_q1_goal})
        WHEN {{ date_parameter._parameter_value }} = 1 and ${top_focus} = 'Service Managers' THEN MAX(${sm_month_goal})
        WHEN {{ date_parameter._parameter_value }} = 2 and ${top_focus} = 'Service Managers' THEN MAX(${sm_month_goal})
        WHEN {{ date_parameter._parameter_value }} = 3 and ${top_focus} = 'Service Managers' THEN MAX(${sm_q1_goal})
        WHEN {{ date_parameter._parameter_value }} = 1 and ${top_focus} = 'Techs' THEN MAX(${techs_month_goal})
        WHEN {{ date_parameter._parameter_value }} = 2 and ${top_focus} = 'Techs' THEN MAX(${techs_month_goal})
        WHEN {{ date_parameter._parameter_value }} = 3 and ${top_focus} = 'Techs' THEN MAX(${techs_q1_goal})
        ELSE NULL END;;
  }

  dimension: headcount_formatted {
    label: "Current Headcount"
    type: number
    sql: ${headcount_last_month} ;;
    html:{% if top_focus_month_goal._value == null %}
        <div style="background-color: #F2F2F2;">
          <div style="text-align: right; font-weight: bold;">
            <span style="color: #8C8C8C;">{{rendered_value}}</span>
          </div>
          <div style="text-align: right; font-weight: normal;">
            <span style="color: #8C8C8C;"> No Goal Listed</span>
          </div>
        </div>

      {% elsif headcount_formatted._value > top_focus_month_goal._value %}
      <div style="background-color: #DFF7ED;">
      <div style="text-align: right; font-weight: bold;">
      <span style="color: green;">{{rendered_value}}</span>
      </div>
      <div style="text-align: right; font-weight: normal;">
      <span style="color: #8C8C8C;"> Goal: {{top_focus_month_goal._value}}</span>
      </div>
      </div>

      {% elsif headcount_formatted._value == top_focus_month_goal._value %}
      <div style="background-color: #DFF7ED;">
      <div style="text-align:right; font-weight: bold;">
      <span style="color: #D4B200;">{{rendered_value}}</span>
      </div>
      <div style="text-align: right; font-weight: normal;">
      <span style="color: #8C8C8C;"> Goal: {{top_focus_month_goal._value}}</span>
      </div>
      </div>

      {% elsif headcount_formatted._value < top_focus_month_goal._value %}
      <div style="background-color: #FDE2E2;">
      <div style="text-align: right; font-weight: bold;">
      <span style="color: red;">{{rendered_value}}</span>
      </div>
      <div style="text-align: right; font-weight: normal;">
      <span style="color: #8C8C8C;"> Goal: {{top_focus_month_goal._value}}</span>
      </div>
      </div>

      {% else %}
      <div style="background-color: #F2F2F2;">
      <div style="text-align: right; font-weight: bold;">
      <span style="color: #808080;">{{rendered_value}}</span>
      </div>
      <div style="text-align: right; font-weight: normal;">
      <span style="color: #8C8C8C;"> No Goal Listed</span>
      </div>
      </div>
      {% endif %}
      ;;
  }


  parameter: date_parameter_months {
    type: unquoted
    default_value: "1"
    allowed_value: {
      value: "1"
      label: "Current Month"
    }
    allowed_value: {
      value: "2"
      label: "Last Month"
    }
    allowed_value: {
      value: "3"
      label: "Two Months Ago"
    }
  }

  dimension: offers_extended_filterable {
    type: string
    sql:
    case
    when {{ date_parameter_months._parameter_value }} = 1 then ${offers_extended_current_month}
    when {{ date_parameter_months._parameter_value }} = 2 then ${offers_extended_last_month}
    else ${offers_extended_2_months_ago}
    end;;
  }

  dimension: offers_extended_goal_filterable {
    type: string
    sql:
    case
    when {{ date_parameter_months._parameter_value }} = 1 then ${hiring_update_table_oe_oa_goals.offers_extended_goal_current_month}
    when {{ date_parameter_months._parameter_value }} = 2 then ${hiring_update_table_oe_oa_goals.offers_extended_goal_last_month}
    else ${hiring_update_table_oe_oa_goals.offers_extended_goal_two_months_ago}
    end;;
  }

  dimension: offers_extended_bar_current_month {
    type: number
    hidden: yes
    sql:  round(${hiring_update_table_oe_oa_goals.offers_extended_goal_current_month} * ${hiring_update_table_oe_oa_goals.percent_complete_with_current_month});;
  }

  dimension: offers_extended_bar_current_month_90_perc {
    type: number
    hidden: yes
    sql:  round(${hiring_update_table_oe_oa_goals.offers_extended_goal_current_month} * ${hiring_update_table_oe_oa_goals.percent_complete_with_current_month} * 0.9);;
  }

  dimension: offers_extended_bar_90_perc {
    type: number
    hidden: yes
    sql:  round(${offers_extended_goal_filterable} * 0.9);;
  }

  dimension: offers_extended_final {
    type: string
    sql: ${offers_extended_filterable};;
    html:
    {% assign period = date_parameter_months._parameter_value %}
    {% assign final = offers_extended_final._value | to_number %}
    {% assign goal  = offers_extended_goal_filterable._value | to_number %}
    {% assign bar_curr = offers_extended_bar_current_month._value | to_number %}
    {% assign bar_curr90 = offers_extended_bar_current_month_90_perc._value | to_number %}
    {% assign bar90 = offers_extended_bar_90_perc._value | to_number %}
    {% if period == '1' and final >= bar_curr %}
    <div style="background-color: #DFF7ED;">
    <div style="text-align: right; font-weight: normal;">
    <span style="color: green;">{{rendered_value}}</span>
    </div>
    <div style="text-align: right; font-weight: normal;">
    <span style="color: black;"> Goal: {{goal}}</span>
    </div>
    </div>

    {% elsif period == '1' and final < bar_curr and final >= bar_curr90 %}
    <div style="background-color: #F2F2F2;">
    <div style="text-align: right; font-weight: normal;">
    <span style="color: #D4B200;">{{rendered_value}}</span>
    </div>
    <div style="text-align: right; font-weight: normal;">
    <span style="color: black;"> Goal: {{goal}}</span>
    </div>
    </div>

    {% elsif period == '1' and final < bar_curr90 %}
    <div style="background-color: #FDE2E2;">
    <div style="text-align: right; font-weight: normal;">
    <span style="color: red;">{{rendered_value}}</span>
    </div>
    <div style="text-align: right; font-weight: normal;">
    <span style="color: black;"> Goal: {{goal}}</span>
    </div>
    </div>

    {% elsif period == '2' and final >= goal%}
    <div style="background-color: #DFF7ED;">
    <div style="text-align: right; font-weight: normal;">
    <span style="color: green;">{{rendered_value}}</span>
    </div>
    <div style="text-align: right; font-weight: normal;">
    <span style="color: black;"> Goal: {{goal}}</span>
    </div>
    </div>

    {% elsif period == '2' and final < goal and final >= bar90 %}
    <div style="background-color: #F2F2F2;">
    <div style="text-align: right; font-weight: normal;">
    <span style="color: #D4B200;">{{rendered_value}}</span>
    </div>
    <div style="text-align: right; font-weight: normal;">
    <span style="color: black;"> Goal: {{goal}}</span>
    </div>
    </div>

    {% elsif period == '2' and final < bar90 %}
    <div style="background-color: #FDE2E2;">
    <div style="text-align: right; font-weight: normal;">
    <span style="color: red;">{{rendered_value}}</span>
    </div>
    <div style="text-align: right; font-weight: normal;">
    <span style="color: black;"> Goal: {{goal}}</span>
    </div>
    </div>

    {% elsif period == '3' and final >= goal%}
    <div style="background-color: #DFF7ED;">
    <div style="text-align: right; font-weight: normal;">
    <span style="color: green;">{{rendered_value}}</span>
    </div>
    <div style="text-align: right; font-weight: normal;">
    <span style="color: black;"> Goal: {{goal}}</span>
    </div>
    </div>

    {% elsif period == '3' and final < goal and final >= bar90 %}
    <div style="background-color: #F2F2F2;">
    <div style="text-align: right; font-weight: normal;">
    <span style="color: #D4B200;">{{rendered_value}}</span>
    </div>
    <div style="text-align: right; font-weight: normal;">
    <span style="color: black;"> Goal: {{goal}}</span>
    </div>
    </div>

    {% else %}
    <div style="background-color: #FDE2E2;">
    <div style="text-align: right; font-weight: normal;">
    <span style="color: red;">{{rendered_value}}</span>
    </div>
    <div style="text-align: right; font-weight: normal;">
    <span style="color: black;"> Goal: {{goal}}</span>
    </div>
    </div>
    {% endif %}
    ;;
  }

  dimension: offers_accepted_filterable {
    type: string
    sql:
    case
    when {{ date_parameter_months._parameter_value }} = 1 then ${offers_accepted_current_month}
    when {{ date_parameter_months._parameter_value }} = 2 then ${offers_accepted_last_month}
    else ${offers_accepted_2_months_ago}
    end;;
  }

  dimension: offers_accepted_goal_filterable {
    type: string
    sql:
    case
    when {{ date_parameter_months._parameter_value }} = 1 then ${hiring_update_table_oe_oa_goals.offers_accepted_goal_current_month}
    when {{ date_parameter_months._parameter_value }} = 2 then ${hiring_update_table_oe_oa_goals.offers_accepted_goal_last_month}
    else ${hiring_update_table_oe_oa_goals.offers_accepted_goal_two_months_ago}
    end;;
  }

  dimension: offers_accepted_bar_current_month {
    type: number
    hidden: yes
    sql:  round(${hiring_update_table_oe_oa_goals.offers_accepted_goal_current_month} * ${hiring_update_table_oe_oa_goals.percent_complete_with_current_month});;
  }

  dimension: offers_accepted_bar_current_month_90_perc {
    type: number
    hidden: yes
    sql:  round(${hiring_update_table_oe_oa_goals.offers_accepted_goal_current_month} * ${hiring_update_table_oe_oa_goals.percent_complete_with_current_month} * 0.9);;
  }

  dimension: offers_accepted_bar_90_perc {
    type: number
    hidden: yes
    sql:  round(${offers_accepted_goal_filterable} * 0.9);;
  }

  dimension: offers_accepted_final {
    type: string
    sql: ${offers_accepted_filterable};;
    html:
    {% assign period = date_parameter_months._parameter_value %}
    {% assign final = offers_accepted_final._value | to_number %}
    {% assign goal  = offers_accepted_goal_filterable._value | to_number %}
    {% assign bar_curr = offers_accepted_bar_current_month._value | to_number %}
    {% assign bar_curr90 = offers_accepted_bar_current_month_90_perc._value | to_number %}
    {% assign bar90 = offers_accepted_bar_90_perc._value | to_number %}
    {% if period == '1' and final >= bar_curr %}
    <div style="background-color: #DFF7ED;">
    <div style="text-align: right; font-weight: normal;">
    <span style="color: green;">{{rendered_value}}</span>
    </div>
    <div style="text-align: right; font-weight: normal;">
    <span style="color: black;"> Goal: {{goal}}</span>
    </div>
    </div>

    {% elsif period == '1' and final < bar_curr and final >= bar_curr90 %}
    <div style="background-color: #FEFCE8;">
    <div style="text-align: right; font-weight: normal;">
    <span style="color: #D4B200;">{{rendered_value}}</span>
    </div>
    <div style="text-align: right; font-weight: normal;">
    <span style="color: black;"> Goal: {{goal}}</span>
    </div>
    </div>

    {% elsif period == '1' and final < bar_curr90 %}
    <div style="background-color: #FDE2E2;">
    <div style="text-align: right; font-weight: normal;">
    <span style="color: red;">{{rendered_value}}</span>
    </div>
    <div style="text-align: right; font-weight: normal;">
    <span style="color: black;"> Goal: {{goal}}</span>
    </div>
    </div>

      {% elsif period == '2' and final >= goal%}
      <div style="background-color: #DFF7ED;">
      <div style="text-align: right; font-weight: normal;">
      <span style="color: green;">{{rendered_value}}</span>
      </div>
      <div style="text-align: right; font-weight: normal;">
      <span style="color: black;"> Goal: {{goal}}</span>
      </div>
      </div>

      {% elsif period == '2' and final < goal and final >= bar90 %}
      <div style="background-color: #FEFCE8;">
      <div style="text-align: right; font-weight: normal;">
      <span style="color: #D4B200;">{{rendered_value}}</span>
      </div>
      <div style="text-align: right; font-weight: normal;">
      <span style="color: black;"> Goal: {{goal}}</span>
      </div>
      </div>

      {% elsif period == '2' and final < bar90 %}
      <div style="background-color: #FDE2E2;">
      <div style="text-align: right; font-weight: normal;">
      <span style="color: red;">{{rendered_value}}</span>
      </div>
      <div style="text-align: right; font-weight: normal;">
      <span style="color: black;"> Goal: {{goal}}</span>
      </div>
      </div>

      {% elsif period == '3' and final >= goal%}
      <div style="background-color: #DFF7ED;">
      <div style="text-align: right; font-weight: normal;">
      <span style="color: green;">{{rendered_value}}</span>
      </div>
      <div style="text-align: right; font-weight: normal;">
      <span style="color: black;"> Goal: {{goal}}</span>
      </div>
      </div>

      {% elsif period == '3' and final < goal and final >= bar90 %}
      <div style="background-color: #FEFCE8;">
      <div style="text-align: right; font-weight: normal;">
      <span style="color: #D4B200;">{{rendered_value}}</span>
      </div>
      <div style="text-align: right; font-weight: normal;">
      <span style="color: black;"> Goal: {{goal}}</span>
      </div>
      </div>

      {% else %}
      <div style="background-color: #FDE2E2;">
      <div style="text-align: right; font-weight: normal;">
      <span style="color: red;">{{rendered_value}}</span>
      </div>
      <div style="text-align: right; font-weight: normal;">
      <span style="color: black;"> Goal: {{goal}}</span>
      </div>
      </div>
      {% endif %}
      ;;
  }

  dimension: starts_filterable {
    type: string
    sql:
    case
    when {{ date_parameter_months._parameter_value }} = 1 then ${starts_current_month}
    when {{ date_parameter_months._parameter_value }} = 2 then ${starts_last_month}
    else ${starts_two_months_ago}
    end;;
  }

  dimension: turnover_filterable {
    type: string
    sql:
    case
    when {{ date_parameter_months._parameter_value }} = 1 then ${turnover_current_month}
    when {{ date_parameter_months._parameter_value }} = 2 then ${turnover}
    else ${turnover_2_months_ago}
    end;;
  }

  dimension: headcount_filterable {
    type: string
    sql:
    case
    when {{ date_parameter_months._parameter_value }} = 1 then ${current_headcount}
    when {{ date_parameter_months._parameter_value }} = 2 then ${headcount_last_month}
    else ${headcount_2_months_ago}
    end;;
  }
}


explore: hiring_update_table {
  label: "TA Strategic Leadership"

  join: hiring_update_table_oe_oa_goals {
    type: left_outer
    relationship: one_to_one
    sql_on: ${hiring_update_table.top_focus} = ${hiring_update_table_oe_oa_goals.top_focus} ;;
  }
}
