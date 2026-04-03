# New Historical Model for Assets

## Goals
Generally this will become a one stop shop for historical asset information. I can see this becoming very widely used given the pervasive nature of analytics around assets. The current world is fragmented in logic all of the place. This will hope to unify logic under one umbrella and provide an easy entry point for fleet reporting, 

### Definite replacements:
- branch earnings asset detail ("calculation", not the snapshot, + live)
- historical_asset_market (HAM table) - which market/company owns the asset
- historical_utilization - make rental/fleet determinations
- asset financing snapshot (calculation)

## Change Management
Given this model will be used for internal, external looker and financial reporting, it is likely a more formal change management process will be required to ensure sound, tested coding changes.

## Stakeholders
- Chris Kinney - audited financial OEC reporting on our statements + ABL reporting
- Russell Scott - utilization/modeling
- Michael Brown - general looker reporting
- Vishesh Mathur + Loren Severs - financial analytics/branch earnings
- Hayden Mills - currently using our utilization model

## Key Tables
Document all the key tables, from when the data can be trusted, whether it can be changed in the past, and what to do if the data changes

- scd_asset_rsp
  - Description: Historical asset rental_branch tracking table
  - Source: Data ops has a process during postgres WAL consumption to check whether the asset's RSP has changed.
  - Old data should not change because of how this is done.
  - Earliest data: 2014-11-02
- scd_asset_inventory
  - Description: Historical asset inventory_branch tracking table
  - Source: Data ops has a process during postgres WAL consumption to check whether the asset's inventory branch has changed.
  - Old data should not change because of how this is done.
  - Earliest data: 2014-11-02
- scd_asset_msp
  - Description: Historical asset service_branch tracking table
  - Source: Data ops has a process during postgres WAL consumption to check whether the asset's MSP has changed.
  - Old data should not change because of how this is done.
  - Earliest data: 2014-11-02
- scd_asset_company
  - Description: Tracks an asset's company through history
  - Source: Data ops has a process during postgres WAL consumption to check whether the asset's company_id has changed.
  - Old data should not change because of how this is done.
  - Earliest data: 2014-11-02
- scd_asset_inventory_status
  - Description: Asset's historical inventory status
  - Source: Data ops has a process during postgres WAL consumption to check whether the asset's inventory status has changed.
  - Old data should not change because of how this is done.
  - Earliest data: 2019-11-02 
- equipment_assignments
  - Description: Tracks an asset's assignment to a rental
  - Source: es-db. There is an equipment-assignments api that allows users to patch start/end dates for assets.
  - Old data can change - an asset's assignment can be changed through api. An asset's first rental date can change
  - Earliest data: 2015-02-04
- assets_aggregate
  - Description: dynamic table that combines asset informatino tables like class/category/others
  - Source: es-db
  - Live
- markets
  - Description: Get market name/info
  - Source: es-db
  - Live
- companies
  - Description: Get company/customer name
  - Source: es-db
  - Live
- v_payout_programs
  - Description: Dynamic table combining payout_programs and payout_program_assignments every 15 minutes. This will tell us when an asset is on a contractor payout program such as the OWN program.
  - Source: es-db
  - Known issues: they will sometimes not put assets on programs on time and then end up back dating.
- asset_purchase_history_logs
  - Description: Historical tracker for asset purchase history table - this is how we get OEC, finance status, financial schedule
  - Source: there is an es-api process that generates the logs. User has to do ?something to generate the logs
  - Earliest data: 2019-09-23
    - Earliest trusted data: 2020-08-01
      - Per comment on asset financing snapshot query. Added by VM https://equipmentshare.slack.com/archives/GJUE5B355/p1742589299524159?thread_ts=1742588322.464839&cid=GJUE5B355 
  - ? What is our patch for purchasing information prior to 2019-09? 
  
## Decisions

### Payout program assignment needs adjustment
Problems: 
- overlapping start dates
- couple assets are on multiple programs at the same time
- end dates are ending day before the last day which is bad for our typical pattern 
  of using the last nanosecond of the month to determine payout status
  

### Determine if asset is in rental fleet
Rentals used to be limited to asset type 1, which is why some assets were coerced to 1 even if they weren't equipment. We can't rely on this to tell if it can be rented.
Rental branch is another good possible check, but the api lets you rent if inventory branch matches the order. 
Historical utilization has a multi-step check around if asset_id is assigned to a rental or not and then if it's re-rent and then if it's contractor payout program. It also ages stuff out of the fleet after 9 months of not renting. Which is starting to make sense as an option given we can't tell if an asset is rentable or not.
Looker is using - if rental_branch_id is not null 