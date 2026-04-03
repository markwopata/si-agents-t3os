
view: vendor_intacct_vs_t3_status {
  derived_table: {
    sql: SELECT
          SAGE_VENDORS.VENDORID                                                       AS INT_VENDOR_ID,
          SAGE_VENDORS.NAME                                                           AS INT_VENDOR_NAME,
          T3_ENTITIES.ENTITY_ID                                                       AS T3_ENTITY_ID,
          T3_ENTITIES.NAME                                                            AS T3_VENDOR_NAME,
          SAGE_VENDORS.STATUS                                                         AS INT_STATUS,
          CASE WHEN T3_ENTITIES.ACTIVE THEN 'active' ELSE 'inactive' END              AS T3_STATUS,
          SAGE_VENDORS.VENDOR_CATEGORY                                                AS INT_VENDOR_CATEGORY,
          SAGE_VENDORS.REPORTING_CATEGORY                                             AS INT_REPT_CATEGORY,
          SAGE_VENDORS.EXTERNAL_SYNC_OVERRIDE                                         AS INT_OVERRIDE,

          CONCAT(
            COALESCE(SAGE_CONTACTS.MAILADDRESS_ADDRESS1,''), (' '),
            COALESCE(SAGE_CONTACTS.MAILADDRESS_ADDRESS2,''), (' '),
            COALESCE(SAGE_CONTACTS.MAILADDRESS_CITY,''), (' '),
            COALESCE(UPPER(SAGE_CONTACTS.MAILADDRESS_STATE),''), (' '),
            COALESCE(SAGE_CONTACTS.MAILADDRESS_ZIP,''))                               AS INT_ADDRESS,

          CONCAT(
            COALESCE(T3_LOCNS.STREET_1,''), (' '),
            COALESCE(T3_LOCNS.STREET_2,''), (' '),
            COALESCE(T3_LOCNS.CITY,''), (' '),
            COALESCE(T3_STATES.STATE_ABBREVIATION,''), (' '),
            COALESCE(T3_LOCNS.ZIP_CODE,''))                                           AS T3_ADDRESS,

          CASE WHEN T3_ENTITIES.ACTIVE
          THEN
              CASE WHEN COALESCE(INT_OVERRIDE,'') = 'Override - No sync to T3'
              THEN 'DEACTIVATE'
              ELSE
                  CASE WHEN COALESCE(INT_OVERRIDE,'') != 'Override - Sync to T3'
                  THEN
                      CASE WHEN COALESCE(INT_VENDOR_CATEGORY,'') IN ('Advertising/Education/Marketing/Subscriptions', 'Banking/Financial/Collection/Business Services', 'Charity', 'Customer Refund', 'Landlord', 'Legal', 'Medical/Health Services', 'Owner Payout', 'Travel', 'Employee', 'Government - City', 'Government - County', 'Government - Federal', 'Government - Postage (USPS)', 'Government - State', 'Public Utilities - Electricity', 'Public Utilities - Gas', 'Public Utilities - Telecommunications', 'Public Utilities - Water', 'Hardware Company Vendors')
                      THEN 'DEACTIVATE'
                      ELSE
                          CASE WHEN INT_STATUS = 'inactive'
                          THEN 'DEACTIVATE'
                          END
                      END
                  END
              END
          ELSE
              CASE WHEN NOT T3_ENTITIES.ACTIVE
              THEN
                  CASE WHEN COALESCE(INT_OVERRIDE,'') = 'Override - Sync to T3'
                  THEN 'REACTIVATE'
                  ELSE
                      CASE WHEN COALESCE(INT_OVERRIDE,'') != 'Override - No sync to T3'
                      THEN
                          CASE WHEN INT_STATUS = 'active' AND COALESCE(INT_VENDOR_CATEGORY,'') NOT IN ('Advertising/Education/Marketing/Subscriptions', 'Banking/Financial/Collection/Business Services', 'Charity', 'Customer Refund', 'Landlord', 'Legal', 'Medical/Health Services', 'Owner Payout', 'Travel', 'Employee', 'Government - City', 'Government - County', 'Government - Federal', 'Government - Postage (USPS)', 'Government - State', 'Public Utilities - Electricity', 'Public Utilities - Gas', 'Public Utilities - Telecommunications', 'Public Utilities - Water', 'Hardware Company Vendors')
                          THEN 'REACTIVATE'
                          END
                      END
                  END
              END
          END                                                                         AS T3_UPDATE_STATUS_FLAG,

          CASE WHEN COALESCE(INT_VENDOR_NAME,'') != COALESCE(T3_VENDOR_NAME,'')
          THEN
              CASE WHEN T3_ENTITIES.ACTIVE
              THEN
                  CASE WHEN COALESCE(INT_OVERRIDE,'') != 'Override - No sync to T3'
                  THEN 'NEEDS UPDATE'
                  END
              ELSE
                  CASE WHEN COALESCE(INT_OVERRIDE,'') = 'Override - Sync to T3'
                  THEN 'NEEDS UPDATE'
                  END
              END
          END                                                                         AS T3_UPDATE_NAME_FLAG,
          CASE WHEN INT_ADDRESS != T3_ADDRESS
          THEN
              CASE WHEN T3_ENTITIES.ACTIVE
              THEN
                  CASE WHEN COALESCE(INT_OVERRIDE,'') != 'Override - No sync to T3'
                  THEN 'NEEDS UPDATE'
                  END
              ELSE
                  CASE WHEN COALESCE(INT_OVERRIDE,'') = 'Override - Sync to T3'
                  THEN 'NEEDS UPDATE'
                  END
              END
          END                                                                         AS T3_UPDATE_ADDR_FLAG,
          CONCAT_WS(' ',(CASE WHEN COALESCE(SAGE_CONTACTS.MAILADDRESS_ADDRESS1,'') != COALESCE(T3_LOCNS.STREET_1,'') THEN 'STREET1' ELSE '' END),
                    (CASE WHEN COALESCE(SAGE_CONTACTS.MAILADDRESS_ADDRESS2,'') != COALESCE(T3_LOCNS.STREET_2,'') THEN 'STREET2' ELSE '' END),
                    (CASE WHEN COALESCE(SAGE_CONTACTS.MAILADDRESS_CITY,'') != COALESCE(T3_LOCNS.CITY,'') THEN 'CITY' ELSE '' END),
                    (CASE WHEN COALESCE((SAGE_CONTACTS.MAILADDRESS_STATE),'') != COALESCE(T3_STATES.STATE_ABBREVIATION,'') THEN 'STATE' ELSE '' END),
                    (CASE WHEN COALESCE(SAGE_CONTACTS.MAILADDRESS_ZIP,'') != COALESCE(T3_LOCNS.ZIP_CODE,'') THEN 'ZIP' ELSE '' END)) AS ADDR_DIFF_WHERE,
          CASE
          WHEN T3_UPDATE_STATUS_FLAG IS NOT NULL OR T3_UPDATE_NAME_FLAG IS NOT NULL OR T3_UPDATE_ADDR_FLAG IS NOT NULL
              THEN 'Vendor Needs Update'
          ELSE NULL END                                                               AS CHECK_VENDOR,

          COALESCE(CONVERT_TIMEZONE('America/Chicago', T3_ENTITIES.CREATED_AT),
                   CONVERT_TIMEZONE('America/Chicago', T3_ENTITIES._ES_UPDATE_TIMESTAMP)) AS T3_WHEN_CREATED,
          CONVERT_TIMEZONE('America/Chicago', T3_ENTITIES.MODIFIED_AT)                    AS T3_LAST_MODIFIED,
          CONVERT_TIMEZONE('America/Chicago', T3_LOCNS._ES_UPDATE_TIMESTAMP)              AS T3_LOCATN_UPDATED
      FROM
          ANALYTICS.INTACCT.VENDOR SAGE_VENDORS
              LEFT JOIN ANALYTICS.INTACCT.CONTACT SAGE_CONTACTS
                        ON SAGE_CONTACTS.RECORDNO = SAGE_VENDORS.DISPLAYCONTACTKEY
              LEFT JOIN ES_WAREHOUSE.PURCHASES.ENTITY_VENDOR_SETTINGS EVS
                        ON EVS.EXTERNAL_ERP_VENDOR_REF = SAGE_VENDORS.VENDORID
              LEFT JOIN ES_WAREHOUSE.PURCHASES.ENTITIES T3_ENTITIES ON EVS.ENTITY_ID = T3_ENTITIES.ENTITY_ID AND T3_ENTITIES.COMPANY_ID = '1854'
              LEFT JOIN ES_WAREHOUSE.PURCHASES.ENTITY_LOCATIONS T3_LOCNS ON T3_LOCNS.ENTITY_LOCATION_ID = T3_ENTITIES.BUSINESS_ADDRESS_ID
              LEFT JOIN ANALYTICS.INTACCT.STATES T3_STATES ON T3_STATES.ENITITY_STATE_ID = T3_LOCNS.ENTITY_STATE_ID;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: int_vendor_id {
    type: string
    sql: ${TABLE}."INT_VENDOR_ID" ;;
  }

  dimension: int_vendor_name {
    type: string
    sql: ${TABLE}."INT_VENDOR_NAME" ;;
  }

  dimension: t3_entity_id {
    type: number
    sql: ${TABLE}."T3_ENTITY_ID" ;;
  }

  dimension: t3_vendor_name {
    type: string
    sql: ${TABLE}."T3_VENDOR_NAME" ;;
  }

  dimension: int_status {
    type: string
    sql: ${TABLE}."INT_STATUS" ;;
  }

  dimension: t3_status {
    type: string
    sql: ${TABLE}."T3_STATUS" ;;
  }

  dimension: int_vendor_category {
    type: string
    sql: ${TABLE}."INT_VENDOR_CATEGORY" ;;
  }

  dimension: int_rept_category {
    type: string
    sql: ${TABLE}."INT_REPT_CATEGORY" ;;
  }

  dimension: int_override {
    type: string
    sql: ${TABLE}."INT_OVERRIDE" ;;
  }

  dimension: int_address {
    type: string
    sql: ${TABLE}."INT_ADDRESS" ;;
  }

  dimension: t3_address {
    type: string
    sql: ${TABLE}."T3_ADDRESS" ;;
  }

  dimension: t3_update_status_flag {
    type: string
    sql: ${TABLE}."T3_UPDATE_STATUS_FLAG" ;;
  }

  dimension: t3_update_name_flag {
    type: string
    sql: ${TABLE}."T3_UPDATE_NAME_FLAG" ;;
  }

  dimension: t3_update_addr_flag {
    type: string
    sql: ${TABLE}."T3_UPDATE_ADDR_FLAG" ;;
  }

  dimension: addr_diff_where {
    type: string
    sql: ${TABLE}."ADDR_DIFF_WHERE" ;;
  }

  dimension_group: t3_when_created {
    type: time
    sql: ${TABLE}."T3_WHEN_CREATED" ;;
  }

  dimension_group: t3_last_modified {
    type: time
    sql: ${TABLE}."T3_LAST_MODIFIED" ;;
  }

  dimension_group: t3_locatn_updated {
    type: time
    sql: ${TABLE}."T3_LOCATN_UPDATED" ;;
  }

  dimension: check_vendor {
    type: string
    sql: ${TABLE}."CHECK_VENDOR" ;;
  }

  set: detail {
    fields: [
        int_vendor_id,
  int_vendor_name,
  t3_entity_id,
  t3_vendor_name,
  int_status,
  t3_status,
  int_vendor_category,
  int_rept_category,
  int_override,
  int_address,
  t3_address,
  t3_update_status_flag,
  t3_update_name_flag,
  t3_update_addr_flag,
  t3_when_created_time,
  t3_last_modified_time,
  t3_locatn_updated_time,
  check_vendor,
  addr_diff_where
    ]
  }
}
