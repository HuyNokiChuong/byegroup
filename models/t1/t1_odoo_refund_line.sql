SELECT 
    mm.res_id AS sale_order_id,
    mm.create_date AS change_date,
    so.opportunity_id AS lead_id,
    mtv.old_value_char AS old_status,
    mtv.new_value_char AS new_status,
		sol.id as line_id,
		sol.product_uom_qty,
		sol.price_unit,
		sol.price_subtotal
FROM byebeo.mail_message mm
JOIN byebeo.mail_tracking_value mtv ON mtv.mail_message_id = mm.id
JOIN byebeo.ir_model_fields imf ON mtv.field_id = imf.id
JOIN byebeo.ir_model irm ON imf.model_id = irm.id
JOIN byebeo.sale_order so ON so.id = mm.res_id
JOIN byebeo.sale_order_line sol ON so.id = sol.order_id
WHERE irm.model = 'sale.order'
  AND imf.name = 'status_transfer'
  AND mm.model = 'sale.order'
  AND mtv.old_value_char IS DISTINCT FROM mtv.new_value_char
	AND mtv.new_value_char = 'Hoàn'
ORDER BY sale_order_id NULLS FIRST, change_date