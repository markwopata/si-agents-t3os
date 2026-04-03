{%- macro get_last_timestamp_from_dim(model_name) -%}
    
    {%- if model_name == 'dim_dates' -%}
        (
            SELECT max(dt_recordtimestamp)
            FROM {{ ref(model_name) }}
        )

    {%- elif model_name == 'dim_times' -%}
        (
             SELECT max(tm_recordtimestamp)
            FROM {{ ref(model_name) }}
        )
    
    {%- elif model_name == 'dim_orders' -%}
        (
            SELECT max(order_recordtimestamp)
            FROM {{ ref(model_name) }}
        )
    
    {%- elif model_name == 'dim_invoices' -%}
        (
            SELECT max(invoice_recordtimestamp)
            FROM {{ ref(model_name) }}
        )

    {%- elif model_name == 'dim_users' -%}
        (
            SELECT max(user_recordtimestamp)
            FROM {{ ref(model_name) }}
        )   

    {%- elif model_name == 'dim_markets' -%}
        (
            SELECT max(market_recordtimestamp)
            FROM {{ ref(model_name) }}
        )        

    {%- elif model_name == 'dim_parts' -%}
        (
            SELECT max(part_recordtimestamp)
            FROM {{ ref(model_name) }}
        )    

    {%- elif model_name == 'dim_assets' -%}
    (
        SELECT max(asset_recordtimestamp)
        FROM {{ ref(model_name) }}
    )      

    {%- elif model_name == 'dim_companies' -%}
    (
        SELECT max(company_recordtimestamp)
        FROM {{ ref(model_name) }}
    )   

    {# BUSINESS INTELLIGENCE DIMENSIONS #}
    
    {%- elif model_name == 'dim_salesperson_enhanced' -%}
        (
            SELECT max(_updated_recordtimestamp)
            FROM {{ ref(model_name) }}
        )   

     {%- elif model_name == 'dim_employees' -%}
        (
            SELECT max(_updated_recordtimestamp)
            FROM {{ ref(model_name) }}            
        )   

    {%- elif model_name == 'dim_equipment_classes' -%}
        (
            SELECT max(_updated_recordtimestamp)
            FROM {{ ref(model_name) }}
        )      

    {%- elif model_name == 'dim_quotes' -%}
        (
            SELECT max(_updated_recordtimestamp)
            FROM {{ ref(model_name) }}
        )

    {%- endif -%}

{%- endmacro -%}