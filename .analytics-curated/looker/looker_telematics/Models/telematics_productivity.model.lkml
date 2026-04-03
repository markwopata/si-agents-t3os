connection: "es_snowflake_c_analytics"

include: "/views/custom_sql/telematics_installer_productivity.view.lkml"
include: "/views/custom_sql/telematics_installer_productivity_detail.view.lkml"

# include all views in the views/ folder in this project
# include: "/**/*.view.lkml"                 # include all views in this project
# include: "my_dashboard.dashboard.lookml"   # include a LookML dashboard called my_dashboard

# # Select the views that should be a part of this model,
# # and define the joins that connect them together.
#
# explore: order_items {
#   join: orders {
#     relationship: many_to_one
#     sql_on: ${orders.id} = ${order_items.order_id} ;;
#   }
#
#   join: users {
#     relationship: many_to_one
#     sql_on: ${users.id} = ${orders.user_id} ;;
#   }
# }

explore: telematics_installer_productivity {
  case_sensitive: no
  sql_always_where: --Per Bryan Walsh 2024-03-29 exclude these users from this dashboard because they are supervisors
                    UPPER(${telematics_installer_productivity.email_address}) NOT IN
                      (UPPER('donald.mcadams@equipmentshare.com'),
                      UPPER('gabriel.poland@equipmentshare.com'),
                      UPPER('devin.gallo@equipmentshare.com'),
                      UPPER('jeff.sassie@equipmentshare.com'),
                      UPPER('jose.ruiz@equipmentshare.com'),
                      UPPER('zane.leith@equipmentshare.com')) ;;
}

explore: telematics_installer_productivity_detail {
  case_sensitive: no
  sql_always_where:
    (
      ${telematics_installer_productivity_detail.email_address} ILIKE '{{ _user_attributes['email'] }}'
    )
    OR
    (
        ('developer' = {{ _user_attributes['department'] }}
      OR 'god view' = {{ _user_attributes['department'] }}
      OR 'managers' = {{ _user_attributes['department'] }}
      OR 'collectors' = {{ _user_attributes['department'] }})
    )
    OR
    (
     '{{ _user_attributes['email'] }}' ILIKE ANY
        ('preston.kellum@equipmentshare.com',
         'brandon.chrisman@equipmentshare.com',
         'cody.malm@equipmentshare.com',
         'justin.hatton@equipmentshare.com',
         'lorenzo.gonzalez@equipmentshare.com',
         'donald.mcadams@equipmentshare.com',
         'gabriel.poland@equipmentshare.com',
         'devin.gallo@equipmentshare.com',
         'jeff.sassie@equipmentshare.com',
         'jose.ruiz@equipmentshare.com',
         'zane.leith@equipmentshare.com')
        )
  ;;
}
