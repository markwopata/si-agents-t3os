SELECT
    pp._row,
    pp.trunc,
    pp.year,
    pp.display,
    pp.month_num,
    pp._fivetran_synced,
    pp.quarter,
    pp.period_published
FROM {{ source('analytics_gs', 'plexi_periods') }} as pp
