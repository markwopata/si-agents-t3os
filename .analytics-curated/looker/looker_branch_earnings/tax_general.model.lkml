connection: "es_snowflake"

include: "/**/**.view.lkml"
include: "suggestions.lkml"

explore: stargate_top_assets {
  label: "Stargate Onsite - Top Assets"

  sql_always_where: (
    'finance' = {{ _user_attributes['department'] }}
    OR 'developer' = {{ _user_attributes['department'] }}
    OR 'admin' = {{ _user_attributes['department'] }}
    OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'lewis.hornsby@equipmentshare.com'
    OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'sherri.miller@equipmentshare.com'
    OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'lori.burgner@equipmentshare.com'
    OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'ken.lalonde@equipmentshare.com'
  ) ;;
}

explore: ap_ar_invoices {
  label: "AP & AR Invoices"

  sql_always_where: (
    'finance' = {{ _user_attributes['department'] }}
    OR 'developer' = {{ _user_attributes['department'] }}
    OR 'admin' = {{ _user_attributes['department'] }}
    OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'sydney.flores@equipmentshare.com'
    OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'erik.chu@equipmentshare.com'
    OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'evan.hosna@equipmentshare.com'
    OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'natalie.ciciva@equipmentshare.com'
  ) ;;
}

explore: gross_rental_and_sales_revenue {
  label: "Gross Receipts - Rental & Sales Revenue"

  sql_always_where: (
    'finance' = {{ _user_attributes['department'] }}
    OR 'developer' = {{ _user_attributes['department'] }}
    OR 'admin' = {{ _user_attributes['department'] }}
    OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'ben.henry@equipmentshare.com'
    OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'laura.alegria@equipmentshare.com'
    OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'ryan.mccurdy@equipmentshare.com'
    OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'ryli.jetton@equipmentshare.com'
    OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'kim.black@equipmentshare.com'
    OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'yolanda.elenes@equipmentshare.com'
    OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'brian.k.brown@equipmentshare.com'
    OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}') = 'mitch.roth@equipmentshare.com'
  ) ;;
}
