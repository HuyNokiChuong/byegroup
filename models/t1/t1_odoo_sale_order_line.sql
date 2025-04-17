SELECT 
ol.id,
ol.order_id,
o.name,
o.order_type,
o.receiver_name,
o.receiver_phone,
o.state_id,
s.name as city,
st.name as district,
w.name as ward,
o.address,
o.shipping_provider,
b.name as branch_name,
sw.name as warehouse_name,
o.transfer_code,
ol.order_partner_id,
ol.name as product_name,
ol.qty_delivered,
ol.qty_invoiced,
ol.product_uom,
ol.price_unit,
ol.is_discount_line,
ol.discount_amount,
ol.price_subtotal,
 FROM byebeo.sale_order_line ol
 left join byebeo.sale_order o on ol.order_id = o.id
 left join byebeo.res_country_state s on o.state_id = CAST(s.id as string)
 LEFT JOIN byebeo.byebeo_district st on o.district_id = cast(st.id as string)
 left join byebeo.byebeo_wards w on o.wards_id = CAST(w.id as string)
 left join byebeo.byebeo_branch b on o.branch_id = cast(b.id as string)
 left join byebeo.stock_warehouse sw on o.shipping_warehouse_id = cast(sw.id as string)
--  where o.name = 'S00789'