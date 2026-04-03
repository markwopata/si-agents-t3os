SELECT
    efv.month_,
    efv.version,
    efv.version_set_name,
    efv.date_registered
FROM {{ source('analytics_revmodel', 'es_financials_versions') }} as efv
