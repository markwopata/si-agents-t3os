{% macro generate_commission_id(
    line_item_id,
    salesperson_user_id,
    credit_note_line_item_id,
    manual_adjustment_id,
    transaction_type,
    commission_type
) %}
    {{ line_item_id }} || '-' || 
    coalesce({{ salesperson_user_id }}, 0) || '-' || 
    coalesce({{ credit_note_line_item_id }}, 0) || '-' || 
    coalesce({{ manual_adjustment_id }}, 0)::int || '-' || 
    {{ transaction_type }} || '-' || 
    {{ commission_type }}
{% endmacro %}