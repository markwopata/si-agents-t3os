view: yooz_01_last_submitted_by {
  derived_table: {
    sql: SELECT DISTINCT
          YZ1.YOOZ_ID AS "Yooz_ID",
          YZ1.LAST_SUBMITTER_NAME AS "Last_Submitted_By",
          YZ1.VENDOR_ID AS "Vendor_ID",
          VEN.Name AS "Vendor_Name",
          YZ1.INVOICE_NUMBER AS "Bill_Number",
          CONVERT_TIMEZONE('America/Chicago',YZ3.FIRST_SUBMITTED) AS "Last_Submitted_On_DT",
          CAST(CONVERT_TIMEZONE('America/Chicago',YZ3.FIRST_SUBMITTED) AS DATE) AS "Last_Submitted_On_Date",
          CONVERT_TIMEZONE('America/Chicago',YZ3.LAST_APPROVED) AS "Last_Approved_On_DT",
          CAST(CONVERT_TIMEZONE('America/Chicago',YZ3.LAST_APPROVED) AS DATE) AS "Last_Approved_On_Date",
          CAST(DEL.DELETED_ON AS DATE) AS "Deleted_On_Date"
      FROM "ANALYTICS"."YOOZ"."YOOZ_AP" YZ1
          LEFT JOIN
                (SELECT DISTINCT
                    YOOZ_ID,
                    MAX(_ES_UPDATE_TIMESTAMP) AS "TIMESTAMP",
                    MAX(LAST_SUBMITTER_DATE) AS "FIRST_SUBMITTED",
                    MAX(COALESCE(APPROVER_08_DATE, APPROVER_07_DATE, APPROVER_06_DATE, APPROVER_05_DATE, APPROVER_04_DATE, APPROVER_03_DATE, APPROVER_02_DATE, APPROVER_01_DATE)) AS LAST_APPROVED
                FROM "ANALYTICS"."YOOZ"."YOOZ_AP"
                WHERE
                    CURRENT_DOCUMENT_STATUS IN ('01710_COMPLETED', '02710_COMPLETED', '08710_COMPLETED')
                GROUP BY
                    YOOZ_ID) AS YZ3
              ON
                  YZ3.YOOZ_ID = YZ1.YOOZ_ID AND
                  YZ3.TIMESTAMP = YZ1._ES_UPDATE_TIMESTAMP
          LEFT JOIN "ANALYTICS"."YOOZ"."INVOICE_DELETES" DEL ON YZ1.YOOZ_ID = DEL.YOOZ_DOC_ID
          LEFT JOIN "ANALYTICS"."PUBLIC"."VENDOR" VEN ON VEN.VENDORID = YZ1.VENDOR_ID
      WHERE
          YZ1.LAST_SUBMITTER_NAME != 'Joshua Bromer' AND
          YZ1.LAST_SUBMITTER_NAME != 'Sunshine Westbrook' AND
          YZ3.FIRST_SUBMITTED IS NOT NULL
      GROUP BY
          YZ1.YOOZ_ID,
          YZ1.LAST_SUBMITTER_NAME,
          YZ1.VENDOR_ID,
          VEN.Name,
          YZ1.INVOICE_NUMBER,
          YZ3.FIRST_SUBMITTED,
          YZ3.LAST_APPROVED,
          DEL.DELETED_ON
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: yooz_id {
    type: string
    sql: ${TABLE}."Yooz_ID" ;;
  }

  dimension: last_submitted_by {
    type: string
    sql: ${TABLE}."Last_Submitted_By" ;;
  }

  dimension: vendor_id {
    type: string
    sql: ${TABLE}."Vendor_ID" ;;
  }

  dimension: vendor_name {
    type: string
    sql: ${TABLE}."Vendor_Name" ;;
  }

  dimension: bill_number {
    type: string
    sql: ${TABLE}."Bill_Number" ;;
  }

  dimension_group: last_submitted_on_dt {
    type: time
    sql: ${TABLE}."Last_Submitted_On_DT" ;;
  }

  dimension: last_submitted_on_date {
    type: date
    sql: ${TABLE}."Last_Submitted_On_Date" ;;
  }

  dimension_group: last_approved_on_dt {
    type: time
    sql: ${TABLE}."Last_Approved_On_DT" ;;
  }

  dimension: last_approved_on_date {
    type: date
    sql: ${TABLE}."Last_Approved_On_Date" ;;
  }

  dimension: deleted_on_date {
    type: date
    sql: ${TABLE}."Deleted_On_Date" ;;
  }

  set: detail {
    fields: [
      yooz_id,
      last_submitted_by,
      vendor_id,
      vendor_name,
      bill_number,
      last_submitted_on_dt_time,
      last_submitted_on_date,
      last_approved_on_dt_time,
      last_approved_on_date,
      deleted_on_date
    ]
  }
}
