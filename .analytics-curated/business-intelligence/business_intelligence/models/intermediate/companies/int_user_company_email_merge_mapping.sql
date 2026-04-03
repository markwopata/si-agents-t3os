{%- set excluded_patterns = [
     'yhaoo', 'example', '.come', '.con'
] -%}

-- country code top-level domains (ccTLDs)
{%- set excluded_cctlds = [
  'uk', 'fr', 'de', 'ru', 'br', 'jp', 'nz', 'au', 'se', 'pt', 'ie',
  'cn', 'in', 'mx', 'ca', 'pl', 'by', 'ua', 'tr', 'cl', 'ng', 'ne',
  'bz', 'ag', 'hk', 'il', 'sg', 'za', 'tw', 'kr'
] -%}

-- '%(%@%)%', 
-- , '%google.com', 'me.co', 'ix.netcom.com', 'startmail.com'

-- get email addresses from users
with users as (
    select 
        user_id
        , company_id
        , email_address
        , NULLIF(TRIM(LOWER(SPLIT_PART(email_address, '@', 2))), '') AS email_domain
    from {{ ref('platform', 'users') }} u
    where NOT (email_address ILIKE '%delete%'
            OR email_address ILIKE '%customersupport%'
            OR email_address ILIKE '%equipmentshare%'
            OR email_address = ''
        )
        and email_address like '%@%'
)

    , excluded_companies as (
        SELECT company_id FROM {{ ref('int_companies_seed_flagged') }}
        UNION ALL
        SELECT from_company_id FROM {{ ref('int_companies_seed_merged') }}
    )

    -- exclude companies that have already been identified as flagged or merged
    , companies as (
        select c.company_id
            , c.company_name
            , CASE 
                WHEN c.company_name ilike '%@%.%'
                    AND (
                    {% for pattern in excluded_patterns -%}
                        c.company_name NOT ILIKE '%{{ pattern }}%' {% if not loop.last %}AND {% endif %}
                    {% endfor -%}
                    )
                    -- exclude emails with international geographical domains, ending with .ru, .cn, etc
                    AND  (
                        {% for tld in excluded_cctlds -%}
                        COALESCE(
                            REGEXP_SUBSTR(
                                TRIM(LOWER(SPLIT_PART(c.company_name, '@', 2))), 
                                '\\.([a-z]{2,})$', 1, 1, 'e', 1
                            ), ''
                        ) NOT ILIKE '{{ tld }}'
                        {% if not loop.last %}AND {% endif %}
                        {% endfor -%}
                    )
                    AND NULLIF(TRIM(SPLIT_PART(c.company_name, '@', 2)), '') IS NOT NULL
                THEN TRIM(LOWER(SPLIT_PART(c.company_name, '@', 2)))
                ELSE NULL 
            END AS email_domain
        from {{ ref('platform', 'dim_companies') }} c
        LEFT JOIN excluded_companies e ON c.company_id = e.company_id
        where e.company_id IS NULL
        and c.company_name <> ''
    )

    -- Filter users that have a company_id but that company is not an email
    , user_companies AS (
        SELECT
            u.user_id
            , u.company_id
            , u.email_address
            , u.email_domain
        FROM users u
        LEFT JOIN companies c
        ON u.company_id = c.company_id AND c.email_domain IS NOT NULL
        WHERE c.company_id IS NULL
        -- AND u.company_id IS NOT NULL
    )

    -- type 1: find companies that match the user's email address exactly
    -- but the company ids do not match
    --  that should map but have different company_ids somehow when company_name is an email
    -- and leverage the one tied to the user
    , match_email_company_name as (
        select u.user_id
            , u.email_address
            , c.company_id as from_company_id 
            , c.company_name as from_company_name
            , u.company_id as to_company_id
            , to_company.company_name as to_company_name
        from user_companies u
        join companies c
        on lower(u.email_address) = lower(c.company_name)
        left join {{ ref('platform', 'dim_companies') }} to_company -- join to original because this is only for mapping purposes
        on to_company.company_id = u.company_id
        where u.company_id <> c.company_id 
        and c.company_id not in (68949) -- weird exception; this maps to two different company ids
    )

    -- type 2: match user email domain to company email domain
    -- for companies that have don't have an email domain
    -- only for those that don't
    -- , company_domain AS (
    --     SELECT
    --         u.company_id
    --         , u.email_domain
    --     FROM users u
    --     LEFT JOIN (select company_id from companies where email_domain is not null) c
    --     ON u.company_id = c.company_id
    --     WHERE c.company_id IS NULL
    -- )


    , valid_email_domains as (
        select email_domain
        from user_companies
        group by email_domain
        having count(distinct company_id) = 1
    )

    , filtered_companies as (
        select c.*
        from companies c 
        where email_domain in (select email_domain from valid_email_domains)
        and email_domain is not null
    )

    -- deduplicate before joining
    , user_company_domains as (
        select company_id, email_domain
        from user_companies
        group by company_id, email_domain
    )

    , match_email_domain as (
        select
            fc.company_id as from_company_id
            , fc.company_name as from_company_name
            , uc.company_id as to_company_id
            , c.company_name as to_company_name
        from filtered_companies fc
        JOIN user_company_domains uc
        on fc.email_domain = uc.email_domain
        JOIN {{ ref('platform', 'dim_companies') }} c --join to original because this is only for mapping purposes
        on uc.company_id = c.company_id
        where uc.company_id <> fc.company_id
    )

    -- combine the two types
    , combined as (
        select from_company_id, from_company_name, to_company_id, to_company_name
        from match_email_company_name
        UNION
        select from_company_id, from_company_name, to_company_id, to_company_name
        from match_email_domain
    )

    select
        from_company_id
        , from_company_name
        , to_company_id
        , to_company_name
    from combined
    where to_company_id not in (select company_id from {{ ref("int_companies_seed_flagged") }})