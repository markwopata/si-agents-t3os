SELECT
    user_id,
    CASE
        WHEN company_id <> 1854 AND (deleted = FALSE OR email_address NOT ILIKE '%deleted%')
        AND (
                (first_name ILIKE '%customer%' AND last_name ILIKE '%support%')
                OR  (first_name ILIKE '%customer%' AND last_name ILIKE '%service%')
                OR  (first_name ILIKE '%customer%' AND last_name ILIKE '%success%')
                OR  (first_name ILIKE '% support')
                OR  (last_name  ILIKE '% support')
                OR  (first_name ILIKE 'support')
                OR  (last_name  ILIKE 'support')
                OR  (first_name ILIKE 'customer' AND last_name ILIKE 'customer')
            )
        AND last_name NOT ILIKE '%uptime operations%'
        AND last_name NOT ILIKE '%services, llc (ap)%'
        AND last_name NOT ILIKE '%service inquiries%'
        AND first_name NOT ILIKE 'ap customer'
        THEN TRUE
        ELSE FALSE
    END AS is_support_user
FROM {{ ref('platform', 'users') }} 
WHERE _users_effective_delete_utc_datetime IS NULL