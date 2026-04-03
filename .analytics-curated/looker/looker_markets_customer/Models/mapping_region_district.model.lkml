connection: "es_snowflake_analytics"

# include: "/views/ANALYTICS/districts.view.lkml"
# include: "/views/ANALYTICS/regions.view.lkml"
# include: "/views/ANALYTICS/topo_json_region_district.view.lkml"
# include: "/views/ANALYTICS/county_fips_district_mapping.view.lkml"

#MB commented out 5/23/24 explore returned unused or tied to old dashboard
# map_layer: region_layer {
#   file: "/map_region.topojson"
#   property_key: "id"
# }

# explore: county_fips_district_mapping{
#   label: "Region-District Mapping"
#   group_label: "Region-District Mapping"

#   join: districts {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${county_fips_district_mapping.district} = ${districts.district_id};;
#   }

#   join: regions {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${districts.region_id} = ${regions.region_id} ;;
#   }
# }

# explore: topo_json_region_district {
#   join: districts{
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${topo_json_region_district.id} = ${districts.district_id} ;;
#   }

#   join: regions {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${districts.region_id} = ${regions.region_id} ;;
#   }
# }
