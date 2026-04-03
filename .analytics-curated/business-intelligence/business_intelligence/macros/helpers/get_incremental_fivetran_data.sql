{%- macro get_incremental_fivetran_data() -%}

    where _fivetran_synced > ( 
        select max(_fivetran_synced) 
        from {{ this }} 
    )

{%- endmacro -%}