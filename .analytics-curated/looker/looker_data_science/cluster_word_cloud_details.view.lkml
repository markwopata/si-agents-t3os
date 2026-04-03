view: cluster_word_cloud_details {
  derived_table: {
    sql: select dk.ID, m.text, dk."cluster_id"
      from DATA_SCIENCE.DS_SCRATCH_NOT_FOR_PROD.MIKE_VOC_CLUSTERING_OUTPUT_DATA_LABELS dk
          join analytics.front.message m on (m.id = dk.ID)
       ;;
  }

  dimension: id {
    type: string
    sql: ${TABLE}.ID ;;
  }

  dimension: cluster_id {
    type: number
    sql: ${TABLE}."cluster_id" ;;
  }

  dimension: message_text {
    type: string
    sql: ${TABLE}.text ;;
  }

  set: detail {
    fields: [id, message_text]
  }
}
