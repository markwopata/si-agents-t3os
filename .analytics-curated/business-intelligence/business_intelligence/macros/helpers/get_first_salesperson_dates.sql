{%- macro get_first_salesperson_dates(source_model, title_list) -%}


with hybrid_model as (
    select *
    from {{ ref(source_model) }} 
    {% if is_incremental() %}
    WHERE _dbt_updated_timestamp > (SELECT MAX(_dbt_updated_timestamp) FROM {{ this }})
    {% endif %}
),

-- Helper CTE for snapshot cutoff
helper_date AS (
    SELECT '2022-05-20'::date AS first_snapshot_date
),

-- Qualifying rehire into a title in the list
qualifying_rehire AS (
    SELECT employee_id,
           COALESCE(position_effective_date_hist, date_rehired_current) AS rehire_date
    FROM hybrid_model
    WHERE date_rehired_current IS NOT NULL
    AND employee_title_hist IN (
        {%- for title in title_list %}
        '{{ title }}'{% if not loop.last %}, {% endif %}
        {%- endfor -%}
    )
    AND TIMESTAMPADD(SECOND, 86399, DATE_TRUNC('day', date_rehired_current)) BETWEEN _valid_from AND _valid_to
),

-- Never Started rows to exclude
never_started AS (
    SELECT employee_id, employee_title_hist,
           position_effective_date_hist, date_hired_current, date_rehired_current, date_terminated_current
    FROM {{ ref(source_model) }} 
    WHERE employee_status_hist = 'Never Started'
),

-- isolate any employees that we don't have history before 2022-05-20 and doesn't get a new role
ambiguous_employees AS (
  SELECT employee_id
  FROM {{ ref(source_model) }} 
  GROUP BY employee_id
  HAVING 
    -- History starts at snapshot
    MIN(CAST(_valid_from AS DATE)) = (SELECT first_snapshot_date FROM helper_date)

    -- Only one distinct title in their history
    AND COUNT(DISTINCT employee_title_hist) = 1

    -- No rehire into a qualifying salesperson title
    AND COUNT_IF(
      date_rehired_current IS NOT NULL
      AND employee_title_hist IN (
        {%- for title in title_list %}
          '{{ title }}'{% if not loop.last %}, {% endif %}
        {%- endfor %}
      )
    ) = 0
),

-- Main logic to resolve start date
resolved_dates AS (
    SELECT s.employee_id,
           CAST(CASE 
             WHEN q.rehire_date IS NOT NULL THEN q.rehire_date
             WHEN s.position_effective_date_hist IS NOT NULL AND s.position_effective_date_hist < s._valid_to::date THEN s.position_effective_date_hist
             WHEN s.date_hired_current IS NOT NULL AND s.date_hired_current >= s._valid_from::date AND s.date_hired_current < s._valid_to::date THEN s.date_hired_current
             WHEN s._valid_from::date = (select first_snapshot_date from helper_date) THEN NULL
             ELSE s._valid_from
           END AS DATE) AS resolved_start_date
    FROM {{ ref(source_model) }}  s
    LEFT JOIN qualifying_rehire q 
    ON s.employee_id = q.employee_id
    WHERE s.employee_title_hist IN (
        {%- for title in title_list %}
        '{{ title }}'{% if not loop.last %}, {% endif %}
        {%- endfor -%}
    )
    AND s.employee_status_hist NOT IN ('Terminated')
    AND NOT EXISTS (
        SELECT 1
        FROM never_started ns
        WHERE s.employee_id = ns.employee_id
          AND s.employee_title_hist = ns.employee_title_hist
          AND (s.position_effective_date_hist IS NOT DISTINCT FROM ns.position_effective_date_hist)
          AND (s.date_hired_current IS NOT DISTINCT FROM ns.date_hired_current)
          AND (s.date_rehired_current IS NOT DISTINCT FROM ns.date_rehired_current)
          AND (s.date_terminated_current IS NOT DISTINCT FROM ns.date_terminated_current)
    )
    AND s.employee_id NOT IN (SELECT employee_id FROM ambiguous_employees)
)

SELECT employee_id, min(resolved_start_date) as start_date
FROM resolved_dates
GROUP BY 1

{%- endmacro -%}