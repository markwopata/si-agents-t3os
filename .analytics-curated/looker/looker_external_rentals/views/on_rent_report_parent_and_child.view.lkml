view: on_rent_report_parent_and_child {
    derived_table: {
      sql:
      select
        VENDOR
      , RENTAL_ID
      , ORDER_ID
      , CUSTOM_NAME
      , MAKE_AND_MODEL
      , JOBSITE
      , PURCHASE_ORDER_NAME
      , ASSET_CLASS
      , CATEGORY
      --, PARENT_CATEGORY
      , ORDERED_BY
      , RENTAL_START_DATE
      , SCHEDULED_OFF_RENT_DATE
      , NEXT_CYCLE_DATE
      , TOTAL_DAYS_ON_RENT
      , TOTAL_WEEKDAYS_ON_RENT
      , BILLING_DAYS_LEFT
      , CURRENT_ASSET_LOCATION
      , PRICE_PER_DAY
      , PRICE_PER_MONTH
      , PRICE_PER_WEEK
      , CURRENT_CYCLE
      , TO_DATE_RENTAL
      , PREVIOUS_DAY_DATE
      , coalesce(public_health_status, 'No Tracker Data') as public_health_status
      --, PREVIOUS_DAY_UTILIZATION
      , case
                when '{{ _user_attributes['user_timezone'] }}' = 'UTC' then NULLIF(PREVIOUS_DAY_UTILIZATION_utc,0)
                when '{{ _user_attributes['user_timezone'] }}' = 'America/Chicago' then NULLIF(PREVIOUS_DAY_UTILIZATION_cst,0)
                when '{{ _user_attributes['user_timezone'] }}' = 'America/America/Denver' then NULLIF(PREVIOUS_DAY_UTILIZATION_mnt,0)
                when '{{ _user_attributes['user_timezone'] }}' = 'America/Los_Angeles' then NULLIF(PREVIOUS_DAY_UTILIZATION_wst,0)
                --- else is Eastern Standard Time
                else NULLIF(PREVIOUS_DAY_UTILIZATION_est,0)
      end as PREVIOUS_DAY_UTILIZATION
      , TWO_DAYS_AGO_DATE
      --, TWO_DAYS_UTILIZATION
      , case
                when '{{ _user_attributes['user_timezone'] }}' = 'UTC' then NULLIF(TWO_DAYS_UTILIZATION_utc,0)
                when '{{ _user_attributes['user_timezone'] }}' = 'America/Chicago' then NULLIF(TWO_DAYS_UTILIZATION_cst,0)
                when '{{ _user_attributes['user_timezone'] }}' = 'America/America/Denver' then NULLIF(TWO_DAYS_UTILIZATION_mnt,0)
                when '{{ _user_attributes['user_timezone'] }}' = 'America/Los_Angeles' then NULLIF(TWO_DAYS_UTILIZATION_wst,0)
                --- else is Eastern Standard Time
                else NULLIF(TWO_DAYS_UTILIZATION_est,0)
      end as TWO_DAYS_UTILIZATION
      , THREE_DAYS_AGO_DATE
      --, THREE_DAYS_UTILIZATION
      , case
                when '{{ _user_attributes['user_timezone'] }}' = 'UTC' then NULLIF(THREE_DAYS_UTILIZATION_utc,0)
                when '{{ _user_attributes['user_timezone'] }}' = 'America/Chicago' then NULLIF(THREE_DAYS_UTILIZATION_cst,0)
                when '{{ _user_attributes['user_timezone'] }}' = 'America/America/Denver' then NULLIF(THREE_DAYS_UTILIZATION_mnt,0)
                when '{{ _user_attributes['user_timezone'] }}' = 'America/Los_Angeles' then NULLIF(THREE_DAYS_UTILIZATION_wst,0)
                --- else is Eastern Standard Time
                else NULLIF(THREE_DAYS_UTILIZATION_est,0)
      end as THREE_DAYS_UTILIZATION
      , FOUR_DAYS_AGO_DATE
      --, FOUR_DAYS_UTILIZATION
      , case
                when '{{ _user_attributes['user_timezone'] }}' = 'UTC' then NULLIF(FOUR_DAYS_UTILIZATION_utc,0)
                when '{{ _user_attributes['user_timezone'] }}' = 'America/Chicago' then NULLIF(FOUR_DAYS_UTILIZATION_cst,0)
                when '{{ _user_attributes['user_timezone'] }}' = 'America/America/Denver' then NULLIF(FOUR_DAYS_UTILIZATION_mnt,0)
                when '{{ _user_attributes['user_timezone'] }}' = 'America/Los_Angeles' then NULLIF(FOUR_DAYS_UTILIZATION_wst,0)
                --- else is Eastern Standard Time
                else NULLIF(FOUR_DAYS_UTILIZATION_est,0)
      end as FOUR_DAYS_UTILIZATION
      , FIVE_DAYS_AGO_DATE
      --, FIVE_DAYS_UTILIZATION
      , case
                when '{{ _user_attributes['user_timezone'] }}' = 'UTC' then NULLIF(FIVE_DAYS_UTILIZATION_utc,0)
                when '{{ _user_attributes['user_timezone'] }}' = 'America/Chicago' then NULLIF(FIVE_DAYS_UTILIZATION_cst,0)
                when '{{ _user_attributes['user_timezone'] }}' = 'America/America/Denver' then NULLIF(FIVE_DAYS_UTILIZATION_mnt,0)
                when '{{ _user_attributes['user_timezone'] }}' = 'America/Los_Angeles' then NULLIF(FIVE_DAYS_UTILIZATION_wst,0)
                --- else is Eastern Standard Time
                else NULLIF(FIVE_DAYS_UTILIZATION_est,0)
      end as FIVE_DAYS_UTILIZATION
      , SIX_DAYS_AGO_DATE
      --, SIX_DAYS_UTILIZATION
      , case
                when '{{ _user_attributes['user_timezone'] }}' = 'UTC' then NULLIF(SIX_DAYS_UTILIZATION_utc,0)
                when '{{ _user_attributes['user_timezone'] }}' = 'America/Chicago' then NULLIF(SIX_DAYS_UTILIZATION_cst,0)
                when '{{ _user_attributes['user_timezone'] }}' = 'America/America/Denver' then NULLIF(SIX_DAYS_UTILIZATION_mnt,0)
                when '{{ _user_attributes['user_timezone'] }}' = 'America/Los_Angeles' then NULLIF(SIX_DAYS_UTILIZATION_wst,0)
                --- else is Eastern Standard Time
                else NULLIF(SIX_DAYS_UTILIZATION_est,0)
      end as SIX_DAYS_UTILIZATION
      , SEVEN_DAYS_AGO_DATE
      --, SEVEN_DAYS_UTILIZATION
      , case
                when '{{ _user_attributes['user_timezone'] }}' = 'UTC' then NULLIF(SEVEN_DAYS_UTILIZATION_utc,0)
                when '{{ _user_attributes['user_timezone'] }}' = 'America/Chicago' then NULLIF(SEVEN_DAYS_UTILIZATION_cst,0)
                when '{{ _user_attributes['user_timezone'] }}' = 'America/America/Denver' then NULLIF(SEVEN_DAYS_UTILIZATION_mnt,0)
                when '{{ _user_attributes['user_timezone'] }}' = 'America/Los_Angeles' then NULLIF(SEVEN_DAYS_UTILIZATION_wst,0)
                --- else is Eastern Standard Time
                else NULLIF(SEVEN_DAYS_UTILIZATION_est,0)
      end as SEVEN_DAYS_UTILIZATION
      , case
                when '{{ _user_attributes['user_timezone'] }}' = 'UTC' then NULLIF(rental_period_utilization_utc,0)
                when '{{ _user_attributes['user_timezone'] }}' = 'America/Chicago' then NULLIF(rental_period_utilization_cst,0)
                when '{{ _user_attributes['user_timezone'] }}' = 'America/America/Denver' then NULLIF(rental_period_utilization_mnt,0)
                when '{{ _user_attributes['user_timezone'] }}' = 'America/Los_Angeles' then NULLIF(rental_period_utilization_wst,0)
                --- else is Eastern Standard Time
                else NULLIF(rental_period_utilization_est,0)
      end as rental_period_utilization
      , ASSET_ID
      , FILENAME
      , PURCHASE_ORDER_ID
      , RENTAL_LOCATION
      , UTILIZATION_STATUS
      , LAT_LON
      , RENTAL_START_DATE_AND_TIME
      , SCHEDULED_OFF_RENT_DATE_AND_TIME
      , JOBSITE_CITY_STATE
      , BENCHMARKED_ASSET_COUNT
      , UTILIZATION_30_DAY_CLASS_BENCHMARK
      , CLASS_COMPARABLE_ASSETS
      , CLASS_UTILIZATION_COMPARISON
      , BENCHMARKED_CATEGORY_ASSET_COUNT
      , UTILIZATION_30_DAY_CATEGORY_BENCHMARK
      , CATEGORY_COMPARABLE_ASSETS
      , CATEGORY_UTILIZATION_COMPARISON
      , BENCHMARKED_PARENT_CATEGORY_ASSET_COUNT
      , UTILIZATION_30_DAY_PARENT_CATEGORY_BENCHMARK
      , PARENT_CATEGORY_COMPARABLE_ASSETS
      , PARENT_CATEGORY_UTILIZATION_COMPARISON
      , onr.company_id as renting_company_id
      , onr.parent_company_id
      , cp.name as parent_company_name
      from
      BUSINESS_INTELLIGENCE.TRIAGE.STG_T3__ON_RENT onr
      left join es_warehouse.public.companies cp on onr.parent_company_id = cp.company_id
      where
      onr.company_id = {{ _user_attributes['company_id'] }}
      or
      onr.parent_company_id = {{ _user_attributes['company_id'] }}
      ;;
    }


    measure: count {
      label: "Total Assets"
      type: count
      drill_fields: [detail*]
    }

    dimension: primary_key {
      type: string
      primary_key: yes
      sql: concat(${vendor},${rental_id},${asset_id}) ;;
    }

    dimension: vendor {
      type: string
      sql: ${TABLE}."VENDOR" ;;
    }

    dimension: renting_company_id {
      type: number
      sql: ${TABLE}."RENTING_COMPANY_ID" ;;
    }

    dimension: rental_id {
      type: string
      sql: ${TABLE}."RENTAL_ID" ;;
      # primary_key: yes
      # value_format_name: id
    }

    dimension: ORDER_ID {
      type: string
      label: "Order ID"
      sql: ${TABLE}."ORDER_ID" ;;
      # primary_key: yes
      # value_format_name: id
    }

   dimension: parent_company_id {
    type: string
    sql: ${TABLE}."PARENT_COMPANY_ID" ;;
    # primary_key: yes
    # value_format_name: id
  }

  dimension: parent_company_name {
    type: string
    sql: ${TABLE}."PARENT_COMPANY_NAME" ;;
    # primary_key: yes
    # value_format_name: id
  }


    # dimension: custom_name_make_model {
    #   type: string
    #   sql: ${TABLE}."CUSTOM_NAME_MAKE_MODEL" ;;
    # }

    dimension: custom_name {
      type: string
      sql: ${TABLE}."CUSTOM_NAME" ;;

    }

    dimension: make_and_model {
      type: string
      sql: COALESCE(${TABLE}."MAKE_AND_MODEL",' ') ;;
    }

    dimension: jobsite {
      type: string
      sql: ${TABLE}."JOBSITE" ;;
    }

    dimension: purchase_order_name {
      label: "Purchase Order"
      type: string
      sql: ${TABLE}."PURCHASE_ORDER_NAME" ;;
    }

    dimension: asset_class {
      label: "Class"
      type: string
      sql: ${TABLE}."ASSET_CLASS" ;;
    }

    dimension: category {
      type: string
      sql: ${TABLE}."CATEGORY" ;;
    }

    dimension: public_health_status {
      label: "Tracker Health Status"
      type: string
      sql: ${TABLE}."PUBLIC_HEALTH_STATUS" ;;
    }

    dimension: ordered_by {
      type: string
      sql: ${TABLE}."ORDERED_BY" ;;
    }

    dimension: rental_start_date {
      type: date
      sql: ${TABLE}."RENTAL_START_DATE" ;;
      html: {{ rendered_value | date: "%b %d, %Y"  }};;
    }

    dimension: scheduled_off_rent_date {
      type: date
      sql: coalesce(${TABLE}."SCHEDULED_OFF_RENT_DATE", '2999-12-31') ;;
      html: {{ rendered_value | date: "%b %d, %Y"  }};;
    }

    dimension: next_cycle_date {
      type: date
      sql: ${TABLE}."NEXT_CYCLE_DATE" ;;
    }

    dimension: next_cycle_date_fmd {
      group_label: "FMD"
      label: "Next Billing Date"
      type: date
      sql: ${TABLE}."NEXT_CYCLE_DATE" ;;
      html: {{ rendered_value | date: "%b %d, %Y"  }};;
    }

    dimension: current_cycle {
      label: "Rental Billing Cycle"
      type: number
      sql: ${TABLE}."CURRENT_CYCLE" ;;
    }

    dimension: total_days_on_rent {
      label: "Days on Rent"
      type: number
      sql: ${TABLE}."TOTAL_DAYS_ON_RENT" ;;
    }

    dimension: total_weekdays_on_rent {
      label: "Days on Rent"
      type: number
      sql: ${TABLE}."TOTAL_WEEKDAYS_ON_RENT" ;;
      # CASE WHEN ${total_days_on_rent} > {TABLE}."TOTAL_WEEKDAYS_ON_RENT" then ${total_days_on_rent}
      # else
      # ${TABLE}."TOTAL_WEEKDAYS_ON_RENT"
      # end ;;
    }


    dimension: billing_days_left {
      type: number
      sql: ${TABLE}."BILLING_DAYS_LEFT" ;;
    }

    dimension: current_asset_location {
      type: string
      sql: ${TABLE}."CURRENT_ASSET_LOCATION" ;;
    }

    dimension: price_per_day {
      type: number
      sql: ${TABLE}."PRICE_PER_DAY" ;;
      value_format_name: usd_0
    }

    dimension: price_per_month {
      type: number
      sql: ${TABLE}."PRICE_PER_MONTH" ;;
      value_format_name: usd_0
    }

    dimension: price_per_week {
      type: number
      sql: ${TABLE}."PRICE_PER_WEEK" ;;
      value_format_name: usd_0
    }

    dimension: to_date_rental {
      type: number
      sql: ${TABLE}."TO_DATE_RENTAL" ;;
      value_format_name: usd_0
    }

    dimension: previous_day_date {
      type: date
      sql: ${TABLE}."PREVIOUS_DAY_DATE" ;;
      html: {{ rendered_value | date: "%b %d, %Y"  }};;
    }

    dimension: previous_day_on_time_hours {
      type: number
      sql: COALESCE(${TABLE}."PREVIOUS_DAY_UTILIZATION",0) ;;
      value_format_name: decimal_1
    }

    dimension: two_days_ago_date {
      type: date
      sql: ${TABLE}."TWO_DAYS_AGO_DATE" ;;
      html: {{ rendered_value | date: "%b %d, %Y"  }};;
    }

    dimension: two_days_ago_on_time_hours {
      type: number
      sql: COALESCE(${TABLE}."TWO_DAYS_UTILIZATION",0) ;;
      value_format_name: decimal_1
      html: {{rendered_value}} ;;
    }

    dimension: three_days_ago_date {
      type: date
      sql: ${TABLE}."THREE_DAYS_AGO_DATE" ;;
      html: {{ rendered_value | date: "%b %d, %Y"  }};;
    }

    dimension: three_days_ago_on_time_hours {
      type: number
      sql: COALESCE(${TABLE}."THREE_DAYS_UTILIZATION",0) ;;
      value_format_name: decimal_1
    }

    dimension: four_days_ago_date {
      type: date
      sql: ${TABLE}."FOUR_DAYS_AGO_DATE" ;;
      html: {{ rendered_value | date: "%b %d, %Y"  }};;
    }

    dimension: four_days_ago_on_time_hours {
      type: number
      sql: COALESCE(${TABLE}."FOUR_DAYS_UTILIZATION",0) ;;
      value_format_name: decimal_1
    }

    dimension: five_days_ago_date {
      type: date
      sql: ${TABLE}."FIVE_DAYS_AGO_DATE" ;;
      html: {{ rendered_value | date: "%b %d, %Y"  }};;
    }

    dimension: five_days_ago_on_time_hours {
      type: number
      sql: COALESCE(${TABLE}."FIVE_DAYS_UTILIZATION",0) ;;
      value_format_name: decimal_1
    }

    dimension: six_days_ago_date {
      type: date
      sql: ${TABLE}."SIX_DAYS_AGO_DATE" ;;
      html: {{ rendered_value | date: "%b %d, %Y"  }};;
    }

    dimension: six_days_ago_on_time_hours {
      type: number
      sql: COALESCE(${TABLE}."SIX_DAYS_UTILIZATION",0) ;;
      value_format_name: decimal_1
    }

    dimension: seven_days_ago_date {
      type: date
      sql: ${TABLE}."SEVEN_DAYS_AGO_DATE" ;;
      html: {{ rendered_value | date: "%b %d, %Y"  }};;
    }

    dimension: seven_days_ago_on_time_hours {
      type: number
      sql: COALESCE(${TABLE}."SEVEN_DAYS_UTILIZATION",0) ;;
      value_format_name: decimal_1
    }

    dimension: rental_period_utilization {
      type: number
      sql: COALESCE(${TABLE}."RENTAL_PERIOD_UTILIZATION",0)  ;;
      value_format_name: decimal_1
    }

    dimension: rental_period_utilization_hours {
      type: number
      sql: COALESCE(${TABLE}."RENTAL_PERIOD_UTILIZATION" / 3600,0)   ;;
      value_format_name: decimal_1
    }

    dimension: asset_id {
      type: number
      sql: ${TABLE}."ASSET_ID" ;;
      value_format_name: id
    }

    dimension: filename {
      type: string
      sql: ${TABLE}."FILENAME" ;;
    }

    dimension: purchase_order_id {
      type: number
      sql: ${TABLE}."PURCHASE_ORDER_ID" ;;
    }

    dimension: rental_location {
      type: string
      sql: ${TABLE}."RENTAL_LOCATION" ;;
    }

    dimension: utilization_status {
      type: string
      sql: ${TABLE}."UTILIZATION_STATUS" ;;
    }

    dimension: lat_lon {
      type: string
      sql: ${TABLE}."LAT_LON" ;;
    }

    dimension_group: rental_start_date_and_time {
      type: time
      sql: ${TABLE}."RENTAL_START_DATE_AND_TIME" ;;
    }

    dimension_group: scheduled_off_rent_date_and_time {
      type: time
      sql: ${TABLE}."SCHEDULED_OFF_RENT_DATE_AND_TIME" ;;
    }

    dimension: jobsite_city_state {
      type: string
      sql: ${TABLE}."JOBSITE_CITY_STATE" ;;
    }

    dimension: benchmarked_asset_count {
      type: number
      sql:coalesce( ${TABLE}."BENCHMARKED_ASSET_COUNT",0) ;;
    }

    dimension: utilization_30_day_class_benchmark {
      type: number
      sql: coalesce(${TABLE}."UTILIZATION_30_DAY_CLASS_BENCHMARK",0) ;;
      value_format_name: percent_1
    }

    measure: utilization_30_day_class_benchmark_measure {
      group_label: "Benchmarks"
      label: "30 Day Class Utilization Benchmark"
      type: number
      sql:coalesce(DIV0NULL(sum(${utilization_30_day_class_benchmark}) , count(${asset_id})),0);;
      value_format_name: percent_1
    }

    measure: benchmarked_asset_count_groups {
      group_label: "Benchmarks"
      label: "Class Benchmark Group"
      type: string
      sql:case
        when coalesce(DIV0NULL(sum(${benchmarked_asset_count}), count(${asset_id})),0) >= 1000 then '1,000+'
        when coalesce(DIV0NULL(sum(${benchmarked_asset_count}), count(${asset_id})),0) >= 500 then '500 - 1,000'
        when coalesce(DIV0NULL(sum(${benchmarked_asset_count}), count(${asset_id})),0) >= 100 then '100 - 500'
        when coalesce(DIV0NULL(sum(${benchmarked_asset_count}), count(${asset_id})),0) >= 50 then '50 - 100'
        when coalesce(DIV0NULL(sum(${benchmarked_asset_count}), count(${asset_id})),0) > 5 then 'Less than 50'
        else 'Not Enough Comparable Assets' end
    ;;
    }

    dimension: benchmarked_cateogry_asset_count {
      type: number
      sql:coalesce( ${TABLE}."BENCHMARKED_CATEGORY_ASSET_COUNT",0) ;;
    }

    dimension: utilization_30_day_category_benchmark {
      type: number
      sql: coalesce(${TABLE}."UTILIZATION_30_DAY_CATEGORY_BENCHMARK",0) ;;
      value_format_name: percent_1
    }

    measure: utilization_30_day_cateogry_benchmark_measure {
      group_label: "Benchmarks"
      label: "30 Day Cateogry Utilization Benchmark"
      type: number
      sql:coalesce(DIV0NULL(sum(${utilization_30_day_category_benchmark}) , count(${asset_id})),0);;
      value_format_name: percent_1
    }

    measure: benchmarked_category_asset_count_groups {
      group_label: "Benchmarks"
      label: "Category Comparable Assests"
      type: string
      sql:case
        when coalesce(DIV0NULL(sum(${benchmarked_cateogry_asset_count}), count(${asset_id})),0) >= 1000 then '1,000+'
        when coalesce(DIV0NULL(sum(${benchmarked_cateogry_asset_count}), count(${asset_id})),0) >= 500 then '500 - 1,000'
        when coalesce(DIV0NULL(sum(${benchmarked_cateogry_asset_count}), count(${asset_id})),0) >= 100 then '100 - 500'
        when coalesce(DIV0NULL(sum(${benchmarked_cateogry_asset_count}), count(${asset_id})),0) >= 50 then '50 - 100'
        when coalesce(DIV0NULL(sum(${benchmarked_cateogry_asset_count}), count(${asset_id})),0) > 5 then 'Less than 50'
        else 'Not Enough Comparable Assets' end
    ;;
    }

    dimension: benchmarked_parent_cateogry_asset_count {
      type: number
      sql:coalesce( ${TABLE}."BENCHMARKED_PARENT_CATEGORY_ASSET_COUNT",0) ;;
    }

    dimension: utilization_30_day_parent_category_benchmark {
      type: number
      sql: coalesce(${TABLE}."UTILIZATION_30_DAY_PARENT_CATEGORY_BENCHMARK",0) ;;
      value_format_name: percent_1
    }

    measure: utilization_30_day_parent_category_benchmark_measure {
      group_label: "Benchmarks"
      label: "30 Day Parent Cateogry Utilization Benchmark"
      type: number
      sql:coalesce(DIV0NULL(sum(${utilization_30_day_parent_category_benchmark}) , count(${asset_id})),0);;
      value_format_name: percent_1
    }

    measure: benchmarked_parent_category_asset_count_groups {
      group_label: "Benchmarks"
      label: "Parent Category Comparable Assests"
      type: string
      sql:case
        when coalesce(DIV0NULL(sum(${benchmarked_parent_cateogry_asset_count}), count(${asset_id})),0) >= 1000 then '1,000+'
        when coalesce(DIV0NULL(sum(${benchmarked_parent_cateogry_asset_count}), count(${asset_id})),0) >= 500 then '500 - 1,000'
        when coalesce(DIV0NULL(sum(${benchmarked_parent_cateogry_asset_count}), count(${asset_id})),0) >= 100 then '100 - 500'
        when coalesce(DIV0NULL(sum(${benchmarked_parent_cateogry_asset_count}), count(${asset_id})),0) >= 50 then '50 - 100'
        when coalesce(DIV0NULL(sum(${benchmarked_parent_cateogry_asset_count}), count(${asset_id})),0) > 5 then 'Less than 50'
        else 'Not Enough Comparable Assets' end
    ;;
    }

    dimension: asset_info {
      group_label: "Asset Info"
      # label: " "
      type: string
      # sql: coalesce(${rental_id},0) ;;
      sql: concat('Asset: ',${link_to_asset_t3}, ' Make and Model: ',${make_and_model}, ' Class: ', ${asset_class}, ' Jobsite: ', ${jobsite}, ' PO: ', ${purchase_order_name}, ' Current Asset Location: ', ${current_asset_location}) ;;
      html:
          <table>
        <tr>
          <td><b>Asset:</b> </td>
          <td>
            <font color="blue"> <u> <a  href="https://app.estrack.com/#/assets/all/asset/{{ on_rent_report.asset_id._rendered_value }}/history?selectedDate={{ current_date._value }}" target="_blank"style="text-decoration: none;">{{on_rent_report.custom_name._rendered_value}} </a></u></font?
      </td>
        </tr>
        <tr>
        <tr>
          <td><b>Make/Model:</b> </td>
          <td>{{on_rent_report.make_and_model._rendered_value}}</td>
        </tr>
        <tr>
          <td><b>Class:</b> </td>
          <td>{{on_rent_report.asset_class._rendered_value}}</td>
        </tr>
        <tr>
          <td><b>Jobsite:</b> </td>
          <td>{{on_rent_report.jobsite._rendered_value}}</td>
        </tr>
        <tr>
          <td><b>PO:</b> </td>
          <td>{{on_rent_report.purchase_order_name._rendered_value}}</td>
        </tr>
        <tr>
          <td><b>Current Asset Location:</b> </td>
          <td>{{on_rent_report.current_asset_location._rendered_value}}</td>
        </tr>
        </table>
          ;;
    }

    dimension: rental_info {
      group_label: "Rental Info"
      # label: " "
      type: string
      # sql: coalesce(${rental_id},0) ;;
      sql: concat('Vendor: ',${vendor}, 'Ordered By: ',${ordered_by}, ' Rental Start Date: ', ${rental_start_date}, ' Scheduled Off Rent Date: ', ${scheduled_off_rent_date}) ;;
      html:
          <table>
          <tr>
            <td><b>Vendor:</b> </td>
            <td>{{on_rent_report.vendor._rendered_value}}</td>
          </tr>
          <tr>
            <td><b>Ordered By:</b> </td>
            <td>{{on_rent_report.ordered_by._rendered_value}}</td>
          </tr>
          <tr>
            <td><b>Rental Start Date:</b> </td>
            <td>{{on_rent_report.rental_start_date._rendered_value }}</td>
          </tr>
          <tr>
            <td><b>Scheduled Off Rent Date:</b> </td>
            <td>
            {% if on_rent_report.scheduled_off_rent_date._rendered_value == '2999-12-31' %}  {% else %} {{on_rent_report.scheduled_off_rent_date._rendered_value }} {% endif %}
            </td>

        </table>
        ;;
    }

    dimension: billing_info {
      group_label: "Billing Info"
      # label: " "
      type: string
      # sql: coalesce(${rental_id},0) ;;
      sql: concat('Next Cycle Date: ',${next_cycle_date}, ' Total Days On Rent: ', ${total_days_on_rent}, ' Current Cycle: ', ${current_cycle} ) ;;
      html:
          <table>
          <tr>
            <td><b>Next Cycle Date:</b> </td>
            <td>{{on_rent_report.next_cycle_date._rendered_value }}</td>
          </tr>
          <tr>
            <td><b>Total Days On Rent:</b> </td>
            <td>{{on_rent_report.total_days_on_rent._rendered_value }}</td>
          </tr>
          <tr>
            <td><b>Billing Days Left:</b> </td>
            <td>{{on_rent_report.billing_days_left._rendered_value }}</td>
          </tr>
          <tr>
            <td><b>Rental Billing Cycle:</b> </td>
            <td>{{on_rent_report.current_cycle._rendered_value }}</td>
          </tr>
          </table>
          ;;
    }

    dimension: spend_info {
      group_label: "Spend Info"
      # label: " "
      type: string
      # sql: coalesce(${rental_id},0) ;;
      sql: concat('Day Rate: ',${price_per_day}, ' Week Rate: ', ${price_per_week}, ' Month Rate: ', ${price_per_month}, ' To Date Rental: ', ${to_date_rental}, ' Current Asset Location: ', ${current_asset_location}) ;;
      html:
          <table>
          <tr>
            <td><b>Day Rate:</b> </td>
            <td>{{on_rent_report.price_per_day._rendered_value}}</td>
          </tr>
          <tr>
            <td><b>Week Rate:</b> </td>
            <td>{{on_rent_report.price_per_week._rendered_value }}</td>
          </tr>
          <tr>
            <td><b>Month Rate:</b> </td>
            <td>{{on_rent_report.price_per_month._rendered_value }}</td>
          </tr>
          <tr>
            <td><b>Total Invoiced Amount:</b> </td>
            <td>{{on_rent_report.to_date_rental._rendered_value }}</td>
          </tr>
          <tr>
            <td><b>Days On Rent: </b> </td>
            <td>{{on_rent_report.total_days_on_rent._rendered_value }}</td>
          </tr>
            <tr>
            <td><b>Weekdays On Rent: </b> </td>
            <td>{{on_rent_report.total_weekdays_on_rent._rendered_value }}</td>
          </tr>
          </table>
          ;;
    }

    dimension: current_date {
      type: date
      sql: current_date() ;;
      html: {{ rendered_value | date: "%b %d, %Y" }};;
    }

    dimension: link_to_asset_t3 {
      type: string
      sql: ${TABLE}."CUSTOM_NAME" ;;
      label: "Asset"
      group_label: "Link to T3 Status Page"
      html: <font color="#0063f3"><u><a href="https://app.estrack.com/#/assets/all/asset/{{ asset_id._filterable_value }}/status" target="_blank">{{value}}</a></font></u>;;
    }

    measure: test_utilization_info {
      group_label: "Utilization Info"
      # label: " "
      type: string
      # sql: coalesce(${total_previous_day_on_time_hours},0) ;;
      sql: concat(${previous_day_date}, ': ',${total_previous_day_on_time_hours}, ' ',${two_days_ago_date}, ': ', ${total_two_days_ago_on_time_hours}, ' ', ${three_days_ago_date},  ': ', ${total_three_days_ago_on_time_hours},' ',${four_days_ago_date}, ': ', ${total_four_days_ago_on_time_hours},' ',${five_days_ago_date}, ': ', ${total_five_days_ago_on_time_hours},' ', ${six_days_ago_date}, ': ', ${total_six_days_ago_on_time_hours},' ', ${seven_days_ago_date}, ': ', ${total_seven_days_ago_on_time_hours}) ;;
      # sql: concat('Previous Day: ', ${total_previous_day_on_time_hours}, ' Two Days Ago: ', ${total_two_days_ago_on_time_hours}, ' Three Days Ago: ', ${total_three_days_ago_on_time_hours},' Four Days Ago: ', ${total_four_days_ago_on_time_hours},' Five Days Ago: ', ${total_five_days_ago_on_time_hours},' Six Days Ago: ', ${total_six_days_ago_on_time_hours},' Seven Days Ago: ', ${total_seven_days_ago_on_time_hours}) ;;
      html:
          <table>
          <tr>
          <td><b>{{ on_rent_report.previous_day_date._rendered_value }} Run Time Hrs.:</b></td>
          <td>{{ on_rent_report.total_previous_day_on_time_hours._rendered_value }}</td>
          </tr>
          </table> ;;
    }

    measure: total_run_time_hours{
      group_label: "Utilization Info"
      type: number
      sql: sum(${previous_day_on_time_hours} + ${two_days_ago_on_time_hours} + ${three_days_ago_on_time_hours} + ${four_days_ago_on_time_hours} + ${five_days_ago_on_time_hours} + ${six_days_ago_on_time_hours} + ${seven_days_ago_on_time_hours}) ;;
    }

    measure: utilization_info {
      group_label: "Utilization Info"
      # label: " "
      type: string
      # sql: coalesce(${total_previous_day_on_time_hours},0) ;;
      sql: concat(${previous_day_date}, ': ',${total_previous_day_on_time_hours}, ' ',${two_days_ago_date}, ': ', ${total_two_days_ago_on_time_hours}, ' ', ${three_days_ago_date},  ': ', ${total_three_days_ago_on_time_hours},' ',${four_days_ago_date}, ': ', ${total_four_days_ago_on_time_hours},' ',${five_days_ago_date}, ': ', ${total_five_days_ago_on_time_hours},' ', ${six_days_ago_date}, ': ', ${total_six_days_ago_on_time_hours},' ', ${seven_days_ago_date}, ': ', ${total_seven_days_ago_on_time_hours}) ;;
      # sql: concat('Previous Day: ', ${total_previous_day_on_time_hours}, ' Two Days Ago: ', ${total_two_days_ago_on_time_hours}, ' Three Days Ago: ', ${total_three_days_ago_on_time_hours},' Four Days Ago: ', ${total_four_days_ago_on_time_hours},' Five Days Ago: ', ${total_five_days_ago_on_time_hours},' Six Days Ago: ', ${total_six_days_ago_on_time_hours},' Seven Days Ago: ', ${total_seven_days_ago_on_time_hours}) ;;
      html:
          <table>
      <tr>
      <td><b>
          {% if  on_rent_report.rental_start_date._rendered_value  <=  on_rent_report.previous_day_date._rendered_value  %}
          <a >
          <td><b>{{ on_rent_report.previous_day_date._rendered_value }} Run Time Hrs.:</b></td>
          <td>{{ on_rent_report.total_previous_day_on_time_hours._rendered_value }}</td>
        </a>
          {% else %}
          {% endif %}
          </b></td>
       </tr>

        <tr>
        <td><b>
        {% if  on_rent_report.rental_start_date._rendered_value  <=  on_rent_report.two_days_ago_date._rendered_value  %}
        <a >
        <td><b>{{ on_rent_report.two_days_ago_date._rendered_value }} Run Time Hrs.:</b></td>
        <td>{{ on_rent_report.total_two_days_ago_on_time_hours._rendered_value }}</td>
        </a>
        {% else %}
        {% endif %}
        </b></td>
        </tr>


        <tr>
        <td><b>
        {% if  on_rent_report.rental_start_date._rendered_value  <=  on_rent_report.three_days_ago_date._rendered_value  %}
        <a >
        <td><b>{{ on_rent_report.three_days_ago_date._rendered_value }} Run Time Hrs.:</b></td>
        <td>{{ on_rent_report.total_three_days_ago_on_time_hours._rendered_value }}</td>
        </a>
        {% else %}
        {% endif %}
        </b></td>
        </tr>


        <tr>
        <td><b>
        {% if  on_rent_report.rental_start_date._rendered_value  <=  on_rent_report.four_days_ago_date._rendered_value  %}
        <a >
        <td><b>{{ on_rent_report.four_days_ago_date._rendered_value }} Run Time Hrs.:</b></td>
        <td>{{ on_rent_report.total_four_days_ago_on_time_hours._rendered_value }}</td>
        </a>
        {% else %}
        {% endif %}
        </b></td>
        </tr>


        <tr>
        <td><b>
        {% if  on_rent_report.rental_start_date._rendered_value  <=  on_rent_report.five_days_ago_date._rendered_value  %}
        <a >
        <td><b>{{ on_rent_report.five_days_ago_date._rendered_value }} Run Time Hrs.:</b></td>
        <td>{{ on_rent_report.total_five_days_ago_on_time_hours._rendered_value }}</td>
        </a>
        {% else %}
        {% endif %}
        </b></td>
        </tr>


        <tr>
        <td><b>
        {% if  on_rent_report.rental_start_date._rendered_value  <=  on_rent_report.six_days_ago_date._rendered_value  %}
        <a >
        <td><b>{{ on_rent_report.six_days_ago_date._rendered_value }} Run Time Hrs.:</b></td>
        <td>{{ on_rent_report.total_six_days_ago_on_time_hours._rendered_value }}</td>
        </a>
        {% else %}
        {% endif %}
        </b></td>
        </tr>

        <tr>
        <td><b>
        {% if  on_rent_report.rental_start_date._rendered_value  <=  on_rent_report.seven_days_ago_date._rendered_value  %}
        <a >
        <td><b>{{ on_rent_report.seven_days_ago_date._rendered_value }} Run Time Hrs.:</b></td>
        <td>{{ on_rent_report.total_seven_days_ago_on_time_hours._rendered_value }}</td>
        </a>
        {% else %}
        {% endif %}
        </b></td>
        </tr>

        </table>
        ;;
    }

    measure: total_previous_day_on_time_hours {
      type: sum
      sql: ${previous_day_on_time_hours} ;;
      html: {{rendered_value}} hrs. ;;
      #value_format_name: decimal_1
    }

    measure: total_previous_day_percent_of_day {
      type: sum
      sql: ${previous_day_on_time_hours}/24 ;;
      value_format_name: percent_1
    }

    measure: total_two_days_ago_on_time_hours {
      type: sum
      sql: ${two_days_ago_on_time_hours} ;;
      html: {{rendered_value}} hrs. ;;
      #value_format_name: decimal_1
    }

    measure: total_two_days_ago_percent_of_day {
      type: sum
      sql: ${two_days_ago_on_time_hours}/24 ;;
      value_format_name: percent_1
    }

    measure: total_three_days_ago_on_time_hours {
      type: sum
      sql: ${three_days_ago_on_time_hours} ;;
      html: {{rendered_value}} hrs. ;;
      #value_format_name: decimal_1
    }

    measure: total_three_days_ago_percent_of_day {
      type: sum
      sql: ${three_days_ago_on_time_hours}/24 ;;
      value_format_name: percent_1
    }

    measure: total_four_days_ago_on_time_hours {
      type: sum
      sql: ${four_days_ago_on_time_hours} ;;
      html: {{rendered_value}} hrs. ;;
      #value_format_name: decimal_1
    }

    measure: total_four_days_ago_percent_of_day {
      type: sum
      sql: ${four_days_ago_on_time_hours}/24 ;;
      value_format_name: percent_1
    }

    measure: total_five_days_ago_on_time_hours {
      type: sum
      sql: ${five_days_ago_on_time_hours} ;;
      html: {{rendered_value}} hrs. ;;
      #value_format_name: decimal_1
    }

    measure: total_five_days_ago_percent_of_day {
      type: sum
      sql: ${five_days_ago_on_time_hours}/24 ;;
      value_format_name: percent_1
    }

    measure: total_six_days_ago_on_time_hours {
      type: sum
      sql: ${six_days_ago_on_time_hours} ;;
      html: {{rendered_value}} hrs. ;;
      #value_format_name: decimal_1
    }

    measure: total_six_days_ago_percent_of_day {
      type: sum
      sql: ${six_days_ago_on_time_hours}/24 ;;
      value_format_name: percent_1
    }

    measure: total_seven_days_ago_on_time_hours {
      type: sum
      sql: ${seven_days_ago_on_time_hours} ;;
      html: {{rendered_value}} hrs. ;;
      #value_format_name: decimal_1
    }

    measure: total_seven_days_ago_percent_of_day {
      type: sum
      sql: ${seven_days_ago_on_time_hours}/24 ;;
      value_format_name: percent_1
    }

    measure: total_rental_period_on_time_seconds {
      type: sum
      sql: ${rental_period_utilization} ;;
      html: {{rendered_value}} ;;
      #value_format_name: decimal_1
    }

    measure: total_rental_period_on_time_hours {
      type: sum
      sql: ${rental_period_utilization_hours} ;;
      html: {{rendered_value}} hrs. ;;
      value_format_name: decimal_1
    }

    measure: rental_period_utilization_percent {
      label: "Rental Period Utilization"
      type: number
      sql: coalesce(
        CASE
          WHEN sum(${total_days_on_rent}) * 8 = 0 THEN NULL
          ELSE sum(${rental_period_utilization_hours}) / (sum(${total_days_on_rent}) * 8)
        END,0)  ;;
      html: {{rendered_value}} ;;
      value_format_name: percent_1
    }

    measure: over_under_utilization_class{
      group_label: "Benchmarks"
      label: "Compared To Class Average"
      type: string
      sql:case
        when ${benchmarked_asset_count_groups} = 'Not Enough Comparable Assets' then 'Not Enough Comparable Assets'
        when  ${rental_period_utilization_percent} - ${utilization_30_day_class_benchmark_measure} >= .05 then 'Higher Utilization'
        when ${rental_period_utilization_percent} - ${utilization_30_day_class_benchmark_measure} < .05
        and  ${rental_period_utilization_percent} - ${utilization_30_day_class_benchmark_measure} > -.05 then 'Average Utilization'
        when ${rental_period_utilization_percent} - ${utilization_30_day_class_benchmark_measure} <= -.05 then 'Lower Utilization'
        else 'Unknown' end
    ;;
    }

    measure: over_under_utilization_category{
      group_label: "Benchmarks"
      label: "Compared To Category Average"
      type: string
      sql:case
        when ${benchmarked_category_asset_count_groups} = 'Not Enough Comparable Assets' then 'Not Enough Comparable Assets'
        when  ${rental_period_utilization_percent} - ${utilization_30_day_parent_category_benchmark_measure} >= .05 then 'Higher Utilization'
        when ${rental_period_utilization_percent} - ${utilization_30_day_parent_category_benchmark_measure} < .05
        and  ${rental_period_utilization_percent} - ${utilization_30_day_parent_category_benchmark_measure} > -.05 then 'Average Utilization'
        when ${rental_period_utilization_percent} - ${utilization_30_day_parent_category_benchmark_measure} <= -.05 then 'Lower Utilization'
        else 'Unknown' end
    ;;
    }

    measure: over_under_utilization_parent_category{
      group_label: "Benchmarks"
      label: "Compared To Parent Category Average"
      type: string
      sql:case
        when ${benchmarked_parent_category_asset_count_groups} = 'Not Enough Comparable Assets' then 'Not Enough Comparable Assets'
        when  ${rental_period_utilization_percent} - ${utilization_30_day_parent_category_benchmark_measure} >= .05 then 'Higher Utilization'
        when ${rental_period_utilization_percent} - ${utilization_30_day_parent_category_benchmark_measure} < .05
        and  ${rental_period_utilization_percent} - ${utilization_30_day_parent_category_benchmark_measure} > -.05 then 'Average Utilization'
        when ${rental_period_utilization_percent} - ${utilization_30_day_parent_category_benchmark_measure} <= -.05 then 'Lower Utilization'
        else 'Unknown' end
    ;;
    }


    measure: utilization_hours {
      type: number sql: (${total_previous_day_on_time_hours});;
      value_format_name: decimal_1
      html: <div style="float: left
          ; width:{{ on_rent_report.total_previous_day_percent_of_day._value }}%
          ; background-color: rgba(0,128,255,{{ value }})
          ; text-align:left
          ; color: #FFFFFF
          ; border-radius: 5px"> <p style="margin-bottom: 0; margin-left: 4px;">{{ rendered_value }} </p>
          </div>
          ;;
    }

    dimension: asset_google_maps {
      type: string
      sql: concat('https://www.google.com/maps/place/',${lat_lon}) ;;
    }

    dimension: rental_start_date_and_time_formatted {
      group_label: "HTML Passed Date Format"
      label: "Rental Start Date/Time"
      type:  date_time
      sql: ${rental_start_date_and_time_raw} ;;
      html: {{ rendered_value | date: "%b %d, %Y %r"  }} {{ _user_attributes['user_timezone_label'] }};;
    }

    dimension: rental_end_date_and_time_formatted {
      group_label: "HTML Passed Date Format"
      label: "Rental End Date/Time"
      type:  date_time
      sql: ${scheduled_off_rent_date_and_time_raw} ;;
      html: {{ rendered_value | date: "%b %d, %Y %r"  }} {{ _user_attributes['user_timezone_label'] }} ;;
    }

    dimension: asset_used_last_seven_days {
      type: yesno
      sql: ${rental_period_utilization} > 0 ;;
    }

    measure: distinct_assets {
      type: count_distinct
      sql: ${asset_id} ;;
      drill_fields: [detail*]
    }

    measure: non_utilized_assets {
      label: "Non-Utilized Assets"
      type: count_distinct
      sql: ${asset_id} ;;
      filters: [asset_used_last_seven_days: "No", utilization_status: "show utilization"]
      drill_fields: [detail*]
    }

    measure: total_utilization_hours_last_seven_days {
      type: number
      sql: ${total_run_time_hours} ;;
      value_format_name: decimal_0
      drill_fields: [utilizaton_detail*]
    }

    dimension: health_detail {
      group_label: "Tracker Health Status Formatted"
      label: "Tracker Health Status"
      type: string
      sql: ${public_health_status} ;;
      html: {% if value == 'Healthy' %}

                        <span style="color: #00ad73;">◉ </span>{{rendered_value}}

        {% elsif value == 'Asset Likely Under Cover or Inside Building' %}

        <span style="color: #70d9a5;">◉ </span>{{rendered_value}}

        {% elsif value == 'Asset Likely In Low Cell Coverage Area' %}

        <span style="color: #c1ecd4;">◉ </span>{{rendered_value}}

        {% elsif value == 'Dead Asset Battery' %}

        <span style="color: #e55c66;">◉ </span>{{rendered_value}}

        {% elsif value == 'Drained Asset Battery' %}

        <span style="color: #FFB14E;">◉ </span>{{rendered_value}}

        {% elsif value == 'Master Cutoff Switch/Tracker Disconnected' %}

        <span style="color: #fcdd6a;">◉ </span>{{rendered_value}}

        {% elsif value == 'Needs Tracker Attention' %}

        <span style="color: #b02a3e;">◉ </span>{{rendered_value}}

        {% else %}

        {{rendered_value}}

        {% endif %};;
    }

    set: detail {
      fields: [
        rental_id,
        link_to_asset_t3,
        make_and_model,
        asset_class,
        jobsite,
        vendor,
        ordered_by,
        purchase_order_name,
        rental_start_date,
        scheduled_off_rent_date,
        total_days_on_rent,
        billing_days_left,
        current_asset_location,
        price_per_day,
        price_per_week,
        price_per_month

      ]
    }

    set: utilizaton_detail {
      fields: [
        rental_id,
        link_to_asset_t3,
        make_and_model,
        asset_class,
        jobsite,
        vendor,
        ordered_by,
        purchase_order_name,
        rental_start_date,
        scheduled_off_rent_date,
        total_days_on_rent,
        billing_days_left,
        current_asset_location,
        price_per_day,
        price_per_week,
        price_per_month,
        total_utilization_hours_last_seven_days

      ]
    }
  }

