connection: "es_snowflake_c_analytics"

include: "/**/**.view.lkml"                # include all views in the views/ folder in this project
include: "suggestions.lkml"

# Drives any transactional/detailed branch earnings views.
explore: be_transaction_listing {
  label: "Branch Earnings transactional"

  sql_always_where: (
      ${market_region_xwalk.District_Region_Market_Access}
      and ${plexi_periods.period_published} = 'published'
    )
    -- Let devs, admins, and jabbok see unpublished BE periods.
    or 'developer' = {{ _user_attributes['department'] }}
    or 'admin' = {{ _user_attributes['department'] }}
    or trim(lower('{{ _user_attributes['email'] | replace: "'", "\\'"}}')) = 'jabbok@equipmentshare.com'
    ;;

  join: parent_market {
    type: left_outer
    relationship: many_to_one
    sql_on: ${be_transaction_listing.mkt_id}::text = ${parent_market.market_id}::text
      and date_trunc(month, ${be_transaction_listing.gl_date}::date) >= date_trunc(month, ${parent_market.start_date}::date)
      and date_trunc(month, ${be_transaction_listing.gl_date}::date) <= coalesce(date_trunc(month, ${parent_market.end_date}::date), '2099-12-31')
      ;;
  }

  join: market_region_xwalk {
    type: inner
    relationship: many_to_one
    sql_on: coalesce(${parent_market.parent_market_id}, ${be_transaction_listing.mkt_id})::text = ${market_region_xwalk.market_id}::text ;;
  }

  join: revmodel_market_rollout_conservative {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = ${revmodel_market_rollout_conservative.market_id} ;;
  }

  join: plexi_periods {
    type: inner
    relationship: many_to_one
    sql_on: date_trunc(month, ${be_transaction_listing.gl_date}::date) = ${plexi_periods.date} ;;
  }
}

# Drives the month over month BE view (What changed this month)
explore: trans_listing_2mom {
  label: "Branch Earnings 2-month transactional"

  sql_always_where: (
      ${market_region_xwalk.District_Region_Market_Access}
      and ${plexi_periods.period_published} = 'published'
    )
    -- Let devs, admins, and jabbok see unpublished BE periods.
    or 'developer' = {{ _user_attributes['department'] }}
    or 'admin' = {{ _user_attributes['department'] }}
    or trim(lower('{{ _user_attributes['email'] | replace: "'", "\\'"}}')) = 'jabbok@equipmentshare.com'
    ;;

  join: parent_market {
    type: left_outer
    relationship: many_to_one
    sql_on: ${trans_listing_2mom.mkt_id}::text = ${parent_market.market_id}::text
      and date_trunc(month, ${trans_listing_2mom.gl_date2}::date) >= date_trunc(month, ${parent_market.start_date}::date)
      and date_trunc(month, ${trans_listing_2mom.gl_date2}::date) <= coalesce(date_trunc(month, ${parent_market.end_date}::date), '2099-12-31')
      ;;
  }

  join: market_region_xwalk {
    type: inner
    relationship: many_to_one
    sql_on: coalesce(${parent_market.parent_market_id}, ${trans_listing_2mom.mkt_id}) = ${market_region_xwalk.market_id}::text ;;
  }

  join: revmodel_market_rollout_conservative {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = ${revmodel_market_rollout_conservative.market_id} ;;
  }

  join: plexi_periods {
    type: inner
    relationship: many_to_one
    sql_on: date_trunc(month, ${trans_listing_2mom.gl_date2}::date) = ${plexi_periods.date}::date ;;
  }
}

# Used on the branch earnings OEC dashboard
explore: oec_detail {
  label: "Market OEC"

  sql_always_where: ${market_region_xwalk.District_Region_Market_Access}
    -- Let devs, admins, and jabbok see unpublished BE periods.
    or 'developer' = {{ _user_attributes['department'] }}
    or 'admin' = {{ _user_attributes['department'] }}
    or trim(lower('{{ _user_attributes['email'] | replace: "'", "\\'"}}')) = 'jabbok@equipmentshare.com'
    ;;

  join: parent_market {
    type: left_outer
    relationship: many_to_one
    sql_on: ${oec_detail.market_id}::text = ${parent_market.market_id}::text
      and date_trunc(month, ${oec_detail.gl_date}::date) >= date_trunc(month, ${parent_market.start_date}::date)
      and date_trunc(month, ${oec_detail.gl_date}::date) <= coalesce(date_trunc(month, ${parent_market.end_date}::date),'2099-12-31')
      ;;
  }

  join: market_region_xwalk {
    type: inner
    relationship: many_to_one
    sql_on: coalesce(${parent_market.parent_market_id}, ${oec_detail.market_id}) = ${market_region_xwalk.market_id}::text ;;
  }

  join: revmodel_market_rollout_conservative {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = ${revmodel_market_rollout_conservative.market_id} ;;
  }

  join: plexi_periods {
    type: inner
    relationship: many_to_one
    sql_on: ${oec_detail.gl_date} = ${plexi_periods.date}
      and {% condition oec_detail.Period %} plexi_periods.display {% endcondition %}
    ;;
  }

  join: personal_property_tax_rates {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = ${personal_property_tax_rates.market_id} ;;
  }
}

# Used on the branch earnings OEC dashboard (aggregated summary)
explore: oec_detail_aggregated {
  label: "Market OEC Aggregated"

  sql_always_where: ${market_region_xwalk.District_Region_Market_Access}
    -- Let devs, admins, and jabbok see unpublished BE periods.
    or 'developer' = {{ _user_attributes['department'] }}
    or 'admin' = {{ _user_attributes['department'] }}
    or trim(lower('{{ _user_attributes['email'] | replace: "'", "\\'"}}')) = 'jabbok@equipmentshare.com'
    ;;

  join: parent_market {
    type: left_outer
    relationship: many_to_one
    sql_on: ${oec_detail_aggregated.market_id}::text = ${parent_market.market_id}::text
      and date_trunc(month, ${oec_detail_aggregated.gl_date}::date) >= date_trunc(month, ${parent_market.start_date}::date)
      and date_trunc(month, ${oec_detail_aggregated.gl_date}::date) <= coalesce(date_trunc(month, ${parent_market.end_date}::date),'2099-12-31')
      ;;
  }

  join: market_region_xwalk {
    type: inner
    relationship: many_to_one
    sql_on: coalesce(${parent_market.parent_market_id}, ${oec_detail_aggregated.market_id}) = ${market_region_xwalk.market_id}::text ;;
  }

  join: revmodel_market_rollout_conservative {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = ${revmodel_market_rollout_conservative.market_id} ;;
  }

  join: plexi_periods {
    type: inner
    relationship: many_to_one
    sql_on: ${oec_detail_aggregated.gl_date} = ${plexi_periods.date} ;;
  }

  join: personal_property_tax_rates {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = ${personal_property_tax_rates.market_id} ;;
  }
}

