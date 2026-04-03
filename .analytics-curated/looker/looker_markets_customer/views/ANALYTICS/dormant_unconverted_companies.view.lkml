view: dormant_unconverted_companies {
  sql_table_name: "BUSINESS_INTELLIGENCE"."TRIAGE"."STG_BI__DORMANT_UNCONVERTED_COMPANIES" ;;
#   derived_table: {
#     : select * from business_intelligence.triage.stg_bi__dormant_unconverted_companies
#     ;;
# }
  dimension: billing_location {
    type: string
    sql: COALESCE(${TABLE}."BILLING_LOCATION", 'No Location Found') ;;
  }
  dimension: closest_district {
    type: string
    sql: ${TABLE}.closest_district ;;
  }
  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }
  dimension: company_market_type_segment {
    label: "Market Type Segment"
    type: string
    sql: COALESCE(${TABLE}."COMPANY_MARKET_TYPE_SEGMENT", 'Unknown') ;;
  }
  dimension: company_name {
    label: "Company Name"
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }
  dimension: company_status {
    type: string
    sql: ${TABLE}."COMPANY_STATUS" ;;
  }
  dimension: company_status_link {
    group_label: "Company Status Colors"
    label: "Status"
    type: string
    sql: ${company_status} ;;
    html:
    {% if company_status._value == 'Dormant' %}
      <span style="background-color:#00B9DF; color:black; padding:3px; border-radius:5px;">
        <b>{{ rendered_value }}</b>
      </span>
      <td>
        <span>{{days_since._value}} Days Since Rental</span>
      </td>
    {% elsif company_status._value == 'Inactive' %}
      <span style="background-color:#FF8E2B; color:black; padding:3px; border-radius:5px;">
        <b>{{ rendered_value }}</b>
      </span>
      <td>
        <span>{{days_since._value}} Days Since Rental</span>
      </td>
    {% elsif company_status._value == 'Unconverted' %}
      <span style="background-color:#56D4B8; color:black; padding:3px; border-radius:5px;">
        <b>{{ rendered_value }}</b>
      </span>
      <td>
        <span>{{days_since._value}} Days Since Creation</span>
      </td>
    {% else %}
      <span style="background-color:#f5f5f5; color:black; padding:3px; border-radius:5px;">
      <b>{{ rendered_value }}</b></span>
    {% endif %}
  ;;
  }
  dimension: company_ttm_rental_revenue {
    label: "TTM Rental Revenue"
    type: number
    sql: COALESCE(${TABLE}."COMPANY_TTM_RENTAL_REVENUE", 0) ;;
    value_format_name: usd_0
  }

  dimension: lifetime_rental_revenue {
    type: number
    sql: COALESCE(${TABLE}."LIFETIME_RENTAL_REVENUE", 0) ;;
    value_format_name: usd_0
  }
  measure: lifetime_rental_revenue_sum {
    label: "Lifetime Rental Revenue"
    type: sum
    sql: COALESCE(${TABLE}."LIFETIME_RENTAL_REVENUE", 0) ;;
    value_format_name: usd_0
  }
  dimension: days_since {
    label: "Days Since Creation/Rental"
    type: number
    sql: COALESCE(${TABLE}."DAYS_SINCE_CREATION", ${TABLE}."DAYS_SINCE_INVOICE") ;;
  }
  dimension: district {
    type: string
    sql: COALESCE(${TABLE}."DISTRICT", 'No District Found');;
  }
  dimension: email_address {
    type: string
    sql: ${TABLE}."EMAIL_ADDRESS" ;;
  }
  dimension: employee_status {
    type: string
    sql: ${TABLE}."EMPLOYEE_STATUS" ;;
  }
  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }
  dimension: market_name {
    label: "Highest Rev. Market"
    type: string
    sql: COALESCE(${TABLE}."MARKET_NAME", 'No Market Found') ;;
  }
  dimension: national_account {
    type: yesno
    sql: ${TABLE}."NATIONAL_ACCOUNT" ;;
  }
  dimension: quotes {
    type: number
    sql: COALESCE(${TABLE}."QUOTES", 0) ;;
  }
  dimension: has_quotes {
    type: yesno
    sql: case when ${quotes} > 0 then true else false end ;;
  }
  dimension: rep_1 {
    label: "Rep 1 original"
    type: string
    sql: COALESCE(${TABLE}."REP_1_NAME", 'No Primary Rep') ;;
  }
  dimension: rep_1_active  {
    type: string
    sql: ${TABLE}."ACTIVE_EMPLOYEE_CHECK_REP_1";;
  }
  dimension: rep_1_concat {
    label: "Rep 1"
    type: string
    sql: ${rep_1} ;;
    html:
      {% if rep_1_active._value == 'Terminated' %}
        <span style="color: red;"> {{rendered_value}}-Terminated </span>
      {% elsif rep_1_active._value == 'Active' %}
        <span>{{rendered_value}}-Active</span>
      {% else %}
        <span>{{rendered_value}}</span>
      {% endif %};;
  }
  dimension: rank_1_revenue {
    label: "Rep 1 Rental Revenue"
    sql: ${TABLE}."RANK_1_REVENUE" ;;
    value_format_name: usd_0
  }
  dimension: rep_2 {
    type: string
    sql: COALESCE(${TABLE}."REP_2_NAME", 'No Secondary Rep') ;;
  }
  dimension: rep_2_active {
    type: string
    sql: ${TABLE}."ACTIVE_EMPLOYEE_CHECK_REP_2";;
  }
  dimension: rep_2_concat {
    label: "Rep 2"
    type: string
    sql: ${rep_2} ;;
    html:
      {% if rep_2_active._value == 'Terminated' %}
        <span style="color: red;"> {{rendered_value}}-Terminated </span>
      {% elsif rep_2_active._value == 'Active' %}
        <span>{{rendered_value}}-Active</span>
      {% else %}
        <span>{{rendered_value}}</span>
      {% endif %};;
  }
  dimension: rank_2_revenue {
    label: "Rep 2 Rental Revenue"
    sql: ${TABLE}."RANK_2_REVENUE" ;;
    value_format_name: usd_0
  }
  dimension: rep_3 {
    type: string
    sql: COALESCE(${TABLE}."REP_3_NAME", 'No Third Rep') ;;
  }
  dimension: rep_3_active {
    type: string
    sql: ${TABLE}."ACTIVE_EMPLOYEE_CHECK_REP_3";;
  }
  dimension: rep_3_concat {
    label: "Rep 3"
    type: string
    sql: ${rep_3} ;;
    html:
      {% if rep_3_active._value == 'Terminated' %}
        <span style="color: red;"> {{rendered_value}}-Terminated </span>
      {% elsif rep_3_active._value == 'Active' %}
        <span>{{rendered_value}}-Active</span>
      {% else %}
        <span>{{rendered_value}}</span>
      {% endif %};;
  }
  dimension: rank_3_revenue {
    label: "Rep 3 Rental Revenue"
    sql: ${TABLE}."RANK_3_REVENUE" ;;
    value_format_name: usd_0
  }
  dimension: sp_name {
    type: string
    sql: COALESCE(${TABLE}."SP_NAME", 'No Active Reps') ;;
  }
  measure: rec_rep {
    label: "Recommended Rep"
    type: string
    sql: ANY_VALUE(${sp_name}) ;;
    drill_fields: [company_name, rep_1_concat, rank_1_revenue, rep_2_concat, rank_2_revenue, rep_3_concat, rank_3_revenue]
    html:
      {% if value != 'No Active Reps' and company_status._value != 'Unconverted' %}
        <a href="#drillmenu" target="_self" style="display: block; text-align: left;">
          {{ rendered_value }}
          <td>
            <span>
              View Associated Reps <img src="https://imgur.com/ZCNurvk.png" height="15" width="15">
            </span>
          </td>
        </a>
      {% else %}
        <td style="text-align: left;">
          <span>{{ rendered_value }}</span>
        </td>
      {% endif %} ;;
  }
  dimension: sp_user_id {
    type: number
    sql: ${TABLE}."SP_USER_ID" ;;
  }
  dimension: ttm_rentals_at_market {
    type: number
    sql: COALESCE(${TABLE}."TTM_RENTALS_AT_MARKET", 0) ;;
  }
  dimension: company_name_link {
    group_label: "Company Navigation"
    label: "Company"
    type: string
    sql: ${company_name} ;;
    html:
      {% if national_account._value == 'Yes' %}
        <a href="https://equipmentshare.looker.com/dashboards/28?Company+Name={{ company_name._filterable_value | url_encode }}" target="_blank"
        style="color:blue;">
          <b>
            <img src="https://cdn-icons-png.flaticon.com/512/63/63811.png" title="National Account" height="15" width="15"> {{ rendered_value }} ➔
          </b>
        </a>
        <td>
        <span style="color: #8C8C8C;"> ID: {{company_id._value}} </span>
        </td>
      {% else %}
        <a href="https://equipmentshare.looker.com/dashboards/28?Company+Name={{ company_name._filterable_value | url_encode }}" target="_blank"
        style="color:blue;">
          <b>
            {{ rendered_value }} ➔
          </b>
        </a>
        <td>
        <span style="color: #8C8C8C;"> ID: {{company_id._value}} </span>
        </td>
      {% endif %}
      ;;
  }
  dimension: revenue_buckets {
    label: "Rental Revenue Buckets"
    type: string
    sql: case when ${days_since} <= 365 and ${company_ttm_rental_revenue} >= 100000 then '$100k+'
          when ${days_since} <= 365 and ${company_ttm_rental_revenue} >= 50000 then '$50k-$100k'
          when ${days_since} <= 365 and ${company_ttm_rental_revenue} <= 50000 then '<$50k'
          else null
          end;;
  }
  dimension: region {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }
  dimension: debug_job_role {
    type: string
    sql: '{{ _user_attributes["job_role"] | remove: "'" | strip }}' ;;
  }


  measure: count {
    type: count
    drill_fields: [company_name, market_name, sp_name]
  }
  measure: total_count {
    type: count
  }
  measure: revenue {
    label: "Rental Revenue"
    type: sum
    sql: ${company_ttm_rental_revenue} ;;
    value_format_name: usd_0
  }

  measure: market_breakdown {
    type: count_distinct
    sql: ${dormant_unconverted_market_map.market_name} ;;
    drill_fields: [
      dormant_unconverted_market_map.company_name,
      dormant_unconverted_market_map.market_name,
      dormant_unconverted_market_map.ttm_rental_revenue
    ]
    filters: {
      field: dormant_unconverted_market_map.ttm_rental_revenue
      value: ">0"
    }
  }


  measure: ttm_rental_revenue_by_market {
    label: "TTM Rental Revenue"
    type: sum
    sql: coalesce(${dormant_unconverted_market_map.ttm_rental_revenue}, 0) ;;
    value_format_name: usd_0
  }

  measure: lifetime_rental_revenue_by_market {
    label: "Lifetime Rental Revenue"
    type: sum
    sql: coalesce(${dormant_unconverted_market_map.lifetime_rental_revenue}, 0) ;;
    value_format_name: usd_0
  }

  dimension: is_user_revenue_district {
    type: yesno
    sql:
    CASE
      WHEN ${user_district_pull_district.assigned_district} IS NOT NULL THEN true
      ELSE false
      END ;;
    }

  dimension: is_user_billing_location_district {
    type: yesno
    sql:
    CASE
      WHEN ${user_district_pull.assigned_district} IS NOT NULL THEN true
      ELSE false
    END ;;
  }


  measure: ttm_rental_revenue_in_user_district {
    type: sum
    sql: ${dormant_unconverted_market_map.ttm_rental_revenue} ;;
    filters: [dormant_unconverted_market_map.in_user_district_market: "yes"]
    value_format_name: usd_0
  }

  measure: lifetime_rental_revenue_in_user_district {
    type: sum
    sql: ${dormant_unconverted_market_map.lifetime_rental_revenue} ;;
    filters: [dormant_unconverted_market_map.in_user_district_market: "yes"]
    value_format_name: usd_0
  }

  # dimension: is_user_any_district {
  #   type: string
  #   sql:
  #   CASE
  #     WHEN ${user_district_pull_district.assigned_district} IS NOT NULL
  #       THEN 'Highest Rev. Market in District'
  #     WHEN ${user_district_pull.assigned_district} IS NOT NULL
  #       THEN 'Billing Location in District'
  #     ELSE 'Show All'
  #   END ;;
  # }





  dimension: ttm_revenue_html {
    label: "TTM Rental Revenue"
    type: number
    sql: ${company_ttm_rental_revenue} ;;
    value_format_name: usd_0
    html:
    {% assign rev_filter  = _filters['dormant_unconverted_companies.is_user_revenue_district'] | default: '' %}
    {% assign bill_filter = _filters['dormant_unconverted_companies.is_user_billing_location_district'] | default: '' %}

      {% if rev_filter contains 'Yes' or bill_filter contains 'Yes' %}
      <span>District: {{ ttm_rental_revenue_in_user_district._rendered_value }}</span><br>
      <span>Total: {{ rendered_value }}</span>
      {% else %}
      <span>{{ rendered_value }}</span>
      {% endif %} ;;
  }


  dimension: lifetime_revenue_html {
    group_label: "HTML Lifetime Rental Revenue"
    label: "Lifetime Rental Revenue"
    type: number
    sql: ${lifetime_rental_revenue} ;;
    value_format_name: "usd_0"
    html:
    {% assign rev_filter  = _filters['dormant_unconverted_companies.is_user_revenue_district'] | default: '' %}
    {% assign bill_filter = _filters['dormant_unconverted_companies.is_user_billing_location_district'] | default: '' %}

      {% if rev_filter contains 'Yes' or bill_filter contains 'Yes' %}
    <span>District: {{ ttm_rental_revenue_in_user_district._rendered_value }}</span><br>
    <span>Total: {{ rendered_value }}</span>
    {% else %}
    <span>{{ rendered_value }}</span>
    {% endif %} ;;
  }

