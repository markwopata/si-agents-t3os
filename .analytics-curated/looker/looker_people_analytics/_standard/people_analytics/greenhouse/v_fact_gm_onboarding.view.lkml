view: v_fact_gm_onboarding {
  sql_table_name:  "PEOPLE_ANALYTICS"."LOOKER"."GM_ONBOARDING_DATA" ;;

  dimension: gm_name {
    type: string
    sql: ${TABLE}."GM_NAME" ;;
  }

  dimension: gm_email {
    type: string
    sql: ${TABLE}."GM_EMAIL" ;;
  }

  dimension: dm_email {
    type: string
    sql: ${TABLE}."DM_EMAIL" ;;
  }

  dimension: termed_first_year {
    type: string
    sql: ${TABLE}."TERMED_FIRST_YEAR" ;;
  }

  dimension: int_ext {
    type: string
    sql: ${TABLE}."INT_EXT" ;;
  }

  dimension: start_date {
    type: date
    sql: ${TABLE}."START_DATE" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: week_in_training {
    type: string
    sql: ${TABLE}."WEEK_IN_TRAINING" ;;
  }

  dimension: market_type {
    type: string
    sql: ${TABLE}."MARKET_TYPE" ;;
  }

  dimension: completion_date {
    type: date
    sql: ${TABLE}."COMPLETION_DATE" ;;
  }

  dimension: dm_email_sent {
    type: string
    sql: ${TABLE}."DM_EMAIL_SENT" ;;
  }

  dimension: reminder_email_sent {
    type: string
    sql: ${TABLE}."REMINDER_EMAIL_SENT" ;;
  }

  dimension: onboarding_group {
    type: string
    sql: ${TABLE}."ONBOARDING_GROUP" ;;
  }

  dimension: onboarding_group_badge {
    type: string
    sql: ${onboarding_group} ;;

    html:
    {% assign val = value %}
    {% assign v = val | strip | downcase %}

      {% if v == "completed" %}
      <span style="background-color:#2E7D32; color:white; padding:4px 8px; border-radius:6px; font-weight:600;">{{ val }}</span>

      {% elsif v contains "8 week training completed" %}
      <span style="background-color:#4CAF50; color:white; padding:4px 8px; border-radius:6px; font-weight:600;">{{ val }}</span>

      {% elsif v == "did not complete onboarding" %}
      <span style="background-color:#C62828; color:white; padding:4px 8px; border-radius:6px; font-weight:600;">{{ val }}</span>

      {% elsif v == "completed / termed in first 12 months" %}
      <span style="background-color:#DC4D01; color:white; padding:4px 8px; border-radius:6px; font-weight:600;">{{ val }}</span>

      {% elsif v == "pre start date" %}
      <span style="background-color:#9E9E9E; color:white; padding:4px 8px; border-radius:6px;">{{ val }}</span>

      {% elsif v == "week 1" %}
      <span style="background-color:#BBDEFB; color:#0D47A1; padding:4px 8px; border-radius:6px;">{{ val }}</span>

      {% elsif v == "week 2" %}
      <span style="background-color:#90CAF9; color:#0D47A1; padding:4px 8px; border-radius:6px;">{{ val }}</span>

      {% elsif v == "week 3" %}
      <span style="background-color:#64B5F6; color:white; padding:4px 8px; border-radius:6px;">{{ val }}</span>

      {% elsif v == "week 4" %}
      <span style="background-color:#42A5F5; color:white; padding:4px 8px; border-radius:6px;">{{ val }}</span>

      {% elsif v == "week 5" %}
      <span style="background-color:#1E88E5; color:white; padding:4px 8px; border-radius:6px;">{{ val }}</span>

      {% elsif v == "week 6" %}
      <span style="background-color:#1976D2; color:white; padding:4px 8px; border-radius:6px;">{{ val }}</span>

      {% elsif v == "week 7" %}
      <span style="background-color:#1565C0; color:white; padding:4px 8px; border-radius:6px;">{{ val }}</span>

      {% elsif v == "week 8" %}
      <span style="background-color:#0D47A1; color:white; padding:4px 8px; border-radius:6px;">{{ val }}</span>

      {% else %}
      {{ val }}
      {% endif %} ;;
  }

  dimension: week_in_training_order {
    type: number
    hidden: no
    sql:
    CASE
      WHEN LOWER(TRIM(${onboarding_group})) = 'pre start date' THEN 0
      WHEN LOWER(TRIM(${onboarding_group})) = 'week 1' THEN 1
      WHEN LOWER(TRIM(${onboarding_group})) = 'week 2' THEN 2
      WHEN LOWER(TRIM(${onboarding_group})) = 'week 3' THEN 3
      WHEN LOWER(TRIM(${onboarding_group})) = 'week 4' THEN 4
      WHEN LOWER(TRIM(${onboarding_group})) = 'week 5' THEN 5
      WHEN LOWER(TRIM(${onboarding_group})) = 'week 6' THEN 6
      WHEN LOWER(TRIM(${onboarding_group})) = 'week 7' THEN 7
      WHEN LOWER(TRIM(${onboarding_group})) = 'week 8' THEN 8
      WHEN LOWER(TRIM(${onboarding_group})) LIKE '%8 week training completed%' THEN 9
      WHEN LOWER(TRIM(${onboarding_group})) = 'completed' THEN 10
      WHEN LOWER(TRIM(${onboarding_group})) LIKE 'completed / termed in first 12 months' THEN 11
      WHEN LOWER(TRIM(${onboarding_group})) = 'did not complete onboarding' THEN 12
      ELSE 99
    END ;;
  }

  }