# Used for single KPI metric tiles
explore: kpi_inputs {
  label: "Financial KPI Metrics"

  sql_always_where: (
      ${market_region_xwalk.District_Region_Market_Access}
      and ${plexi_periods.period_published} = 'published'
    )
    -- Let devs, admins, and jabbok see unpublished BE periods.
    or 'developer' = {{ _user_attributes['department'] }}
    or 'admin' = {{ _user_attributes['department'] }}
    or trim(lower('{{ _user_attributes['email'] | replace: "'", "\\'"}}')) = 'jabbok@equipmentshare.com'
    ;;

  join: parent_market {
    type: left_outer
    relationship: many_to_one
    sql_on: ${kpi_inputs.mkt_id}::text = ${parent_market.market_id}::text
      and date_trunc(month, ${kpi_inputs.gl_date}::date) >= date_trunc(month, ${parent_market.start_date}::date)
      and date_trunc(month, ${kpi_inputs.gl_date}::date) <= coalesce(date_trunc(month, ${parent_market.end_date}::date), '2099-12-31')
      ;;
  }

  join: market_region_xwalk {
    type: inner
    relationship: many_to_one
    sql_on: coalesce(${parent_market.parent_market_id}, ${kpi_inputs.mkt_id}) = ${market_region_xwalk.market_id}::text ;;
  }

  join: revmodel_market_rollout_conservative {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = ${revmodel_market_rollout_conservative.market_id} ;;
  }

  join: plexi_periods {
    type: inner
    relationship: many_to_one
    sql_on: ${kpi_inputs.gl_date}::date = ${plexi_periods.date}::date ;;
  }

  join: collected_revenue_benchmark {
    view_label: "Collected Revenue At or Above Benchmark"
    type: left_outer
    relationship: many_to_one
    # TODO left side might need to be market_region_xwalk.market_id, but the raw query looks buggy
    sql_on: ${kpi_inputs.mkt_id}::text = ${collected_revenue_benchmark.market_id}::text ;;
  }
}

# Branch earnings main - used for the link tiles
explore: links {
  label: "Dashboard Links"
  description: "Links for use on the main branch earnings dashboard single link tiles."

  sql_always_where: ${market_region_xwalk.District_Region_Market_Access}
    or 'developer' = {{ _user_attributes['department'] }}
    or 'admin' = {{ _user_attributes['department'] }}
    or trim('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'jabbok@equipmentshare.com';;

  join: parent_market {
    type: left_outer
    relationship: many_to_one
    sql_on: ${parent_market.market_id} = ${links.market_id}
      and ${parent_market.end_date} is null;;
  }

  join: market_region_xwalk {
    type: inner
    relationship: many_to_one
    sql_on: coalesce(${parent_market.parent_market_id}, ${links.market_id}) = ${market_region_xwalk.market_id} ;;
  }

  join: revmodel_market_rollout_conservative {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = ${revmodel_market_rollout_conservative.market_id} ;;
  }

  join: plexi_periods {
    type: cross # This is a cross join because the links view doesn't have a date.
    relationship: many_to_many
  }
}

explore: market_rollout_age_card {
  from: revmodel_market_rollout_market_age_card
  label: "Market Rollout Age Card"

  sql_always_where: ${market_region_xwalk.District_Region_Market_Access}
    -- Let devs, admins, and jabbok see unpublished BE periods.
    or 'developer' = {{ _user_attributes['department'] }}
    or 'admin' = {{ _user_attributes['department'] }}
    or trim(lower('{{ _user_attributes['email'] | replace: "'", "\\'"}}')) = 'jabbok@equipmentshare.com'
    ;;

  join: parent_market {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_rollout_age_card.market_id}::text = ${parent_market.market_id}::text
      and date_trunc(month, ${market_rollout_age_card.branch_earnings_start_month_date}::date) >= date_trunc(month, ${parent_market.start_date}::date)
      and date_trunc(month, ${market_rollout_age_card.branch_earnings_start_month_date}::date) <= coalesce(date_trunc(month, ${parent_market.end_date}::date), '2099-12-31')
      ;;
  }

  join: market_region_xwalk {
    type: inner
    relationship: many_to_one
    sql_on: coalesce(${parent_market.parent_market_id}, ${market_rollout_age_card.market_id})::text = ${market_region_xwalk.market_id}::text ;;
  }

  join: plexi_periods {
    type: cross # Allows dashboard period filters without a transaction join.
    relationship: many_to_many
  }
}


explore: payroll_census {
  label: "Payroll Census & Hours"

  sql_always_where: (
      ${market_region_xwalk.District_Region_Market_Access}
      and ${plexi_periods.period_published} = 'published'
    )
    -- Let devs, admins, and jabbok see unpublished BE periods.
    or 'developer' = {{ _user_attributes['department'] }}
    or 'admin' = {{ _user_attributes['department'] }}
    or trim(lower('{{ _user_attributes['email'] | replace: "'", "\\'"}}')) = 'jabbok@equipmentshare.com'
    ;;

  join: parent_market {
    type: left_outer
    relationship: many_to_one
    sql_on: ${payroll_census.market_id}::text = ${parent_market.market_id}::text
      and date_trunc(month, ${payroll_census.period_date}::date) >= date_trunc(month, ${parent_market.start_date}::date)
      and date_trunc(month, ${payroll_census.period_date}::date) <= coalesce(date_trunc(month, ${parent_market.end_date}::date), '2099-12-31')
      ;;
  }

  join: market_region_xwalk {
    type: inner
    relationship: many_to_one
    sql_on: coalesce(${parent_market.parent_market_id}, ${payroll_census.market_id}) = ${market_region_xwalk.market_id}::text ;;
  }

  join: revmodel_market_rollout_conservative {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = ${revmodel_market_rollout_conservative.market_id} ;;
  }

  join: plexi_periods {
    type: inner
    relationship: many_to_one
    sql_on: ${payroll_census.period_date} = ${plexi_periods.date} ;;
  }
}

