view: company_notes_rank {
  derived_table: {
    # datagroup_trigger: Every_Hour_Update
    sql: with companynote_rank as (
              select
                company_id,
                date_created,
                note_text,
                  RANK() OVER(
                      partition by company_id order by date_created desc) as DateRank
              from
                ES_WAREHOUSE.PUBLIC.company_notes
              )
              select
                company_id,
                date_created,
                note_text
              from
                companynote_rank
              where
                DateRank = 1
 ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: company_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension_group: date_created {
    type: time
    sql: ${TABLE}."DATE_CREATED" ;;
  }

  dimension: no_notes_last_30 {
    type: yesno
    sql: ${date_created_date} < ((DATEADD('day', -30, CURRENT_DATE()))) ;;
  }

  dimension: note_text {
    type: string
    sql: ${TABLE}."NOTE_TEXT" ;;
  }

  dimension: date_and_note_text {
    type: string
    sql: concat(${date_created_date}, ' - ',${note_text}) ;;
  }

  dimension: days_last_note {
    type: number
    sql: datediff(day,${date_created_date},current_date()) ;;
#     current_date - ${invoice_date} <= 30;;
  }

  set: detail {
    fields: [company_id, date_created_time, note_text]
  }
}
