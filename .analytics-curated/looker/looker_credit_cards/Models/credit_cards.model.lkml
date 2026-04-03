connection: "es_snowflake_c_analytics"

include: "/views/PUBLIC/users.view.lkml"
include: "/views/PUBLIC/markets.view.lkml"
include: "/views/PUBLIC/districts.view.lkml"
include: "/views/PUBLIC/regions.view.lkml"
include: "/views/ANALYTICS/disc_master.view.lkml"
include: "/views/ANALYTICS/cc_and_fuel_spend_all.view.lkml"
include: "/views/ANALYTICS/cc_strikes.view.lkml"
include: "/views/ANALYTICS/cc_spend_receipt_upload.view.lkml"
include: "/views/ANALYTICS/paycor_employees_managers.view.lkml"
include: "/views/ANALYTICS/paycor_employees_managers_full_hierarchy.view.lkml"
include: "/views/ANALYTICS/cc_similar_spend.view.lkml"
include: "/views/ANALYTICS/cc_spend_receipt_validation.view.lkml"
include: "/views/ANALYTICS/ukg_paycor_mapping.view.lkml"
include: "/views/ANALYTICS/ukg_cost_center_market_id_mapping.view.lkml"
include: "/views/ANALYTICS/market_region_xwalk.view.lkml"
include: "/views/PURCHASES/purchases.view.lkml"
include: "/views/ANALYTICS/cc_spend_receipt_costcapture.view.lkml"
include: "/views/ANALYTICS/cc_spend_receipt_google.view.lkml"
include: "/views/PROCUREMENT/procurement_purchases.view.lkml"
include: "/views/PROCUREMENT/business_unit_snapshots.view.lkml"
include: "/views/EXPENSE_TRACKER/expense_lines.view.lkml"
include: "/views/EXPENSE_TRACKER/sub_departments.view.lkml"
include: "/views/EXPENSE_TRACKER/departments.view.lkml"
include: "/views/ANALYTICS/transaction_verification.view.lkml"
include: "/views/ANALYTICS/company_directory.view.lkml"
include: "/views/ANALYTICS/transaction_verification_all_statuses.view.lkml"
include: "/views/custom_sql/cardholder_status.view.lkml"
include: "/views/custom_sql/contractor_to_employee_conversions.view.lkml"
include: "/views/ANALYTICS/cc_vs_rental_rev.view.lkml"
include: "/views/ANALYTICS/fuel_vs_rental_rev.view.lkml"
include: "/views/custom_sql/cc_shutoff_email_history.view.lkml"
include: "/views/custom_sql/manager_hierarchy.view.lkml"
include: "/cpm_transactions.view.lkml"
include: "/views/ANALYTICS/stg_analytics_credit_card__receipt_ocr_itemization_fraud.view.lkml"
include: "/views/ANALYTICS/stg_analytics_credit_card__receipt_ocr_itemization_analysis.view.lkml"
include: "/views/ANALYTICS/int_credit_card__citi_fuel_cardholder_status.view.lkml"
include: "/views/ANALYTICS/employee_rewards_card.view.lkml"
include: "/views/ANALYTICS/citi_card_holder.view.lkml"
include: "/views/ANALYTICS/corporate_card_accounts.view.lkml"

