connection: "es_snowflake_analytics"

include: "/Dashboards/National_Accounts_Dashboard/views/national_accounts_rental_revenue.view.lkml"
include: "/Dashboards/National_Accounts_Dashboard/views/national_accounts_ancillary_revenue.view.lkml"
include: "/Dashboards/National_Accounts_Dashboard/views/national_accounts_oec_aor.view.lkml"
include: "/Dashboards/National_Accounts_Dashboard/views/national_accounts_bulk.view.lkml"
include: "/Dashboards/National_Accounts_Dashboard/views/national_accounts_discount_percentage.view.lkml"
include: "/Dashboards/National_Accounts_Dashboard/views/national_account_assignments.view.lkml"
include: "/Dashboards/National_Accounts_Dashboard/views/national_account_kpis.view.lkml"
include: "/Dashboards/National_Accounts_Dashboard/views/national_accounts_quotes.view.lkml"
include: "/Dashboards/National_Accounts_Dashboard/nam_company_performance/nam_company_rep_performance.view.lkml"
include: "/Dashboards/National_Accounts_Dashboard/nam_company_performance/top_1k_national_account_performance.view.lkml"
include: "/views/ES_WAREHOUSE/companies.view.lkml"
include: "/views/ES_WAREHOUSE/net_terms.view.lkml"

explore: national_accounts_rental_revenue {
  group_label: "National Accounts"
  case_sensitive: no
  description: "Sum of rental revenue by date, salesperson, company, market, and business segment."
}

explore: national_accounts_ancillary_revenue {
  group_label: "National Accounts"
  case_sensitive: no
  description: "Sum of ancillary revenue by date, salesperson, company, market, business segment, and revenue type."
}

explore: national_accounts_oec_aor {
  group_label: "National Accounts"
  case_sensitive: no
  description: "Sum of assets on rent and oec on rent by date, salesperson, company, market, and business segment."
}

explore: national_accounts_bulk {
  group_label: "National Accounts"
  case_sensitive: no
  description: "Sum of bulk parts on rent and bulk cost on rent by date, salesperson, company, market, and business segment."
}

explore: national_account_assignments {
  group_label: "National Accounts"
  case_sensitive: no
  description: "Details on national accounts, including the NAM, NAC, Sales Director, and affiliate groupings, among other things.
                Used for HTML cards on NA dashboards. Primary source for the National Account Export Retool Table."
  sql_always_where: ({{ _user_attributes['job_role'] }} = 'nam' AND lower(${nam_email}) = '{{ _user_attributes['email'] }}')
            -- Hardcode for Jessica to only see Tyler Levin's accounts
            OR ('{{ _user_attributes['email'] }}' = 'jessica.howard@equipmentshare.com' AND lower(${nam_email}) = 'tyler.levins@equipmentshare.com')
            OR ('{{ _user_attributes['email'] }}' <> 'jessica.howard@equipmentshare.com' AND {{ _user_attributes['job_role'] }} <> 'nam') ;;

  join: companies {
    type: left_outer
    relationship: many_to_one
    sql_on: ${national_account_assignments.company_id} = ${companies.company_id} ;;
  }
  join: net_terms {
    type: left_outer
    relationship: many_to_one
    sql_on: ${net_terms.net_terms_id} = ${companies.net_terms_id} ;;
  }
}

explore: national_accounts_discount_percentage {
  group_label: "National Accounts"
  case_sensitive: no
  description: "Discount % and Average Discount % by market, business segment, company, or salesperson."
}

explore: national_account_kpis {
  group_label: "National Accounts"
  case_sensitive: no
  description: "Current OEC, current AOR, current month rental revenue, previous month rental revenue, current bulk cost OR,
                and bulk quantity OR by company and salesperson."
}

explore: national_accounts_quotes {
  group_label: "National Accounts"
  case_sensitive: no
  description: "Quotes from last 60 days tied to companies that are assigned a NAM."
  persist_for: "3 hours"
}

explore: nam_company_rep_performance {
  group_label: "National Accounts"
  label: "GC Company and Rep Performance"
  case_sensitive: no
  description: "Rental Performance of Top 50 GC and Reps"
}

explore: top_1k_national_account_performance {
  group_label: "National Accounts"
  label: "National Account Performance"
  case_sensitive: no
  description: "Rental Performance of all national accounts and reps"
}
