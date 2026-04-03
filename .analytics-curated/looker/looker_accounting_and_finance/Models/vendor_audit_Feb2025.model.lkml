connection: "es_snowflake_analytics"

include: "/views/custom_sql/vendor_audit_feb25.view.lkml"

# Commented out due to low usage on 2026-03-30
# explore: vendor_audit {
#   label: "Vendor Audit Feb 2025"
#   description: "Audit and compliance data for vendors."
# }
