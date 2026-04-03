connection: "es_snowflake_c_analytics"

include: "/**/**.view.lkml"                # include all views in the views/ folder in this project
include: "suggestions.lkml"
# include: "my_dashboard.dashboard.lookml"   # include a LookML dashboard called my_dashboard

explore: manager_bonus_calculations {
  label: "Manager Bonus Calculations"
  sql_always_where:
    TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'jabbok@equipmentshare.com'
    OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'nick.guthrie@equipmentshare.com'
    OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'david.adams@equipmentshare.com'
    OR (TRIM(LOWER(${paycor_employees_managers_full_hierarchy.manager_email}))=  TRIM(LOWER('{{ _user_attributes['email'] | replace: "'", "\\'" }}'))
    OR TRIM(LOWER(${users.email_address})) =  TRIM(LOWER('{{ _user_attributes['email'] | replace: "'", "\\'" }}'))
    OR 'finance' = {{ _user_attributes['department'] }}
    OR 'developer' = {{ _user_attributes['department'] }}
    or 'admin' = {{ _user_attributes['department'] }});;

  join: paycor_employees_managers_full_hierarchy {
    type: left_outer
    relationship: one_to_many
    sql_on: TRIM(LOWER(${manager_bonus_calculations.employee_id})) = TRIM(LOWER(${paycor_employees_managers_full_hierarchy.employee_number}));;
  }

  join: users {
    type: full_outer
    relationship: one_to_one
    sql_on: TRIM(LOWER(${manager_bonus_calculations.employee_id})) = TRIM(LOWER(${users.employee_id})) ;;
  }
}