explore: projected_bad_debt {
  label: "Expected Bad Debt"

  sql_always_where: ${market_region_xwalk.District_Region_Market_Access}
    -- Let devs, admins, and jabbok see unpublished BE periods.
    or 'developer' = {{ _user_attributes['department'] }}
    or 'admin' = {{ _user_attributes['department'] }}
    or trim(lower('{{ _user_attributes['email'] | replace: "'", "\\'"}}')) = 'jabbok@equipmentshare.com'
    ;;

  join: parent_market {
    type: left_outer
    relationship: many_to_one
    sql_on: ${projected_bad_debt.market_id}::text = ${parent_market.market_id}::text
      and date_trunc(month, ${projected_bad_debt.billing_approved_date}::date) >= date_trunc(month, ${parent_market.start_date}::date)
      and date_trunc(month, ${projected_bad_debt.billing_approved_date}::date) <= coalesce(date_trunc(month, ${parent_market.end_date}::date), '2099-12-31')
      ;;
  }

  join: market_region_xwalk {
    type: inner
    relationship: many_to_one
    sql_on: coalesce(${parent_market.parent_market_id}, ${projected_bad_debt.market_id}::text) = ${market_region_xwalk.market_id}::text ;;
  }

  join: revmodel_market_rollout_conservative {
    type: inner
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = ${revmodel_market_rollout_conservative.market_id} ;;
  }

  join: plexi_periods {
    type: inner
    relationship: many_to_one
    sql_on: date_trunc(month, ${projected_bad_debt.billing_approved_date}::date) = ${plexi_periods.date}::date ;;
  }
}

explore: rent_rev_act_tar {
  label: "Rent Charge Actuals & Targets"
  description: "Branch earnings is currently showing rental revenue against targets at the bottom of BE."

  sql_always_where: (
      ${market_region_xwalk.District_Region_Market_Access}
      and ${plexi_periods.period_published} = 'published'
    )
    -- Let devs, admins, and jabbok see unpublished BE periods.
    or 'developer' = {{ _user_attributes['department'] }}
    or 'admin' = {{ _user_attributes['department'] }}
    or trim(lower('{{ _user_attributes['email'] | replace: "'", "\\'"}}')) = 'jabbok@equipmentshare.com'
    ;;

  join: parent_market {
    type: left_outer
    relationship: many_to_one
    sql_on: ${rent_rev_act_tar.mkt_id}::text = ${parent_market.market_id}::text
      and date_trunc(month, ${rent_rev_act_tar.gl_mo}::date) >= date_trunc(month, ${parent_market.start_date}::date)
      and date_trunc(month, ${rent_rev_act_tar.gl_mo}::date) <= coalesce(date_trunc(month, ${parent_market.end_date}::date), '2099-12-31')
      ;;
  }

  join: market_region_xwalk {
    type: inner
    relationship: many_to_one
    sql_on: coalesce(${parent_market.parent_market_id}, ${rent_rev_act_tar.mkt_id}) = ${market_region_xwalk.market_id}::text ;;
  }

  join: revmodel_market_rollout_conservative {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = ${revmodel_market_rollout_conservative.market_id} ;;
  }

  join: plexi_periods {
    type: inner
    relationship: many_to_one
    sql_on: date_trunc(month, ${rent_rev_act_tar.gl_mo}::date) = ${plexi_periods.date}::date ;;
  }
}

explore: be_vs_mkt_db_rent_rev {
  label: "Earnings vs Market Dashboard Rental Revenue"
  description: "Compare branch earnings rental revenue to market dashboard rental revenue. We need this bridge because markets dashboard is not the end financial rental revenue."

  sql_always_where: ${market_region_xwalk.District_Region_Market_Access} ;;

  join: parent_market {
    type: left_outer
    relationship: many_to_one
    sql_on: ${be_vs_mkt_db_rent_rev.market_id}::text = ${parent_market.market_id}::text
                and date_trunc(month, ${be_vs_mkt_db_rent_rev.gl_date}::date) >= date_trunc(month, ${parent_market.start_date}::date)
                  and date_trunc(month, ${be_vs_mkt_db_rent_rev.gl_date}::date) <= coalesce(date_trunc(month, ${parent_market.end_date}::date),'2099-12-31')
                ;;
  }

  join: market_region_xwalk {
    type: inner
    relationship: many_to_one
    sql_on: coalesce(${parent_market.parent_market_id}, ${be_vs_mkt_db_rent_rev.market_id})::text = ${market_region_xwalk.market_id}::text ;;
  }

  join: revmodel_market_rollout_conservative {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = ${revmodel_market_rollout_conservative.market_id} ;;
  }

  join: plexi_periods {
    type: inner
    relationship: many_to_one
    sql_on: date_trunc(month, ${be_vs_mkt_db_rent_rev.gl_date}::date) = ${plexi_periods.date}::date ;;
  }
}

explore: suggest_improvements {
  label: "How do I improve performance?"

  sql_always_where: (
      ${market_region_xwalk.District_Region_Market_Access}
      and ${plexi_periods.period_published} = 'published'
    )
    -- Let devs, admins, and jabbok see unpublished BE periods.
    or 'developer' = {{ _user_attributes['department'] }}
    or 'admin' = {{ _user_attributes['department'] }}
    or trim(lower('{{ _user_attributes['email'] | replace: "'", "\\'"}}')) = 'jabbok@equipmentshare.com'
    ;;

  join: parent_market {
    type: left_outer
    relationship: many_to_one
    sql_on: ${suggest_improvements.market_id}::text = ${parent_market.market_id}::text
      and date_trunc(month, ${suggest_improvements.gl_mo}::date) >= date_trunc(month, ${parent_market.start_date}::date)
      and date_trunc(month, ${suggest_improvements.gl_mo}::date) <= coalesce(date_trunc(month, ${parent_market.end_date}::date), '2099-12-31')
      ;;
  }

  join: market_region_xwalk {
    type: inner
    relationship: many_to_one
    sql_on: coalesce(${parent_market.parent_market_id}, ${suggest_improvements.market_id}) = ${market_region_xwalk.market_id}::text ;;
  }

  join: revmodel_market_rollout_conservative {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = ${revmodel_market_rollout_conservative.market_id} ;;
  }

  join: plexi_periods {
    type: inner
    relationship: many_to_one
    sql_on: ${suggest_improvements.gl_mo} = ${plexi_periods.date}::date ;;
  }
}

explore: comparison_source {
  label: "Branch Comparison Source"
  # sql_always_where: ${market_region_xwalk.District_Region_Market_Access} ;;
  # join: market_region_xwalk {
  # type:  left_outer
  # relationship: many_to_one
  # sql_on: ${comparison_source.mkt_id} = ${market_region_xwalk.market_id}::text ;;
  # }
}

explore: comparison_target {
  label: "Branch Comparison Target"

  join: parent_market {
    type: left_outer
    relationship: many_to_one
    sql_on: ${comparison_target.mkt_id}::text = ${parent_market.market_id}::text
      and date_trunc(month, ${comparison_target.gl_date}::date) >= date_trunc(month, ${parent_market.start_date}::date)
      and date_trunc(month, ${comparison_target.gl_date}::date) <= coalesce(date_trunc(month, ${parent_market.end_date}::date), '2099-12-31')
      ;;
  }

  join: market_region_xwalk {
    type: inner
    relationship: many_to_one
    sql_on: coalesce(${parent_market.parent_market_id}, ${comparison_target.mkt_id}) = ${market_region_xwalk.market_id}::text ;;
  }

  join: revmodel_market_rollout_conservative {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = ${revmodel_market_rollout_conservative.market_id} ;;
  }

  join: plexi_periods {
    type: inner
    relationship: many_to_one
    sql_on: date_trunc(month, ${comparison_target.gl_date}::date) = ${plexi_periods.date} ;;
  }

  join: comparison_source {
    type: full_outer
    relationship: many_to_many
    sql_on: ${comparison_source.gl_date} = ${comparison_target.gl_date}
      and ${comparison_source.gl_acctno} = ${comparison_target.gl_acctno} ;;
  }
}

