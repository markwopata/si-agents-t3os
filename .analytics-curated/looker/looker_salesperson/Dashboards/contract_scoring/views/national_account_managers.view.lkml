view: national_account_managers {

derived_table: {

sql: with current_nam_assignments as (select nca.* , c.name as company_name,
row_number() over(partition by nca.company_id order by effective_start_date asc) as rank
from analytics.commission.nam_company_assignments nca
LEFT JOIN es_warehouse.public.companies as c
on nca.company_id = c.company_id
where current_timestamp() between effective_start_date and effective_end_date
qualify rank = 1
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
)

select
cna.company_name as company_name,
cna.nam_user_id as nam_user_id,
cna.company_id as company_id,
u.name as NAM,
cna.effective_start_date as effective_start_date,
cna.effective_end_date as effective_end_date
from current_nam_assignments as cna
left join user_map as u
on u.user_id = cna.nam_user_id
;;



}
dimension: company_name {

  type: string
  sql: ${TABLE}."COMPANY_NAME" ;;


}


 dimension: NAM_user_id {

  type: number
  sql: ${TABLE}."NAM_USER_ID" ;;
  value_format: "#############0"

 }
  dimension: NAM {

    type: string
    sql: ${TABLE}."NAM" ;;
  }
  dimension: company_id {

    type: number
    sql: ${TABLE}."COMPANY_ID";;
    value_format: "##########0"
  }
  dimension: effective_start_date {

    type: date
    sql: ${TABLE}."EFFECTIVE_START_DATE" ;;
  }
  dimension: effective_end_date {

    type: date
    sql: ${TABLE}."EFFECTIVE_END_DATE" ;;

  }

  }
