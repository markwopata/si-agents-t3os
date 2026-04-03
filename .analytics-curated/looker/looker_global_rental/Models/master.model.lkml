connection: "es_warehouse_global"

# include: "/views/*.view.lkml"                # include all views in the views/ folder in this project

# datagroup: 6AM_update {
#   sql_trigger: SELECT FLOOR((EXTRACT(epoch from NOW()) - 60*60*12)/(60*60*24)) ;;
#   max_cache_age: "24 hours"
# }

# datagroup: Every_Hour_Update {
#   sql_trigger: SELECT DATE_PART('hour', NOW()) ;;
#   max_cache_age: "1 hour"
# }

# datagroup: Every_Two_Hours_Update {
#   sql_trigger: SELECT FLOOR(EXTRACT(epoch from NOW()) / (2*60*60)) ;;
#   max_cache_age: "2 hours"
# }

# datagroup: Every_5_Min_Update {
#   sql_trigger: SELECT DATE_PART('minute', NOW()) ;;
#   max_cache_age: "5 minutes"
# }