# include all views in the views/ folder in this project
# include: "/**/view.lkml"                   # include all views in this project
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
explore: credit_card_users {
  from: paycor_employees_managers
  group_label: "Credit Cards"
  label: "Credit Card Transactions"
  case_sensitive: no
  sql_always_where: (
  {% assign user_email = _user_attributes['email'] | replace: "'", "\\'" | strip %}
  {% assign user_dept  = _user_attributes['department'] | strip %}

  (
  -- Priority Access: Departments with full visibility
  {{ user_dept }} IN ('finance', 'developer', 'admin')

  -- Explicit email whitelist
  OR TRIM('{{ user_email }}') IN (
  'jabbok@equipmentshare.com',
  'will@equipmentshare.com',
  'andrew.cowherd@equipmentshare.com',
  'tiffany.goalder@equipmentshare.com',
  'allie.porting@equipmentshare.com',
  'bobbi.malone@equipmentshare.com',
  'katie.cunningham@equipmentshare.com',
  'nathaniel.hardy@equipmentshare.com',
  'kinzie.leach@equipmentshare.com',
  'hope.vaughn@equipmentshare.com',
  'sarah.clark@equipmentshare.com',
  'erik.copley@equipmentshare.com',
  'ashley.steiner@equipmentshare.com',
  'bill.loucks@equipmentshare.com',
  'greg.knaack@equipmentshare.com',
  'kyle.jones@equipmentshare.com',
  'rebecca.quint@equipmentshare.com',
  'shawna.soptick@equipmentshare.com',
  'ellyn.meketsy@equipmentshare.com',
  'jessica.gipson@equipmentshare.com',
  'mollie.goodwin@equipmentshare.com',   -- Per Tory Hicks Help Looker 4/4/24 KC
  'megan.smith@equipmentshare.com',      -- Per Lisa Evans 4/5/24 KC
  'kate.helmstetler@equipmentshare.com', -- Per Bobbi Malone Help Looker 4/25/24 PB
  'sean.m.maguire@equipmentshare.com',   -- Per Gina Campagna DM 6/13/24 PB
  'clint.kendrick@equipmentshare.com',   -- Per request through Bri via DM 7/3/24 PB
  'alistair.tyrrell@equipmentshare.com', -- Per Bri Porter in #help-looker 7/3/24 - KC
  'mylin.drummond@equipmentshare.com',   -- Per Katie Cunningham via DM 8/16/24 - PB
  'angie.bailey@equipmentshare.com',     -- Per Bobbi Malone & Sunshine via Help Looker & DM 8/27/24 - KC
  'feven.bowers@equipmentshare.com',     -- Per Bobbi Malone & Sunshine via Help Looker & DM 8/27/24 - KC
  'chris.doehring@equipmentshare.com',   -- Per Kari Gruenberg help-looker
  'maddy.wise@equipmentshare.com',       -- Per Sunshine help-looker 9/18/24 - KC
  'lynze.soderstrom@equipmentshare.com', -- Per Rebecca Quint help-looker 10/18/24 - KC
  'toni.mccrady@equipmentshare.com',     -- Per Lisa Evans group DM 2024-10-24 - PB
  'penny.mcqueen@equipmentshare.com',    -- Per Approved per Sonya Collier 2024-12-11 - PB
  'ashley.pannell@equipmentshare.com',   -- Per Katie Cunningham DM 2024-12-26 - PB
  'cody.turner@equipmentshare.com',      -- Per Katie Cunningham DM 2025-01-09 - SM
  'braydon.friesz@equipmentshare.com',   -- Per Katie Cunningham DM 2025-02-07 - SM
  'bianca.braun@equipmentshare.com',     -- Per help looker 2025-02-24 - SM
  'savana.luebbert@equipmentshare.com',  -- Per help looker 2025-02-24 - SM
  'robin.shaw@equipmentshare.com',       -- Per help looker 2025-03-12 - SM
  'steve.lackner@equipmentshare.com',    -- Per Slack with Steve Lackner & Lisa Evans 2025-04-14 - PL
  'jeff.freese@equipmentshare.com',       -- Per help looker 2025-04-24 - SM
  'jack.widhalm@equipmentshare.com',       -- Per help looker 2025-05-05 - SM
  'connor.streck@equipmentshare.com'      -- Per Katie Cunningham in help looker 2025-06-18 - SM
  )

  -- Email or manager email match to user attribute
  OR LOWER(TRIM(${manager_hierarchy.manager_email})) = LOWER(TRIM('{{ user_email }}'))
  OR LOWER(TRIM(${users.email_address})) = LOWER(TRIM('{{ user_email }}'))
  )
  )
  ;;
  #
  # OR TRIM(LOWER(${orphaned_receipts.employee_email_address}))=TRIM(LOWER('{{ _user_attributes['email'] | replace: "'", "\\'" }}'))
  # OR TRIM(LOWER(${orphaned_receipts.email_address}))=  TRIM(LOWER('{{ _user_attributes['email'] | replace: "'", "\\'" }}'))

  # join: market_region_xwalk {
  #   type: full_outer
  #   relationship: many_to_one
  #   sql_on: ${credit_card_users.market_id} = ${market_region_xwalk.market_id} ;;
  # }

  # join: paycor_employees_managers {
  #   type: full_outer
  #   relationship: one_to_one
  #   sql_on: ${paycor_employees_managers.employee_number}=${credit_card_users.employee_number};;
  # }

  join: manager_hierarchy {
    type: left_outer
    relationship: one_to_many
    sql_on: ${credit_card_users.employee_number}=${manager_hierarchy.employee_id};;
  }

    join: cc_and_fuel_spend_all {
      type: left_outer
      relationship: one_to_many
      sql_on: ${credit_card_users.employee_number}=${cc_and_fuel_spend_all.employee_number} ;;
    }

    join: transaction_verification {
      type: left_outer
      relationship: one_to_many
      # sql_where: ${transaction_verification.card_type} <> 'cent' ;; --commenting out since there are some active central bank cards still 11/06/23 kc
      sql_where: ${transaction_verification.corporate_account_name} <> 'EQS EMPLOYEE REWARDS' ;; # requested from Gina Campagna
      sql_on: ${credit_card_users.employee_number} = ${transaction_verification.employee_id}  ;;
    }

    join: transaction_verification_all_statuses {
      # This transaction_verification includes reallocated transactions
      type: left_outer
      relationship: one_to_many
      sql_where: ${transaction_verification_all_statuses.corporate_account_name} <> 'EQS EMPLOYEE REWARDS' ;; # requested from Gina Campagna
      sql_on: ${credit_card_users.employee_number} = ${transaction_verification_all_statuses.employee_id} ;;
    }

    join: users {
      type: left_outer
      relationship: one_to_one
      sql_on: TRIM(LOWER(${credit_card_users.employee_email})) = TRIM(LOWER(${users.email_address})) ;;
    }

    join: company_directory {
      type: left_outer
      relationship: many_to_many
      sql_on: trim(lower(${credit_card_users.employee_email})) = trim(lower(${company_directory.work_email}));;
      #sql_on: lower(${users.email_address}) = lower(${company_directory.work_email}) --commenting out 10/2/23 best join on employee ID
      #sql_on: ${users.user_id} = ${company_directory.employee_id} --commenting out 8/10/23 to make a better join on email ;;
    }

    join: ukg_cost_center_market_id_mapping {
      type: left_outer
      relationship: many_to_one
      sql_on:  TRIM(LOWER(${company_directory.default_cost_centers_full_path}))=TRIM(LOWER(${ukg_cost_center_market_id_mapping.cost_centers_full_path})) ;;
    }

    join: market_region_xwalk {
      type: left_outer
      relationship: many_to_one
      sql_on: ${ukg_cost_center_market_id_mapping.market_id}::TEXT=${market_region_xwalk.market_id}::TEXT ;;
    }

    join: districts {
      type: left_outer
      relationship: many_to_one
      sql_on: ${market_region_xwalk.district}=${districts.district_id} ;;
    }

  # join: purchases {
  #   type: full_outer
  #   relationship: one_to_one
  #   sql_on: TRIM(LOWER(${users.email_address})) = TRIM(LOWER(${purchases.employee_email_address}))
  #             and ${cc_and_fuel_spend_all.transaction_amount}=${purchases.receipt_amount}
  #             and ${cc_and_fuel_spend_all.transaction_date_date}>=(${purchases.transaction_date_date}::DATE - interval '20 days') ;;
  # }


    join: cc_spend_receipt_upload {
      type: left_outer
      relationship: one_to_one
      sql_on: ${cc_spend_receipt_upload.user_id}=${users.user_id}
              and (${cc_and_fuel_spend_all.card_type} = ${cc_spend_receipt_upload.card_type} and ${cc_spend_receipt_upload.receipt_source} = 'Cost_Capture')
              and ${cc_and_fuel_spend_all.transaction_amount}=${cc_spend_receipt_upload.receipt_amount}
              and ${cc_and_fuel_spend_all.transaction_date_date}>=(${cc_spend_receipt_upload.transaction_date_date}::DATE - interval '30 days')
              and ${cc_and_fuel_spend_all.transaction_date_date}< (${cc_spend_receipt_upload.transaction_date_date}::DATE + interval '30 days') ;;
    }

    # # join: spend_users {
    # #   from: users
    # #   type: left_outer
    # #   relationship: many_to_one
    # #   sql_on: TRIM(LOWER(${cc_spend_receipt_upload.employee_email_address}))=TRIM(LOWER(${spend_users.email_address})) ;;
    # # }

    join: orphaned_receipts {
      from:cc_spend_receipt_upload
      type: full_outer
      relationship: many_to_one
      sql_on:
          ${orphaned_receipts.user_id}=${users.user_id}
          AND  ${cc_and_fuel_spend_all.transaction_amount}=${orphaned_receipts.receipt_amount}
          AND (${cc_and_fuel_spend_all.card_type} = ${orphaned_receipts.card_type} and ${cc_spend_receipt_upload.receipt_source} = 'Cost_Capture')
          AND  ${cc_and_fuel_spend_all.transaction_date_date}>=(${orphaned_receipts.transaction_date_date}::DATE - interval '30 days')
          AND  ${cc_and_fuel_spend_all.transaction_date_date}< (${orphaned_receipts.transaction_date_date}::DATE + interval '30 days') ;;
    }

    join: cc_strikes {
      type: left_outer
      relationship: many_to_one
      sql_on: ${transaction_verification.employee_id}=${cc_strikes.employee_id}
        and ${transaction_verification.card_type}=${cc_strikes.card_type};;
    }

  join: cc_similar_spend {
    type: full_outer
    relationship: one_to_many
    sql_on: ${credit_card_users.employee_email}=${cc_similar_spend.email_address} ;;
  }

  # join: cc_spend_receipt_validation {
  #   type: left_outer
  #   relationship: one_to_one
  #   sql_on: trim(${cc_spend_receipt_upload.upload_receipt})=trim(${cc_spend_receipt_validation.receipt_image}) ;;
  # }


#   join: paycor_managers_email {
#     type: full_outer
#     relationship: one_to_many
#     sql_on: TRIM(${paycor_employees_managers.employee_email})=TRIM(${paycor_managers_email.manager_employee_email}) ;;
# #     sql_on: TRIM(${users.email_address})=TRIM(${paycor_managers_email.manager_employee_email}) ;;
#   }

  join: procurement_purchases {
    type: left_outer
    relationship: one_to_one
    sql_on: ${users.user_id} = ${procurement_purchases.user_id}
          AND ${cc_and_fuel_spend_all.card_type} = ${procurement_purchases.card_type};;
          # AND  ${cc_and_fuel_spend_all.transaction_amount}=${procurement_purchases.grand_total}
          # AND  ${cc_and_fuel_spend_all.transaction_date_date}>=(${procurement_purchases.submitted_date_date}::DATE - interval '30 days')
          # AND  ${cc_and_fuel_spend_all.transaction_date_date}< (${procurement_purchases.submitted_date_date}::DATE + interval '30 days');;
  }

  join: purchase_market {
    from: market_region_xwalk
    type: left_outer
    relationship: many_to_one
    sql_on: ${transaction_verification.receipt_market_id} = ${market_region_xwalk.market_id} ;;
  }

  join: expense_line_item_xref{
    from: business_unit_snapshots
    type: left_outer
    fields: []
    relationship: one_to_one
    sql_on: ${expense_line_item_xref.business_unit_snapshot_id} = ${procurement_purchases.business_expense_line_snapshot_id} AND ${expense_line_item_xref.business_unit_type} = 'EXPENSE_LINE';;
  }

  join: sub_department_xref {
    from: business_unit_snapshots
    type: left_outer
    fields: []
    relationship: one_to_one
    sql_on: ${sub_department_xref.business_unit_snapshot_id} = ${procurement_purchases.business_sub_department_snapshot_id} AND ${sub_department_xref.business_unit_type} = 'SUB_DEPARTMENT';;
  }

  join: department_xref {
    from: business_unit_snapshots
    type: left_outer
    fields: []
    relationship: one_to_one
    sql_on: ${department_xref.business_unit_snapshot_id} = ${procurement_purchases.business_department_snapshot_id} AND ${department_xref.business_unit_type} = 'DEPARTMENT';;
  }

  join: expense_lines {
    type: left_outer
    relationship: many_to_one
    sql_on: ${expense_line_item_xref.business_unit_id} = ${expense_lines.expense_line_id};;
  }

  join: sub_departments {
    type: left_outer
    relationship: many_to_one
    sql_on: ${sub_department_xref.business_unit_id} = ${sub_departments.sub_departments_id} ;;
  }

  join: departments {
    type: left_outer
    relationship: many_to_one
    sql_on: ${department_xref.business_unit_id} = ${departments.department_id} ;;
  }

  join: cardholder_status {
    type: left_outer
    relationship: many_to_one
    sql_on: ${cardholder_status.employee_id} = ${transaction_verification.employee_id}
    and ${cardholder_status.corporate_account_name} = ${transaction_verification.corporate_account_name};;
  }
}

