SELECT
  o.id as order_id,
  o.name,
  o.date_order,
  o.state,
  o.origin,
  o.partner_id,
  o.receiver_phone,
  o.receiver_name,
  o.type_customer,
  o.order_type,
  o.bye_delivery_status,
  o.shipping_provider,
  o.deposit_amount,--Tiền cọc
  o.money_collection, -- Tiền COD
  o.amount_total+cast(total_discount_amount as float64) as total_amount,
  cast(o.total_discount_amount as float64) as discount_amount,
  o.amount_total as net_amount,
  o.discount_in_order,
  o.amount_untaxed
FROM
  byebeo.sale_order o
   left join byebeo.res_country_state s on o.state_id = CAST(s.id as string)
 LEFT JOIN byebeo.byebeo_district st on o.district_id = cast(st.id as string)
 left join byebeo.byebeo_wards w on o.wards_id = CAST(w.id as string)
 left join byebeo.byebeo_branch b on o.branch_id = cast(b.id as string)
 left join byebeo.stock_warehouse sw on o.shipping_warehouse_id = cast(sw.id as string)
 left join byebeo.res_users u on o.user_id = CAST(u.id as string)
 left join byebeo.crm_team t on o.team_id = cast(t.id as string)
 left join byebeo.res_users u1 on o.marketing_id = CAST(u1.id as string)
--  where o.name = 'S00789'