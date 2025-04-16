SELECT id,
order_id,
order_partner_id,
name as product_name,
price_unit,
qty_to_invoice,
product_uom,
price_subtotal,
price_reduce_taxinc,
price_total
 FROM byebeo.sale_order_line