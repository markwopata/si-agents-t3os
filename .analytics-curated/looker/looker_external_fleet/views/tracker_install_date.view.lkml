view: tracker_install_date {

  derived_table: {

    sql: select distinct ata.asset_id, ata.tracker_id, ata.date_installed
            from asset_tracker_assignments ata
            where ata.date_uninstalled is null
            QUALIFY ROW_NUMBER() OVER (PARTITION BY ata.asset_id ORDER BY ata.asset_id, ata.date_installed desc) = 1
    ;;
    }

  dimension: asset_id {
    type: string
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: tracker_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."TRACKER_ID" ;;
  }

  dimension: last_tracker_install_date {
    label: "Tracker Install Date"
    type: date
    sql: ${TABLE}."DATE_INSTALLED" ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
  }

  }
