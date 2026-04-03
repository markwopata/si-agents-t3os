view: stg_t3__national_account_assignments {
  derived_table: {
    sql:

      WITH base AS (
        SELECT
          company_id,
          sales_director_user_id,
          commissioned_nam_user_id,
          effective_nam_user_id,
          coordinator_user_id,
          nac_2_user_id,
          nac_3_user_id
        FROM business_intelligence.triage.stg_t3__national_account_assignments
      )

      SELECT DISTINCT
      b.company_id,
      f.value::string AS user_id
      FROM base b,
      LATERAL FLATTEN(
      INPUT => ARRAY_CONSTRUCT(
      b.sales_director_user_id,
      b.commissioned_nam_user_id,
      b.effective_nam_user_id,
      b.coordinator_user_id,
      b.nac_2_user_id,
      b.nac_3_user_id
      )
      ) f
      WHERE f.value IS NOT NULL

      ;;
  }

  dimension: company_id {
    type: string
    sql: ${TABLE}.company_id ;;
  }

  dimension: user_id {
    type: string
    sql: ${TABLE}.user_id ;;
  }
}
