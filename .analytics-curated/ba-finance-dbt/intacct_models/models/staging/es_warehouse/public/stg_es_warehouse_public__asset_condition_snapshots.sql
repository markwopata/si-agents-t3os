SELECT
    acs.asset_condition_snapshot_id,
    acs.asset_id,
    acs.reporting_user_id,
    acs.new_damage_description,
    acs.notes,
    acs.hours_reading,
    acs.odometer_reading,
    acs.fuel_reading,
    acs.photos,
    acs.date_created,
    acs._es_update_timestamp
FROM {{ source('es_warehouse_public', 'asset_condition_snapshots') }} as acs
