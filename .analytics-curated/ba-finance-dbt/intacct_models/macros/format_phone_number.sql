-- Clean up a phone number field by removing all non-numeric characters and formatting it as a standard US phone number.
{% macro format_phone_number(phone_field) %}
    replace(
        regexp_replace(
            regexp_replace({{ phone_field }}, '[^0-9x]', '', 1, 0, 'i'),
            '(\\d{3})(\\d{3})(\\d{4})(x\\d+)?',
            '\\1-\\2-\\3\\4',
            1,
            0,
            'i'
        ),
        'x',
        ' x'
    )
{% endmacro %}
