view: dnr_companies {
    derived_table: {
      sql:
          SELECT
              ARD.CUSTOMER_NAME AS CUSTOMER_NAME,
              CN.COMPANY_ID AS COMPANY_ID,
              LOC.STREET_1 AS STREET_1,
              LOC.CITY AS CITY,
              ST.ABBREVIATION AS STATE,
              LOC.ZIP_CODE AS ZIP_CODE,
              ADM_CUST.DO_NOT_RENT AS DNR
          FROM
              ES_WAREHOUSE.PUBLIC.COMPANIES ADM_CUST
              LEFT JOIN ES_WAREHOUSE.PUBLIC.COMPANY_ERP_REFS ADM_CUST_ERPREF
                  ON ADM_CUST.COMPANY_ID = ADM_CUST_ERPREF.COMPANY_ID
              LEFT JOIN ES_WAREHOUSE.PUBLIC.NET_TERMS TERMS
                  ON ADM_CUST.NET_TERMS_ID = TERMS.NET_TERMS_ID
              LEFT JOIN ANALYTICS.GS.COLLECTOR_OIL_GAS_LEGAL COGL
                  ON ADM_CUST.COMPANY_ID = COGL.CUSTOMER_ID
              LEFT JOIN ES_WAREHOUSE.PUBLIC.BILLING_COMPANY_PREFERENCES BCP
                  ON ADM_CUST.COMPANY_ID = BCP.COMPANY_ID
              LEFT JOIN ES_WAREHOUSE.PUBLIC.USERS USER_1_BILLING
                  ON TRY_TO_NUMBER(SPLIT_PART(
                      SPLIT_PART(REPLACE(BCP.PREFS, '"', ''), 'primary_billing_contact_user_id:', 2), ',', 0)) = USER_1_BILLING.USER_ID
              LEFT JOIN ES_WAREHOUSE.PUBLIC.USERS USER_2_OWNER
                  ON ADM_CUST.OWNER_USER_ID = USER_2_OWNER.USER_ID
              LEFT JOIN ES_WAREHOUSE.PUBLIC.LOCATIONS LOC
                  ON ADM_CUST.BILLING_LOCATION_ID = LOC.LOCATION_ID
              LEFT JOIN ES_WAREHOUSE.PUBLIC.STATES ST
                  ON LOC.STATE_ID = ST.STATE_ID
              LEFT JOIN ES_WAREHOUSE.PUBLIC.CREDIT_NOTES CN
                  ON ADM_CUST.COMPANY_ID = CN.COMPANY_ID
              LEFT JOIN ANALYTICS.INTACCT_MODELS.AR_DETAIL ARD
                  ON CN.CREDIT_NOTE_ID = ARD.CREDIT_NOTE_ID
              LEFT JOIN ANALYTICS.SAGE_INTACCT.CUSTOMER C
                  ON C.CUSTOMERID = ARD.CUSTOMER_ID
          WHERE
              ADM_CUST.DO_NOT_RENT = 'TRUE'
              AND ARD.CUSTOMER_NAME IS NOT NULL
          GROUP BY
              ARD.CUSTOMER_NAME,
              CN.COMPANY_ID,
              LOC.STREET_1,
              LOC.CITY,
              ST.ABBREVIATION,
              LOC.ZIP_CODE,
              ADM_CUST.DO_NOT_RENT ;;
    }

    dimension: customer_name {
      sql: ${TABLE}.CUSTOMER_NAME ;;
      type: string
    }

    dimension: company_id {
      sql: ${TABLE}.COMPANY_ID ;;
      type: number
    }

    dimension: street_1 {
      sql: ${TABLE}.STREET_1 ;;
      type: string
    }

    dimension: city {
      sql: ${TABLE}.CITY ;;
      type: string
    }

    dimension: state {
      sql: ${TABLE}.STATE ;;
      type: string
    }

    dimension: zip_code {
      sql: ${TABLE}.ZIP_CODE ;;
      type: string
    }

    dimension: dnr {
      sql: ${TABLE}.DNR ;;
      type: string
    }


   set: detail {
     fields: [
     customer_name,
     company_id,
     street_1,
     city,
     state,
     zip_code,
     dnr
  ]
}
}