explore: be_comparison {
  label: "Branch Comparison"

  sql_always_where: (
      ${market_region_xwalk.District_Region_Market_Access}
      and ${plexi_periods.period_published} = 'published'
    )
    -- Let devs, admins, and jabbok see unpublished BE periods.
    or 'developer' = {{ _user_attributes['department'] }}
    or 'admin' = {{ _user_attributes['department'] }}
    or trim(lower('{{ _user_attributes['email'] | replace: "'", "\\'"}}')) = 'jabbok@equipmentshare.com'
    ;;

  join: parent_market {
    type: left_outer
    relationship: many_to_one
    sql_on: ${be_comparison.market_id}::text = ${parent_market.market_id}::text
      and date_trunc(month, ${be_comparison.gl_date}::date) >= date_trunc(month, ${parent_market.start_date}::date)
      and date_trunc(month, ${be_comparison.gl_date}::date) <= coalesce(date_trunc(month, ${parent_market.end_date}::date), '2099-12-31')
      ;;
  }

  join: market_region_xwalk {
    type: inner
    relationship: many_to_one
    sql_on: coalesce(${parent_market.parent_market_id}::text, ${be_comparison.market_id}::text) = ${market_region_xwalk.market_id}::text ;;
  }

  join: revmodel_market_rollout_conservative {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = ${revmodel_market_rollout_conservative.market_id} ;;
  }

  join: plexi_periods {
    type: inner
    relationship: many_to_one
    sql_on: date_trunc(month, ${be_comparison.gl_date}::date) = ${plexi_periods.date}  ;;
  }
}

explore: be_comparison_itl {
  from: be_comparison
  label: "ITL Branch Comparison"
  description: "Branch comparison specially recreated for tooling."

  sql_always_where:
    ((TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'grant.reviere@equipmentshare.com'
    OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'jabbok@equipmentshare.com'
    OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'nick.guthrie@equipmentshare.com'
    OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'brandon.wilson@equipmentshare.com'
    OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'josh.switzer@equipmentshare.com'
    OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'curtis.lenio@equipmentshare.com'
    OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'ronny.robinson@equipmentshare.com'
    OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'jason.daniel@equipmentshare.com'
    OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'chad.guillaumin@equipmentshare.com')
    --OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'jake.gisclair@equipmentshare.com')
    AND ${plexi_periods.period_published} = 'published')
    OR ${market_region_xwalk.District_Region_Market_Access}
    --OR ( {{ _user_attributes['market_id'] }} in
    --('26564','26563','35514','59687','61873','61220','43646','55842','58065','66104','66105','56716','38634','44836','44834','48698')
    --AND ${plexi_periods.period_published} = 'published')
    OR 'finance' = {{ _user_attributes['department'] }}
    OR 'developer' = {{ _user_attributes['department'] }}
    or 'admin' = {{ _user_attributes['department'] }};;

  join: parent_market {
    type: left_outer
    relationship: many_to_one
    sql_on: ${be_comparison_itl.market_id}::text = ${parent_market.market_id}::text
      and date_trunc(month, ${be_comparison_itl.gl_date}::date) >= date_trunc(month, ${parent_market.start_date}::date)
      and date_trunc(month, ${be_comparison_itl.gl_date}::date) <= coalesce(date_trunc(month, ${parent_market.end_date}::date),'2099-12-31')
      ;;
  }

  join: market_region_xwalk {
    type: inner
    relationship: many_to_one
    sql_on: coalesce(${parent_market.parent_market_id}, ${be_comparison_itl.market_id}) = ${market_region_xwalk.market_id}::text ;;
  }

  join: revmodel_market_rollout_conservative {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = ${revmodel_market_rollout_conservative.market_id} ;;
  }

  join: plexi_periods {
    type: inner
    relationship: many_to_one
    sql_on: date_trunc(month, ${be_comparison_itl.gl_date}::date) = ${plexi_periods.date}  ;;
  }
}

explore: high_level_financials {
  label: "High Level Financials"

  sql_always_where: (
      ${market_region_xwalk.District_Region_Market_Access}
      -- and ${plexi_periods.period_published} = 'published'
    )
    -- Let devs, admins, and jabbok see unpublished BE periods.
    or 'developer' = {{ _user_attributes['department'] }}
    or 'admin' = {{ _user_attributes['department'] }}
    or trim(lower('{{ _user_attributes['email'] | replace: "'", "\\'"}}')) = 'jabbok@equipmentshare.com'
    ;;

  join: parent_market {
    type: left_outer
    relationship: many_to_one
    sql_on: ${high_level_financials.market_id}::text = ${parent_market.market_id}
      and date_trunc(month, ${high_level_financials.gl_date}::date) >= date_trunc(month, ${parent_market.start_date}::date)
      and date_trunc(month, ${high_level_financials.gl_date}::date) <= coalesce(date_trunc(month, ${parent_market.end_date}::date), '2099-12-31')
      ;;
  }

  join: market_region_xwalk {
    type: inner
    relationship: many_to_one
    sql_on: coalesce(${parent_market.parent_market_id}, ${high_level_financials.market_id}::text) = ${market_region_xwalk.market_id}::text ;;
  }

  join: revmodel_market_rollout_conservative {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = ${revmodel_market_rollout_conservative.market_id} ;;
  }

  join: plexi_periods {
    type: inner
    relationship: many_to_one
    sql_on: ${high_level_financials.gl_date}::date = ${plexi_periods.date}::date;;
  }
}

explore: executive_summary {
  label: "Executive Summary - Branch Earnings"

  sql_always_where: (
      ${market_region_xwalk.District_Region_Market_Access}
      -- and ${plexi_periods.period_published} = 'published'
    )
    -- Let devs, admins, and jabbok see unpublished BE periods.
    or 'developer' = {{ _user_attributes['department'] }}
    or 'admin' = {{ _user_attributes['department'] }}
    or trim(lower('{{ _user_attributes['email'] | replace: "'", "\\'"}}')) = 'jabbok@equipmentshare.com'
    ;;

  join: parent_market {
    type: left_outer
    relationship: many_to_one
    sql_on: ${executive_summary.market_id} = ${parent_market.market_id}
      and date_trunc(month, ${executive_summary.gl_date}::date) >= date_trunc(month, ${parent_market.start_date}::date)
      and date_trunc(month, ${executive_summary.gl_date}::date) <= coalesce(date_trunc(month, ${parent_market.end_date}::date),'2099-12-31')
      ;;
  }

  join: market_region_xwalk {
    type: inner
    relationship: many_to_one
    sql_on: coalesce(${parent_market.parent_market_id}, ${executive_summary.market_id}) = ${market_region_xwalk.market_id} ;;
  }

  join: revmodel_market_rollout_conservative {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = ${revmodel_market_rollout_conservative.market_id} ;;
  }

  join: plexi_periods {
    type: inner
    relationship: many_to_one
    sql_on: ${executive_summary.gl_date}::date = ${plexi_periods.date}::date;;
  }
}

