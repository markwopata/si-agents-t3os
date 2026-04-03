
view: interactions_by_day {
  derived_table: {
    sql: with intercom as (
select
'Intercom' as contact_type
, conversation_updated_at::date as contact_date
,
case
when name = 'Keypads**' then 'Keycodes/Keypads'
when name = 'Parts &amp; Inventory' then 'Parts & Inventory'
when name = 'Tracker Troubleshooting**' then 'Tracker Troubleshooting'
when name = 'added equipment' then 'Fleet'
when name = 'credit' then 'Billing'
when name = 'geofence' then 'Fleet'
when name = 'gps' then 'Fleet'
when name = 'invoice, statement' then 'Billing'
when name = 'keypad' then 'Keycodes/Keypads'
when name = 'login' then 'Login'
when name = 'mileage' then 'Fleet'
when name = 'pay bill' then 'Billing'
when name = 'tracker number' then 'Fleet'
when name = 'user' then 'New user/access level'
else name end as contact_disposition
--, coalesce(name, 'Unknown Disposition') as contact_disposition
, count(id) as total_contacts
from
ANALYTICS.INTERCOM.CONVERSATION_TAG_HISTORY th
left join ANALYTICS.INTERCOM.TAG t on (t.id = th.tag_id)
group by
contact_type
, contact_date
, contact_disposition
)
, cxone as (
select
'CXONE' as contact_type
, contact_start::date as contact_date
--, coalesce(team_name, 'Unknown Disposition') as contact_disposition
,
case
when disposition_notes = '1st Attempt' then 'Unknown Disposition'
when disposition_notes = '2nd Attempt' then 'Unknown Disposition'
when disposition_notes = '3rd Attempt' then 'Unknown Disposition'
when disposition_notes = 'AR Included (See Notes)' then 'Unknown Disposition'
when disposition_notes = 'Escalation' then 'Unknown Disposition'
when disposition_notes = 'No Action Required' then 'Unknown Disposition'
when disposition_notes = 'Transfer' then 'Unknown Disposition'
when disposition_notes = 'Accounts Payable' then 'Transfer to Accounts Payable'
when disposition_notes = 'Accounts Receivable' then 'Unknown Disposition'
when disposition_notes = 'Billing Statements and Invoices' then 'Billing Statement & Invoices'
when disposition_notes = 'Branch/TAM' then 'Transfer to Branch/TAM'
when disposition_notes = 'Call-Off' then 'Call-Off'
when disposition_notes = 'Customer COI' then 'Customer COI'
when disposition_notes = 'Collections' then 'Transfer to Collections'
when disposition_notes = 'Credit Team' then 'Transfer to Credit'
when disposition_notes = 'Delivery Inquiries' then 'Delivery Inquiries'
when disposition_notes = 'Employment Opportunities' then 'Employment Opportunities'
when disposition_notes = 'Environmental Fee' then 'Unknown Disposition'
when disposition_notes = 'ES COI Request' then 'Unknown Disposition'
when disposition_notes = 'Fleet/OWN' then 'Fleet/OWN'
when disposition_notes = 'General Billing Inquiries' then 'General Billing Inquiries'
when disposition_notes = 'General Inquiry' then 'General Inquiry'
when disposition_notes = 'HR' then 'Transfer to Human Resources'
when disposition_notes = 'Invoice Dispute' then 'Invoice Dispute'
when disposition_notes = 'IT' then 'Transfer to IT'
when disposition_notes = 'Incomplete Remit' then 'Incomplete Remit'
when disposition_notes = 'Liens/Waivers' then 'Liens/Waivers'
when disposition_notes = 'Marketing' then 'Marketing'
when disposition_notes = 'Notice to Owner (NTO)' then 'Notice to Owner (NTO)'
when disposition_notes = 'Online Bill Pay' then 'Online Bill Pay'
when disposition_notes = 'Paperless Billing' then 'Paperless Billing'
when disposition_notes = 'Parts' then 'Transfer to Parts'
when disposition_notes = 'Payments' then 'Payments'
when disposition_notes = 'Purchase Order Update' then 'Purchase Order Update'
when disposition_notes = 'Remit Notifications' then 'Unknown Disposition'
when disposition_notes = 'Rental Inquiry' then 'Rental Inquiry'
when disposition_notes = 'Rental Inquiry - Key Codes' then 'Rental Inquiry - Key Codes'
when disposition_notes = 'Rental Inquiry - Delivery Status/ETA' then 'Rental Inquiry - Delivery Status/ETA'
when disposition_notes = 'Rental Requests' then 'Rental Request'
when disposition_notes = 'Risk Management/Insurance Claims' then 'Risk Management/Insurance Claims'
when disposition_notes = 'Service Request' then 'Service Request'
when disposition_notes = 'Customer Support Center T3' then 'Customer Support Center T3'
when disposition_notes = 'Transfer to T3 Support' then 'Transfer to T3 Support'
when disposition_notes = 'Tax Inquiry' then 'Tax Inquiry'
when disposition_notes = 'Vendors' then 'Transfer to Vendors'
when disposition_notes = 'Additionally Insured' then 'Unknown Disposition'
when disposition_notes = 'Awaiting Credits' then 'Credit Request'
when disposition_notes = 'Cancellation/Reinstatement' then 'Unknown Disposition'
when disposition_notes = 'Certificate Holder' then 'Unknown Disposition'
when disposition_notes = 'Coverage Limit' then 'Unknown Disposition'
when disposition_notes = 'Expired COI' then 'Unknown Disposition'
when disposition_notes = 'General Liability' then 'Unknown Disposition'
when disposition_notes = 'Account Name/Address' then 'Unknown Disposition'
when disposition_notes = 'Loss Payee' then 'Unknown Disposition'
when disposition_notes = 'Not in System' then 'Unknown Disposition'
when disposition_notes = 'Property Coverage' then 'Unknown Disposition'
when disposition_notes = 'Add/Edit Customer Asset' then 'Add/Edit Customer Asset'
when disposition_notes = 'Analytics' then 'Analytics'
when disposition_notes = 'Costcapture' then 'Costcapture'
when disposition_notes = 'E-Logs' then 'E-Logs'
when disposition_notes = 'Escalate to Tier 2' then 'Escalate to Tier 2'
when disposition_notes = 'Waiting on Installer' then 'Unknown Disposition'
when disposition_notes = 'Keycodes/Keypads' then 'Keycodes/Keypads'
when disposition_notes = 'New User/Access Level' then 'New User/Access Level'
when disposition_notes = 'Onboarding' then 'Onboarding'
when disposition_notes = 'Parts & Inventory' then 'Parts & Inventory'
when disposition_notes = 'Rental Funnel' then 'Rental Funnel'
when disposition_notes = 'Rental Ops Troubleshooting' then 'Rental Ops Troubleshooting'
when disposition_notes = 'Service/Work Orders Troubleshooting' then 'Service/Work Orders Troubleshooting'
when disposition_notes = 'Scrub' then 'Scrub'
when disposition_notes = 'T3' then 'T3'
when disposition_notes = 'T3 Portal/Fleet App' then 'T3 Portal/Fleet App'
when disposition_notes = 'Telematics Sales' then 'Telematics Sales'
when disposition_notes = 'Timecards' then 'Timecards'
when disposition_notes = 'Tracker/Camera Tie' then 'Tracker/Camera Tie'
when disposition_notes = 'Tracker Troubleshooting' then 'Tracker Troubleshooting'
else team_name end
as contact_disposition
--, disposition_notes
, count(master_contact_id) as total_contacts
from ANALYTICS.CXONE_API.COMPLETED_CONTACTS cxi
group by
contact_type
, contact_date
, contact_disposition
)
, front as (
select
'Front' as contact_type
, tgh.updated_at::date as contact_date
--, name as contact_disposition
,
case
when name = '1st Attempt' then 'Unknown Disposition'
when name = '2nd Attempt' then 'Unknown Disposition'
when name = '3rd Attempt' then 'Unknown Disposition'
when name = 'AR Included (See Notes)' then 'Unknown Disposition'
when name = 'Escalation' then 'Unknown Disposition'
when name = 'No Action Required' then 'Unknown Disposition'
when name = 'Transfer' then 'Unknown Disposition'
when name = 'Accounts Payable' then 'Transfer to Accounts Payable'
when name = 'Accounts Receivable' then 'Unknown Disposition'
when name = 'Billing Statements and Invoices' then 'Billing Statement & Invoices'
when name = 'Branch/TAM' then 'Transfer to Branch/TAM'
when name = 'Call-Off' then 'Call-Off'
when name = 'Customer COI' then 'Customer COI'
when name = 'Collections' then 'Transfer to Collections'
when name = 'Credit Team' then 'Transfer to Credit'
when name = 'Delivery Inquiries' then 'Delivery Inquiries'
when name = 'Employment Opportunities' then 'Employment Opportunities'
when name = 'Environmental Fee' then 'Unknown Disposition'
when name = 'ES COI Request' then 'Unknown Disposition'
when name = 'Fleet/OWN' then 'Fleet/OWN'
when name = 'General Billing Inquiries' then 'General Billing Inquiries'
when name = 'General Inquiry' then 'General Inquiry'
when name = 'HR' then 'Transfer to Human Resources'
when name = 'Invoice Dispute' then 'Invoice Dispute'
when name = 'IT' then 'Transfer to IT'
when name = 'Incomplete Remit' then 'Incomplete Remit'
when name = 'Liens/Waivers' then 'Liens/Waivers'
when name = 'Marketing' then 'Marketing'
when name = 'Notice to Owner (NTO)' then 'Notice to Owner (NTO)'
when name = 'Online Bill Pay' then 'Online Bill Pay'
when name = 'Paperless Billing' then 'Paperless Billing'
when name = 'Parts' then 'Transfer to Parts'
when name = 'Payments' then 'Payments'
when name = 'Purchase Order Update' then 'Purchase Order Update'
when name = 'Remit Notifications' then 'Unknown Disposition'
when name = 'Rental Inquiry' then 'Rental Inquiry'
when name = 'Rental Inquiry - Key Codes' then 'Rental Inquiry - Key Codes'
when name = 'Rental Inquiry - Delivery Status/ETA' then 'Rental Inquiry - Delivery Status/ETA'
when name = 'Rental Requests' then 'Rental Request'
when name = 'Risk Management/Insurance Claims' then 'Risk Management/Insurance Claims'
when name = 'Service Request' then 'Service Request'
when name = 'Customer Support Center T3' then 'Customer Support Center T3'
when name = 'Transfer to T3 Support' then 'Transfer to T3 Support'
when name = 'Tax Inquiry' then 'Tax Inquiry'
when name = 'Vendors' then 'Transfer to Vendors'
when name = 'Additionally Insured' then 'Unknown Disposition'
when name = 'Awaiting Credits' then 'Credit Request'
when name = 'Cancellation/Reinstatement' then 'Unknown Disposition'
when name = 'Certificate Holder' then 'Unknown Disposition'
when name = 'Coverage Limit' then 'Unknown Disposition'
when name = 'Expired COI' then 'Unknown Disposition'
when name = 'General Liability' then 'Unknown Disposition'
when name = 'Account Name/Address' then 'Unknown Disposition'
when name = 'Loss Payee' then 'Unknown Disposition'
when name = 'Not in System' then 'Unknown Disposition'
when name = 'Property Coverage' then 'Unknown Disposition'
when name = 'Add/Edit Customer Asset' then 'Add/Edit Customer Asset'
when name = 'Analytics' then 'Analytics'
when name = 'Costcapture' then 'Costcapture'
when name = 'E-Logs' then 'E-Logs'
when name = 'Escalate to Tier 2' then 'Escalate to Tier 2'
when name = 'Waiting on Installer' then 'Unknown Disposition'
when name = 'Keycodes/Keypads' then 'Keycodes/Keypads'
when name = 'New User/Access Level' then 'New User/Access Level'
when name = 'Onboarding' then 'Onboarding'
when name = 'Parts & Inventory' then 'Parts & Inventory'
when name = 'Rental Funnel' then 'Rental Funnel'
when name = 'Rental Ops Troubleshooting' then 'Rental Ops Troubleshooting'
when name = 'Service/Work Orders Troubleshooting' then 'Service/Work Orders Troubleshooting'
when name = 'Scrub' then 'Scrub'
when name = 'T3' then 'T3'
when name = 'T3 Portal/Fleet App' then 'T3 Portal/Fleet App'
when name = 'Telematics Sales' then 'Telematics Sales'
when name = 'Timecards' then 'Timecards'
when name = 'Tracker/Camera Tie' then 'Tracker/Camera Tie'
when name = 'Tracker Troubleshooting' then 'Tracker Troubleshooting'
else 'Not Customer Service' end
as contact_disposition

, count(tag_id) as total_contacts
FROM ANALYTICS.FRONT.CONVERSATION_TAG_HISTORY tgh
left join ANALYTICS.FRONT.TAG tg on (tgh.tag_id = tg.id)
group by
contact_type
, contact_date
, contact_disposition
)
--, uniquediss as (
select
contact_type
, contact_date
, coalesce(contact_disposition, 'Unknown Disposition') as contact_disposition
, total_contacts
from intercom com
where (contact_date not in ('2022-08-08','2022-08-03','2022-09-14', '2022-04-18','2022-06-15', '2023-05-09', '2022-04-20'))
union
select
contact_type
, contact_date
, coalesce(contact_disposition, 'Unknown Disposition') as contact_disposition
, total_contacts
from cxone cx
union
select
contact_type
, contact_date
, coalesce(contact_disposition, 'Unknown Disposition') as contact_disposition
, total_contacts
from front frnt
where contact_disposition <> 'Not Customer Service'
and (contact_date not in ('2022-05-23'))
order by contact_date desc
;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: contact_type {
    type: string
    sql: ${TABLE}."CONTACT_TYPE" ;;
  }

  dimension: contact_date {
    type: date
    sql: ${TABLE}."CONTACT_DATE" ;;
  }

  dimension: contact_disposition {
    type: string
    sql: ${TABLE}."CONTACT_DISPOSITION" ;;
  }

  dimension: total_contacts {
    type: number
    sql: ${TABLE}."TOTAL_CONTACTS" ;;
  }

  measure: total_contacts_measure {
    label: "Total Contacts"
    type: sum
    sql: ${total_contacts} ;;
  }

  set: detail {
    fields: [
        contact_type,
  contact_date,
  contact_disposition,
  total_contacts
    ]
  }
}
