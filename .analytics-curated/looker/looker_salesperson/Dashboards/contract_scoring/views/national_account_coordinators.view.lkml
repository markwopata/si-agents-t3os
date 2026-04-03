 view: national_account_coordinators {
    derived_table: {
      sql:
WITH commission_assignments AS (
  SELECT *,
    CASE
      WHEN effective_end_date <> '2099-12-31 23:59:59.999'::timestamp_ntz THEN 1
      ELSE 0
    END AS upcoming_assignment_change
  FROM analytics.commission.nam_company_assignments
),

parent_company_relationships AS (
  SELECT company_id, parent_company_id
  FROM analytics.bi_ops.parent_company_relationships
  QUALIFY ROW_NUMBER() OVER(PARTITION BY company_id ORDER BY record_created_timestamp DESC) = 1
),

user_map AS (
  SELECT
    u.user_id,
    u.email_address,
    CASE
      WHEN position(' ', coalesce(cd.nickname, cd.first_name)) = 0
        THEN concat(coalesce(cd.nickname, cd.first_name), ' ', cd.last_name)
      ELSE concat(coalesce(cd.nickname, concat(cd.first_name, ' ', cd.last_name)))
    END AS name
  FROM es_warehouse.public.users u
  JOIN analytics.payroll.company_directory cd
    ON lower(u.email_address) = lower(cd.work_email)
),
account_info_history AS (
  SELECT
    nai.*,
    nai.record_creation_date::date                                     AS effective_start_date,
    COALESCE(
      LEAD(nai.record_creation_date::date) OVER (
        PARTITION BY nai.company_id
        ORDER BY nai.record_creation_date
      ),
      '2999-12-31'::date
    )                                                                  AS effective_end_date
  FROM analytics.bi_ops.national_account_info nai
)


SELECT
  f.*,
  p.parent_company_id,
  m.NAM_USER_ID,
  u4.name as NAM,
  /* manager of NAC1 */
  REGEXP_REPLACE(cd_nac1.direct_manager_name, '\\s*\\(\\d+\\)$', '') AS NAC_MANAGER,
  cd_nac1.direct_manager_employee_id AS NAC_MANAGER_ID,


  a.coordinator_user_id AS NAC1_id,
  u1.name AS NAC1,

  a.NAC_2_USER_ID AS NAC2_id,
  u2.name AS NAC2,

  a.NAC_3_USER_ID AS NAC3_id,
  u3.name AS NAC3,

a.snapshot_month as month,

  a.effective_start_date,
  a.effective_end_date

FROM analytics.rate_achievement.contract_scoring_quarterly_agg AS f

LEFT JOIN es_warehouse.public.companies AS c
  ON c.name = f.parent_company_name

LEFT JOIN parent_company_relationships AS p
  ON p.company_id = c.company_id

LEFT JOIN commission_assignments AS m
  ON (m.company_id = c.company_id OR m.company_id = p.parent_company_id)
 AND (
      (f.invoice_date BETWEEN m.effective_start_date AND m.effective_end_date)
   OR (f.invoice_date >= m.effective_start_date AND m.effective_end_date IS NULL)
   OR (
        quarter(m.effective_start_date) = quarter(f.invoice_date)
    AND year(m.effective_start_date) = year(f.invoice_date)
      )
    )

LEFT JOIN analytics.rate_achievement.national_account_info_snapshot AS a
  ON a.company_id = c.company_id
 AND a.snapshot_month IN (
      DATE_TRUNC('month', DATE_TRUNC('quarter', f.invoice_date::date)),                       -- month 0
      DATEADD(month, 1, DATE_TRUNC('month', DATE_TRUNC('quarter', f.invoice_date::date))),  -- month 1
      DATEADD(month, 2, DATE_TRUNC('month', DATE_TRUNC('quarter', f.invoice_date::date)))   -- month 2
 )


LEFT JOIN user_map AS u1
  ON u1.user_id = a.coordinator_user_id

LEFT JOIN user_map AS u2
  ON u2.user_id = a.NAC_2_USER_ID

LEFT JOIN user_map AS u3
  ON u3.user_id = a.NAC_3_USER_ID
LEFT JOIN user_map as u4
on u4.user_id = m.NAM_USER_ID


LEFT JOIN analytics.payroll.company_directory AS cd_nac1
  ON lower(cd_nac1.work_email) = lower(u1.email_address)



    ;;
    }







#dimension: nam_assignment_id {

 # type: number
  #sql: ${TABLE}."NAM_ASSIGNMENT_ID" ;;

#}
dimension: NAM_NAME {

  type: string
  sql: ${TABLE}."NAM" ;;


}
dimension: NAM_ID {

  type: number
  sql: ${TABLE}."NAM_USER_ID" ;;
  value_format: "###########0"



}
dimension: NAC_Manager{

  type: string
  sql: ${TABLE}."NAC_MANAGER" ;;

}

dimension: nac_manager_user_id {

  type: number
  sql: ${TABLE}."NAC_MANAGER_ID";;
  value_format: "###########0"
  }
#dimension: director_user_id {

 # type: number
  #sql: ${TABLE}."DIRECTOR_USER_ID" ;;
  #value_format: "###########0"

#}

dimension: company_id {

  type: number
  sql: ${TABLE}."PARENT_COMPANY_ID" ;;
  value_format: "###########0"
}

dimension: company_name {

  type: string
  sql: ${TABLE}."PARENT_COMPANY_NAME" ;;

}
dimension: effective_start_date {

  type: date
  sql: ${TABLE}."EFFECTIVE_START_DATE" ;;

}

dimension: effective_end_date {

  type: date
  sql: ${TABLE}."EFFECTIVE_END_DATE" ;;

}

#dimension: record_creation_date {

#  type: date
 # sql: ${TABLE}."RECORD_CREATION_DATE" ;;

#}

#dimension: created_by_email {

  #type: string
 # sql: ${TABLE}."CREATED_BY_EMAIL" ;;

#}

#dimension: admin_toggle_off {

  #type: yesno
 # sql: ${TABLE}."ADMIN_TOGGLE_OFF" ;;

#}

#dimension: upcoming_assignment_change {

 # type: number
  #sql: ${TABLE}."UPCOMING_ASSIGNMENT_CHANGE" ;;

#}
dimension: NAC1_name{

  type: string
  sql: ${TABLE}."NAC1" ;;

}
  dimension: NAC2_name{

    type: string
    sql: ${TABLE}."NAC2" ;;

  }
  dimension: NAC3_name{

    type: string
    sql: ${TABLE}."NAC3" ;;

  }
dimension: NAC1{

  type: number
  sql: ${TABLE}."NAC1_ID" ;;
  value_format: "#########0"
}
  dimension: NAC2{

    type: number
    sql: ${TABLE}."NAC2_ID" ;;
    value_format: "#########0"
  }
  dimension: NAC3{

    type: number
    sql: ${TABLE}."NAC3_ID" ;;
    value_format: "#########0"
  }

  dimension: invoice_date {

    type: date
    sql: ${TABLE}."INVOICE_DATE" ;;
  }
  dimension: month {

    type: date
    sql: ${TABLE}."MONTH" ;;

  }
}