# Used on high level financials
explore: market_map {
  label: "Market Map"
  sql_always_where: ${market_region_xwalk.District_Region_Market_Access}
    or 'developer' = {{ _user_attributes['department'] }}
    or 'admin' = {{ _user_attributes['department'] }};;

  join: parent_market {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_map.market_id}::text = ${parent_market.market_id}::text;;
  }

  join: market_region_xwalk {
    type: inner
    relationship: many_to_one
    sql_on: coalesce(${parent_market.parent_market_id}, ${market_map.market_id}) = ${market_region_xwalk.market_id}::text ;;
  }
}

explore: int_markets {
  label: "Market Map Update"
  sql_always_where:
  (
  ${is_active} = TRUE
  AND (${is_public_msp} OR ${is_public_rsp})
  AND (
    ${market_region_xwalk.District_Region_Market_Access}
    OR {{ _user_attributes['department'] }} IN ('developer','admin')
  )
)
    ;;

  join: market_region_xwalk {
    type: inner
    relationship: many_to_one
    sql_on: coalesce(${int_markets.parent_market_id}, ${int_markets.market_id}) = ${market_region_xwalk.market_id}::text ;;
  }

  join: plexi_periods {
    type: left_outer  # using cross join to match all dates
    sql_on: 1=1 ;;
    relationship: many_to_many
  }
}


explore: int_assets {
  label: "Hard Down Heat Map Live"
  sql_always_where:
  (
  ${int_markets.is_active} = TRUE
  AND (${int_markets.is_public_msp} OR ${int_markets.is_public_rsp})
  AND (
    ${market_region_xwalk.District_Region_Market_Access}
    OR {{ _user_attributes['department'] }} IN ('developer','admin')
  )
)
    ;;


  join: int_markets {
    type: inner
    relationship: many_to_one
    sql_on: coalesce(${int_markets.parent_market_id}, ${int_markets.market_id}) = ${int_assets.market_id}::text ;;
  }

  join: market_region_xwalk {
    type: inner
    relationship: many_to_one
    sql_on: coalesce(${int_markets.parent_market_id}, ${int_markets.market_id}) = ${market_region_xwalk.market_id}::text ;;
  }

  join: plexi_periods {
    type: left_outer  # using cross join to match all dates
    sql_on: 1=1 ;;
    relationship: many_to_many
  }
}

explore: ap_accruals {
  label: "AP Accruals"
  sql_always_where: (
      ${market_region_xwalk.District_Region_Market_Access}
      and ${plexi_periods.period_published} = 'published'
    )
    -- Let devs, admins, and jabbok see unpublished BE periods.
    or 'developer' = {{ _user_attributes['department'] }}
    or 'admin' = {{ _user_attributes['department'] }}
    or trim(lower('{{ _user_attributes['email'] | replace: "'", "\\'"}}')) = 'jabbok@equipmentshare.com'
    ;;

  join: parent_market {
    type: left_outer
    relationship: many_to_one
    sql_on: ${ap_accruals.market_id} = ${parent_market.market_id}
      and date_trunc(month, ${ap_accruals.gl_date}::date) >= date_trunc(month, ${parent_market.start_date}::date)
      and date_trunc(month, ${ap_accruals.gl_date}::date) <= coalesce(date_trunc(month, ${parent_market.end_date}::date), '2099-12-31')
      ;;
  }

  join: market_region_xwalk {
    type: inner
    relationship: many_to_one
    sql_on: coalesce(${parent_market.parent_market_id}, ${ap_accruals.market_id}) = ${market_region_xwalk.market_id} ;;
  }

  join: revmodel_market_rollout_conservative {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = ${revmodel_market_rollout_conservative.market_id} ;;
  }

  join: plexi_periods {
    type: inner
    relationship: many_to_one
    sql_on: ${plexi_periods.date} = date_trunc(month, ${ap_accruals.gl_date}::date) ;;
  }
}

explore: vendor_net_expense {
  label: "Vendor Net Expense"
  sql_always_where: (
      ${market_region_xwalk.District_Region_Market_Access}
      and ${plexi_periods.period_published} = 'published'
    )
    -- Let devs, admins, and jabbok see unpublished BE periods.
    or 'developer' = {{ _user_attributes['department'] }}
    or 'admin' = {{ _user_attributes['department'] }}
    or trim(lower('{{ _user_attributes['email'] | replace: "'", "\\'"}}')) = 'jabbok@equipmentshare.com'
    ;;

  join: parent_market {
    type: left_outer
    relationship: many_to_one
    sql_on: ${vendor_net_expense.market_id} = ${parent_market.market_id}
                and date_trunc(month, ${vendor_net_expense.gl_date}::date) >= date_trunc(month, ${parent_market.start_date}::date)
                  and date_trunc(month, ${vendor_net_expense.gl_date}::date) <= coalesce(date_trunc(month, ${parent_market.end_date}::date),'2099-12-31')
                ;;
  }

  join: market_region_xwalk {
    type: inner
    relationship: many_to_one
    sql_on: coalesce(${parent_market.parent_market_id}, ${vendor_net_expense.market_id}) = ${market_region_xwalk.market_id} ;;
  }

  join: revmodel_market_rollout_conservative {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = ${revmodel_market_rollout_conservative.market_id} ;;
  }

  join: plexi_periods {
    type: inner
    relationship: many_to_one
    sql_on: ${plexi_periods.date} = date_trunc(month, ${vendor_net_expense.gl_date}::date) ;;
  }
}

