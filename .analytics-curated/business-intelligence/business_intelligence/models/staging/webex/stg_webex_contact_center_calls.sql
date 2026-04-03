WITH webex_calls AS (
    SELECT 
        TO_TIMESTAMP(cct.created_time / 1000)::DATE AS created_at,
        TO_TIMESTAMP(cct.ended_time / 1000)::DATE AS ended_at,
        cct.termination_type,
        cct.terminating_end,
        cct.matched_skill_name,
        SUM(cct.total_duration) AS total_duration,
        COUNT(*) AS calls,
        CASE 
            WHEN COUNT(m.phone_number) > 0 THEN TRUE
            ELSE FALSE
        END AS is_branch_call
    FROM {{ref('platform', 'inbound__webex__contact_center_task_details')}} AS cct
    LEFT JOIN {{ref('platform', 'es_warehouse__public__markets')}} AS m
        ON RIGHT(REGEXP_REPLACE(m.phone_number, '[^0-9]', ''), 10) = 
           RIGHT(REGEXP_REPLACE(cct.origin::STRING, '[^0-9]', ''), 10)
        AND m.phone_number IS NOT NULL
        AND TRIM(m.phone_number) <> ''
    GROUP BY 1,2,3,4,5
)
SELECT *
FROM webex_calls