explore: cardholder_status {
  from: cardholder_status
  label: "Card Holder Status by Corporate Account"
  case_sensitive: no
  sql_always_where:
  TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')    = 'jabbok@equipmentshare.com'
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'will@equipmentshare.com'
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'andrew.cowherd@equipmentshare.com'
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'tiffany.goalder@equipmentshare.com'
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'allie.porting@equipmentshare.com'
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'bobbi.malone@equipmentshare.com'
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'katie.cunningham@equipmentshare.com'
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'nathaniel.hardy@equipmentshare.com'
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'kinzie.leach@equipmentshare.com'
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'hope.vaughn@equipmentshare.com'
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'sarah.clark@equipmentshare.com'
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'erik.copley@equipmentshare.com'
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'ashley.steiner@equipmentshare.com'
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'bill.loucks@equipmentshare.com'
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'greg.knaack@equipmentshare.com'
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'kyle.jones@equipmentshare.com'
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'rebecca.quint@equipmentshare.com'
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'kyle.jones@equipmentshare.com'
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'shawna.soptick@equipmentshare.com'
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'ellyn.meketsy@equipmentshare.com'
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'jessica.gipson@equipmentshare.com'
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'mollie.goodwin@equipmentshare.com'   --- Per Tory Hicks Help Looker 4/4/24 KC
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'megan.smith@equipmentshare.com'      --- Per Lisa Evans 4/5/24 KC
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'kate.helmstetler@equipmentshare.com' --- Per Bobbi Malone Help Looker 4/25/24 PB
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'sean.m.maguire@equipmentshare.com'   --- Per Gina Campagna DM 6/13/24 PB
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'clint.kendrick@equipmentshare.com'   --- Per request through Bri via DM 7/3/24 PB
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'alistair.tyrrell@equipmentshare.com' --- Per Bri Porter in #help-looker 7/3/24 - KC
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'mylin.drummond@equipmentshare.com'   --- Per Katie Cunningham via DM 8/16/24 - PB
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'angie.bailey@equipmentshare.com'     --- Per Bobbi Malone & Sunshine via Help Looker & DM 8/27/24 - KC
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'feven.bowers@equipmentshare.com'     --- Per Bobbi Malone & Sunshine via Help Looker & DM 8/27/24 - KC
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'chris.doehring@equipmentshare.com'   --- Per Kari Gruenberg help-looker
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'maddy.wise@equipmentshare.com'       --- Per Sunshine help-looker 9/18/24 - KC
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'lynze.soderstrom@equipmentshare.com' --- Per Rebecca Quint help-looker 10/18/24 - KC
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'toni.mccrady@equipmentshare.com'     --- Per Lisa Evans group DM 2024-10-24 - PB
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'penny.mcqueen@equipmentshare.com'    --- Per Approved per Sonya Collier 2024-12-11 - PB
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'ashley.pannell@equipmentshare.com'    --- Per Katie Cunningham DM 2024-12-26 - PB
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'cody.turner@equipmentshare.com'    --- Per Katie Cunningham DM 2025-01-09 - SM
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'lynze.soderstrom@equipmentshare.com'    --- Per Katie Cunningham help-looker 2025-01-17 - PB
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'braydon.friesz@equipmentshare.com'    --- Per Katie Cunningham DM 2025-02-07 - SM
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'bianca.braun@equipmentshare.com'    --- Per help looker 2025-02-24 - SM
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'savana.luebbert@equipmentshare.com'    --- Per help looker 2025-02-24 - SM
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'robin.shaw@equipmentshare.com'    --- Per help looker 2025-03-12 - SM
  OR (TRIM(LOWER(${manager_hierarchy.manager_email}))=  TRIM(LOWER('{{ _user_attributes['email'] | replace: "'", "\\'" }}'))
  OR TRIM(LOWER(${users.email_address})) =  TRIM(LOWER('{{ _user_attributes['email'] | replace: "'", "\\'" }}'))
  OR 'finance' = {{ _user_attributes['department'] }}
  OR 'developer' = {{ _user_attributes['department'] }}
  OR 'admin' = {{ _user_attributes['department'] }});;

  join: manager_hierarchy {
    type: left_outer
    relationship: one_to_many
    sql_on: ${cardholder_status.employee_id}=${manager_hierarchy.employee_id};;
  }

  join: users {
    type: left_outer
    relationship: one_to_one
    sql_on: TRIM(LOWER(${cardholder_status.cardholder_email})) = TRIM(LOWER(${users.email_address})) ;;
  }

    join: company_directory {
      type: left_outer
      relationship: one_to_one
      sql_on: TRY_TO_NUMBER(${users.employee_id}) = ${company_directory.employee_id};;
  }
}