explore: credit_card_transactions {
  label: "BE Credit Card Transactions"

  sql_always_where: (
      ${market_region_xwalk.District_Region_Market_Access}
      and ${plexi_periods.period_published} = 'published'
    )
    -- Let devs, admins, and jabbok see unpublished BE periods.
    or 'developer' = {{ _user_attributes['department'] }}
    or 'admin' = {{ _user_attributes['department'] }}
    or trim(lower('{{ _user_attributes['email'] | replace: "'", "\\'"}}')) = 'jabbok@equipmentshare.com'
    ;;

  join: parent_market {
    type: left_outer
    relationship: many_to_one
    sql_on: ${credit_card_transactions.market_id} = ${parent_market.market_id}::text
      and date_trunc(month, ${credit_card_transactions.gl_date}::date) >= date_trunc(month, ${parent_market.start_date}::date)
      and date_trunc(month, ${credit_card_transactions.gl_date}::date) <= coalesce(date_trunc(month, ${parent_market.end_date}::date), '2099-12-31')
      ;;
  }

  join: market_region_xwalk {
    type: inner
    relationship: many_to_one
    sql_on: coalesce(${parent_market.parent_market_id}, ${credit_card_transactions.market_id})::text = ${market_region_xwalk.market_id}::text ;;
  }

  join: plexi_periods {
    type: inner
    relationship: many_to_one
    sql_on: ${plexi_periods.date} = date_trunc(month, ${credit_card_transactions.gl_date}::date);;
  }

  join: revmodel_market_rollout_conservative {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = ${revmodel_market_rollout_conservative.market_id} ;;
  }
}

explore: time_tracking_wo_vs_unallocated {

  sql_always_where: ${market_region_xwalk.District_Region_Market_Access}
    or 'developer' = {{ _user_attributes['department'] }}
    or 'admin' = {{ _user_attributes['department'] }}
    or trim('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'jabbok@equipmentshare.com';;

  join: parent_market {
    type: left_outer
    relationship: many_to_one
    sql_on: ${time_tracking_wo_vs_unallocated.market_id}::text = ${parent_market.market_id}::text
      and date_trunc(month, ${time_tracking_wo_vs_unallocated.start_date}::date) >= date_trunc(month, ${parent_market.start_date}::date)
      and date_trunc(month, ${time_tracking_wo_vs_unallocated.start_date}::date) <= coalesce(date_trunc(month, ${parent_market.end_date}::date),'2099-12-31')
      ;;
  }

  join: market_region_xwalk {
    type: inner
    relationship: many_to_one
    sql_on: coalesce(${parent_market.parent_market_id}::text, ${time_tracking_wo_vs_unallocated.market_id}::text) = ${market_region_xwalk.market_id}::text ;;
  }

  join: revmodel_market_rollout_conservative {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id}::text = ${revmodel_market_rollout_conservative.market_id}::text ;;
  }

  join: plexi_periods {
    type: inner
    relationship: many_to_one
    sql_on: date_trunc(month,${plexi_periods.date}::date) = date_trunc(month,${time_tracking_wo_vs_unallocated.start_date}::date);;
  }
}

explore: time_tracking_wo_vs_unallocated_open {
  from: time_tracking_wo_vs_unallocated

  sql_always_where: ${market_region_xwalk.District_Region_Market_Access}
    or 'developer' = {{ _user_attributes['department'] }}
    or 'admin' = {{ _user_attributes['department'] }}
    or trim('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'jabbok@equipmentshare.com';;

  join: parent_market {
    type: left_outer
    relationship: many_to_one
    sql_on: ${time_tracking_wo_vs_unallocated_open.market_id}::text = ${parent_market.market_id}::text
      and date_trunc(month, ${time_tracking_wo_vs_unallocated_open.start_date}::date) >= date_trunc(month, ${parent_market.start_date}::date)
      and date_trunc(month, ${time_tracking_wo_vs_unallocated_open.start_date}::date) <= coalesce(date_trunc(month, ${parent_market.end_date}::date),'2099-12-31')
      ;;
  }

  join: market_region_xwalk {
    type: inner
    relationship: many_to_one
    sql_on: coalesce(${parent_market.parent_market_id}::text, ${time_tracking_wo_vs_unallocated_open.market_id}::text) = ${market_region_xwalk.market_id}::text ;;
  }

  join: revmodel_market_rollout_conservative {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id}::text = ${revmodel_market_rollout_conservative.market_id}::text ;;
  }

  join: plexi_periods {
    type: inner
    relationship: many_to_one
    sql_on: date_trunc(month,${plexi_periods.date}::date) = date_trunc(month,${time_tracking_wo_vs_unallocated_open.start_date}::date);;
  }
}

# Used on assigned vs unassigned tech hour dashboard.
explore: service_tech_list {
  sql_always_where: ${market_region_xwalk.District_Region_Market_Access}
    or 'developer' = {{ _user_attributes['department'] }}
    or 'admin' = {{ _user_attributes['department'] }};;

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${service_tech_list.market_id}::text = ${market_region_xwalk.market_id}::text ;;
  }
}

# TODO Missing parent market join, but is this even used? Used in ITL Market Summary (https://equipmentshare.looker.com/dashboards/698)
explore: units_on_rent {
  sql_always_where: ${market_region_xwalk.District_Region_Market_Access}
    or 'developer' = {{ _user_attributes['department'] }}
    or 'admin' = {{ _user_attributes['department'] }};;

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${units_on_rent.rental_branch_id}::text = ${market_region_xwalk.market_id}::text ;;
  }
}


