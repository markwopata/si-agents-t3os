with future_markets as (
    {{ generate_monday_table_from_column_map('10075479065') }}
)

select
    -- Project / Market Details
    item_id,
    item_name as market,
    city_state,
    branch_type,
    region_district,
    master_markets,
    under_contract_master_markets,
    new_market_additions,
    current_mrkt_expansion,
    project_status,

    -- Timeline / Milestones
    start_date,
    construction_start_dollars,
    close_date_expected,
    timeline,
    launch_phase,
    cpm_dm_kickoff_call,

    -- Incentives (status, apps, targets)
    incentive_status,
    incentive_application,
    potential_incentive_value,
    application_fee,
    ideal_quarter_target,
    quarter_target,

    -- Financials / Projections
    projected_oec,
    projected_fte,
    projected_payroll,
    maximum_monthly_spend,
    mega_project_2030_dollars,

    -- Activity / Ops
    subitems,
    survey_requests_2025,
    peer_locations,
    current_es_locations,
    num_of_deliveries,
    avg_delivery_miles_to,
    delivery_rank,
    addition_type,
    minimum_acreage,

    -- RFI / Links
    rfi_status,
    rfi_link_to_google_drive,
    local_discovery_call,
    cpm as construction_project_manager,

    -- Market Metrics
    total_current_es_in_msa,
    total_peer_in_msa,

    -- Notes / Priority
    notes_priority

from future_markets