explore: transaction_verification {
  from: transaction_verification
  label: "Credit Card Transactions by Verification Status"
  case_sensitive: no
  sql_always_where:
    TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'jabbok@equipmentshare.com'
    OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'will@equipmentshare.com'
    OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'andrew.cowherd@equipmentshare.com'
    OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'tiffany.goalder@equipmentshare.com'
    OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'allie.porting@equipmentshare.com'
    OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'bobbi.malone@equipmentshare.com'
    OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'katie.cunningham@equipmentshare.com'
    OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'nathaniel.hardy@equipmentshare.com'
    OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'kinzie.leach@equipmentshare.com'
    OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'hope.vaughn@equipmentshare.com'
    OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'sarah.clark@equipmentshare.com'
    OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'erik.copley@equipmentshare.com'
    OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'ashley.steiner@equipmentshare.com'
    OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'bill.loucks@equipmentshare.com'
    OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'greg.knaack@equipmentshare.com'
    OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'kyle.jones@equipmentshare.com'
    OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'rebecca.quint@equipmentshare.com'
    OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'kyle.jones@equipmentshare.com'
    OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'shawna.soptick@equipmentshare.com'
    OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'ellyn.meketsy@equipmentshare.com'
    OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'jessica.gipson@equipmentshare.com'
    OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'mollie.goodwin@equipmentshare.com'   --- Per Tory Hicks Help Looker 4/4/24 KC
    OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'megan.smith@equipmentshare.com'      --- Per Lisa Evans 4/5/24 KC
    OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'kate.helmstetler@equipmentshare.com' --- Per Bobbi Malone Help Looker 4/25/24 PB
    OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'sean.m.maguire@equipmentshare.com'   --- Per Gina Campagna DM 6/13/24 PB
    OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'clint.kendrick@equipmentshare.com'   --- Per request through Bri via DM 7/3/24 PB
    OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'alistair.tyrrell@equipmentshare.com' --- Per Bri Porter in #help-looker 7/3/24 - KC
    OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'mylin.drummond@equipmentshare.com'   --- Per Katie Cunningham via DM 8/16/24 - PB
    OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'angie.bailey@equipmentshare.com'     --- Per Bobbi Malone & Sunshine via Help Looker & DM 8/27/24 - KC
    OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'feven.bowers@equipmentshare.com'     --- Per Bobbi Malone & Sunshine via Help Looker & DM 8/27/24 - KC
    OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'chris.doehring@equipmentshare.com'   --- Per Kari Gruenberg help-looker
    OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'maddy.wise@equipmentshare.com'       --- Per Sunshine help-looker 9/18/24 - KC
    OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'lynze.soderstrom@equipmentshare.com' --- Per Rebecca Quint help-looker 10/18/24 - KC
    OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'toni.mccrady@equipmentshare.com'     --- Per Lisa Evans group DM 2024-10-24 - PB
    OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'penny.mcqueen@equipmentshare.com'    --- Per Approved per Sonya Collier 2024-12-11 - PB
    OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'ashley.pannell@equipmentshare.com'    --- Per Katie Cunningham DM 2024-12-26 - PB
    OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'cody.turner@equipmentshare.com'    --- Per Katie Cunningham DM 2025-01-09 - SM
    OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'lynze.soderstrom@equipmentshare.com'    --- Per Katie Cunningham help-looker 2025-01-17 - PB
    OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'braydon.friesz@equipmentshare.com'    --- Per Katie Cunningham DM 2025-02-07 - SM
    OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'bianca.braun@equipmentshare.com'    --- Per help looker 2025-02-24 - SM
    OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'savana.luebbert@equipmentshare.com'    --- Per help looker 2025-02-24 - SM
    OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'robin.shaw@equipmentshare.com'    --- Per help looker 2025-03-12 - SM
    OR TRIM(LOWER(${company_directory.work_email})) = TRIM(LOWER('{{ _user_attributes['email'] | replace: "'", "\\'" }}'))
    OR TRIM(LOWER(${manager_hierarchy.manager_email})) = TRIM(LOWER('{{ _user_attributes['email'] | replace: "'", "\\'" }}'))
    OR 'finance' = {{ _user_attributes['department'] }}
    OR 'developer' = {{ _user_attributes['department'] }}
    OR 'admin' = {{ _user_attributes['department'] }};;

  join: company_directory {
    type: inner
    relationship: one_to_one
    sql_on: ${transaction_verification.employee_id} = ${company_directory.employee_id};;
  }

  # This model's only use is to go from manager_email -> direct reports (and their direct reports). See sql_always_where.
  join: manager_hierarchy {
    type: left_outer
    relationship: one_to_many
    sql_on: ${company_directory.employee_id}=${manager_hierarchy.employee_id};;
  }

  join: int_credit_card__citi_fuel_cardholder_status {
    type: left_outer
    relationship: one_to_many
    sql_on: ${int_credit_card__citi_fuel_cardholder_status.employee_id} = ${transaction_verification.employee_id} and ${int_credit_card__citi_fuel_cardholder_status.corporate_account_name} = ${transaction_verification.corporate_account_name} ;;
  }

  join: cc_strikes {
    type: left_outer
    relationship: one_to_many
    sql_on: ${transaction_verification.employee_id}=${cc_strikes.employee_id}
    and ${transaction_verification.corporate_account_name}=${cc_strikes.corporate_account_name};;
  }

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${company_directory.market_id}::TEXT=${market_region_xwalk.market_id}::TEXT ;;
  }
}