explore: obt_disputes {
  label: "obt_disputes"
  sql_always_where: ${market_region_xwalk.District_Region_Market_Access}
    or 'developer' = {{ _user_attributes['department'] }}
    or 'admin' = {{ _user_attributes['department'] }}
    or trim('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'jabbok@equipmentshare.com'
    or trim('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'lisa.evans@equipmentshare.com'
    or trim('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'diane.canepa@equipmentshare.com'
    or trim('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'kris@equipmentshare.com'
    or trim('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'robin.huighe@equipmentshare.com';;

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${obt_disputes.branch_id} = ${market_region_xwalk.market_id}::text ;;
  }
}

explore: obt_credit_invoices_memos {
  label: "obt_credit_invoices_memos"

  sql_always_where: ${market_region_xwalk.District_Region_Market_Access}
      or 'developer' = {{ _user_attributes['department'] }}
      or 'admin' = {{ _user_attributes['department'] }}
      OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'jabbok@equipmentshare.com'
      OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'lisa.evans@equipmentshare.com'
      OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'diane.canepa@equipmentshare.com'
      OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'kris@equipmentshare.com'
      OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'robin.huighe@equipmentshare.com';;

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${obt_credit_invoices_memos.market_id} = ${market_region_xwalk.market_id}::text ;;
  }
}

explore: obt_customer_invoices_credit_memos {
  label: "obt_customer_invoices_credit_memos"

  sql_always_where: ${market_region_xwalk.District_Region_Market_Access}
    or 'developer' = {{ _user_attributes['department'] }}
    or 'admin' = {{ _user_attributes['department'] }}
    or trim('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'jabbok@equipmentshare.com'
    or trim('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'lisa.evans@equipmentshare.com'
    or trim('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'diane.canepa@equipmentshare.com'
    or trim('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'kris@equipmentshare.com'
    or trim('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'robin.huighe@equipmentshare.com';;

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${obt_customer_invoices_credit_memos.market_id} = ${market_region_xwalk.market_id}::text ;;
  }
}


explore: branch_directory {
  label: "branch_directory"
}

explore: payroll_trend {
  label: "payroll trend"
}

explore: live_payroll_trend {
  label: "Live Payroll Trend"
}

explore: bi_weekly_payroll_wages {
  label: "Bi-Weekly Payroll Wages"
}

explore: live_bi_weekly_payroll_wages {
  label: "Live Bi-Weekly Payroll Wages"
}

explore: branch_customers {
  label: "Branch Customers"
}

explore: mw_customer_tam {
  label: "MW Customer TAMs"
}

explore: mw_customer_yoy {
  label: "MW Customers YoY"
}

explore: customers_monthly {
  label: "Customers Monthly"
}

explore: trending_be_snapshot {
  label: "Trending BE Delta"
}

explore: int_live_branch_earnings_looker_snapshot {
  label: "Trending BE Snapshot"
}

explore: inventory_write_off {
  label: "Inventory Write Off"
}

explore: invoice_balance {
  label: "Invoice Balance"
}

explore: be_forecast {
  label: "BE Forecast"
}

explore: headcount_targets {
  label: "Target Headcounts"
}
# Did not go to production use
explore: bad_transfers {
  label: "Bad Transfers"
  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${bad_transfers.from_market_id}::text = ${market_region_xwalk.market_id}::text ;;
  }

  join: plexi_periods {
    type: left_outer
    relationship: many_to_one
    sql_on: ${bad_transfers.equipment_charge_date}::date = ${plexi_periods.date}::date ;;
  }

  join: revmodel_market_rollout_conservative {
    type: left_outer
    relationship: many_to_one
    sql_on: ${bad_transfers.from_market_id} = ${revmodel_market_rollout_conservative.market_id} ;;
  }
}

explore: delivery_metrics {
  label: "Delivery Metrics"

  sql_always_where: (
  ${market_region_xwalk.District_Region_Market_Access}
  and ${plexi_periods.period_published} = 'published'
  )
  -- Let devs, admins, and jabbok see unpublished BE periods.
  or 'developer' = {{ _user_attributes['department'] }}
  or 'admin' = {{ _user_attributes['department'] }}
  or trim(lower('{{ _user_attributes['email'] | replace: "'", "\\'"}}')) = 'jabbok@equipmentshare.com'
  ;;

  join: parent_market {
    type: left_outer
    relationship: many_to_one
    sql_on: ${delivery_metrics.market_id}::text = ${parent_market.market_id}::text
      and date_trunc(month, ${delivery_metrics.delivery_month}::date) >= date_trunc(month, ${parent_market.start_date}::date)
      and date_trunc(month, ${delivery_metrics.delivery_month}::date) <= coalesce(date_trunc(month, ${parent_market.end_date}::date), '2099-12-31')
      ;;
  }
  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${delivery_metrics.market_id}::text = ${market_region_xwalk.market_id}::text ;;
  }

  join: plexi_periods {
    type: left_outer
    relationship: many_to_one
    sql_on: ${delivery_metrics.delivery_month}::date = ${plexi_periods.date}::date ;;
  }
}

explore: delivery_types {
  label: "Delivery Types"
  sql_always_where: (
  ${market_region_xwalk.District_Region_Market_Access}
  and ${plexi_periods.period_published} = 'published'
  )  ;;

  join: parent_market {
    type: left_outer
    relationship: many_to_one
    sql_on: ${delivery_types.market_id}::text = ${parent_market.market_id}::text
      and date_trunc(month, ${delivery_types.delivery_month}.delivery_month}::date) >= date_trunc(month, ${parent_market.start_date}::date)
      and date_trunc(month, ${delivery_types.delivery_month}::date) <= coalesce(date_trunc(month, ${parent_market.end_date}::date), '2099-12-31')
      ;;
  }

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${delivery_types.market_id}::text = ${market_region_xwalk.market_id}::text ;;
  }

  join: plexi_periods {
    type: left_outer
    relationship: many_to_one
    sql_on: ${delivery_types.delivery_month}::date = ${plexi_periods.date}::date ;;
  }
}


explore: target_market_comparison {
  label: "Target Market Comparison"

  sql_always_where:(
  ${market_region_xwalk.District_Region_Market_Access}
  and ${plexi_periods.period_published} = 'published'
  )
  -- Let devs, admins, and jabbok see unpublished BE periods.
  or 'developer' = {{ _user_attributes['department'] }}
  or 'admin' = {{ _user_attributes['department'] }}
  or trim(lower('{{ _user_attributes['email'] | replace: "'", "\\'"}}')) = 'jabbok@equipmentshare.com'
  ;;

  join: parent_market {
    type: left_outer
    relationship: many_to_one
    sql_on: ${target_market_comparison.market_id}::text = ${parent_market.market_id}::text
      and date_trunc(month, ${target_market_comparison.month}::date) >= date_trunc(month, ${parent_market.start_date}::date)
      and date_trunc(month, ${target_market_comparison.month}::date) <= coalesce(date_trunc(month, ${parent_market.end_date}::date), '2099-12-31')
      ;;
  }
  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${target_market_comparison.market_id}::text = ${market_region_xwalk.market_id}::text ;;
  }

  join: plexi_periods {
    type: left_outer
    relationship: many_to_one
    sql_on: LEFT(${target_market_comparison.month}, 7) = LEFT((${plexi_periods.date}), 7) ;;
  }
}

explore: target_market_colorado {
  label: "Target Market Comparison - Colorado Markets"

  sql_always_where:(
      ${market_region_xwalk.District_Region_Market_Access}
      and ${plexi_periods.period_published} = 'published'
      )
      -- Let devs, admins, and jabbok see unpublished BE periods.
      or 'developer' = {{ _user_attributes['department'] }}
      or 'admin' = {{ _user_attributes['department'] }}
      or trim(lower('{{ _user_attributes['email'] | replace: "'", "\\'"}}')) = 'jabbok@equipmentshare.com'
      ;;

  join: parent_market {
    type: left_outer
    relationship: many_to_one
    sql_on: ${target_market_colorado.market_id}::text = ${parent_market.market_id}::text
      and date_trunc(month, ${target_market_colorado.month}::date) >= date_trunc(month, ${parent_market.start_date}::date)
      and date_trunc(month, ${target_market_colorado.month}::date) <= coalesce(date_trunc(month, ${parent_market.end_date}::date), '2099-12-31')
      ;;
  }
  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${target_market_colorado.market_id}::text = ${market_region_xwalk.market_id}::text ;;
  }

  join: plexi_periods {
    type: left_outer
    relationship: many_to_one
    sql_on: LEFT(${target_market_colorado.month}, 7) = LEFT((${plexi_periods.date}), 7) ;;
  }
}

explore: asset_level_profitability {
  label: "Asset-Level Profitability"

  sql_always_where:(
      ${market_region_xwalk.District_Region_Market_Access}
      )
      -- Let devs, admins, and jabbok see unpublished BE periods.
      or 'developer' = {{ _user_attributes['department'] }}
      or 'admin' = {{ _user_attributes['department'] }}
      or trim(lower('{{ _user_attributes['email'] | replace: "'", "\\'"}}')) = 'jabbok@equipmentshare.com'
      ;;


  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${asset_level_profitability.market_id}::text = ${market_region_xwalk.market_id}::text ;;
  }
}

