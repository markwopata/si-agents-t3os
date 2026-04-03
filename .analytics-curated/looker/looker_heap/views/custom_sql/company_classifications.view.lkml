view: company_classifications {
derived_table: {
  sql:
    WITH company_sic_codes AS (SELECT company_id,
                                    csc.sic_code,
                                    null as naics_1,
                                    null as naics_2
                               FROM analytics.public.company_sic_codes csc
                              UNION
                             SELECT TRY_CAST(customer_id AS number) AS company_id,
                                    TRY_CAST(sic AS number)         AS sic_code,
                                    TRY_CAST(naics_1 AS number),
                                    TRY_CAST(naics_2 AS number)
                               FROM analytics.gs.credit_app_master_list ca
                              WHERE company_id IS NOT NULL
                                AND sic_code IS NOT NULL
                              UNION
                             SELECT TRY_CAST(customer_id AS number) AS company_id,
                                    TRY_CAST(sic AS number)         AS sic_code,
                                    TRY_CAST(naics_1 AS number),
                                    TRY_CAST(naics_2 AS number)
                               FROM analytics.gs.credit_app_master_list_archived caa
                              WHERE company_id IS NOT NULL
                                AND sic_code IS NOT NULL)

SELECT
       csc.company_id,
       csc.sic_code,
       sc.description,
       naics_1,
       naics_2

  FROM company_sic_codes csc
       INNER JOIN analytics.public.sic_codes sc
                  ON csc.sic_code = sc.sic_code
 WHERE csc.sic_code <> 9999


;;
}

dimension: company_id {
  type: number
  sql: ${TABLE}."COMPANY_ID" ;;
}

dimension: sic_code {
  type: number
  sql: ${TABLE}."SIC_CODE" ;;
}

dimension: sic_description {
  type: string
  sql: ${TABLE}."DESCRIPTION" ;;
}

dimension: naics_1 {
  type: number
  sql: ${TABLE}."NAICS_1" ;;
}

dimension: naics_2 {
  type: number
  sql: ${TABLE}."NAICS_2" ;;
}
}
