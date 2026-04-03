include: "/_base/analytics/payroll/company_directory.view.lkml"

view: +company_directory {
  label: "Company Directroy"

  dimension: is_manager {
    type: yesno
    sql: ${employee_title} in ('General Manager','General Manager - Advanced Solutions','National Account Manager','Territory Account Manager','District Sales Manager','District Manager','District Operations Manager','Fleet Manager','Retail Account Manager','Sales Manager','Regional Sales Manager','Regional Operations Director','Regional Operations Director - Advanced Solutions','Regional Sales Director','Regional Service Manager','Regional Vice President','Vice President of Sales') ;;
  }

  dimension: is_technicians {
    type: yesno
    sql: ${employee_title} in ('Field Mechanic','Field Mechanic A','Field Mechanic I','Field Mechanic II','Field Mechanic III','Field Technician','Field Technician I','Field Technician II','Field Technician III','Field Technician IV','Lead/Road Mechanic','Road Mechanic','Service Technician - Field','Service Technician - Lube Truck','Telematics Mechanic','Traveling Technician') ;;
  }

  dimension: is_delivery_driver {
    type: yesno
    sql: ${employee_title} ilike any ('%delivery%','%driver%','%cdl%','%tractor%') ;;
  }

  dimension: is_telematics_installers {
    type: yesno
    sql: ${employee_title} ilike '%Installer%' ;;
  }

  measure: managers {
    type: count_distinct
    sql: ${employee_id} ;;
    filters: [is_manager: "YES",employee_status: "Active"]
    value_format_name: decimal_0
  }

  measure: technicians {
    type: count_distinct
    sql: ${employee_id} ;;
    filters: [is_technicians: "YES",employee_status: "Active"]
    value_format_name: decimal_0
  }

  measure: delivery_drivers {
    type: count_distinct
    sql: ${employee_id} ;;
    filters: [is_delivery_driver: "YES",employee_status: "Active"]
    value_format_name: decimal_0
  }

  measure: telematics_installers {
    type: count_distinct
    sql: ${employee_id} ;;
    filters: [is_telematics_installers: "YES",employee_status: "Active"]
    value_format_name: decimal_0
  }
}
