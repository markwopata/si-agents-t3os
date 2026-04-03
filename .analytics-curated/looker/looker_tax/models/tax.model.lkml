connection: "es_snowflake"

include: "/views/**.view.lkml"

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
