
include: "/dashboards/commission_investigation/direct_query/commission_lookup.view.lkml"

explore: commission_lookup {
  label: "Commission Lookup"
  from:  commission_lookup
}