dimension: user_district_filter {
  type: string
  sql: case when ${is_user_billing_location_district} = 'Yes'
            then 'Billing Location in District'
            when ${is_user_revenue_district} = 'Yes'
            then 'Highest Rev. Market in District'
            else 'Show All'
            end
    ;;
}

# Parameter: gives the user a dropdown control
  parameter: user_any_district {
    type: string
    allowed_value: { label: "Show All"                        value: "all" }
    allowed_value: { label: "Highest Rev. Market in District" value: "rev" }
    allowed_value: { label: "Billing Location in District"    value: "bill" }
    default_value: "all"
  }

  dimension: row_in_scope {
    type: yesno
    # sql:
    # (
    #   ({% parameter user_any_district %} = 'rev'  AND ${user_district_pull_district.assigned_district} IS NOT NULL)
    #   OR
    #   ({% parameter user_any_district %} = 'bill' AND ${user_district_pull.assigned_district}          IS NOT NULL)
    #   OR
    #   ({% parameter user_any_district %} = 'all')
    # ) ;;
    sql:
    (
    ({% parameter user_any_district %} = 'rev'  AND ${is_user_revenue_district} = 'Yes')
    OR
    ({% parameter user_any_district %} = 'bill' AND ${is_user_billing_location_district} = 'Yes')
    OR
    ({% parameter user_any_district %} = 'all')
    ) ;;
  }





  measure: quote_count {
    group_label: "Quote Drilldown"
    label: "Open Quotes"
    type: sum
    sql: ${quotes};;
     html:
     {% if quotes._value >= 1 %}
     <a href="#drillmenu" target="_self">
     {{ rendered_value }}
     <img src="https://imgur.com/ZCNurvk.png" height="15" width="15">
     </a>
     {% else %}
     {{ rendered_value }}
     {% endif %};;
     drill_fields: [
       company_name,
       dormant_unconverted_quotes.quote_number,
       dormant_unconverted_quotes.created_date,
       dormant_unconverted_quotes.equipment_class_name,
       dormant_unconverted_quotes.last_modified_date,
       dormant_unconverted_quotes.sp_name
       ]
  }
}