explore: class_level_fleet_profitability {
  label: "Class-Level Fleet Profitability"

  sql_always_where:(
      ${market_region_xwalk.District_Region_Market_Access}
      )
      -- Let devs, admins, and jabbok see unpublished BE periods.
      or 'developer' = {{ _user_attributes['department'] }}
      or 'admin' = {{ _user_attributes['department'] }}
      or trim(lower('{{ _user_attributes['email'] | replace: "'", "\\'"}}')) = 'jabbok@equipmentshare.com'
      ;;


  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${class_level_fleet_profitability.market_id}::text = ${market_region_xwalk.market_id}::text ;;
  }

}

# Built for R4
explore: keys_to_success {
  view_name: keys_to_success
  label: "Market KPI's (Keys to Success)"
  description: "KPIs for the Midwest region requeested by Jeff Coward."

  sql_always_where: ${market_region_xwalk.District_Region_Market_Access}
      or 'developer' = {{ _user_attributes['department'] }}
      or 'admin' = {{ _user_attributes['department'] }}
      or trim('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'jabbok@equipmentshare.com';;

  join: parent_market {
    type: left_outer
    relationship: many_to_one
    sql_on: ${keys_to_success.market_id}::text = ${parent_market.market_id}
      and date_trunc(month, ${keys_to_success.gl_date}::date) >= date_trunc(month, ${parent_market.start_date}::date)
      and date_trunc(month, ${keys_to_success.gl_date}::date) <= coalesce(date_trunc(month, ${parent_market.end_date}::date), '2099-12-31')
      ;;
  }

  join: market_region_xwalk {
    type: inner
    relationship: many_to_one
    sql_on: coalesce(${parent_market.parent_market_id}, ${keys_to_success.market_id}::text) = ${market_region_xwalk.market_id}::text ;;
  }

  join: revmodel_market_rollout_conservative {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = ${revmodel_market_rollout_conservative.market_id} ;;
  }

  join: plexi_periods_published {
    type: inner
    relationship: many_to_one
    sql_on: ${keys_to_success.gl_date}::date = ${plexi_periods_published.date}::date ;;
  }
}

# Missing parent market
explore: monthly_headcount {
  label: "Total Monthly Headcount by Market"

  join: plexi_periods_to_date {
    type: left_outer
    relationship: many_to_one
    sql_on: ${monthly_headcount.gl_date} = ${plexi_periods_to_date.display};;
  }
}



explore: maintenance_and_repair {
  from: maintenance_and_repair
  label: "Maintenance & Repair"
  description: "Branch-level earnings for maintenance and repair accounts."
}

explore: fleet_status {
  from:  fleet_status
  label: "fleet status"
  description: "asset purchase order history and current status"
}

explore: vsg_reservations_daily_on_rent {
  label: "VSG Reservations Daily On Rent"

}

explore: vsg_reservations_daily_realized_rentals {
  label: "VSG Reservations Daily Realized Rentals"

}

explore: vsg_reservations_daily_utilization {
  label: "VSG Reservations Daily Utilization"

}

explore: vsg_reservations_daily_vehicle_status {
  label: "VSG Reservations Daily Vehicle Status"

}

explore: dealership_sales {
  label: "Dealership Sales"
}

explore: revenue_heat_map {
  label: "Revenue Heat Map"
}

explore: bad_debt_to_rev {
  label: "Bad Debt to Revenue"

  sql_always_where: (
      ${market_region_xwalk.District_Region_Market_Access}
      and ${plexi_periods.period_published} = 'published'
      )
      -- Let devs, admins, and jabbok see unpublished BE periods.
      or 'developer' = {{ _user_attributes['department'] }}
      or 'admin' = {{ _user_attributes['department'] }}
      or trim(lower('{{ _user_attributes['email'] | replace: "'", "\\'"}}')) = 'jabbok@equipmentshare.com'
      ;;

  join: parent_market {
    type: left_outer
    relationship: many_to_one
    sql_on: ${bad_debt_to_rev.market_id}::text = ${parent_market.market_id}::text
      and date_trunc(month, ${bad_debt_to_rev.bad_debt_month}::date) >= date_trunc(month, ${parent_market.start_date}::date)
      and date_trunc(month, ${bad_debt_to_rev.bad_debt_month}::date) <= coalesce(date_trunc(month, ${parent_market.end_date}::date), '2099-12-31')
      ;;
  }
  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${bad_debt_to_rev.market_id}::text = ${market_region_xwalk.market_id}::text ;;
  }

  join: plexi_periods {
    type: left_outer
    relationship: many_to_one
    sql_on: ${bad_debt_to_rev.bad_debt_month}::date = ${plexi_periods.date}::date ;;
  }
}

explore: projected_bad_debt_trending {
  label: "Trending Bad Debt"

  sql_always_where: ${market_region_xwalk.District_Region_Market_Access}
    -- Let devs, admins, and jabbok see unpublished BE periods.
    or 'developer' = {{ _user_attributes['department'] }}
    or 'admin' = {{ _user_attributes['department'] }}
    or trim(lower('{{ _user_attributes['email'] | replace: "'", "\\'"}}')) = 'jabbok@equipmentshare.com'
    ;;

    join: parent_market {
      type: left_outer
      relationship: many_to_one
      sql_on: ${projected_bad_debt_trending.market_id}::text = ${parent_market.market_id}::text
              and date_trunc(month, ${projected_bad_debt_trending.billing_approved_date}::date) >= date_trunc(month, ${parent_market.start_date}::date)
              and date_trunc(month, ${projected_bad_debt_trending.billing_approved_date}::date) <= coalesce(date_trunc(month, ${parent_market.end_date}::date), '2099-12-31')
              ;;
    }

    join: market_region_xwalk {
      type: inner
      relationship: many_to_one
      sql_on: coalesce(${parent_market.parent_market_id}, ${projected_bad_debt_trending.market_id}::text) = ${market_region_xwalk.market_id}::text ;;
    }

    join: revmodel_market_rollout_conservative {
      type: inner
      relationship: many_to_one
      sql_on: ${market_region_xwalk.market_id} = ${revmodel_market_rollout_conservative.market_id} ;;
    }
  }
