SELECT
    pbm._row,
    pbm.display_name,
    pbm.sort_group,
    pbm.revexp,
    pbm."GROUP",
    pbm.gaap_account,
    pbm.sage_name,
    pbm.sage_gl,
    pbm._fivetran_synced,
    pbm.exclude_flag
FROM {{ source('analytics_gs', 'plexi_bucket_mapping') }} as pbm
