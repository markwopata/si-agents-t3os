connection: "es_snowflake"

include: "/views/PUBLIC/assets.view.lkml"
include: "/views/PUBLIC/cameras.view.lkml"
include: "/views/PUBLIC/camera_vendors.view.lkml"
include: "/views/PUBLIC/public_keypads.view.lkml"
include: "/views/PUBLIC/public_trackers.view.lkml"
include: "/views/keypads.view.lkml"
include: "/views/PUBLIC/asset_status_key_values.view.lkml"
include: "/views/PUBLIC/tracker_types.view.lkml"
include: "/views/PUBLIC/tracker_vendors.view.lkml"
include: "/views/keypad_firmware.view.lkml"
include: "/views/keypad_asset_assignments.view.lkml"
include: "/views/rentals.view.lkml"
include: "/views/keypad_controller_types.view.lkml"
include: "/views/trackers.view.lkml"
include: "/views/CUSTOM_SQL/tracker_report.view.lkml"

# MB commented out unused explores on May 21, 2024
# explore: cameras {
#   group_label: "Trackers"
#   label: "Active Cameras"
#   case_sensitive: no

#     join: camera_vendors {
#       type: inner
#       relationship: one_to_one
#       sql_on: ${cameras.camera_vendor_id} = ${camera_vendors.camera_vendor_id}
#         ;;
#     }

#     join : assets {
#       type: inner
#       relationship: one_to_one
#       sql_on: ${cameras.camera_id} = ${assets.camera_id}
#         ;;
#     }

#   }

# explore: public_trackers {
#   group_label: "Trackers"
#   sql_always_where: ${assets.company_id} NOT IN (420, 155) ;;
#   label: "Active Trackers"
#   case_sensitive: no

#   join: assets {
#     type: inner
#     relationship: one_to_one
#     sql_on: ${public_trackers.tracker_id} = ${assets.tracker_id} AND ${assets.company_id} != (420)
#       ;;
#   }

#   join : tracker_types{
#     type:  inner
#     relationship: one_to_one
#     sql_on: ${public_trackers.tracker_type_id} = ${tracker_types.tracker_type_id} ;;

#   }
# }

# Commented out due to low usage on 2026-03-26
# explore: public_keypads {
#     group_label: "Trackers"
#     label: "Keypads"
#     case_sensitive: no
#
#   join: keypad_asset_assignments {
#     type: inner
#     relationship: many_to_one
#     sql_on: ${public_keypads.keypad_id} = ${keypad_asset_assignments.keypad_id}
#       ;;
#   }
#
#   join: assets {
#     type: inner
#     relationship: one_to_one
#     sql_on: ${public_keypads.asset_id} = ${assets.asset_id}
#       ;;
#   }
#
#   join: keypads {
#     type: inner
#     relationship: one_to_one
#     sql_on: ${keypads.serial_number} = ${public_keypads.serial_number}
#       ;;
#   }
#
#   join: keypad_controller_types{
#     type: inner
#     relationship: many_to_one
#     sql_on: ${keypad_controller_types.keypad_controller_type_id} = ${keypads.keypad_controller_type_id}
#       ;;
#   }
#
#
# }

# explore: assets {
#   group_label: "Trackers"
#   label: "Total assets per firmware version"
#   case_sensitive: no

#   join: trackers {
#     type: inner
#     relationship: one_to_one
#     sql_on: ${assets.tracker_id} = ${trackers.tracker_id} ;;
#   }
# }

# explore: rentals {
#   group_label: "Trackers"


#   join: assets {
#     type: inner
#     relationship: many_to_one
#     sql_on: ${rentals.asset_id} = ${assets.asset_id} ;;
#   }

# }

# Commented out due to low usage on 2026-03-26
# explore: asset_status_key_values {
#     group_label: "Trackers"
#     label: "OOL"
#     case_sensitive: no
#
#     join: assets {
#       type: inner
#       relationship: many_to_one
#       sql_on: ${asset_status_key_values.asset_id} = ${assets.asset_id}
#         ;;
#     }
#
#     join: public_trackers {
#       type: inner
#       relationship:  one_to_one
#       sql_on: ${public_trackers.tracker_id} = ${assets.tracker_id} ;;
#
#     }
#
#   join: tracker_types {
#     type: inner
#     relationship:  one_to_one
#     sql_on: ${public_trackers.tracker_type_id} = ${tracker_types.tracker_type_id} ;;
#
#   }
#
#
# }

explore: tracker_report {}
