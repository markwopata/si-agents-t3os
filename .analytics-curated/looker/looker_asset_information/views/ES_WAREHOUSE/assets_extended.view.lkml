#
# The purpose of this view is to add ownership status to assets so we can incorporate Non-ES Owned assets
# into inventory information but still default to ES Owned assets.
#
# Britt Shanklin | Built 2022-06-27 | Last Modified 2022-07-21 BES

include: "/views/ES_WAREHOUSE/assets.view.lkml"

view: assets_extended {
  label: "Assets Rental Ownership"
  extends: [assets]

  # ownership status is dependent on joins to markets ompanies in the explore
  # added 1855 and 8151 w/ rental branch per Andrew Cowherd - 2022-06-30 BES
  # added 61306 to ES Owned - 2022-07-21 BES
  dimension: ownership_status {
    type: string
    sql:      CASE
              WHEN ${company_id} in (1854, 1855, 61036) or (${company_id} = 8151 and ${rental_branch_id} is not null) THEN 'ES Owned'
              WHEN  ${companies.name} REGEXP 'IES\\d.+'  or ${custom_name} REGEXP 'FP\\d.+'  THEN 'Floor Plan'
              WHEN ${rental_market.company_id} = 1854 and ${company_id} <> 1854 THEN 'OWN Program'
              WHEN ${company_id} = 11606 OR ${serial_number} REGEXP 'RR\\d.+' OR ${custom_name} REGEXP 'RR\\d.+'  THEN 'Re-rent'
              ELSE 'Customer Asset'
              END ;;
  }

 # used to filter assets to include in inventory information
 dimension: include_asset {
    type: yesno
    sql: NOT ${deleted} AND ${company_id} NOT IN (32367, 31712, 32365, 155)
    and (${company_id} = 1854 OR ${rental_market.company_id} = 1854) ;;
  }

}
