view: work_order_updates_with_pictures {
  derived_table: {
    sql: select
        won.work_order_id,
        won.date_created,
        'note' as type,
        note,
        concat(u.first_name,' ',u.last_name) as full_name
    from
        work_orders.work_order_notes won
        left join users u on won.creator_user_id = u.user_id
    union
    select
        wof.work_order_id,
        wof.date_created,
        'picture' as type,
        case
            when YEAR(wof.date_created) <= 2020 AND substr(url, 0, 16) = 'work_order_files' then concat('https://appcdn.equipmentshare.com/uploads/',url)
            when (YEAR(wof.date_created) = 2021 AND MONTH(wof.date_created) = 1) AND substr(url, 0, 16) = 'work_order_files' then concat('https://appcdn.equipmentshare.com/uploads/',url)
            when substr(url, 0, 16) = 'work_order_files' then concat('https://static.estrack.com/upload/200/200/',url)
            else url
            end as url,
        concat(u.first_name,' ',u.last_name) as full_name
    from
       work_orders.work_order_files wof
       left join users u on wof.created_by = u.user_id
    where
      date_deleted is null
 ;;
  }

  # case
  #           when YEAR(wof.date_created) <= 2020 AND substr(url, 0, 16) = 'work_order_files' then concat('https://appcdn.equipmentshare.com/uploads/',url)
  #           when (YEAR(wof.date_created) = 2021 AND MONTH(wof.date_created) = 1) AND substr(url, 0, 16) = 'work_order_files' then concat('https://appcdn.equipmentshare.com/uploads/',url)
  #           when substr(url, 0, 16) = 'work_order_files' then concat('https://appcdn.equipmentshare.com/uploads/small',url)
  #           else url
  #           end as url,

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: work_order_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_ID" ;;
  }

  dimension_group: date_created {
    type: time
    sql: ${TABLE}."DATE_CREATED" ;;
  }

  dimension: type {
    type: string
    sql: ${TABLE}."TYPE" ;;
  }

  dimension: note {
    type: string
    sql: ${TABLE}."NOTE" ;;
  }

  dimension: full_name {
    type: string
    sql: ${TABLE}."FULL_NAME" ;;
  }

  dimension: picture_embed {
    type: string
    sql: ${note} ;;
    html: <img src="{{value}}" width="100" height="100"/> ;;
  }

  dimension: date_created_time_html {
    group_label: "HTML Formatted Date Time"
    # sql: convert_timezone('{{ _user_attributes['user_timezone'] }}',${date_created_raw}) ;;
    sql: convert_timezone('America/Chicago',${date_created_raw}) ;;
    html: {{ rendered_value | date: "%b %d %y, %r"  }} {{ _user_attributes['user_timezone_label'] }} ;;
  }

  dimension: show_note {
    type: string
    sql: ${note} ;;
    html:
    {% if type._value == "picture" %}
    <img src="{{value}}" width="100" height="100"/>
    {% else %}
    {{value}}
    {% endif %} ;;
  }

  set: detail {
    fields: [date_created_time, type, note, full_name]
  }
}