# ,two_days_ago_utilization as (
#       select
#           alr.asset_id,
#           ea.rental_id,
#           --convert_timezone('UTC', '{{ _user_attributes['user_timezone'] }}',dateadd('day',-2,current_timestamp))::date as two_days_ago_date,
#           round(sum(on_time)/3600,2) as two_days_ago_on_time_hours
#       from
#           asset_list_rental alr
#           left join equipment_assignments ea on ea.asset_id = alr.asset_id and ea.rental_id = alr.rental_id
#           left join es_warehouse.public.hourly_asset_usage hau on alr.asset_id = hau.asset_id and hau.report_range:start_range >= alr.start_date AND hau.report_range:end_range <= alr.end_date
#       where
#           convert_timezone('UTC','{{ _user_attributes['user_timezone'] }}',report_range:start_range) >= convert_timezone('UTC','{{ _user_attributes['user_timezone'] }}',dateadd('day',-2,current_timestamp))::date
#           AND convert_timezone('UTC','{{ _user_attributes['user_timezone'] }}',report_range:start_range) < convert_timezone('UTC','{{ _user_attributes['user_timezone'] }}',dateadd('day',-1,current_timestamp))::date
#       group by
#           alr.asset_id,
#           ea.rental_id
#           --convert_timezone('UTC', '{{ _user_attributes['user_timezone'] }}',dateadd('day',-2,current_timestamp))::date
#       )
#         ,three_days_ago_utilization as (
#       select
#           alr.asset_id,
#           ea.rental_id,
#           --convert_timezone('UTC', '{{ _user_attributes['user_timezone'] }}',dateadd('day',-3,current_timestamp))::date as three_days_ago_date,
#           round(sum(on_time)/3600,2) as three_days_ago_on_time_hours
#       from
#           asset_list_rental alr
#           left join equipment_assignments ea on ea.asset_id = alr.asset_id and ea.rental_id = alr.rental_id
#           left join es_warehouse.public.hourly_asset_usage hau on alr.asset_id = hau.asset_id and hau.report_range:start_range >= alr.start_date AND hau.report_range:end_range <= alr.end_date
#       where
#     convert_timezone('UTC','{{ _user_attributes['user_timezone'] }}',report_range:start_range) >= convert_timezone('UTC','{{ _user_attributes['user_timezone'] }}',dateadd('day',-3,current_timestamp))::date
#           AND convert_timezone('UTC','{{ _user_attributes['user_timezone'] }}',report_range:start_range) < convert_timezone('UTC','{{ _user_attributes['user_timezone'] }}',dateadd('day',-2,current_timestamp))::date
#       group by
#           alr.asset_id,
#           ea.rental_id
#           --convert_timezone('UTC', '{{ _user_attributes['user_timezone'] }}',dateadd('day',-3,current_timestamp))::date
#       )
#         ,four_days_ago_utilization as (
#       select
#           alr.asset_id,
#           ea.rental_id,
#           --convert_timezone('UTC', '{{ _user_attributes['user_timezone'] }}',dateadd('day',-4,current_timestamp))::date as four_days_ago_date,
#           round(sum(on_time)/3600,2) as four_days_ago_on_time_hours
#       from
#           asset_list_rental alr
#           left join equipment_assignments ea on ea.asset_id = alr.asset_id and ea.rental_id = alr.rental_id
#           left join es_warehouse.public.hourly_asset_usage hau on alr.asset_id = hau.asset_id and hau.report_range:start_range >= alr.start_date AND hau.report_range:end_range <= alr.end_date
#       where
#     convert_timezone('UTC','{{ _user_attributes['user_timezone'] }}',report_range:start_range) >= convert_timezone('UTC','{{ _user_attributes['user_timezone'] }}',dateadd('day',-4,current_timestamp))::date
#           AND convert_timezone('UTC','{{ _user_attributes['user_timezone'] }}',report_range:start_range) < convert_timezone('UTC','{{ _user_attributes['user_timezone'] }}',dateadd('day',-3,current_timestamp))::date
#       group by
#           alr.asset_id,
#           ea.rental_id
#           --convert_timezone('UTC', '{{ _user_attributes['user_timezone'] }}',dateadd('day',-4,current_timestamp))::date
#       )
#         ,five_days_ago_utilization as (
#       select
#           alr.asset_id,
#           ea.rental_id,
#           --convert_timezone('UTC', '{{ _user_attributes['user_timezone'] }}',dateadd('day',-5,current_timestamp))::date as five_days_ago_date,
#           round(sum(on_time)/3600,2) as five_days_ago_on_time_hours
#       from
#           asset_list_rental alr
#           left join equipment_assignments ea on ea.asset_id = alr.asset_id and ea.rental_id = alr.rental_id
#           left join es_warehouse.public.hourly_asset_usage hau on alr.asset_id = hau.asset_id and hau.report_range:start_range >= alr.start_date AND hau.report_range:end_range <= alr.end_date
#       where
#     convert_timezone('UTC','{{ _user_attributes['user_timezone'] }}',report_range:start_range) >= convert_timezone('UTC','{{ _user_attributes['user_timezone'] }}',dateadd('day',-5,current_timestamp))::date
#           AND convert_timezone('UTC','{{ _user_attributes['user_timezone'] }}',report_range:start_range) < convert_timezone('UTC','{{ _user_attributes['user_timezone'] }}',dateadd('day',-4,current_timestamp))::date
#       group by
#           alr.asset_id,
#           ea.rental_id
#           --convert_timezone('UTC', '{{ _user_attributes['user_timezone'] }}',dateadd('day',-5,current_timestamp))::date
#       )
#         ,six_days_ago_utilization as (
#       select
#           alr.asset_id,
#           ea.rental_id,
#           --convert_timezone('UTC', '{{ _user_attributes['user_timezone'] }}',dateadd('day',-6,current_timestamp))::date as six_days_ago_date,
#           round(sum(on_time)/3600,2) as six_days_ago_on_time_hours
#       from
#           asset_list_rental alr
#           left join equipment_assignments ea on ea.asset_id = alr.asset_id and ea.rental_id = alr.rental_id
#           left join es_warehouse.public.hourly_asset_usage hau on alr.asset_id = hau.asset_id and hau.report_range:start_range >= alr.start_date AND hau.report_range:end_range <= alr.end_date
#       where
#     convert_timezone('UTC','{{ _user_attributes['user_timezone'] }}',report_range:start_range) >= convert_timezone('UTC','{{ _user_attributes['user_timezone'] }}',dateadd('day',-6,current_timestamp))::date
#           AND convert_timezone('UTC','{{ _user_attributes['user_timezone'] }}',report_range:start_range) < convert_timezone('UTC','{{ _user_attributes['user_timezone'] }}',dateadd('day',-5,current_timestamp))::date
#       group by
#           alr.asset_id,
#           ea.rental_id
#           --convert_timezone('UTC', '{{ _user_attributes['user_timezone'] }}',dateadd('day',-6,current_timestamp))::date
#       )
#         ,seven_days_ago_utilization as (
#       select
#           alr.asset_id,
#           ea.rental_id,
#           --convert_timezone('UTC', '{{ _user_attributes['user_timezone'] }}',dateadd('day',-7,current_timestamp))::date as seven_days_ago_date,
#           round(sum(on_time)/3600,2) as seven_days_ago_on_time_hours
#       from
#           asset_list_rental alr
#           left join equipment_assignments ea on ea.asset_id = alr.asset_id and ea.rental_id = alr.rental_id
#           left join es_warehouse.public.hourly_asset_usage hau on alr.asset_id = hau.asset_id and hau.report_range:start_range >= alr.start_date AND hau.report_range:end_range <= alr.end_date
#       where
#     convert_timezone('UTC','{{ _user_attributes['user_timezone'] }}',report_range:start_range) >= convert_timezone('UTC','{{ _user_attributes['user_timezone'] }}',dateadd('day',-7,current_timestamp))::date
#           AND convert_timezone('UTC','{{ _user_attributes['user_timezone'] }}',report_range:start_range) < convert_timezone('UTC','{{ _user_attributes['user_timezone'] }}',dateadd('day',-6,current_timestamp))::date
#       group by
#           alr.asset_id,
#           ea.rental_id
#           --convert_timezone('UTC', '{{ _user_attributes['user_timezone'] }}',dateadd('day',-7,current_timestamp))::date
#       )
# test
