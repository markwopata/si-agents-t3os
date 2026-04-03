view: vendor_comparison {
  derived_table: {
    sql:
WITH t3_id_duplicates AS (
    SELECT ENTITY_ID, COUNT(*) as total_count
    FROM ES_WAREHOUSE.PURCHASES.ENTITIES
    GROUP BY ENTITY_ID
    HAVING COUNT(*) > 1
),
sage_id_t3_mapping_duplicates AS (
    SELECT EXTERNAL_ERP_VENDOR_REF, COUNT(*) as total_count
    FROM ES_WAREHOUSE.PURCHASES.ENTITY_VENDOR_SETTINGS
    GROUP BY EXTERNAL_ERP_VENDOR_REF
    HAVING COUNT(*) > 1
),
sage_id_concur_mapping_duplicates AS (
    SELECT VENDOR_CODE, COUNT(*) as total_count
    FROM ANALYTICS.CONCUR.VENDOR
    GROUP BY VENDOR_CODE
    HAVING COUNT(*) > 1
)
SELECT
    intacct.VENDORID AS intacct_vendor_id,  -- Need to update ANALYTICS.INTACCT.RECORD_URL to store Vendor URL.
    intacct.NAME AS intacct_name,
    t3s.ENTITY_ID as t3_vendor_id,          -- We're pretty sure a record link to this doesn't exist
    t3.NAME AS t3_name,
    concur.VENDOR_CODE as concur_vendor_id, -- No clear mapping for the Concur Vendor page URL and the vendor
    concur.VENDOR AS concur_name,

    CASE
        WHEN intacct.NAME != t3.NAME OR intacct.NAME != concur.VENDOR THEN 'Mismatch'
    END AS name_status,
    t3_id_duplicates.total_count                    as t3_entity_id_duplication,
    sage_id_t3_mapping_duplicates.total_count       as duplicate_sage_id_in_t3_mapping,
    sage_id_concur_mapping_duplicates.total_count   as duplicate_sage_id_in_concur_mapping,
    intacct.status,
    intacct.vendor_category,
    intacct.approved_entities,
    intacct.new_vendor_category
FROM
    ANALYTICS.INTACCT.VENDOR intacct
    LEFT JOIN ES_WAREHOUSE.PURCHASES.ENTITY_VENDOR_SETTINGS t3s ON intacct.VENDORID = t3s.EXTERNAL_ERP_VENDOR_REF
    LEFT JOIN ES_WAREHOUSE.PURCHASES.ENTITIES t3 ON t3s.ENTITY_ID = t3.ENTITY_ID
    LEFT JOIN ANALYTICS.CONCUR.VENDOR concur ON intacct.VENDORID = concur.VENDOR_CODE
    LEFT JOIN t3_id_duplicates ON t3.entity_id = t3_id_duplicates.entity_id
    LEFT JOIN sage_id_t3_mapping_duplicates ON intacct.vendorid = sage_id_t3_mapping_duplicates.EXTERNAL_ERP_VENDOR_REF
    LEFT JOIN sage_id_concur_mapping_duplicates ON concur.VENDOR_CODE = sage_id_concur_mapping_duplicates.VENDOR_CODE
;;
  }

  dimension: intacct_vendor_id {
    type: string
    sql: ${TABLE}.intacct_vendor_id;;
  }

  dimension: intacct_name {
    type: string
    sql: ${TABLE}.intacct_name;;
  }

  dimension: t3_vendor_id {
    type: string
    sql: ${TABLE}.t3_vendor_id;;
  }

  dimension: t3_name {
    type: string
    sql: ${TABLE}.t3_name;;
  }

  dimension: concur_vendor_id {
    type: string
    sql: ${TABLE}.concur_vendor_id;;
  }

  dimension: concur_name {
    type: string
    sql: ${TABLE}.concur_name;;
  }

  dimension: name_status {
    type: string
    sql: ${TABLE}.name_status;;
  }

  dimension: t3_duplicate_count {
    type: string
    sql: ${TABLE}.t3_entity_id_duplication;;
  }

  dimension: t3_sage_id_duplicate_count {
    type: string
    sql: ${TABLE}.duplicate_sage_id_in_t3_mapping;;
  }

  dimension: concur_sage_id_duplicate_count {
    type: string
    sql: ${TABLE}.duplicate_sage_id_in_concur_mapping;;
  }

  dimension: intacct_vendor_status {
    type: string
    sql: ${TABLE}.status;;
  }

  dimension: intacct_vendor_category {
    type: string
    sql: ${TABLE}.vendor_category;;
  }

  dimension: intacct_approved_entities {
    type: string
    sql: ${TABLE}.approved_entities;;
  }

  dimension: intacct_new_vendor_category {
    type: string
    sql: ${TABLE}.new_vendor_category;;
  }
}
