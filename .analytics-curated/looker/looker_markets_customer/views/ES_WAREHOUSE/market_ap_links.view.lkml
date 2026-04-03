#
# View to extend markets to be used to generate links for emailing contact list for PO Warnings. Requires
# joins to both districts and regions in the explore.
#
# https://app.shortcut.com/businessanalytics/story/144363/concur-ba-to-build-looker-contact-list-for-ap
#

include: "/views/ES_WAREHOUSE/markets.view"

view: market_ap_links {
  extends: [markets]


  dimension: first_recipients {
    sql: CONCAT(COALESCE(${sales_email}, ''), ', ', COALESCE(${service_email},''), ', ', COALESCE(${districts.sales_manager_email},''), ', ', COALESCE(${districts.service_manager_email}, ''));;
  }

  dimension: final_recipients {
    sql: CONCAT(${first_recipients}, ', ', COALESCE(${districts.manager_email}, ''), ', ', COALESCE(${regions.manager_email}, '')) ;;
  }
  #backup google url for mailto
  #"https://mail.google.com/mail/u/0/?view=cm&fs=1&tf=1&to={{value}}&su=Initial%20Warning%20-%20PO%20Needs%20Receipt"
  dimension: first_warning_email {
    sql: ${first_recipients} ;;
    html: <a target="new" href=  "https://app.frontapp.com/compose?mailto=mailto:{{value}}&subject=Initial%20Warning%20-%20PO%20Needs%20Receipt"><button>Send First Warning</button></a>;;
  }

  dimension: final_warning_email {
    sql: ${final_recipients} ;;
    html: <a target="new" href= "https://app.frontapp.com/compose?mailto=mailto:{{value}}&subject=Final%20Warning%20-%20PO%20Needs%20Receipt"><button>Send Final Warning</button></a>;;
  }

 }
