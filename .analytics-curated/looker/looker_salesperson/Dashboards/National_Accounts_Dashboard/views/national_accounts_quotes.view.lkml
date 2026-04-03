
view: national_accounts_quotes {
  derived_table: {
    sql: with assigned_national_accounts as (
                  SELECT
                    bcp.company_id,
                    c.name as company,
                    pcr.parent_company_name as parent_company,
                    COALESCE(CASE WHEN position(' ',coalesce(cd.nickname,cd.first_name)) = 0
                                   THEN concat(coalesce(cd.nickname,cd.first_name), ' ', cd.last_name)
                                   ELSE concat(coalesce(cd.nickname,concat(cd.first_name, ' ',cd.last_name))) END,
                             'Unassigned') as assigned_nam,
                    lower(cd.work_email) as nam_email,
                    CASE WHEN bcp.PREFS:general_services_administration = TRUE AND bcp.PREFS:managed_billing = TRUE THEN 'GSA, Managed Billing'
                         WHEN bcp.PREFS:general_services_administration = TRUE THEN 'GSA'
                         WHEN bcp.PREFS:managed_billing = TRUE THEN 'Managed Billing'
                         ELSE '' END as billing_preferences,
                    nca.effective_start_date
                  FROM es_warehouse.public.billing_company_preferences bcp
                  JOIN es_warehouse.public.companies c ON bcp.company_id = c.company_id
                  LEFT JOIN analytics.bi_ops.v_parent_company_relationships pcr ON c.company_id = pcr.company_id
                  LEFT JOIN analytics.commission.nam_company_assignments nca ON nca.company_id = c.company_id
                  LEFT JOIN es_warehouse.public.users u on u.user_id = nca.nam_user_id
                  LEFT JOIN analytics.payroll.company_directory cd ON lower(u.EMAIL_ADDRESS) = lower(cd.WORK_EMAIL)
                  WHERE bcp.PREFS:national_account = TRUE
                    AND (current_timestamp() BETWEEN nca.effective_start_date AND nca.effective_end_date
                         OR nca.effective_start_date IS NULL AND nca.effective_end_date IS NULL)
                    AND nam_email IS NOT NULL --only looking at companies that have an assigned nam
      )
      , quotes_info AS (
              select
                  mrx.market_name,
                  q.id as quote_id,
                  q.quote_number,
                  q.order_id,
                  q.created_date::DATE as quote_created_date,
                  q.start_date::DATE as quote_start_date,
                  q.end_date::DATE as quote_end_date,
                  q.order_created_date::DATE as order_created_date,
                  q.company_id,
                  ana.company as company_name,
                  ana.parent_company as parent_company,
                  COALESCE(si.name, concat(u.first_name, ' ', u.last_name)) as sp_on_quote,
                  q.sales_rep_id as sp_user_id_on_quote,
                  COALESCE(si.home_market_dated, CASE WHEN si.district_dated IS NULL THEN NULL ELSE concat('District ', si.district_dated) END, si.region_name_dated) as sp_on_quote_home,
                  ana.assigned_nam,
                  ana.nam_email,

                  q.missed_rental_reason as missed_quote_reason,
                  q.missed_rental_reason_other as missed_quote_reason_other,
                  coalesce(equipment_class_name,concat('Bulk Item - ',et.part_id)) AS full_equipment_name,
                  et.day_rate,
                  et.week_rate,
                  et.four_week_rate,
                  coalesce(cat.SINGULAR_NAME,'Bulk Items') AS category,
      --            CASE WHEN
      --            COALESCE(CONVERT_TIMEZONE('America/Chicago', q.order_created_date)::DATE, CONVERT_TIMEZONE( 'America/Chicago', q.created_date)::DATE)
      --                    >= dateadd(day, '-30', CONVERT_TIMEZONE('America/Chicago', current_date))::DATE
      --                AND COALESCE(CONVERT_TIMEZONE('America/Chicago', q.order_created_date)::DATE, CONVERT_TIMEZONE('America/Chicago', q.created_date)::DATE)
      --                    <=  CONVERT_TIMEZONE('America/Chicago', current_timestamp)::DATE
      --                      THEN 'Current'
      --            WHEN COALESCE(CONVERT_TIMEZONE('America/Chicago', q.order_created_date)::DATE, CONVERT_TIMEZONE( 'America/Chicago', q.created_date)::DATE) >= dateadd(day, '-60', CONVERT_TIMEZONE('America/Chicago', current_timestamp))::DATE AND COALESCE(CONVERT_TIMEZONE('America/Chicago', q.order_created_date)::DATE, CONVERT_TIMEZONE('America/Chicago', q.created_date)::DATE) <= dateadd(day, '-31', CONVERT_TIMEZONE( 'America/Chicago', current_timestamp))::DATE
      --                      THEN 'Previous'
      --            END AS timeframe,
                  q.expiry_date::DATE as expiration_date,
                  qp.rental_subtotal as quote_rental_subtotal,
                  q.location_description,
                  mrx.district,
                  mrx.region,
                  mrx.region_name,
                   q.escalation_id,
                   e.MESSAGE as escalation_message,
                   e.CREATED_AT as escalation_create_date,
                   e.USER_NAME as escalation_created_by,
                  q.LAST_MODIFIED_DATE::DATE as last_modified_date,
                   CASE WHEN missed_rental_reason IS NOT NULL OR missed_rental_reason_other IS NOT NULL
                          --THEN CONVERT_TIMEZONE('UTC', 'America/Chicago', q.LAST_MODIFIED_DATE)::DATE
                          THEN q.LAST_MODIFIED_DATE::DATE
                          --- Assuming they will not touch the quote after it's missed
                        WHEN q.order_id IS NOT NULL
                         -- THEN CONVERT_TIMEZONE('UTC', 'America/Chicago', q.order_created_date)::DATE
                        THEN q.order_created_date::DATE
                        ELSE expiration_date END AS current_status,
                   CASE WHEN q.escalation_id IS NOT NULL AND order_id IS NULL
                     -- THEN datediff(day, CONVERT_TIMEZONE('UTC', 'America/Chicago', e.CREATED_AT)::DATE, current_status)
                        THEN datediff(day,  e.CREATED_AT::DATE, current_status)
                      ELSE null END as days_escalated,

                   CASE WHEN order_id IS NOT NULL
                          THEN 'Order Created'
                        WHEN missed_quote_reason IS NOT NULL OR missed_quote_reason_other IS NOT NULL
                          THEN 'Missed Quote'
                        WHEN  DATE_TRUNC(day, EXPIRATION_DATE) <= current_date()
                          THEN 'Expired'
                         WHEN q.escalation_id IS NOT NULL
                          THEN 'Escalated'
                        ELSE 'Open' END as path

              FROM quotes.quotes.quote AS q
              JOIN assigned_national_accounts ana ON q.company_id = ana.company_id
              LEFT JOIN QUOTES.QUOTES.EQUIPMENT_TYPE et ON q.ID = et.QUOTE_ID
              LEFT JOIN ES_WAREHOUSE.PUBLIC.EQUIPMENT_CLASSES ec  ON et.EQUIPMENT_CLASS_ID = ec.EQUIPMENT_CLASS_ID
              LEFT JOIN ES_WAREHOUSE.PUBLIC.CATEGORIES cat ON ec.CATEGORY_ID = cat.CATEGORY_ID
              LEFT JOIN ANALYTICS.PUBLIC.MARKET_REGION_XWALK AS mrx ON q.branch_id = mrx.MARKET_ID
              LEFT JOIN ES_WAREHOUSE.PUBLIC.COMPANIES AS c ON c.COMPANY_ID = q.company_id
              LEFT JOIN ES_WAREHOUSE.PUBLIC.USERS AS u ON u.USER_ID = q.sales_rep_id
              LEFT JOIN analytics.bi_ops.salesperson_info si ON q.sales_rep_id = si.user_id and record_ineffective_date IS NULL

              LEFT JOIN quotes.quotes.quote_pricing qp ON q.ID = qp.QUOTE_ID

              LEFT JOIN quotes.quotes.escalations e on q.ESCALATION_ID = e.ESCALATION_ID

            WHERE q.created_date::DATE >= dateadd(day, '-60', current_date())

            )


            select
             qi.*,con.concatenated_equipment_category
            from quotes_info qi
            left join (select quote_number, quote_created_date, LISTAGG(category, ', ') WITHIN GROUP (ORDER BY category) AS concatenated_equipment_category
                        FROM quotes_info
                        GROUP BY quote_number,quote_created_date)
                            con ON con.quote_number = qi.quote_number and con.quote_created_date = qi.quote_created_date
            WHERE ({{ _user_attributes['job_role'] }} = 'nam' AND lower(nam_email) = '{{ _user_attributes['email'] }}')
               -- Hardcode for Jessica to only see Tyler Levin's accounts
               OR ('{{ _user_attributes['email'] }}' = 'jessica.howard@equipmentshare.com' AND lower(nam_email) = 'tyler.levins@equipmentshare.com')
              OR ('{{ _user_attributes['email'] }}' <> 'jessica.howard@equipmentshare.com' AND {{ _user_attributes['job_role'] }} <> 'nam') ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: market_name {
    group_label: "Quote Location"
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: quote_id {
    type: string
    sql: ${TABLE}."QUOTE_ID" ;;
  }

  dimension: quote_number {
    type: number
    sql: ${TABLE}."QUOTE_NUMBER" ;;
    value_format_name: id

  }

  measure: quotes_created_count {
    type: count_distinct
    sql: ${quote_id} ;;
    drill_fields: [quote_detail_managers*]
  }

  measure: quotes_created_count_customers {
    type: count_distinct
    sql: ${quote_id} ;;
    drill_fields: [quote_detail_customers*]
  }

  dimension: order_id {
    type: string
    sql: ${TABLE}."ORDER_ID" ;;
  }

  dimension_group: quote_created_date {
    label: "Quote Created"
    type: time
    timeframes: [date, month, month_name, quarter, year]
    sql: ${TABLE}."QUOTE_CREATED_DATE" ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
  }

  dimension_group: quote_start_date {
    type: time
    timeframes: [date, month, month_name, quarter, year]
    sql: ${TABLE}."QUOTE_START_DATE" ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
  }

  dimension_group: quote_end_date {
    type: time
    timeframes: [date, month, month_name, quarter, year]

    sql: ${TABLE}."QUOTE_END_DATE" ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
  }

  dimension_group: order_created_date {
    type: time
    timeframes: [date, month, month_name, quarter, year]
    sql: ${TABLE}."ORDER_CREATED_DATE" ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
  }

  dimension: company_id {
    type: string
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
    html: <img src="https://cdn-icons-png.flaticon.com/512/63/63811.png" title="National Account" height="15" width="15"> <font color="#000000"> {{rendered_value}}
    <br />
    <font style="color: #8C8C8C; text-align: right;">ID: {{company_id._rendered_value}}</font>
    </font>  ;;
  }

  dimension: company_name_man_dash {
    group_label: "Managers Dash"
    label: "Company Name"
    type: string
    sql: ${company_name};;
    html: <img src="https://cdn-icons-png.flaticon.com/512/63/63811.png" title="National Account" height="15" width="15">
          <a href="https://equipmentshare.looker.com/dashboards/1556?Company={{company_name._filterable_value}}&Parent+Company=&Single-Line+Charts+Time+Frame=%5E-90"target="_blank"><font color="#0063f3"> {{rendered_value}}
          <br />
          <font style="color: #8C8C8C; text-align: right;">ID: {{company_id._rendered_value}}</font>
          </font>  ;;
  }


  dimension: parent_company {
    type: string
    sql: ${TABLE}."PARENT_COMPANY" ;;
  }



  dimension: sp_user_id_on_quote {
    type: string
    sql: ${TABLE}."SP_USER_ID_ON_QUOTE" ;;
  }

  dimension: sp_on_quote_home {
    type: string
    sql: ${TABLE}."SP_ON_QUOTE_HOME" ;;
  }

  dimension: sp_on_quote {
    type: string
    label: "Rep On Quote"
    sql: ${TABLE}."SP_ON_QUOTE" ;;
    html: <font color="#000000"> {{rendered_value}}
          <br />
          <font style="color: #8C8C8C; text-align: right;">User ID: {{sp_user_id_on_quote._rendered_value}}</font>
          </font>  ;;
  }

  dimension: assigned_nam {
    type: string
    label: "Assigned NAM"
    sql: ${TABLE}."ASSIGNED_NAM" ;;
  }

  dimension: assigned_nam_co_dash {
    type: string
    group_label: "Customers Dash"
    label: "Assigned NAM"
    sql: ${assigned_nam} ;;
    html: <font color="#0063f3"><a href="https://equipmentshare.looker.com/dashboards/1527?National+Account+Manager={{assigned_nam._filterable_value}}&Single-Line+Charts+Time+Frame=%5E-90"target="_blank">
    {{rendered_value}} ➔</a>
 ;;
  }

  dimension: nam_email {
    type: string
    sql: ${TABLE}."NAM_EMAIL" ;;
  }

  dimension: missed_quote_reason {
    group_label: "Missed Quote"
    type: string
    sql: ${TABLE}."MISSED_QUOTE_REASON" ;;
  }

  dimension: missed_quote_reason_other {
    group_label: "Missed Quote"
    type: string
    sql: ${TABLE}."MISSED_QUOTE_REASON_OTHER" ;;
  }

  dimension: missed_quote_reasoning {
    group_label: "Missed Quote"
    type:  string
    sql:  CASE WHEN ${missed_quote_reason} ILIKE '%other%' OR ${missed_quote_reason} IS NULL then ${missed_quote_reason_other} ELSE ${missed_quote_reason} END  ;;
  }

  dimension: full_equipment_name {
    group_label: "Equipment Info"
    type: string
    sql: ${TABLE}."FULL_EQUIPMENT_NAME" ;;
  }

  dimension: day_rate {
    group_label: "Rates"
    type: number
    sql: ${TABLE}."DAY_RATE" ;;
    value_format_name: usd_0
  }

  dimension: week_rate {
    group_label: "Rates"
    type: number
    sql: ${TABLE}."WEEK_RATE" ;;
    value_format_name: usd_0

  }

  dimension: four_week_rate {
    group_label: "Rates"
    type: number
    sql: ${TABLE}."FOUR_WEEK_RATE" ;;
    value_format_name: usd_0

  }

  dimension: category {
    group_label: "Equipment Info"
    label: "Equipment Category"
    type: string
    sql: ${TABLE}."CATEGORY" ;;
  }

  dimension: concatenated_equipment_category {
    group_label: "Equipment Info"
    label: "Equipment Categories"
    type:  string
    sql: ${TABLE}."CONCATENATED_EQUIPMENT_CATEGORY" ;;
    description: "List of equipment categories to include information about what is in a quote without expanding the grain when we only have rental subtotal of entire quote."
  }

  dimension_group: expiration_date {
    type: time
    sql: ${TABLE}."EXPIRATION_DATE" ;;
    timeframes: [date, month, month_name, quarter, year]
    html: {{ rendered_value | date: "%b %d, %Y" }};;
  }

  dimension: quote_rental_subtotal {
    type: number
    sql: ${TABLE}."QUOTE_RENTAL_SUBTOTAL" ;;
    value_format_name: usd_0

  }

  dimension: location_description {

    type: string
    sql: ${TABLE}."LOCATION_DESCRIPTION" ;;
  }

  dimension: district {
    group_label: "Quote Location"
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: region {
    group_label: "Quote Location"
    type: string
    sql: ${TABLE}."REGION" ;;
  }

  dimension: region_name {
    group_label: "Quote Location"
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension: escalation_id {
    group_label: "Escalation"
    type: string
    sql: ${TABLE}."ESCALATION_ID" ;;
  }

  dimension: escalation_message {
    type: string
    group_label: "Escalation"
    sql: ${TABLE}."ESCALATION_MESSAGE" ;;
  }

  dimension_group: escalation_create_date {
    type: time
    group_label: "Escalation"
    sql: ${TABLE}."ESCALATION_CREATE_DATE" ;;
    timeframes: [date, month, month_name, quarter, year]
    html: {{ rendered_value | date: "%b %d, %Y" }};;
  }

  dimension: escalation_created_by {
    type: string
    group_label: "Escalation"
    sql: ${TABLE}."ESCALATION_CREATED_BY" ;;
  }

  dimension_group: last_modified_date {
    type: time
    timeframes: [date, month, month_name, quarter, year]
    sql: ${TABLE}."LAST_MODIFIED_DATE" ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
  }

  dimension_group: current_status {
    type: time
    sql: ${TABLE}."CURRENT_STATUS" ;;
    timeframes: [date, month, month_name, quarter, year]
  }

  dimension: days_escalated {
    type: number
    group_label: "Escalation"
    sql: ${TABLE}."DAYS_ESCALATED" ;;
  }

  dimension: path {
    type: string
    label: "Quote Status"
    sql: ${TABLE}."PATH";;
    html:
      {% if rendered_value == 'Order Created' %}
       <font color="#4a6f8c">
       <strong>{{ rendered_value }}</strong>
    <br />
    <font style="color: #8C8C8C; text-align: right;">Order ID: {{order_id._rendered_value}}</font>
    </font>

     {% elsif rendered_value == 'Escalated' %}
    <font color="#a57cc6">
     <strong>{{ rendered_value }}</strong>
    <br />
    <font style="color: #8C8C8C; text-align: right;">As of {{escalation_create_date_date._rendered_value| date: "%b %d, %Y" }}</font>
    </font>

    {% elsif rendered_value == 'Missed Quote' %}
    <font color="#d1b13a">
     <strong>{{ rendered_value }}</strong>
    <br />
    <font style="color: #8C8C8C; text-align: right;">{{missed_quote_reasoning._rendered_value}}</font>
    </font>

    {% elsif rendered_value == 'Expired' %}
    <font color="#DA344D">
     <strong>{{ rendered_value }}</strong>

    {% else %}
    <font color="#007747">
     <strong>{{ rendered_value }}</strong>

    {% endif %};;
  }

  dimension: is_order {
    type: yesno
    sql: CASE WHEN ${path} ilike 'order created' THEN TRUE ELSE FALSE END   ;;
  }
  dimension: is_open {
    type: yesno
    sql: CASE WHEN ${path} ilike 'open' THEN TRUE ELSE FALSE END   ;;
  }
  dimension: is_missed {
    type: yesno
    sql: CASE WHEN ${path} ilike 'missed quote' THEN TRUE ELSE FALSE END   ;;
  }


  measure: count_orders {
      type:count_distinct
    group_label: "Customers Dash"

      label: "Total Orders"
      sql: ${quote_id};;
      filters: [is_order: "TRUE"]
      drill_fields: [quote_detail_customers*]
    }
  measure: count_open {
    type:count_distinct
    group_label: "Customers Dash"

    label: "Total Open Quotes"
    sql: ${quote_id};;
    filters: [is_open: "TRUE"]
    drill_fields: [quote_detail_customers*]
  }
  measure: count_missed {
    type:count_distinct
    group_label: "Customers Dash"

    label: "Total Missed Quotes"
    sql: ${quote_id};;
    filters: [is_missed: "TRUE"]
    drill_fields: [quote_detail_customers*]
  }

  measure: count_orders_man {
    type:count_distinct
    group_label: "Managers Dash"
    label: "Total Orders"
    sql: ${quote_id};;
    filters: [is_order: "TRUE"]
    drill_fields: [quote_detail_managers*]
  }
  measure: count_open_man {
    type:count_distinct
    group_label: "Managers Dash"

    label: "Total Open Quotes"
    sql: ${quote_id};;
    filters: [is_open: "TRUE"]
    drill_fields: [quote_detail_managers*]
  }
  measure: count_missed_man {
    type:count_distinct
    group_label: "Managers Dash"

    label: "Total Missed Quotes"
    sql: ${quote_id};;
    filters: [is_missed: "TRUE"]
    drill_fields: [quote_detail_managers*]
  }




  set: detail {
    fields: [
        market_name,
  quote_id,
  quote_number,
  order_id,
  quote_created_date_date,
  quote_start_date_date,
  quote_end_date_date,
  order_created_date_date,
  company_id,
  company_name,
  parent_company,
  sp_on_quote,
  sp_user_id_on_quote,
  sp_on_quote_home,
  assigned_nam,
  nam_email,
  missed_quote_reason,
  missed_quote_reason_other,
  full_equipment_name,
  day_rate,
  week_rate,
  four_week_rate,
  category,
  expiration_date_date,
  quote_rental_subtotal,
  location_description,
  district,
  region,
  region_name,
  escalation_id,
  escalation_message,
  escalation_create_date_date,
  escalation_created_by,
  last_modified_date_date,
  current_status_date,
  days_escalated,
  path
    ]
  }

  set: quote_detail_managers {
    fields: [
      company_name_man_dash,
      quote_created_date_date,
      quote_number,
      concatenated_equipment_category,
      sp_on_quote,
      assigned_nam,
      path,
      quote_rental_subtotal
    ]
}

  set: quote_detail_customers {
    fields: [
      company_name,
      quote_created_date_date,
      quote_number,
      concatenated_equipment_category,
      sp_on_quote,
      assigned_nam_co_dash,
      path,
      quote_rental_subtotal
    ]
  }

  set: quote_number_detail {
    fields: [
      quote_number,
      quote_created_date_date,
      company_name,
      parent_company,
      sp_on_quote,
      assigned_nam,
      path,
      category,
      full_equipment_name,
      quote_rental_subtotal
    ]
  }
}