explore: profit_sharing_statements {
  label: "Profit Sharing Statements"
  sql_always_where:
                    (('developer' = {{ _user_attributes['department'] }}
                    OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'jabbok@equipmentshare.com'
                    OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'david.adams@equipmentshare.com'
                    OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'brody.cridlebaugh@equipmentshare.com'
                    OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'mark.wopata@equipmentshare.com')
                    -- Dale SE Q3 Patch
                    OR ((TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'dale.lawrence@equipmentshare.com')
                      and (${profit_sharing_statements.region} = 'Southeast'
                      AND ${profit_sharing_statements.quarter_timestamp} = '2024Q3'
                      and ${profit_sharing_statements.classification} IN ('Store Managers','Service Manager','District Ops','Regional Ops',
                                                                          'Regional Advanced Solutions Operations'))
                    )
                    -- Zach SE Q3 Patch
                    OR ((TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'zach@equipmentshare.com')
                      and (${profit_sharing_statements.region} = 'Southeast'
                      AND ${profit_sharing_statements.quarter_timestamp} = '2024Q3'
                      and ${profit_sharing_statements.classification} IN ('District Sales','Regional Sales',
                                                                          'Regional Advanced Solutions Sales')))
                    -- Jay Q3 Visibility
                    OR ((TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'jay.mitchell@equipmentshare.com')
                      and (${profit_sharing_statements.quarter_timestamp} = '2024Q3'
                      AND (TRIM(LOWER(${profit_share_statement_access.work_email})) =  TRIM(LOWER('{{ _user_attributes['email'] | replace: "'", "\\'" }}'))
                    OR array_contains (TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')::VARIANT, ${profit_share_statement_access.manager_array}))))
                    -- Steve Q3 Visibility
                    OR ((TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'steven.desormeaux@equipmentshare.com')
                      and (${profit_sharing_statements.quarter_timestamp} = '2024Q3'
                      AND (TRIM(LOWER(${profit_share_statement_access.work_email})) =  TRIM(LOWER('{{ _user_attributes['email'] | replace: "'", "\\'" }}'))
                    OR array_contains (TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')::VARIANT, ${profit_share_statement_access.manager_array}))))
                    -- End of Special
                    OR (((TRIM(LOWER(${profit_share_statement_access.work_email})) =  TRIM(LOWER('{{ _user_attributes['email'] | replace: "'", "\\'" }}'))
                    OR array_contains (TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')::VARIANT, ${profit_share_statement_access.manager_array}))

                    OR (
                        ${profit_sharing_statements.quarter_timestamp} = '2024Q3'
                        AND TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') IN (
                          'dale.lawrence@equipmentshare.com',
                          'zach@equipmentshare.com',
                          'jay.mitchell@equipmentshare.com',
                          'steven.desormeaux@equipmentshare.com'
                        )
                    AND ((TRIM(LOWER(${profit_share_statement_access.work_email})) =  TRIM(LOWER('{{ _user_attributes['email'] | replace: "'", "\\'" }}'))
                    OR array_contains (TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')::VARIANT, ${profit_share_statement_access.manager_array}))))
                    )
                    ))
                    ;;
                    #AND ( ${profit_sharing_statements.quarter_timestamp} != '2024Q3'  --)

  join: profit_share_statement_access {
    type: left_outer
    relationship: many_to_one
    sql_on: TRIM(LOWER(${profit_sharing_statements.id})) = TRIM(LOWER(${profit_share_statement_access.employee_id})) ;;
  }

  # join: users {
  #   type: full_outer
  #   relationship: one_to_one
  #   sql_on: TRIM(LOWER(${profit_sharing_statements.id})) = TRIM(LOWER(${users.employee_id})) and ${users.company_id} = 1854 ;;
  # }

  # join: company_directory {
  #   type: full_outer
  #   relationship: one_to_one
  #   sql_on: TRIM(LOWER(${profit_sharing_statements.id})) = TRIM(LOWER(${users.employee_id})) and ${users.company_id} = 1854 ;;
  # }

  join: profit_share_store_level_distributions {
    type: full_outer
    relationship: many_to_one
    sql_on: ${profit_sharing_statements.market_id}::text = ${profit_share_store_level_distributions.market_id}::text
      and ${quarterly_profit_share_periods.display} = ${profit_share_store_level_distributions.quarter_timestamp};;
    # and ${quarterly_profit_share_periods.period_published} = 'published';;
  }

  join: quarterly_profit_share_periods {
    type: left_outer
    relationship: many_to_one
    sql_on: ${profit_sharing_statements.quarter_timestamp} = ${quarterly_profit_share_periods.display};;
  }

  join: vp_quarterly_profit_share_periods {
    type: left_outer
    relationship: many_to_one
    sql_on: ${profit_sharing_statements.quarter_timestamp} = ${vp_quarterly_profit_share_periods.display};;
  }

  join: profit_share_timestamps {
    type: full_outer
    relationship: many_to_one
    sql_on: ${profit_sharing_statements.quarter_timestamp} = ${profit_share_timestamps.profit_share_period} ;;
    # sql_on: ${profit_sharing_statements.quarter_timestamp} = ${profit_share_timestamps.profit_share_period}
    #         or ${full_year_profit_sharing_statements.quarter_timestamp} = ${profit_share_timestamps.profit_share_period}  ;;
    # sql_on: ${profit_sharing_statements.quarter_timestamp} = ${profit_share_timestamps.profit_share_period}
    #         or ${full_year_profit_sharing_statements.quarter_timestamp} = ${profit_share_timestamps.profit_share_period};;
  }

  join: q4_2023_profit_sharing_24_pct_bench_diff {
    type: left_outer
    relationship: many_to_one
    sql_on: ${profit_sharing_statements.id} = ${q4_2023_profit_sharing_24_pct_bench_diff.id}
      and ${profit_sharing_statements.quarter_timestamp} = ${q4_2023_profit_sharing_24_pct_bench_diff.quarter_timestamp} ;;
  }

}

explore: full_year_profit_sharing_statements {
  label: "Full Year Profit Sharing Statements"
  sql_always_where: (('developer' = {{ _user_attributes['department'] }}
                    OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'jabbok@equipmentshare.com'
                    -- OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'nick.guthrie@equipmentshare.com'
                    OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'david.adams@equipmentshare.com'
                    -- OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'andrew@equipmentshare.com'
                    -- OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'nick.guthrie@equipmentshare.com'
                    -- OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'dale.lawrence@equipmentshare.com'
                    -- OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'jay.mitchell@equipmentshare.com'
                    OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'brody.cridlebaugh@equipmentshare.com'
                    OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'mark.wopata@equipmentshare.com'))
                    OR ((TRIM(LOWER(${profit_share_statement_access.work_email})) =  TRIM(LOWER('{{ _user_attributes['email'] | replace: "'", "\\'" }}'))
                    OR array_contains (TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')::VARIANT, ${profit_share_statement_access.manager_array}))
                    --AND ${full_year_profit_share_periods.period_published} = 'published'
                    );;

  join: profit_share_statement_access {
    type: left_outer
    relationship: many_to_one
    sql_on: TRIM(LOWER(${full_year_profit_sharing_statements.id})) = TRIM(LOWER(${profit_share_statement_access.employee_id})) ;;
  }

  join: full_year_profit_share_store_level_distributions {
    type: full_outer
    relationship: many_to_one
    sql_on: ${full_year_profit_sharing_statements.market_id} = ${full_year_profit_share_store_level_distributions.market_id}
      and ${full_year_profit_share_periods.display} = ${full_year_profit_share_store_level_distributions.quarter_timestamp};;
  }

  join: full_year_profit_share_periods {
    type: left_outer
    relationship: many_to_one
    sql_on: ${full_year_profit_sharing_statements.quarter_timestamp} = ${full_year_profit_share_periods.display} ;;
  }

  join: profit_share_timestamps {
    type: left_outer
    relationship: many_to_one
    sql_on: ${full_year_profit_sharing_statements.quarter_timestamp} = ${profit_share_timestamps.profit_share_period} ;;
  }
}

explore: full_year_profit_sharing_statements_2023 {
  label: "Full Year Profit Sharing Statements 2023"
  sql_always_where: (('developer' = {{ _user_attributes['department'] }}
                    OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'jabbok@equipmentshare.com'
                    -- OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'nick.guthrie@equipmentshare.com'
                    OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'david.adams@equipmentshare.com'
                    -- OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'andrew@equipmentshare.com'
                    -- OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'nick.guthrie@equipmentshare.com'
                    -- OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'dale.lawrence@equipmentshare.com'
                    -- OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'jay.mitchell@equipmentshare.com'
                    -- OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'zach@equipmentshare.com'
                    OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'brody.cridlebaugh@equipmentshare.com'
                    OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'mark.wopata@equipmentshare.com'))
                    OR ((TRIM(LOWER(${profit_share_statement_access.work_email})) =  TRIM(LOWER('{{ _user_attributes['email'] | replace: "'", "\\'" }}'))
                    OR array_contains (TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')::VARIANT, ${profit_share_statement_access.manager_array}))
                    );;
  # AND ${quarter_timestamp} not in ('2022Q3');;
  #AND ${profit_share_store_level_distributions.quarter_timestamp} not in ('2022Q3')));;

    join: profit_share_statement_access {
      type: left_outer
      relationship: many_to_one
      sql_on: TRIM(LOWER(${full_year_profit_sharing_statements_2023.id})) = TRIM(LOWER(${profit_share_statement_access.employee_id})) ;;
    }

    join: full_year_profit_share_store_level_distributions_2023 {
      type: full_outer
      relationship: many_to_one
      sql_on: ${full_year_profit_sharing_statements_2023.market_id} = ${full_year_profit_share_store_level_distributions_2023.market_id1}
        and ${full_year_profit_share_periods.display} = ${full_year_profit_share_store_level_distributions_2023.quarter_timestamp};;
    }

    join: full_year_profit_share_periods {
      type: left_outer
      relationship: many_to_one
      sql_on: ${full_year_profit_sharing_statements_2023.quarter_timestamp} = ${full_year_profit_share_periods.display} ;;
    }

    join: profit_share_timestamps {
      type: left_outer
      relationship: many_to_one
      sql_on: ${full_year_profit_sharing_statements_2023.quarter_timestamp} = ${profit_share_timestamps.profit_share_period} ;;
    }
}

explore: full_year_profit_sharing_statements_2024 {
    label: "Full Year Profit Sharing Statements 2024"
    sql_always_where: (('developer' = {{ _user_attributes['department'] }}
                    OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'jabbok@equipmentshare.com'
                    -- OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'nick.guthrie@equipmentshare.com'
                    OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'david.adams@equipmentshare.com'
                    -- OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'andrew@equipmentshare.com'
                    -- OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'nick.guthrie@equipmentshare.com'
                    -- OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'dale.lawrence@equipmentshare.com'
                    -- OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'jay.mitchell@equipmentshare.com'
                    OR (TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'zach@equipmentshare.com'
                    AND ${full_year_profit_sharing_statements_2024.region} in ('Southeast')
                    and ${full_year_profit_sharing_statements_2024.classification} IN ('District Sales','Regional Sales',
                                                                            'Regional Advanced Solutions Sales'))
                    OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'brody.cridlebaugh@equipmentshare.com'
                    OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'mark.wopata@equipmentshare.com'))
                    OR (((TRIM(LOWER(${profit_share_statement_access.work_email})) =  TRIM(LOWER('{{ _user_attributes['email'] | replace: "'", "\\'" }}'))
                    OR array_contains (TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')::VARIANT, ${profit_share_statement_access.manager_array}))
                    AND ${quarter_timestamp} != '2025FY')
                    );;
    # AND ${quarter_timestamp} not in ('2022Q3');;
    #AND ${profit_share_store_level_distributions.quarter_timestamp} not in ('2022Q3')));;

    join: profit_share_statement_access {
        type: left_outer
        relationship: many_to_one
        sql_on: TRIM(LOWER(${full_year_profit_sharing_statements_2024.id})) = TRIM(LOWER(${profit_share_statement_access.employee_id})) ;;
    }

    join: full_year_profit_share_store_level_distributions_2023 {
        type: full_outer
        relationship: many_to_one
        sql_on: ${full_year_profit_sharing_statements_2024.market_id} = ${full_year_profit_share_store_level_distributions_2023.market_id1}
        and ${full_year_profit_share_periods.display} = ${full_year_profit_share_store_level_distributions_2023.quarter_timestamp};;
    }

    join: full_year_profit_share_periods {
        type: left_outer
        relationship: many_to_one
        sql_on: ${full_year_profit_sharing_statements_2024.quarter_timestamp} = ${full_year_profit_share_periods.display} ;;
    }

    join: profit_share_timestamps {
        type: left_outer
        relationship: many_to_one
        sql_on: ${full_year_profit_sharing_statements_2024.quarter_timestamp} = ${profit_share_timestamps.profit_share_period} ;;
    }
}

explore: full_year_profit_sharing_statements_2025 {
  label: "Full Year Profit Sharing Statements 2025"
  sql_always_where: ('developer' = {{ _user_attributes['department'] }}
                    OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'brody.cridlebaugh@equipmentshare.com')
                    OR (((TRIM(LOWER(${profit_share_statement_access.work_email})) =  TRIM(LOWER('{{ _user_attributes['email'] | replace: "'", "\\'" }}'))
                    OR array_contains (TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')::VARIANT, ${profit_share_statement_access.manager_array}))
                    AND ${quarter_timestamp} != '2025FY')
                    );;
    # AND ${quarter_timestamp} not in ('2022Q3');;
    #AND ${profit_share_store_level_distributions.quarter_timestamp} not in ('2022Q3')));;

    join: profit_share_statement_access {
      type: left_outer
      relationship: many_to_one
      sql_on: TRIM(LOWER(${full_year_profit_sharing_statements_2025.id})) = TRIM(LOWER(${profit_share_statement_access.employee_id})) ;;
    }

    join: full_year_profit_share_store_level_distributions_2023 {
      type: full_outer
      relationship: many_to_one
      sql_on: ${full_year_profit_sharing_statements_2025.market_id} = ${full_year_profit_share_store_level_distributions_2023.market_id1}
        and ${full_year_profit_share_periods.display} = ${full_year_profit_share_store_level_distributions_2023.quarter_timestamp};;
    }

    join: full_year_profit_share_periods {
      type: left_outer
      relationship: many_to_one
      sql_on: ${full_year_profit_sharing_statements_2025.quarter_timestamp} = ${full_year_profit_share_periods.display} ;;
    }

    join: profit_share_timestamps {
      type: left_outer
      relationship: many_to_one
      sql_on: ${full_year_profit_sharing_statements_2025.quarter_timestamp} = ${profit_share_timestamps.profit_share_period} ;;
    }
  }

explore: users_tooling_revenue {
  from: users
  sql_always_where:
    ((TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'grant.reviere@equipmentshare.com'
    or TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'brandon.wilson@equipmentshare.com'
    or TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'josh.merkley@equipmentshare.com'
    or TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'clint.coker@equipmentshare.com'
    or TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'shane.adams@equipmentshare.com'
    or TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'chad.guillaumin@equipmentshare.com'
    or TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'luke.zajkowski@equipmentshare.com'
    or TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'rod.clyatt@equipmentshare.com')
    or 'developer' = {{ _user_attributes['department'] }}
    or 'admin' = {{ _user_attributes['department'] }}
    OR ((TRIM(LOWER(${profit_share_statement_access.work_email})) =  TRIM(LOWER('{{ _user_attributes['email'] | replace: "'", "\\'" }}'))
                      OR array_contains (TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')::VARIANT, ${profit_share_statement_access.manager_array}))))
    AND ${core_sales_manager_tooling_revenue.direct_manager} is not null
    ;;

  join: core_sales_manager_tooling_revenue {
    view_label: "Core Sales Manager Tooling Revenue"
    type: left_outer
    relationship: many_to_one
    sql_on: ${users_tooling_revenue.user_id} = ${core_sales_manager_tooling_revenue.direct_manager_user_id};;
  }

  join: core_sales_reps_tooling_revenue {
    from: core_sales_manager_tooling_revenue
    view_label: "Core Sales Reps Tooling Revenue"
    type: left_outer
    relationship: many_to_one
    sql_on: ${users_tooling_revenue.user_id} = ${core_sales_reps_tooling_revenue.sp_user_id} ;;
  }

  join: profit_share_statement_access {
    type: left_outer
    relationship: many_to_one
    sql_on: TRIM(LOWER(${core_sales_manager_tooling_revenue.direct_manager_user_id})) = TRIM(LOWER(${profit_share_statement_access.user_id})) ;;
  }
}
