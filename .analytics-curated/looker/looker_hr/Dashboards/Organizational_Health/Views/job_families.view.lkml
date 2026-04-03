view: job_families {
  derived_table: {
    sql:
SELECT key_ops_jobs From ( Values ('General Managers'),('Drivers (CDL)'),('Field Technicians'),('Territory Account Managers'),('Telematics Installers'),('Shop Technicians'),('Yard Technicians'),('Rental Coordinators'),('Service Managers'),('Parts Managers and Assistants')) as v1 (key_ops_jobs);;
  }


  dimension: key_ops_jobs {
    primary_key: yes
    type: string
    sql: ${TABLE}."KEY_OPS_JOBS";;
  }


  measure: count {
    type: count
    drill_fields: []
  }


  measure: staff_needed {
    type: sum
    drill_fields: []
    sql:    case
  when ${job_families.key_ops_jobs} = 'Drivers (CDL)'  THEN 2
  when ${job_families.key_ops_jobs} = 'Field Technicians'  THEN 2
  when ${job_families.key_ops_jobs} = 'Rental Coordinators'  THEN 1
  when ${job_families.key_ops_jobs} = 'Shop Technicians'  THEN 2
  when ${job_families.key_ops_jobs} = 'Parts Managers and Assistants' THEN 1
  when ${job_families.key_ops_jobs} = 'Yard Technicians' THEN 1
  when ${job_families.key_ops_jobs} = 'Territory Account Managers' THEN 2
  when ${job_families.key_ops_jobs} = 'General Managers' THEN 1
  when ${job_families.key_ops_jobs} = 'Service Managers' THEN 1
  ELSE 0
  END ;;
  }



}