explore: contractor_to_employee_conversions {
  from: contractor_to_employee_conversions
  label: "Employees that converted from contractors"
  case_sensitive: no
  sql_always_where:
  TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')    = 'jabbok@equipmentshare.com'
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'will@equipmentshare.com'
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'andrew.cowherd@equipmentshare.com'
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'tiffany.goalder@equipmentshare.com'
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'allie.porting@equipmentshare.com'
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'bobbi.malone@equipmentshare.com'
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'katie.cunningham@equipmentshare.com'
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'nathaniel.hardy@equipmentshare.com'
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'kinzie.leach@equipmentshare.com'
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'hope.vaughn@equipmentshare.com'
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'sarah.clark@equipmentshare.com'
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'erik.copley@equipmentshare.com'
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'ashley.steiner@equipmentshare.com'
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'bill.loucks@equipmentshare.com'
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'greg.knaack@equipmentshare.com'
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'kyle.jones@equipmentshare.com'
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'rebecca.quint@equipmentshare.com'
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'kyle.jones@equipmentshare.com'
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'shawna.soptick@equipmentshare.com'
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'ellyn.meketsy@equipmentshare.com'
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'jessica.gipson@equipmentshare.com'
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'mollie.goodwin@equipmentshare.com'   --- Per Tory Hicks Help Looker 4/4/24 KC
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'megan.smith@equipmentshare.com'      --- Per Lisa Evans 4/5/24 KC
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'kate.helmstetler@equipmentshare.com' --- Per Bobbi Malone Help Looker 4/25/24 PB
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'sean.m.maguire@equipmentshare.com'   --- Per Gina Campagna DM 6/13/24 PB
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'clint.kendrick@equipmentshare.com'   --- Per request through Bri via DM 7/3/24 PB
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'alistair.tyrrell@equipmentshare.com' --- Per Bri Porter in #help-looker 7/3/24 - KC
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'mylin.drummond@equipmentshare.com'   --- Per Katie Cunningham via DM 8/16/24 - PB
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'angie.bailey@equipmentshare.com'     --- Per Bobbi Malone & Sunshine via Help Looker & DM 8/27/24 - KC
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'feven.bowers@equipmentshare.com'     --- Per Bobbi Malone & Sunshine via Help Looker & DM 8/27/24 - KC
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'chris.doehring@equipmentshare.com'   --- Per Kari Gruenberg help-looker
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'maddy.wise@equipmentshare.com'       --- Per Sunshine help-looker 9/18/24 - KC
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'lynze.soderstrom@equipmentshare.com' --- Per Rebecca Quint help-looker 10/18/24 - KC
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'toni.mccrady@equipmentshare.com'     --- Per Lisa Evans group DM 2024-10-24 - PB
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'penny.mcqueen@equipmentshare.com'    --- Per Approved per Sonya Collier 2024-12-11 - PB
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'ashley.pannell@equipmentshare.com'    --- Per Katie Cunningham DM 2024-12-26 - PB
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'cody.turner@equipmentshare.com'    --- Per Katie Cunningham DM 2025-01-09 - SM
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'lynze.soderstrom@equipmentshare.com'    --- Per Katie Cunningham help-looker 2025-01-17 - PB
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'braydon.friesz@equipmentshare.com'    --- Per Katie Cunningham DM 2025-02-07 - SM
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'bianca.braun@equipmentshare.com'    --- Per help looker 2025-02-24 - SM
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'savana.luebbert@equipmentshare.com'    --- Per help looker 2025-02-24 - SM
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'robin.shaw@equipmentshare.com'    --- Per help looker 2025-03-12 - SM
  OR 'finance' = {{ _user_attributes['department'] }}
  OR 'developer' = {{ _user_attributes['department'] }}
  OR 'admin' = {{ _user_attributes['department'] }};;
}

