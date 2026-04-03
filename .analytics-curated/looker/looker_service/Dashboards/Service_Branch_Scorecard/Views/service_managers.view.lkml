include: "/Dashboards/Service_Branch_Scorecard/Views/ee_company_directory_12_month_aggregate.view"

  view: service_managers {
    derived_table: {
      sql:
SELECT
    employee_title,
    market_id as branch_id,
    concat(first_name, ' ', Last_name) as service_manager,
    DATEDIFF('months', POSITION_EFFECTIVE_DATE, current_date()) as months_in_role,
    DISC_CODE,
      CONCAT('http://www.discoveryreport.com/v/', DISC_CODE) as service_manager_url_disc
         FROM ${ee_company_directory_12_month_aggregate.SQL_TABLE_NAME}
WHERE DATE_TRUNC('month', CURRENT_DATE()) = DATE_TRUNC('month', _es_update_timestamp)
AND employee_status ilike any ('Active', 'External Payroll', 'Leave with Pay', 'Leave withoutout Pay', 'Work Comp Leave')
and employee_title ilike any ('%Service Manager%')
AND employee_id is not null
and _es_update_timestamp is not null
QUALIFY ROW_NUMBER() OVER(PARTITION BY market_id ORDER BY POSITION_EFFECTIVE_DATE desc) = 1 -- qualifier to get the most recent service manager
;;
    }




    dimension: employee_title {
      type: string
      sql: ${TABLE}.employee_title ;;  # Ensure it exists in the extended view
    }

    dimension: branch_id {
      type: string
      primary_key: yes
      sql: ${TABLE}.branch_id ;;  # Ensure it exists in the extended view
    }

    # dimension: service_manager {
    #   type: string
    #   sql: ${TABLE}.service_manager ;;  # Ensure it exists in the extended view
    # }

    dimension: months_in_role {
      type: number
      sql: ${TABLE}.months_in_role ;;  # Ensure it exists in the extended view
    }



    dimension: disc_code {
      type: string
      sql: ${TABLE}."DISC_CODE" ;;
    }

    # dimension: service_manager_url_greenhouse {
    #   type: string
    #   sql: ${TABLE}."GENERAL_MANAGER_URL_GREENHOUSE" ;;
    # }

    dimension: service_manager_url_disc {
      type: string
      sql: ${TABLE}.service_manager_url_disc ;;
    }

    dimension: service_manager_name {
      type: string
      label: "Service Manager"
      sql: ${TABLE}.service_manager ;;
      # link: {
      #   label: "Greenhouse Profile"
      #   url: "{{ service_manager_url_greenhouse }}"
      # }
      link: {
        label: "DISC Profile ({{ disc_code }})"
        url: "{{ service_manager_url_disc }}"
      }
      html: <span title={{value}}>{{linked_value}}</span> ;;
    }

  }
