connection: "es_snowflake_analytics"

# include: "/Dashboards/Conversion_Contest_2022/Views/distinct_conversions.view.lkml"
# include: "/Dashboards/Conversion_Contest_2022/Views/markets.view.lkml"
# include: "/Dashboards/Conversion_Contest_2022/Views/companies.view.lkml"
# include: "/Dashboards/Conversion_Contest_2022/Views/conversion_contest_2022.view.lkml"
# include: "/Dashboards/Conversion_Contest_2022/Views/market_region_xwalk.view.lkml"
# include: "/Dashboards/Conversion_Contest_2022/Views/invoices.view.lkml"

#MB commented out 5/22/24
# explore: distinct_conversions {
#   join: markets {
#     type: inner
#     relationship: many_to_one
#     sql_on: ${distinct_conversions.invoice_branch} = ${markets.market_id} ;;
#   }
#   join: companies {
#     type: inner
#     relationship: many_to_one
#     sql_on: ${distinct_conversions.company_id} = ${companies.company_id} ;;
#   }
# }


# explore: conversion_contest_2022 {
#   case_sensitive: no

#   join: companies {
#     type: inner
#     relationship: many_to_one
#     sql_on: ${conversion_contest_2022.company_id} = ${companies.company_id} ;;
#   }

#   join: market_region_xwalk {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${conversion_contest_2022.invoice_branch} = ${market_region_xwalk.market_id} ;;
#   }

#   join: invoices {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${conversion_contest_2022.invoice_id} = ${invoices.invoice_id} ;;
#   }
# }