explore: expense_reporting{
  from: paycor_employees_managers
  group_label: "Credit Cards"
  label: "Credit Card Expense Reporting"
  case_sensitive: no
  sql_always_where:
   TRIM('{{ _user_attributes['email'] }}')  = 'jabbok@equipmentshare.com'
  OR TRIM('{{ _user_attributes['email'] }}')  = 'will@equipmentshare.com'
  OR TRIM('{{ _user_attributes['email'] }}')  = 'andrew.cowherd@equipmentshare.com'
  OR TRIM('{{ _user_attributes['email'] }}') = 'tiffany.goalder@equipmentshare.com'
  OR TRIM('{{ _user_attributes['email'] }}') = 'allie.porting@equipmentshare.com'
  OR TRIM('{{ _user_attributes['email'] }}') = 'bobbi.malone@equipmentshare.com'
  OR TRIM('{{ _user_attributes['email'] }}') = 'katie.cunningham@equipmentshare.com'
  OR TRIM('{{ _user_attributes['email'] }}') = 'nathaniel.hardy@equipmentshare.com'
  OR TRIM('{{ _user_attributes['email'] }}') = 'john.ward@equipmentshare.com'
  OR TRIM('{{ _user_attributes['email'] }}') = 'alistair.tyrrell@equipmentshare.com' -- Per Bri Porter in #help-looker 7/3/24 - KC
  OR (TRIM(LOWER(${paycor_employees_managers_full_hierarchy.manager_email}))=  REPLACE(TRIM(LOWER('{{ _user_attributes['email'] }}')), '', '\\')
  OR TRIM(LOWER(${users.email_address})) =  REPLACE(TRIM(LOWER('{{ _user_attributes['email'] }}')), '', '\\')
  OR 'finance' = {{ _user_attributes['department'] }}
  OR 'developer' = {{ _user_attributes['department'] }}
  OR 'admin' = {{ _user_attributes['department'] }})
  ;;

    join: paycor_employees_managers_full_hierarchy {
      type: left_outer
      relationship: one_to_many
      sql_on: ${expense_reporting.employee_number}=${paycor_employees_managers_full_hierarchy.employee_number};;
    }

    join: cc_and_fuel_spend_all {
      type: full_outer
      relationship: one_to_many
      sql_on: ${expense_reporting.employee_number}=${cc_and_fuel_spend_all.employee_number} ;;
    }

    join: users {
      type: full_outer
      relationship: one_to_one
      sql_on: TRIM(LOWER(${expense_reporting.employee_email})) = TRIM(LOWER(${users.email_address})) ;;
    }

    # Need this join so the users.full_name can reference company directory employee ID
    join: company_directory {
      type: inner
      relationship: one_to_one
      sql_on: TRIM(LOWER(${users.email_address})) = TRIM(LOWER(${company_directory.work_email})) ;;
    }


    join: cc_spend_receipt_upload {
      type: left_outer
      relationship: one_to_one
      sql_on: TRIM(LOWER(${users.email_address})) = TRIM(LOWER(${cc_spend_receipt_upload.employee_email_address}))
              and ${cc_and_fuel_spend_all.transaction_amount}=${cc_spend_receipt_upload.receipt_amount}
              and ${cc_and_fuel_spend_all.transaction_date_date}>=${cc_spend_receipt_upload.transaction_date_date}
              and ${cc_and_fuel_spend_all.transaction_date_date}<(${cc_spend_receipt_upload.transaction_date_date}::DATE + interval '30 days');;
    }
  join: cc_spend_receipt_costcapture {
    type: left_outer
    relationship: one_to_one
    sql_on: TRIM(LOWER(${users.email_address})) = TRIM(LOWER(${cc_spend_receipt_costcapture.employee_email_address}))
              and ${cc_and_fuel_spend_all.transaction_amount}=${cc_spend_receipt_costcapture.receipt_amount}
              and ${cc_and_fuel_spend_all.transaction_date_date}=${cc_spend_receipt_costcapture.transaction_date_date} ;;
  }


}

