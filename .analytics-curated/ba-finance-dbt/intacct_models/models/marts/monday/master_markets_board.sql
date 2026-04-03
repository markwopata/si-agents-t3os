with master_markets_output as (
    {{ generate_monday_table_from_column_map('5444327901') }}
)

select
-- Explicitly name columns so schema changes break this model. This will add a second step to make sure we aren't 
-- affecting other reporting.

-- Board/item metadata
    mmb.board_id,
    mmb.item_id,
    mmb.group_id,
    mmb.group_title,
    mmb.grouping_name,
    mmb.is_active_project,

    -- Branch related columns
    mmb.market_id,
    mmb.branch_name,
    mmb.address,
    mmb.region_district,
    mmb.region,
    mmb.division,
    mmb.construction_district,
    mmb.market_type, -- alias for division
    mmb.branch_abbreviation,
    mmb.sales_service_email,
    mmb.url_market_google_drive_folder,

    -- Persons of importance
    mmb.project_manager_name,
    mmb.construction_project_manager_name,

    -- Space metrics
    mmb.useable_acres,
    mmb.total_acres,
    mmb.shop_sq_ft,
    mmb.office_sq_ft,
    mmb.total_sq_ft,

    -- Status fields/general categorization
    mmb.building_type,
    mmb.transaction_type,
    mmb.drawings_status,
    mmb.yard_status,
    mmb.utilities_status,
    mmb.launch_phase,
    mmb.subitem_status,
    mmb.business_license_status,
    mmb.new_market_notifications_status,
    mmb.certificate_of_occupancy_status,
    mmb.point_of_contact_status,
    mmb.fleet_transportation_status,
    mmb.fleet_placement_flag,
    mmb.early_fleet_placement_comments,

    -- General manager fields
    mmb.general_manager_recruiting_status,
    mmb.general_manager_name,
    mmb.general_manager_email,

    -- Dates and timestamps
    mmb.due_diligence_end_date,
    mmb.basic_operational_readiness_completed_date,
    mmb.basic_operational_readiness_target_date,
    split_part(mmb.target_construction_completion_date, ',', 1) as target_construction_completion_date,
    mmb.washbay_completion_date,
    mmb.actual_first_rental_date,
    mmb.close_date,
    mmb.possession_date,
    mmb.cpm_project_completion_date,
    mmb.last_updated_date
from master_markets_output as mmb
