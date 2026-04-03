#
# The purpose of this view is to add ownership status to service assets so we can incorporate Non-ES Owned assets
# into the service bulletin lookup tool. This dashboard is intended to be a place to lookup assets with service or
# recall alerts.
#
# Britt Shanklin | Built 2022-06-30

include: "/views/ES_WAREHOUSE/assets.view.lkml"

view: assets_service_bulletin {
  extends: [assets]

  # service ownership status is dependent on joins to markets and service_markets in the explore
  dimension: service_ownership_status {
    type: string
    sql:  CASE
          WHEN ${company_id} IN (1854, 1855) OR (${company_id} = 8151 AND ${rental_branch_id} IS NOT NULL) THEN 'ES Owned'
          WHEN ${company_id} = 11606 OR ${serial_number} REGEXP 'RR\\d.+' OR ${custom_name} REGEXP 'RR\\d.+' THEN 'Re-rent'
          WHEN ${companies.name} REGEXP 'IES\\d.+'  OR ${custom_name} REGEXP 'FP\\d.+'  THEN 'Floor Plan'
          WHEN ${company_id} <> 1854 AND ${rental_markets.company_id} = 1854 THEN 'Contractor Owned'
          WHEN ${company_id} <> 1854 AND (${rental_markets.company_id} <> 1854 OR ${rental_markets.company_id} IS NULL) AND ${service_markets.company_id} = 1854 THEN 'Serviced by ES'
          END;;
  }

  # used to filter assets to include in inventory information that includes assets serviced by ES
  dimension: include_service_asset {
    type: yesno
    sql: NOT ${deleted} AND ${company_id} NOT IN (32367, 31712, 32365, 155) AND
      (${company_id} = 1854 OR ${rental_markets.company_id} = 1854 OR ${service_markets.company_id} = 1854) ;;
  }

}
