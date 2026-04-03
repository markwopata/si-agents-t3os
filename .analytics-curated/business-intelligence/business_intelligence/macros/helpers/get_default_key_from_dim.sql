{%- macro get_default_key_from_dim(model_name) -%}
    
    {%- if model_name == 'dim_dates' -%}
        (
            SELECT dt_key
            FROM {{ ref(model_name) }}
            WHERE dt_year = 1
        )

    {%- elif model_name == 'dim_times' -%}
        (
             SELECT tm_key
            FROM {{ ref(model_name) }}
            WHERE tm_hour = -1
        )

    {%- elif model_name == 'dim_quotes' -%}
        (
            SELECT quote_key
            FROM {{ ref(model_name) }}
            WHERE quote_number = -1
        )

    {%- elif model_name == 'dim_quote_customers' -%}
        (
            SELECT quote_customer_key
            FROM {{ ref(model_name) }}
            WHERE quote_customer_id = 'Unknown'
        )
    
    {%- elif model_name == 'dim_orders' -%}
        (
            SELECT order_key
            FROM {{ ref(model_name) }}
            WHERE order_id = -1
        )
    
    {%- elif model_name == 'dim_invoices' -%}
        (
            SELECT invoice_key
            FROM {{ ref(model_name) }}
            WHERE invoice_id = -1
        )

    {%- elif model_name == 'dim_users' -%}
        (
            SELECT user_key
            FROM {{ ref(model_name) }}
            WHERE user_id = -1
        )   
    
    {%- elif model_name == 'dim_salesperson_enhanced' -%}
        (
            SELECT salesperson_key
            FROM {{ ref(model_name) }}
            WHERE user_id = -1
        )   

     {%- elif model_name == 'dim_employees' -%}
        (
            SELECT employee_key
            FROM {{ ref(model_name) }}
            WHERE employee_id = -1
            
        )   

    {%- elif model_name == 'dim_markets' -%}
        (
            SELECT market_key
            FROM {{ ref(model_name) }}
            WHERE market_id = -1
        )        

    {%- elif model_name == 'dim_parts' -%}
        (
            SELECT part_key
            FROM {{ ref(model_name) }}
            WHERE part_id = -1
        )    

    {%- elif model_name == 'dim_equipment_classes' -%}
        (
            SELECT equipment_class_key
            FROM {{ ref(model_name) }}
            WHERE equipment_class_id = -1
        )      

    {%- elif model_name == 'dim_assets' -%}
    (
        SELECT asset_key
        FROM {{ ref(model_name) }}
        WHERE asset_id = -1
    )      

    {%- elif model_name == 'dim_companies' -%}
    (
        SELECT company_key
        FROM {{ ref(model_name) }}
        WHERE company_id = -1
    )   

    {%- elif model_name == 'dim_locations' -%}
    (
        SELECT location_key
        FROM {{ ref(model_name) }}
        WHERE location_id = -1
    )   

    {% endif %}

{%- endmacro -%}