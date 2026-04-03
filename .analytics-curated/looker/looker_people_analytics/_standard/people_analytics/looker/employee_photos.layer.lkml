include: "/_base/people_analytics/looker/employee_photos.view.lkml"

view: +employee_photos {

  dimension: image {
    type: string
    sql: ${TABLE}.attachment_content ;;
    html:<p> <img src="data:image/jpeg;base64,{{attachment_content._value}}" style="max-width: 50%; max-height: 50%"> </p>;;
  }

  }
