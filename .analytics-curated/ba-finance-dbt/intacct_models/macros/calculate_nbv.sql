{% macro calculate_nbv(original_equipment_cost, asset_type, first_rental, purchase_date, date_created, billing_approved_date) %}

round(coalesce(
    {{ original_equipment_cost }} - least(
        {{ original_equipment_cost }} *
        case
            when {{ asset_type }} in ('vehicle', 'trailer') then
                0.9 / (7 * 12) -- vehicle salvage = 10%, equip = 20%
            else
                0.8 / (10 * 12)
        end * greatest(
            0, 
            datediff(
                month, 
                iff(
                    {{ asset_type }} = 'equipment', 
                    date_from_parts(year({{ first_rental }}), month({{ first_rental }}), 15),
                    coalesce(
                        date_from_parts(year({{ purchase_date }}), month({{ purchase_date }}), 15),
                        date_from_parts(year({{ date_created }}), month({{ date_created }}), 15)
                    )
                ),
                date_from_parts(year({{ billing_approved_date }}), month({{ billing_approved_date }}), 15)
            )
        ),
        -- salvage value
        {{ original_equipment_cost }} * case
            when {{ asset_type }} in ('vehicle', 'trailer') then 0.9
            else 0.8
        end
    ) * case
        when {{ first_rental }} is null and {{ asset_type }} = 'equipment' then
            0
        else
            1
    end,
    {{ original_equipment_cost }}
), 2)

{% endmacro %}
