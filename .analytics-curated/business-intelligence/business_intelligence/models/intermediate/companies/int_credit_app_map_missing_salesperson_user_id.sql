{{ config(
    materialized='table',
    unique_key=['camr_id'],
    incremental_strategy='merge',
    merge_exclude_columns = ['_created_recordtimestamp']
) }} 

with missing_salesperson_user_id as (
    SELECT
        distinct salesperson as salesperson
        , SPLIT_PART(TRIM(salesperson), ' ', 1) AS first_name
        , IFF(
            POSITION(' ', TRIM(salesperson)) > 0,
            REVERSE(SPLIT_PART(REVERSE(TRIM(salesperson)), ' ', 1)),
            NULL
        ) AS last_name
    from {{ ref('stg_retool__credit_app_master_retool') }}
    where date_created_utc::date < '2024-04-05'::date
    AND salesperson_user_id is null
    AND salesperson is not null and salesperson <> 'Pending Rep Assignment'
    AND salesperson NOT IN ('AUS House Sales','Chattanooga TN','FTM TT House Sales'
            , 'JAX TT House Sales', 'Jacksonville P&P Service', 'Kansas City  Service'
            , 'Las Vegas Sales', 'Little Rock Sales', 'MIA TT House Sales' , 'MKE House Sales'
            , 'N', 'NEW House Sale', 'OLB House  Sales' , 'ORL TT House Sales', 'Omaha - House'
            , 'Orlando Sales', 'PAS House Sales', 'Passed', 'Pine Bluff Sales', 'TMP TT House Sales'
            , 'TUL House Sales', 'Victoria, TX ITL House Sales', 'WPB TT House Sales'
            , 'Wichita Sales', 'abi sales', 'acct.was under cod, PG came in from customer service-cu'
            , 'chris clark', 'in', 'none' , 'sa', 'travis', '0', 'Johnson', 'Louisville Sales'
        )
)

    , map_to_employee_id as (
        select c.camr_id
            , c.salesperson
            , cd.employee_id
        from {{ ref('stg_retool__credit_app_master_retool') }} c
        join missing_salesperson_user_id missing
            on c.salesperson = missing.salesperson
        join {{ ref('stg_payroll__company_directory') }} cd
            ON cd.first_name = missing.first_name
            AND cd.last_name = missing.last_name
            AND c.date_created_ct between COALESCE(cd.position_effective_date, cd.date_hired) and COALESCE(cd.date_terminated, DATE '9999-12-31')
        -- dates in company directory are not always reliable so joins may cause duplicates; make best guess on employee_id mapping
        QUALIFY ROW_NUMBER() OVER (
            PARTITION BY camr_id
            ORDER BY
                COALESCE(cd.position_effective_date, cd.date_hired) DESC NULLS LAST
            ) = 1
    )

    , combined as (
        select 
            m.camr_id
            , m.salesperson
            , m.employee_id
            , br.user_id
        from map_to_employee_id m
        join {{ ref('int_bridge_user_employee') }} br 
        on m.employee_id = br.employee_id
        UNION ALL
        -- manual mapping
        select camr_id
            , salesperson
            , 2857 as employee_id
            , br.user_id
        from {{ ref('stg_retool__credit_app_master_retool') }}  c 
        join {{ ref('int_bridge_user_employee') }} br 
        on 2857 = br.employee_id and c.salesperson = 'Francisco De Jesus'
    )

    select
        camr_id
        , salesperson
        , employee_id
        , user_id
        , {{ get_current_timestamp() }} AS _created_recordtimestamp
        , {{ get_current_timestamp() }} AS _updated_recordtimestamp
    from combined