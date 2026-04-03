SELECT
    pg.user_id,
    pg.company_id,
    pg.market_id,
    pg.resource_id,
    pg.resource_type_id,
    pg.group_id,
    pg.group_name,
    pg.role_spending_limit,
    pg.group_spending_limit,
    pg.permission_granted_by_level,
    pg.branch_level_access
FROM {{ source('procurement_public', 'policy_grants') }} as pg