explore: cc_vs_rental_rev {
  label: "Monthly Credit Card Spend vs Rental Revenue"
  case_sensitive: no
  description: "Displays monthly credit card spend along with rental revenue for that month and the previous.
                Includes salesperson EEs only. Dates back one year."
}

explore: fuel_vs_rental_rev {
  label: "Monthly Fuel Spend vs Rental Revenue"
  case_sensitive: no
  description: "Displays monthlyfuel card spend along with rental revenue for that month and the previous.
  Includes salesperson EEs only. Dates back one year."
}

explore: credit_card_shutoff_email_history {
  from: cc_shutoff_email_history
  description: "Credit card shutoff email history"
}

explore: cpm_transactions {
  case_sensitive: no
  description: "Displays credit card transactions from the Construction Project Management team."
}

explore: credit_card_users_no_filter_test {
  from: paycor_employees_managers
  label: "Credit Card Transactions (No Filter Test)"
  description: "Minimal Explore to test if EQS EMPLOYEE REWARDS rows appear"

  # (Optional) If you need the same user-attribute filters, add them here:
  # sql_always_where: TRIM('{{ _user_attributes['email'] }}') = 'your.email@equipmentshare.com' ;;

  join: transaction_verification {
    type: left_outer
    relationship: one_to_many
    # No sql_where filter here
    sql_on: ${credit_card_users_no_filter_test.employee_number} = ${transaction_verification.employee_id} ;;
  }
}

