view: ghosts_trackers_notes {
  derived_table: {
  sql: select distinct gtn.*,
  try_to_date(left(gtn.date_submitted,10)) as submit_date
  from analytics.ghost_trackers.ghosts_trackers_notes gtn
  where submit_date::date >= {% date_start date_filter %}
  and submit_date::date <= {% date_end date_filter %}
  ;;
  }

  dimension_group: _fivetran_synced {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_FIVETRAN_SYNCED" AS TIMESTAMP_NTZ) ;;
  }
  dimension: fivetran_synced_cst_12h {
    type: string
    label: "Fivetran Synced (Central, 12-hour)"
    sql:
    TO_CHAR(
      CONVERT_TIMEZONE('UTC','America/Chicago', ${_fivetran_synced_raw}),
      'MM-DD HH12:MI AM'
    ) ;;
  }
  dimension: _row {
    type: number
    primary_key: yes
    sql: ${TABLE}."_ROW" ;;
  }
  dimension: asset {
    type: string
    sql: ${TABLE}."ASSET" ;;
    description: "Current asset for the tracker serial number (tracker_sn) entry"
  }
  dimension: companyname {
    type: string
    label: "Company Name"
    sql: ${TABLE}."COMPANYNAME" ;;
  }
  dimension: count_field {
    label: "Count"
    type: number
    sql: ${TABLE}."COUNT" ;;
  }
  dimension: cs_notes {
    type: string
    label: "CS Notes"
    sql: ${TABLE}."CS_NOTES" ;;
    description: "Additional context on the error type involved"
  }
  dimension: installer_notes {
    type: string
    sql: ${TABLE}."INSTALLER_NOTES" ;;
  }
  dimension: submit_date {
    label: "Date Submitted"
    type: date
    sql:${TABLE}."SUBMIT_DATE";;
    description: "Date the entry was made"
  }
  dimension: completion_status {
    type: string
    sql: coalesce(${TABLE}."COMPLETION_STATUS",'Unassigned') ;;
    description: "Status of the entry and if it was handled or needs to be redone"
  }
  dimension: error_type {
    type: string
    sql: ${TABLE}."ERROR_TYPE" ;;
    description: "Upload error type by the installer, most commonly swaps or invalid serial number"
  }
  dimension: install_type {
    type: string
    sql: ${TABLE}."INSTALL_TYPE" ;;
  }
  dimension: swapped_tracker_sn {
    label: "Swapped Tracker SN"
    type: string
    sql: ${TABLE}."SWAPPED_TRACKER_SN" ;;
    description: "The serial number of the tracker that was swapped for the current entry"
  }
  dimension: tracker_sn {
    label: "Tracker SN"
    type: string
    sql: ${TABLE}."TRACKER_SN" ;;
    description: "The serial number of the tracker, referred to as tracker number, sn, serial, or tracker_sn"
  }
  dimension: tracker_type {
    type: string
    sql: ${TABLE}."TRACKER_TYPE" ;;
  }
  dimension: username {
    type: string
    sql: ${TABLE}."USERNAME" ;;
    description: "Installer of the ghost tracker"
  }
  filter: date_filter {
    type: date
    default_value: "this year"
  }
  measure: error_count {
    type: count
    filters: [error_type: "-NULL"]
    drill_fields: [detail*]
  }

  set: detail {
    fields: [
    username,
    asset,
    install_type,
    tracker_type,
    tracker_sn,
    companyname,
    submit_date,
    count_field,
    swapped_tracker_sn,
    error_type,
    completion_status,
    cs_notes,
    installer_notes
    ]
  }

}
