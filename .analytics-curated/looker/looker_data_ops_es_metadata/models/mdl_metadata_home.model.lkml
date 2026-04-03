connection: "snowflake_dataops"

include: "/views/vw_metadata_home.view.lkml"

explore: exp_metadata_home {
  # DISPLAY PARAMETERS
  view_name: vw_home
  fields: [
    vw_home.HOME_ID_HTML_TEXT
  ]
}
# ALL_FIELDS*
#    metadata_home.HOME_ID,
#    metadata_home.HOME_HTML_TEXT,
#    metadata_home.BUSINESS_GLOSSARY_HTML_TEXT
