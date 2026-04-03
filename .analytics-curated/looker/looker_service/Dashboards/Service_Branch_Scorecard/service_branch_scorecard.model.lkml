connection: "es_snowflake_analytics"

include: "/Dashboards/Service_Branch_Scorecard/Views/*.view.lkml"                # include all views in the views/ folder in this project
include: "/views/ANALYTICS/market_region_xwalk.view.lkml"                # include all views in the views/ folder in this project

#include: "/**/*.view.lkml"                 # include all views in this project
# include: "my_dashboard.dashboard.lookml"   # include a LookML dashboard called my_dashboard




explore: service_branch_scorecard {
  label: "Service Branch Scorecard"
  persist_for: "24 hours"
  sql_always_where: ${service_branch_scorecard.District_Region_Market_Access}
  or 'developer' = {{ _user_attributes['department'] }}
  or 'admin' = {{ _user_attributes['department'] }}
  or 'god view'= {{ _user_attributes['department'] }}
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'jabbok@equipmentshare.com';;
  from: market_region_xwalk_and_dates

# join: dim_date_sbs {
#   type: cross
#   sql_on: 1=1 ;;
#   relationship: many_to_many
# }

# #branch ranking:
#   join: branch_ranking_filter {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${branch_ranking_filter.market_id} = ${service_branch_scorecard.market_id};;
#   }

#Warranty:
  join: warranty_aggregate {
    type: left_outer
    relationship: one_to_many
    sql_on: ${warranty_aggregate.branch_id} = ${service_branch_scorecard.market_id} and ${warranty_aggregate.month} = ${service_branch_scorecard.month};;
  }

#Training: Courses completed / Courses assigned

  join: training_aggregate {
    type: left_outer
    relationship: one_to_many
    sql_on: ${training_aggregate.branch_id} = ${service_branch_scorecard.market_id} and ${training_aggregate.month} = ${service_branch_scorecard.month};;
  }

#Aging Work Orders: Age > 3 months / total count
  join: aging_work_orders_aggregate {
    type: left_outer
    relationship: one_to_many
    sql_on: ${aging_work_orders_aggregate.branch_id} = ${service_branch_scorecard.market_id} and ${aging_work_orders_aggregate.month} = ${service_branch_scorecard.month};;
  }

#Compliance Vendors: % Spend with Preferred Vendor
  join: compliance_vendors_aggregate {
    type: left_outer
    relationship: one_to_many
    sql_on: ${compliance_vendors_aggregate.branch_id} = ${service_branch_scorecard.market_id} and ${compliance_vendors_aggregate.month} = ${service_branch_scorecard.month};;
  }

#OEC: Headcount : OEC ratio
  join: headcount_oec_aggregate {
    type: left_outer
    relationship: one_to_many
    sql_on: ${headcount_oec_aggregate.branch_id} = ${service_branch_scorecard.market_id} and ${headcount_oec_aggregate.month} = ${service_branch_scorecard.month};;
  }


#Inspections: overdue Inspections %
  join: overdue_inspections_aggregate {
    type: left_outer
    relationship: one_to_many
    sql_on: ${overdue_inspections_aggregate.branch_id} = ${service_branch_scorecard.market_id} and ${overdue_inspections_aggregate.month} = ${service_branch_scorecard.month};;
  }


#Deadstock: Deadstock Ratio
  join: deadstock_ratio_aggregate {
    type: left_outer
    relationship: one_to_many
    sql_on: ${deadstock_ratio_aggregate.branch_id} = ${service_branch_scorecard.market_id} and ${deadstock_ratio_aggregate.month} = ${service_branch_scorecard.month};;
  }


#Unavailable OEC: % unavailable
  join: unavailable_oec_aggregate {
    type: left_outer
    relationship: one_to_many
    sql_on: ${unavailable_oec_aggregate.branch_id} = ${service_branch_scorecard.market_id} and ${unavailable_oec_aggregate.month} = ${service_branch_scorecard.month};;
  }



#Retention: Turnover %
  join: turnover_aggregate {
    type: left_outer
    relationship: one_to_many
    sql_on: ${turnover_aggregate.branch_id} = ${service_branch_scorecard.market_id} and ${turnover_aggregate.month} = ${service_branch_scorecard.month};;
  }


#Lost Revenue
  join: lost_revenue_aggregate {
    type: left_outer
    relationship: one_to_many
    sql_on: ${lost_revenue_aggregate.branch_id} = ${service_branch_scorecard.market_id} and ${lost_revenue_aggregate.month} = ${service_branch_scorecard.month};;
  }

#wos_within_24hrs_of_delivery_aggregate
  join: wos_within_24hrs_of_delivery_aggregate {
    type: left_outer
    relationship: one_to_many
    sql_on: ${wos_within_24hrs_of_delivery_aggregate.branch_id} = ${service_branch_scorecard.market_id} and ${wos_within_24hrs_of_delivery_aggregate.month} = ${service_branch_scorecard.month};;
  }

#wos_within_7days_of_delivery_aggregate
  join: wos_within_7days_of_delivery_aggregate {
    type: left_outer
    relationship: one_to_many
    sql_on: ${wos_within_7days_of_delivery_aggregate.branch_id} = ${service_branch_scorecard.market_id} and ${wos_within_7days_of_delivery_aggregate.month} = ${service_branch_scorecard.month};;
  }


#service_managers
  join: service_managers {
    type: left_outer
    relationship: one_to_many
    sql_on: ${service_managers.branch_id} = ${service_branch_scorecard.market_id}
      ;;
  }

# #current_oec
  join: current_oec_by_market {
    type: left_outer
    relationship: many_to_one
    sql_on: ${service_branch_scorecard.market_id} = ${current_oec_by_market.market_id}
    ;;
  }

    join: parent_market {
      type: left_outer
      relationship: many_to_one
      sql_on: ${service_branch_scorecard.market_id}::text = ${parent_market.market_id}
                and date_trunc(month, ${service_branch_scorecard.month}::date) >= date_trunc(month, ${parent_market.start_date}::date)
                  and date_trunc(month, ${service_branch_scorecard.month}::date) <= coalesce(date_trunc(month, ${parent_market.end_date}::date),'2099-12-31')
                ;;
    }

    join: market_region_xwalk {
      type: left_outer
      relationship: many_to_one
      sql_on: coalesce(${parent_market.parent_market_id}, ${service_branch_scorecard.market_id}::text) = ${market_region_xwalk.market_id}::text ;;
    }

    join: revmodel_market_rollout_conservative {
      type: left_outer
      relationship: many_to_one
      sql_on: ${service_branch_scorecard.market_id}::varchar = ${revmodel_market_rollout_conservative.market_id}::varchar ;;
    }

    # join: plexi_periods {
    #   type: left_outer
    #   relationship: many_to_one
    #   sql_on: ${high_level_financials.gl_date}::date = ${plexi_periods.date}::date;;
    # }

}
