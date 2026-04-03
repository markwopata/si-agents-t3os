view: clio_matters {

  derived_table: {
    sql:

WITH
  latest_company_note AS (
    SELECT
      company_id,
      note_text,
      ROW_NUMBER() OVER (
        PARTITION BY company_id
        ORDER BY date_created DESC
      ) AS rn
    FROM es_warehouse.public.company_notes
  ),

  clio_matters_sql AS (
    SELECT
      m.customer_number,
      m.display_number,
      m.matter_open_date,
      m.matter_pending_date,
      m.matter_close_date,
      m.practice_area_name,
      m.last_activity_date,
      m.matter_stage_name,
      m.matter_status_value,


       (
        SELECT SUM(p.owed_amount)
        FROM ES_WAREHOUSE.PUBLIC.INVOICES AS p
        WHERE TO_VARCHAR(p.company_id)    = TO_VARCHAR(m.customer_number)
          AND p.paid          = FALSE
          AND p.due_date     < CURRENT_DATE()
      ) AS overdue_invoices,

      (
        SELECT SUM(p.owed_amount)
        FROM ES_WAREHOUSE.PUBLIC.INVOICES AS p
        WHERE TO_VARCHAR(p.company_id)    = TO_VARCHAR(m.customer_number)
          AND p.paid          = FALSE
          AND p.billing_approved = TRUE
      ) AS all_invoices,

      /* latest note from Clio, newline-separated */
      (
      'Author Name: '  || n.author_first_name || ' ' || n.author_last_name || '\n' ||
      'Created_At: '   || TO_VARCHAR(n.created_at,'YYYY-MM-DD HH24:MI:SS') || '\n' ||
      'Subject: '      || n.subject || '\n' ||
      'Detail: '       || n.detail
      ) AS last_clio_note,

      /* full matter-status changelog */
  (
    SELECT LISTAGG(
      'Extracted_At:         ' || TO_VARCHAR(mc.extracted_at, 'YYYY-MM-DD HH24:MI:SS') || '\n' ||
      'Matter_Status_Value:  ' || mc.matter_status_value,
      '\n\n'
    ) WITHIN GROUP (ORDER BY mc.extracted_at DESC)
    FROM financial_systems.clio_gold.matters_changelog AS mc
    WHERE mc.matter_id = m.matter_id
  ) AS matter_changelog,

   (
    SELECT
      SUM(ob.total_outstanding_balance)
    FROM financial_systems.clio_gold.outstanding_balances AS ob
    WHERE ob.matter_id = m.matter_id
  ) AS total_outstanding_balance

    FROM financial_systems.clio_gold.matters AS m

    LEFT JOIN financial_systems.clio_gold.notes AS n
      ON m.matter_id = n.related_matter_id

    QUALIFY
      ROW_NUMBER() OVER (
        PARTITION BY m.matter_id
        ORDER BY n.created_at DESC
      ) = 1
  )

SELECT
  cm.customer_number,
  cm.display_number,
  cm.matter_open_date,
  cm.matter_pending_date,
  cm.matter_close_date,
  cm.practice_area_name,
  cm.last_activity_date,
  cm.matter_stage_name,
  cm.matter_status_value,
  cm.overdue_invoices,
  cm.all_invoices,
  cm.last_clio_note,
  lcn.note_text            AS admin_note,
  cm.matter_changelog,
  cm.total_outstanding_balance
FROM clio_matters_sql AS cm

LEFT JOIN latest_company_note AS lcn
  ON TO_VARCHAR(lcn.company_id) = TO_VARCHAR(cm.customer_number)
 AND lcn.rn = 1

;;}


  dimension: customer_number {
    type: string
    sql: ${TABLE}.customer_number ;;
  }


  dimension: display_number {
    type: string
    sql: ${TABLE}.display_number ;;
  }

  dimension: matter_open_date {
    type: date
    sql: ${TABLE}.matter_open_date ;;
  }

  dimension: matter_pending_date {
    type: date
    sql: ${TABLE}.matter_pending_date ;;
  }

  dimension: matter_close_date {
    type: date
    sql: ${TABLE}.matter_close_date;;
  }

  dimension:  practice_area_name {
    type: string
    sql: ${TABLE}.practice_area_name;;
  }

  dimension: last_activity_date {
    type: date
    sql: ${TABLE}.last_activity_date ;;
  }

  dimension: matter_stage_name {
    type: string
    sql: ${TABLE}.matter_stage_name ;;
  }

  dimension: matter_status_value {
    type: string
    sql: ${TABLE}.matter_status_value;;
  }

  dimension: admin_company_page {
    type: string
    sql: ${TABLE}.customer_number ;;            # base it on the customer_number

    link: {
      label: "View Company Page"
      url:   "https://admin.equipmentshare.com/#/home/companies/{{ value }}"
    }
  }

  dimension: last_clio_note {
    type: string
    sql: ${TABLE}.last_clio_note ;;
  }


  dimension: admin_note {
    type:  string
    sql: ${TABLE}.admin_note ;;
  }

  dimension: matter_changelog {
    type: string
    sql: ${TABLE}.matter_changelog ;;
  }

  dimension: admin_balance {
    type: number
    sql: ${TABLE}.overdue_invoices ;;
    value_format_name: "usd"
    label: "ES All Past Due Balances"
  }

  dimension: all_invoices {
    type: number
    sql: ${TABLE}.all_invoices ;;
    value_format_name: "usd"
    label: " ES Total account Balance (to include current invoices)"
  }

  dimension: total_outstanding_balance {
    type: number
    sql: ${TABLE}.total_outstanding_balance ;;
    value_format_name: "usd"
    label: "Clio Balances"
    description: "Sum of all outstanding balances for this matter in Clio"
  }
}
