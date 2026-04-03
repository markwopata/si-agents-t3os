view: utilization_grading {
    derived_table: {
      sql: with data as (
                 select * from
                  VALUES
                    (12345,'2023-12-01', 'Bulldozers' ,'Caterpillar 10','New York',7.56, 2.33, 10, 3.21, 120, '6 - 8 hours per day', 1, 'Custom Asset 1')
                  , (12345,'2023-12-02', 'Bulldozers' ,'Caterpillar 10','New York',5.21, 2.11, 10, 3.55, 120, '5 - 6 hours per day', 1, 'Custom Asset 1')
                  , (12345,'2023-12-03', 'Bulldozers' ,'Caterpillar 10','New York',14.11, 2.44, 10, 3.01, 120, '8 - 16 hours per day', 1, 'Custom Asset 1')
                  , (12345,'2023-12-04', 'Bulldozers' ,'Caterpillar 10','New York',9.21, 2.11, 10, 3.55, 120, '8 - 16 hours per day', 1, 'Custom Asset 1')
                  , (12345,'2023-12-05', 'Bulldozers' ,'Caterpillar 10','New York',6.11, 2.44, 10, 3.01, 120, '6 - 8 hours per day', 1, 'Custom Asset 1')
                  , (12345,'2023-12-06', 'Bulldozers' ,'Caterpillar 10','New York',5.21, 2.11, 10, 3.55, 120, '5 - 6 hours per day', 1, 'Custom Asset 1')
                  , (12345,'2023-12-07', 'Bulldozers' ,'Caterpillar 10','New York',8.11, 2.44, 10, 3.01, 120, '8 - 16 hours per day', 1, 'Custom Asset 1')
                  , (12345,'2023-12-08', 'Bulldozers' ,'Caterpillar 10','New York',9.21, 2.11, 10, 3.55, 120, '8 - 16 hours per day', 1, 'Custom Asset 1')
                  , (12345,'2023-12-09', 'Bulldozers' ,'Caterpillar 10','New York',10.11, 2.44, 10, 3.01, 120, '8 - 16 hours per day', 1, 'Custom Asset 1')
                  , (12345,'2023-12-10', 'Bulldozers' ,'Caterpillar 10','New York',9.21, 2.11, 10, 3.55, 120, '8 - 16 hours per day', 1, 'Custom Asset 1')
                  , (12345,'2023-12-11', 'Bulldozers' ,'Caterpillar 10','New York',0, 2.44, 10, 3.01, 120, '0 - 2 hours per day', 1, 'Custom Asset 1')
                  , (12345,'2023-12-12', 'Bulldozers' ,'Caterpillar 10','New York',9.21, 2.11, 10, 3.55, 120, '8 - 16 hours per day', 1, 'Custom Asset 1')
                  , (12345,'2023-12-13', 'Bulldozers' ,'Caterpillar 10','New York',8.11, 2.44, 10, 3.01, 120, '8 - 16 hours per day', 1, 'Custom Asset 1')
                  , (66666,'2023-12-01', 'Bulldozers' ,'Caterpillar 10','New York',1.56, 2.33, 10, 3.21, 120, '1 - 2 hours per day', 1, 'Custom Asset 2')
                  , (66666,'2023-12-02', 'Bulldozers' ,'Caterpillar 10','New York',1.21, 2.11, 10, 3.55, 120, '1 - 2 hours per day', 1, 'Custom Asset 2')
                  , (66666,'2023-12-03', 'Bulldozers' ,'Caterpillar 10','New York',1.11, 2.44, 10, 3.01, 120, '1 - 2 hours per day', 1, 'Custom Asset 2')
                  , (99999,'2023-12-02', 'Bulldozers' ,'Caterpillar 15','New York',0.21, 2.11, 10, 3.55, 120, '0 - 2 hours per day', 1, 'Custom Asset 3')
                  , (99999,'2023-12-03', 'Bulldozers' ,'Caterpillar 15','New York',1.11, 2.44, 10, 3.01, 120, '0 - 2 hours per day', 1, 'Custom Asset 3')
                  , (88888,'2023-12-01', 'Bulldozers' ,'Caterpillar 20','New York',12.21, 2.33, 10, 3.21, 120, '8 - 12 hours per day', 1, 'Custom Asset 4')
                  , (88888,'2023-12-02', 'Bulldozers' ,'Caterpillar 20','New York',16.11, 2.11, 10, 3.55, 120, '16 - 24 hours per day', 1, 'Custom Asset 4')
                  , (22222,'2023-12-01', 'Bulldozers' ,'Caterpillar 10','New York',6.2, 2.33, 10, 3.21, 120, '6 - 8 hours per day', 1, 'Custom Asset 5')
                  , (77777,'2023-12-01', 'Mini Excavators' ,'Caterpillar 301.5','New York',3.11, 5.44, 2, 2.01, 105, '2 - 4 hours per day', 1, 'Custom Asset 6')
                  , (77777,'2023-12-02', 'Mini Excavators' ,'Caterpillar 301.5','New York',5.21, 4.11, 2, 4.55, 105, '5 - 6 hours per day', 1, 'Custom Asset 6')
                  , (77777,'2023-12-03', 'Mini Excavators' ,'Caterpillar 301.5','New York',3.11, 4.44, 2, 2.01, 105, '2 - 4 hours per day', 1, 'Custom Asset 6')

                  )
                  , temp_slider as (
                  SELECT 1 AS num
                  UNION ALL
                  SELECT num + 1 FROM temp_slider
                  WHERE num + 1 <= 24
                  )
                  , expected_hours_slider as (
                  SELECT 1 as dummy_join_param
                  , CAST(num AS DECIMAL(15,2)) as expected_utilization_hours
                  FROM temp_slider t
                  -- THIS NEEDS TO BE THE FILTER VALUE
                  WHERE {% condition day_utilization_expectation %} CAST(num AS INT)  {% endcondition %}
                  --WHERE CAST(num AS DECIMAL(15,2)) = 3
                    )
                   --pre as (
                  select
                    concat(COLUMN2, COLUMN1) as pk
                  , COLUMN1 as ASSET_ID
                  , COLUMN2 as Date
                  , COLUMN3 as Category
                  , COLUMN4 as Make_Model
                  , COLUMN5 as Location
                  , COLUMN6 as RUN_TIME
                  , COLUMN7 as COMPANY_COMPARABLE_RUN_TIME
                  , COLUMN8 as COMPANY_COMPARABLE_COUNT
                  , COLUMN9 as ALL_COMPARABLE_RUN_TIME
                  , COLUMN10 as ALL_COMPARABLE_COUNT
                  , COLUMN11 as RATING
                  , COLUMN13 as CUSTOM_NAME
                  , DAYOFWEEK(TO_DATE(COLUMN2)) as weekday




                  , case when DAYOFWEEK(TO_DATE(COLUMN2)) in (6,7) then 'Yes' else 'No' end as Weekend_Filter
                  , expected_utilization_hours
                  from data d
                  join expected_hours_slider eh on (d.COLUMN12 = eh.dummy_join_param)



                  ;;
    }


    filter: day_utilization_expectation {
    group_label: "Filters"
    type: number
    }

    filter: high_low_good_bad {
      group_label: "Filters"
      type: string
    }

    filter: weekend_yesno {
      group_label: "Filters"
      type: yesno
    }

    measure: count {
      type: count
      drill_fields: [detail*]
    }

    dimension: pk {
      type: string
      primary_key: yes
      sql: ${TABLE}."PK" ;;
    }

    dimension: custom_name {
      type: string
      sql: ${TABLE}."CUSTOM_NAME" ;;
    }

    dimension: expected_utilization_hours {
      type: number
      sql: ${TABLE}."EXPECTED_UTILIZATION_HOURS" ;;
    }

    measure: expected_utilization_hours_avg {
      label: "Selected Expected Utilization Hours"
      type: average
      sql: ${expected_utilization_hours} ;;
    }

    dimension: asset_id {
      type: number
      sql: ${TABLE}."ASSET_ID" ;;
    }

    dimension: weekday {
      type: number
      sql: ${TABLE}."WEEKDAY" ;;
    }

    dimension: weekday_count {
      type: number
      sql:  case when ${weekday} in (6,7) then 0 else 1 end ;;
    }

  dimension: weekday_name {
    type: string
    sql:  case when ${weekday} in (6,7) then 'Weekday' else 'Weekend' end ;;
  }

    measure: asset_id_distinct {
      type: average_distinct
      sql: ${asset_id} ;;
    }

    dimension: date {
      type: date
      sql: ${TABLE}."DATE" ;;
    }

    measure: date_count {
      label: "Total Selected Days"
      type: count
    }

    measure: date_count_ran {
      label: "Days Ran"
      type: sum
      sql:  case when ${run_time} > 0 then 1 else 0 end ;;
    }

    measure: date_count_percent {
      label: "Percent of Days Ran"
      type: number
      value_format: "##.#"
      sql:  (${date_count_ran} / ${date_count}) * 100 ;;
      html: {{rendered_value}} % ;;
    }

    measure: date_count_distinct {
      type: count_distinct
      sql: ${date} ;;
    }

    dimension: category {
      type: string
      sql: ${TABLE}."CATEGORY" ;;
    }

    dimension: make_model {
      type: string
      sql: ${TABLE}."MAKE_MODEL" ;;
    }

    dimension: location {
      type: string
      sql: ${TABLE}."LOCATION" ;;
    }

    dimension: run_time {
      type: number
      sql: ${TABLE}."RUN_TIME" ;;
    }

    measure: run_time_sum {
      group_label: "Run Times"
      label: "Total Run Time"
      type: sum
      sql: ${run_time} ;;
      html: {{rendered_value}} hrs. ;;
    }

    measure: run_time_weekday {
      group_label: "Run Times"
      label: "Run Time Weekday"
      type: sum
      sql: case when ${weekday} in (6,7) then 0 else ${run_time} end ;;
    }

    measure: run_time_weekend {
      group_label: "Run Times"
      label: "Run Time Weekend"
      type: sum
      sql: case when ${weekday} not in (6,7) then 0 else ${run_time} end ;;
    }

    measure: weekday_weekend_ratio {
      label: "Weedend Ratio"
      type: percent_of_total
     sql:${run_time_weekday} / ${run_time_weekday} + ${run_time_weekend} ;;
    }

    measure: run_time_avg {
      group_label: "Run Times"
      label: "Average Run Time"
      value_format: "##.##"
      type: average
      sql: ${run_time} ;;
    }

    measure: run_time_max {
      group_label: "Run Times"
      label: "Run Time Max"
      type: max
      sql: ${run_time} ;;
    }

    dimension: company_comparable_run_time {
      type: number
      sql: ${TABLE}."COMPANY_COMPARABLE_RUN_TIME" ;;
    }

    measure: company_comparable_run_time_sum {
      group_label: "Run Times"
      label: "Company Comparable Run Time"
      type: sum
      sql: ${company_comparable_run_time} ;;
    }

    measure: company_comparable_run_time_avg {
      group_label: "Run Times"
      label: "Company Comparable Run Time Avg"
      type: average
      sql: ${company_comparable_run_time} ;;
    }

    measure: company_comparable_run_time_max {
      group_label: "Run Times"
      label: "Company Comparable Run Time Max"
      type: max
      sql: ${company_comparable_run_time} ;;
    }

    dimension: company_comparable_count {
      type: number
      sql: ${TABLE}."COMPANY_COMPARABLE_COUNT" ;;
    }

    measure: company_comparable_count_avg {
      type: average
      sql: ${company_comparable_count};;
    }

    dimension: all_comparable_run_time {
      type: number
      sql: ${TABLE}."ALL_COMPARABLE_RUN_TIME" ;;
    }

    measure: all_comparable_run_time_sum {
      group_label: "Run Times"
      label: "All Comparable Run Time"
      type: sum
      sql: ${all_comparable_run_time} ;;
    }

    measure: all_comparable_run_time_avg {
      group_label: "Run Times"
      label: "All Comparable Run Time Avg"
      type: average
      sql: ${all_comparable_run_time} ;;
    }

    measure: all_comparable_run_time_max {
      group_label: "Run Times"
      label: "All Comparable Run Time Max"
      type: max
      sql: ${all_comparable_run_time} ;;
    }

    dimension: all_comparable_count {
      type: number
      sql: ${TABLE}."ALL_COMPARABLE_COUNT" ;;
    }

    dimension: rating {
      type: string
      sql: ${TABLE}."RATING" ;;
    }

    dimension: grading {
      group_label: "Gradings"
      type: string
      sql: case
      when ${run_time} between 16 and 24 then '16 - 24 hours per day'
      when ${run_time} between 8 and 16 then '8 - 16 hours per day'
      when ${run_time} between 6 and 8 then '6 - 8 hours per day'
      when ${run_time} between 4 and 6 then '4 - 6 hours per day'
      when ${run_time} between 2 and 4 then '2 - 4 hours per day'
      when ${run_time} between 0 and 3 then '0 - 2 hours per day'
      else 'No Data Available' end
      ;;
    }

  measure: grading_over_days {
    group_label: "Gradings"
    type: string
    sql: case
      when ${run_time_avg} between 16 and 24 then '16 - 24 hours per day'
      when ${run_time_avg} between 8 and 16 then '8 - 16 hours per day'
      when ${run_time_avg} between 6 and 8 then '6 - 8 hours per day'
      when ${run_time_avg} between 4 and 6 then '4 - 6 hours per day'
      when ${run_time_avg} between 2 and 4 then '2 - 4 hours per day'
      when ${run_time_avg} between 0 and 3 then '0 - 2 hours per day'
      else 'No Data Available' end
      ;;
  }

  measure: 24_hours_chart_missing {
    group_label: "24 Hours Chart"
    label: "Not Utilized"
    type: number
    sql: 24 - ${run_time_avg}  ;;
  }

  measure: expected_value {
    group_label: "Expected"
    type: string
    sql: case
      when ${run_time_avg} between ${expected_utilization_hours_avg} * .9 and ${expected_utilization_hours_avg} * 1.1 then 'Meeting Expected Utilization'
      when ${run_time_avg} > ${expected_utilization_hours_avg} * 1.1 then 'Above Expected Utilization'
      when ${run_time_avg} < ${expected_utilization_hours_avg} * .9 then 'Below Expected Utilization'
      else 'No Data Available' end
      ;;
  }

  measure: expected_text {
    group_label: "Expected"
    type: string
    sql: case
      when ${run_time_avg} between ${expected_utilization_hours_avg} * .9 and ${expected_utilization_hours_avg} * 1.1
      then concat('On average, ', ${asset_id_distinct}, ' was used within 10% of the expected utilization over the selected time period')
      when ${run_time_avg} > ${expected_utilization_hours_avg} * 1.1
      then concat('On average, ', ${asset_id_distinct}, ' was used above the expected utilization over the selected time period')
      when ${run_time_avg} < ${expected_utilization_hours_avg} * .9
      then concat('On average, ', ${asset_id_distinct}, ' was used below the expected utilization over the selected time period')
      else 'No Data Available' end
      ;;
  }

  measure: expected_text_group {
    group_label: "Expected"
    type: string
    sql: case
      when ${run_time_avg} between ${expected_utilization_hours_avg} * .9 and ${expected_utilization_hours_avg} * 1.1
      then concat('On average, this group of assets were used within 10% of the expected utilization over the selected time period')
      when ${run_time_avg} > ${expected_utilization_hours_avg} * 1.1
      then concat('On average, this group of assets were used above the expected utilization over the selected time period')
      when ${run_time_avg} < ${expected_utilization_hours_avg} * .9
      then concat('On average, this group of assets were used below the expected utilization over the selected time period')
      else 'No Data Available' end
      ;;
  }

  measure: text_recap {
    group_label: "Text"
    type: string
    sql: case
      when ${run_time_sum} >= ${company_comparable_run_time_sum}
      then concat(${asset_id_distinct},' has an average run time between ',${grading_over_days},', which is greater than or equal to comparable assets in your fleet.')
      when ${run_time_sum} < ${company_comparable_run_time_sum}
      then concat(${asset_id_distinct},' has an average run time between ',${grading_over_days},', which is less than than comparable assets in your fleet.')
      else 'No Data Available' end
      ;;
  }

  measure: text_recap_2 {
    group_label: "Text"
    type: string
    sql: case
      when ${run_time_weekend} > 0
      then concat(${asset_id_distinct},' ran on the weekend, which can contribute to higher usage than other similar assets.')
      else
      concat(${asset_id_distinct},' did not run on the weekend during this period, which affected utilization.')
      end
      ;;
  }

  measure: text_recap_3 {
    group_label: "Text"
    type: string
    sql: case
    when ${date_count} = 1
    then concat('The selected time period lasted ', ${date_count}, ' day and ', ${asset_id_distinct}, ' is being compared to ', ${company_comparable_count_avg}, ' similar assets in your companies fleet.')
    when ${date_count} > 1
    then concat('The selected time period lasted ', ${date_count}, ' days and ', ${asset_id_distinct}, ' is being compared to ', ${company_comparable_count_avg}, ' similar assets in your companies fleet.')
    else
    concat(${asset_id_distinct}, ' did not run during the selected period')
    end
      ;;
  }

    set: detail {
      fields: [
        asset_id,
        date,
        category,
        make_model,
        location,
        run_time,
        company_comparable_run_time,
        company_comparable_count,
        all_comparable_run_time,
        all_comparable_count,
        rating
      ]
    }
  }