explore: procurement_purchases {
  from: procurement_purchases
  label: "OCR Line Itemization Credit Card Spend"
  sql_always_where:
  TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')    = 'jabbok@equipmentshare.com'
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'will@equipmentshare.com'
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'katie.cunningham@equipmentshare.com'
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'lisa.evans@equipmentshare.com'
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'gina.campagna@equipmentshare.com'
  OR 'finance' = {{ _user_attributes['department'] }}
  OR 'developer' = {{ _user_attributes['department'] }}
  OR 'admin' = {{ _user_attributes['department'] }};;

  join: stg_analytics_credit_card__receipt_ocr_itemization_analysis {
    type: left_outer
    relationship: one_to_many
    sql_on: ${procurement_purchases.purchase_id} =  ${stg_analytics_credit_card__receipt_ocr_itemization_analysis.purchase_id};;
  }

  join: stg_analytics_credit_card__receipt_ocr_itemization_fraud {
    type: left_outer
    relationship: one_to_many
    sql_on: ${stg_analytics_credit_card__receipt_ocr_itemization_analysis.purchase_id} = ${stg_analytics_credit_card__receipt_ocr_itemization_fraud.purchase_id} and ${stg_analytics_credit_card__receipt_ocr_itemization_analysis.image_url} = ${stg_analytics_credit_card__receipt_ocr_itemization_fraud.image_url};;
  }

  join: purchases {
    type: left_outer
    relationship: one_to_many
    sql_on: ${procurement_purchases.purchase_id} = ${purchases.purchase_id} ;;
  }

  join: users {
    type: left_outer
    relationship: one_to_many
    sql_on: ${purchases.user_id} = ${users.user_id} ;;
  }

  join: company_directory {
    type: left_outer
    relationship: one_to_many
    sql_on: ${users.employee_id}::varchar = ${company_directory.employee_id}::varchar ;;
  }

  join: transaction_verification {
    type: left_outer
    relationship: one_to_many
    sql_on: ${procurement_purchases.purchase_id} = ${transaction_verification.receipt_upload_id} ;;
  }
}

explore: employee_rewards_card_info {
  from: employee_rewards_card
  sql_always_where:
    lower(trim('{{ _user_attributes["email"] }}')) in ('gina.campagna@equipmentshare.com', 'sherrie@equipmentshare.com')
    or
      exists (select 1 from PAYROLL.COMPANY_DIRECTORY cd where cd.work_email ='{{ _user_attributes["email"] }}'
      and split_part(cd.default_cost_centers_full_path,'/',5) = 'Employee Experience')
    or
      lower(${company_directory.work_email}) = lower(trim('{{ _user_attributes["email"] }}')) ;;

  join: company_directory {
    type: left_outer
    relationship: one_to_many
    sql_on: ${company_directory.employee_id} = ${employee_rewards_card_info.employee_id};;
  }
}

explore: citi_card_holder {
  from: citi_card_holder
  label: "Citi Card Holder by Account and Status"
  sql_always_where:
    TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')    = 'jabbok@equipmentshare.com'
      OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'will@equipmentshare.com'
      OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'katie.cunningham@equipmentshare.com'
      OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'lisa.evans@equipmentshare.com'
      OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'gina.campagna@equipmentshare.com'
      OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'sonya.collier@equipmentshare.com'
      OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'connor.streck@equipmentshare.com'
      OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'joanna.kollmeyer@equipmentshare.com'
      OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'toni.mccrady@equipmentshare.com'
      OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'kyle.christiansen@equipmentshare.com'
      OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'sarah.cooley@equipmentshare.com'
      OR 'developer' = {{ _user_attributes['department'] }};;

  join: corporate_card_accounts {
    type: left_outer
    relationship: one_to_many
    sql_on: ${citi_card_holder.corporate_account_number}::varchar = ${corporate_card_accounts.corporate_account_number}::varchar ;;
  }

  join: company_directory {
    type: left_outer
    relationship: one_to_many
    sql_on: ${citi_card_holder.employee_id}::varchar = ${company_directory.employee_id}::varchar ;;
  }
}
