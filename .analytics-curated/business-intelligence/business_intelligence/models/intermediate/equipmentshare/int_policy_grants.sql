with recursive
    policy_grants as (
        select
            ug.user_id as user_id,
            parent_resource.company_id as company_id,
            parent_resource.object_id as object_id,
            parent_resource.resource_id as resource_id,
            parent_resource.resource_type_id as resource_type_id,
            parent_policy.group_id as group_id,
            parent_policy.role_id as role_id,
            r.spending_limit::number as role_spending_limit,
            g.spending_limit::number as group_spending_limit
            ,
            case
                when parent_resource.resource_type_id = 1
                then 'EquipmentShare'
                when parent_resource.resource_type_id = 2
                then 'Company'
                when parent_resource.resource_type_id = 3
                then 'Region'
                when parent_resource.resource_type_id = 4
                then 'Store'
                when parent_resource.resource_type_id = 5
                then 'Branch'
                else 'Unknown'
            end as permission_granted_by_level
        from {{ ref("platform", "resource_policies") }} as parent_policy
        join
            {{ ref("platform", "resources") }} as parent_resource
            on parent_policy.resource_id = parent_resource.resource_id
        join
            {{ ref("platform", "groups") }} as g
            on g.group_id = parent_policy.group_id
            and g.date_archived is null
        join
            {{ ref("platform", "roles") }} as r
            on r.role_id = parent_policy.role_id
            and r.date_archived is null
        join
            {{ ref("platform", "user_groups") }} as ug
            on ug.group_id = parent_policy.group_id
        where parent_resource.company_id in (1854, 60574)
        union all
        select
            policy_grants.user_id as user_id,
            policy_grants.company_id as company_id,
            child_resource.object_id as child_resource_object_id,
            child_resource.resource_id as child_resource_resource_id,
            child_resource.resource_type_id as child_resource_resource_type_id,
            policy_grants.group_id as policy_grants_group_id,
            policy_grants.role_id as policy_grants_role_id,
            policy_grants.role_spending_limit::number as role_spending_limit,
            policy_grants.group_spending_limit::number as group_spending_limit,
            case
                when policy_grants.resource_type_id = 1
                then 'EquipmentShare'
                when policy_grants.resource_type_id = 2
                then 'Company'
                when policy_grants.resource_type_id = 3
                then 'Region'
                when policy_grants.resource_type_id = 4
                then 'Store'
                when policy_grants.resource_type_id = 5
                then 'Branch'
                else 'Unknown'
            end as permission_granted_by_level
        from {{ ref("platform", "resources") }} as child_resource
        join policy_grants on child_resource.parent_id = policy_grants.resource_id
    ),
    policy_grants_with_spend as (
        select distinct
            policy_grants.user_id,
            policy_grants.company_id,
            policy_grants.object_id as market_id,
            policy_grants.resource_id,
            policy_grants.resource_type_id,
            policy_grants.group_id,
            g.name as group_name,
            policy_grants.role_spending_limit,
            policy_grants.group_spending_limit,
            policy_grants.permission_granted_by_level,
            case
                when pg2.permission_granted_by_level = 'Branch' then 'YES' else 'NO'
            end as branch_level_access,
            row_number() over (
                partition by policy_grants.user_id, market_id
                order by
                    policy_grants.group_spending_limit desc,
                    policy_grants.role_spending_limit desc
            ) as rn
        from policy_grants
        join
            {{ ref("platform", "role_permissions") }} as rp
            on rp.role_id = policy_grants.role_id
        join
            {{ ref("platform", "permissions") }} as p
            on p.permission_id
            = rp.permission_id
        left join
            policy_grants pg2
            on pg2.permission_granted_by_level = 'Branch'
            and pg2.user_id = policy_grants.user_id
            and pg2.object_id = policy_grants.object_id
        join {{ ref("platform", "groups") }} as g on g.group_id = policy_grants.group_id
        where
            policy_grants.resource_type_id
            = p.resource_type_id
            and p.permission_id in (70)
            and policy_grants.user_id is not null
    )
select
    user_id,
    company_id,
    market_id,
    resource_id,
    resource_type_id,
    group_id,
    group_name,
    role_spending_limit,
    group_spending_limit,
    permission_granted_by_level,
    branch_level_access
from policy_grants_with_spend
where rn = 1
