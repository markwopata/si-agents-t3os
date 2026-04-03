select
    coalesce(liero.line_item_type_id, liter.line_item_type_id) as line_item_type_id,
    coalesce(liero.override_gl_account_no, liter.intacct_gl_account_no) as intacct_gl_account_no
from {{ ref("stg_es_warehouse_public__line_item_type_erp_refs") }} as liter
    full outer join {{ ref("seed_line_item_erp_refs_override") }} as liero
        on liter.line_item_type_id = liero.line_item_type_id
