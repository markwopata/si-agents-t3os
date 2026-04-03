connection: "es_warehouse"

include: "/views/*.view.lkml"

explore: groupjobsiteauditsummary_cam_7059 {
  group_label: "Fleet"
  label: "Group Jobsite Audit Summary Report for Cam Services"
  case_sensitive: no

}
