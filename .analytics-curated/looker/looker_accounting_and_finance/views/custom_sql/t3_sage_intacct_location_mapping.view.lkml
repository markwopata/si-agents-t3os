view: t3_sage_intacct_location_mapping {
  label: "T3 ↔ Sage Intacct Location Mapping"

  derived_table: {
    sql:
      SELECT
          CAST(s1.STORE_ID AS varchar) AS t3_store_id,
          s1.NAME AS t3_store_name,
          CASE
              WHEN s2.NAME IS NULL THEN s1.NAME
              ELSE s2.NAME
          END AS intacct_dept_name,
          CAST(erp.INTACCT_DEPARTMENT_ID AS varchar) AS intacct_dept_id
      FROM ES_WAREHOUSE.INVENTORY.STORES s1
      LEFT JOIN ES_WAREHOUSE.INVENTORY.STORES s2
          ON s1.PARENT_ID = s2.STORE_ID
      LEFT JOIN ES_WAREHOUSE.PUBLIC.BRANCH_ERP_REFS erp
          ON COALESCE(s2.BRANCH_ID, s1.BRANCH_ID) = erp.BRANCH_ID
      WHERE s1.COMPANY_ID = '1854'
        AND erp.intacct_department_id IS NOT NULL
        AND s1.date_archived IS NULL
      ;;
  }

  # Dimensions
  dimension: t3_store_id {
    label: "T3 Store ID"
    type: string
    sql: ${TABLE}.t3_store_id ;;
  }

  dimension: t3_store_name {
    label: "T3 Store Name"
    type: string
    sql: ${TABLE}.t3_store_name ;;
  }

  dimension: intacct_dept_name {
    label: "Sage Intacct Department Name"
    type: string
    sql: ${TABLE}.intacct_dept_name ;;
  }

  dimension: intacct_dept_id {
    label: "Sage Intacct Department ID"
    type: string
    sql: ${TABLE}.intacct_dept_id ;;
  }

  # Measures
  measure: row_count {
    label: "Row Count"
    type: count
  }

  measure: store_count {
    label: "Distinct T3 Stores"
    type: count_distinct
    sql: ${t3_store_id} ;;
  }

  measure: intacct_dept_count {
    label: "Distinct Sage Intacct Departments"
    type: count_distinct
    sql: ${intacct_dept_id} ;;
  }
}
