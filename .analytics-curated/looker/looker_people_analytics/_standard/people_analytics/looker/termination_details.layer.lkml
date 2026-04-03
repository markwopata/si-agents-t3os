include: "/_base/people_analytics/looker/termination_details.view.lkml"

view: +termination_details {

  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw,date,week,month,quarter,year]
    sql: ${_es_update_timestamp} ;;
  }
  dimension: employee_id {
    value_format_name: id
  }
  # dimension: reason {
  #   type: string
  #   sql: ${TABLE}."REASON" ;;
  # }
  # dimension: rehireable {
  #   type: yesno
  # }
  dimension_group: termination {
    type: time
    timeframes: [raw,date,week,month,quarter,year]
    sql: ${termination} ;;
  }
  dimension: termination_type {
    type: string
    sql: CASE WHEN ${reason} = 'Attendance' then 'Involuntary'
              WHEN ${reason} = 'Deceased' then 'Involuntary'
              WHEN ${reason} = 'Internship Ended' then 'Involuntary'
              WHEN ${reason} = 'Contract Ended' then 'Involuntary'
              WHEN ${reason} = 'Failure to return from LOA' then 'Involuntary'
              WHEN ${reason} = 'Gross Misconduct' then 'Involuntary'
              WHEN ${reason} = 'Unsatisfactory Performance' then 'Involuntary'
              WHEN ${reason} = 'Layoff' then 'Involuntary'
              WHEN ${reason} = 'Other' then 'Involuntary'
              WHEN ${reason} = 'Performance' then 'Involuntary'
              WHEN ${reason} = 'Position Eliminated' then 'Involuntary'
              WHEN ${reason} = 'zzz - Do Not Use - Violate Company Handbook' then 'Involuntary'
              WHEN ${reason} = 'zzz - Do Not Use - Performance, Absenteeism' then 'Involuntary'
              WHEN ${reason} = 'Background Check Unacceptable' then 'Involuntary'
              WHEN ${reason} = 'COVID-19 layoff' then 'Involuntary'
              WHEN ${reason} = 'Close of Market' then 'Involuntary'
              WHEN ${reason} = 'Manager''s Call' then 'Involuntary'
              WHEN ${reason} = 'Non-Compete' then 'Involuntary'
              WHEN ${reason} = 'Resigned - Personal' then 'Voluntary'
              WHEN ${reason} = 'Resigned - Retirement' then 'Voluntary'
              WHEN ${reason} = 'Resigned - To attend school' then 'Voluntary'
              WHEN ${reason} = 'Resigned - Failed to give notice' then 'Voluntary'
              WHEN ${reason} = 'Medical' then 'Voluntary'
              WHEN ${reason} = 'Death' then 'Voluntary'
              WHEN ${reason} = 'Resigned - In Lieu of Termination' then 'Voluntary'
              WHEN ${reason} = 'Resigned - Dissatisfied with job' then 'Voluntary'
              WHEN ${reason} = 'Resigned - Dissatisfied with pay' then 'Voluntary'
              WHEN ${reason} = 'Resigned - Relocation' then 'Voluntary'
              WHEN ${reason} = 'Resigned - Military Service' then 'Voluntary'
              WHEN ${reason} = 'Dissatisfaction with Job' then 'Voluntary'
              WHEN ${reason} = 'Job Abandonment' then 'Voluntary'
              WHEN ${reason} = 'Not a good fit' then 'Voluntary'
              WHEN ${reason} = 'Other Employment' then 'Voluntary'
              WHEN ${reason} = 'Personal' then 'Voluntary'
              WHEN ${reason} = 'Relocation' then 'Voluntary'
              WHEN ${reason} = 'Resigned' then 'Voluntary'
              WHEN ${reason} = 'Retired' then 'Voluntary'
              WHEN ${reason} = 'Never Started' then 'Voluntary'
    ELSE null END;;
  }

  dimension: voluntary_involuntary {
    type: string
    sql: CASE WHEN CONTAINS(${termination_category}, 'Involuntary') then 'Involuntary'
    ELSE 'Voluntary' END;;
  }

  # measure: count {
  #   type: count
  # }
}
