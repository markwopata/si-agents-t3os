{{
    codegen.generate_base_model(
        source_name = 'heap',
        table_name = 'user_migrations'
    )
}}

{{
    codegen.generate_model_yaml(
        model_names=['stg_heap__user_migrations']
    )
}}

{{ generate_model_yaml_with_default_doc_blocks(
    ['dim_companies'
     ]
) }}


{{ generate_source_yaml_with_default_doc_blocks([
    {
        'source_name': 'payroll',
        'database': 'analytics',
        'schema': 'payroll',
        'description': 'Payroll source tables from Workday',
        'tables': [
            'company_directory',
            'company_directory_vault'
            ]
    }
]) }}

{{ generate_doc_blocks_for_model([
    'dim_dates_bi', 'dim_companies_bi'
]) }}