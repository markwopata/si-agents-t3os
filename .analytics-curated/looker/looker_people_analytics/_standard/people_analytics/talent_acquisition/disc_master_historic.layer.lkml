include: "/_base/people_analytics/talent_acquisition/disc_master_historic.view.lkml"


view: +disc_master_historic {
  label: "Disc Master Historic"

  ############### DIMENSIONS ###############

  dimension: environment_d {
    type: number
    sql: TRY_CAST( SPLIT_PART( ${environment_style},' ',1) AS INTEGER) ;;
    description: "D score from environment style"
  }

  dimension: environment_i {
    type: number
    sql: TRY_CAST( SPLIT_PART( ${environment_style},' ',2) AS INTEGER);;
    description: "I score from environment style"
  }

  dimension: environment_s {
    type: number
    sql: TRY_CAST( SPLIT_PART( ${environment_style},' ',3) AS INTEGER) ;;
    description: "S score from environment style"
  }

  dimension: environment_c {
    type: number
    sql: TRY_CAST( SPLIT_PART( ${environment_style},' ',4) AS INTEGER) ;;
    description: "C score from environment style"
  }

  dimension: link_to_disc_pdf {
    type: string
    html: <font color="blue "><u><a href ="https://www.discoveryreport.com/v/{{disc_code._value}}"target="_blank">{{environment_style._value}}</a></font></u> ;;
    sql: ${disc_code} ;;
  }

  dimension: dominant_environment {
    type: string
    sql:  case when ${blend} = 'LEVEL Blend' then 'Level'
          else
            case greatest(${environment_d}, ${environment_i}, ${environment_s}, ${environment_c}) when ${environment_d} then 'D' when ${environment_i} then 'I' when ${environment_s} then 'S' when ${environment_c} then 'C' else null
            end
          end
      ;;
  }

  ################ DATES ################

  dimension_group: disc_sent_date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${disc_sent} ;;
  }

  dimension_group: updated_date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${updated} ;;
  }

  dimension_group: completed_date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${completed} ;;
  }
}
