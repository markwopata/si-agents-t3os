connection: "es_warehouse"

include: "/views/TCCO_Custom/*.view.lkml"                # include all views in the views/ folder in this project
# include: "/**/*.view.lkml"                 # include all views in this project
# include: "my_dashboard.dashboard.lookml"   # include a LookML dashboard called my_dashboard

# # Select the views that should be a part of this model,
# # and define the joins that connect them together.

explore: tcco_custom_invoice_export {
  }

explore: tcco_daily_snapshot {
}

explore: fec_rental_scheduled_job {
}
