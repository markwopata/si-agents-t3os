connection: "es_snowflake_c_analytics"


include: "/Dashboards/safety_meeting_responses/safety_meeting_union.view.lkml"
include: "/Dashboards/safety_meeting_responses/safety_meeting_union_with_tams.view.lkml"


explore: safety_meeting_union {}

# Commented out due to low usage on 2026-03-26
# explore: safety_meeting_union_with_tams {} ## This is for Jacob Allen and Josh Helmstettler. I was approached on 11/22 that they need to see TAMs since there are accidents happening. - KC
