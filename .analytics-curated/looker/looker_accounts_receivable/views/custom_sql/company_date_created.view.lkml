view: company_date_created {
  derived_table: {
    sql: SELECT
          c.company_id,
          u.date_created::date as date_created
         FROM (
           SELECT *,
                  ROW_NUMBER() OVER (PARTITION BY company_id ORDER BY date_created) AS rn
             FROM es_warehouse.public.users
         ) u
         JOIN es_warehouse.public.companies c ON u.company_id = c.company_id
         WHERE u.rn = 1;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: date_created {
    label: "Company Date Created"
    type: date
    sql:  ${TABLE}."DATE_CREATED" ;;
  }
}
