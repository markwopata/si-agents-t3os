connection: "es_snowflake_analytics"

include: "/analytics/dot.view"


explore: dot {case_sensitive: no
  persist_for: "24 hours"}
