include: "/_base/people_analytics/looker/time_entries_t3.view.lkml"

view: +time_entries_t3 {

  dimension: time_entry_primary_key {
    primary_key: yes
    type: string
    sql: ${time_entry_id};;
  }


  dimension_group: end {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${end};;
    description: "End date of time entry."
  }

  dimension_group: end_date_month {
    type: time
    timeframes: [month]
    sql: ${TABLE}.end ;;
    convert_tz: yes
  }

  dimension_group: start {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${start};;
    description: "Start date of time entry."
  }

  dimension: time_entry_date {
    type: date
    sql: sql: FORMAT_DATE('%Y-%m-%d',cast( ${start} as date));;

  }

  dimension: time_entry_link {
    type: string
    html:
      <font color="blue "><u><a href = "https://app.estrack.com/time-tracking/employee/{{ user_id | url_encode }}/{{ start_date | url_encode }}" target="_blank">{{time_entry_id}}</a></font></u>;;
    sql: 'Link' ;;
  }
  }
