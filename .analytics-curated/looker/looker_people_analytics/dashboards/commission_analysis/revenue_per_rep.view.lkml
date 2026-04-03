view: revenue_per_rep {
  derived_table: {
    sql:
WITH months AS (
    -- Generate a list of months dynamically
    SELECT DATE_TRUNC('MONTH', DATEADD(MONTH, ROW_NUMBER() OVER (ORDER BY SEQ4()) - 1, '2023-01-01')) AS month_start
    FROM TABLE (GENERATOR(ROWCOUNT => 25))),
     rep_days AS (
         -- Calculate the number of guarantee and commission days per month for each user
         SELECT e.USER_ID,
                CASE -- will eventually filter out non rental reps
                    WHEN COMMISSION_TYPE_ID IN (1, 2, 3, 4, 5) THEN 'TAMs'
                    WHEN COMMISSION_TYPE_ID IN (6, 7) THEN 'NAMs'
                    WHEN COMMISSION_TYPE_ID IN (8, 9, 10, 11, 12) THEN 'RAMs'
                    ELSE 'Other' -- Optional, to handle unexpected values
                    END                      AS COMMISSION_GROUP,
                e.GUARANTEE_START,
                e.GUARANTEE_END,
                e.COMMISSION_START,
                e.COMMISSION_END,
                m.month_start,
                -- Exclude users if their guarantee ended before this month or started after this month
                CASE
                    WHEN e.GUARANTEE_END < m.month_start OR e.GUARANTEE_START > LAST_DAY(m.month_start) THEN 0
                    ELSE DATEDIFF(DAY, GREATEST(m.month_start, e.GUARANTEE_START),
                                  LEAST(LAST_DAY(m.month_start), e.GUARANTEE_END)) + 1
                    END                      AS guarantee_days,
                -- Exclude users if their commission ended before this month
                CASE
                    WHEN e.COMMISSION_END < m.month_start THEN 0
                    ELSE DATEDIFF(DAY, GREATEST(m.month_start, e.COMMISSION_START),
                                  LEAST(LAST_DAY(m.month_start), e.COMMISSION_END)) + 1
                    END                      AS commission_days,
                DAY(LAST_DAY(m.month_start)) AS total_days_in_month
         FROM analytics.commission.EMPLOYEE_COMMISSION_INFO e
                  CROSS JOIN months m
         WHERE
            -- Only include months where a rep was ever active
             (e.GUARANTEE_START IS NOT NULL AND e.GUARANTEE_END IS NOT NULL AND e.GUARANTEE_END >= m.month_start)
            OR (e.COMMISSION_START IS NOT NULL AND e.COMMISSION_END IS NOT NULL AND e.COMMISSION_END >= m.month_start)),
     calculated_entry AS (
         -- Ensure days are within a valid range and compute the proportion
         SELECT USER_ID,
                COMMISSION_GROUP,
                GUARANTEE_START,
                GUARANTEE_END,
                COMMISSION_START,
                COMMISSION_END,
                month_start,
                GREATEST(0, guarantee_days)                              AS guarantee_days, -- Prevent negative days
                GREATEST(0, commission_days)                             AS commission_days,
                total_days_in_month,
                GREATEST(0, guarantee_days) * 1.0 / total_days_in_month  AS guarantee_percentage,
                GREATEST(0, commission_days) * 1.0 / total_days_in_month AS commission_percentage
         FROM rep_days
         -- Remove users who have 0 guarantee AND 0 commission in a month
         WHERE guarantee_days > 0
            OR commission_days > 0),

     revenue_per_month AS (SELECT COMMISSION_MONTH, SUM(LINE_ITEM_AMOUNT) AS REVENUE
                           FROM analytics.commission.core_commission_increase_table -- referencing long sql query that is created in file create_core_comission_increase_table.sql
                           GROUP BY COMMISSION_MONTH),

     final_organized as (select fo.month_start,
                                COMMISSION_GROUP,
                                sum(guarantee_percentage)                                as guarantee_employees,
                                sum(commission_percentage)                               as commission_employees,
                                (sum(guarantee_percentage) + sum(commission_percentage)) as total_employees
                         from calculated_entry fo
                         where COMMISSION_GROUP in ('TAMs', 'NAMs') --filtering out non rental reps
                         group by month_start, COMMISSION_GROUP)

select MONTH_START,
       COMMISSION_GROUP,
       GUARANTEE_EMPLOYEES,
       COMMISSION_EMPLOYEES,
       TOTAL_EMPLOYEES,
       REVENUE,
       div0null((REVENUE), ((GUARANTEE_EMPLOYEES) + (COMMISSION_EMPLOYEES))) as REVENUE_PER_EMPLOYEE,
       div0null((REVENUE), (COMMISSION_EMPLOYEES))                           as REVENUE_PER_COMMISSION_EMPLOYEE,
       div0null((REVENUE), (GUARANTEE_EMPLOYEES))                            as REVENUE_PER_GUARANTEE_EMPLOYEE
from final_organized
         left join revenue_per_month r on month_start = r.COMMISSION_MONTH
order by month_start desc


;;}

  dimension_group: MONTH_START {
    type: time
    label: "Month"
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}."MONTH_START" ;;
  }
  dimension: COMMISSION_GROUP {
    label: "Commission Salesrep Type"
    type: string
    sql: ${TABLE}."COMMISSION_GROUP" ;;
  }

  measure: GUARANTEE_EMPLOYEES {
    label: "Number of Guarantee Employees"
    type: sum
    sql: ${TABLE}."GUARANTEE_EMPLOYEES" ;;
  }
    measure: COMMISSION_EMPLOYEES {
      label: "Number of Commissionable Employees"
      type: sum
      sql: ${TABLE}."COMMISSION_EMPLOYEES" ;;
    }
    measure: TOTAL_EMPLOYEES {
      label: "Number of Total Employees"
      type: sum
      sql: ${TABLE}."TOTAL_EMPLOYEES" ;;
    }
    measure: REVENUE_PER_EMPLOYEE {
      label: "Revenue per Total Employee"
      type: sum
      sql: ${TABLE}."REVENUE_PER_EMPLOYEE" ;;
    }
    measure: REVENUE_PER_COMMISSION_EMPLOYEE {
      label: "Revenue per Commissionable Employee"
      type: sum
      sql: ${TABLE}."REVENUE_PER_COMMISSION_EMPLOYEE" ;;
    }
    measure: REVENUE_PER_GUARANTEE_EMPLOYEE {
      label: "Revenue per Guarantee Employee"
      type: sum
      sql: ${TABLE}."REVENUE_PER_GUARANTEE_EMPLOYEE" ;;
    }
  }
