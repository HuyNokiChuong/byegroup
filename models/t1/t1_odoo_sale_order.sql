SELECT
  o.id as order_id,
  o.name,
  DATETIME_ADD(datetime(o.create_lead), INTERVAL 7 HOUR) AS create_lead,  -- Ngày tạo lead + 7h
  DATETIME_ADD(datetime(o.date_open_lead), INTERVAL 7 HOUR) AS date_open_lead,  -- Ngày giao lead + 7h
  DATETIME_ADD(datetime(o.date_order), INTERVAL 7 HOUR) AS date_order, -- Ngày đặt hàng + 7h
  DATETIME_ADD(datetime(o.effective_date), INTERVAL 7 hour) as effective_date, ---Ngày hiệu lực
  DATETIME_ADD(datetime(o.commitment_date), INTERVAL 7 hour) as commitment_date, ---Ngày giao hàng dự kiến
  o.state,
  o.origin,
  o.partner_id,
  o.receiver_phone,
  o.receiver_name,
  o.type_customer,
  o.order_type,
  o.bye_delivery_status,
  o.shipping_provider,
  o.delivery_date,
  p.name as seller_employee_name,
  p1.name as marketing_employee_name,
  lc.name as source_name_category,
  us.name as source_name,
  IFNULL(CAST(o.deposit_amount AS float64),0) as deposit_amount,--Tiền cọc
  IFNULL(CAST(o.money_collection AS float64),0) as money_collection, -- Tiền COD
  CASE 
      WHEN o.name like '%PS%' THEN 'Đơn đẩy từ Pushsale qua'
    WHEN IFNULL(CAST(o.deposit_amount AS float64),0)  > 0 and IFNULL(CAST(o.deposit_amount AS float64),0)  < IFNULL(CAST(o.money_collection AS float64),0) then 'Đã cọc 1 phần, chưa thanh toán hết'
    WHEN IFNULL(CAST(o.deposit_amount AS float64),0)  > 0 and IFNULL(CAST(o.money_collection AS float64),0) = 0 THEN 'Đã thanh toán trước & thanh toán đủ'
    WHEN IFNULL(CAST(o.deposit_amount AS float64),0)  = 0 and IFNULL(CAST(o.money_collection AS float64),0) <> 0 THEN 'COD'
    WHEN IFNULL(CAST(o.deposit_amount AS float64),0)  = 0 and IFNULL(CAST(o.money_collection AS float64),0) = 0 THEN 'Đơn 0 đồng, và không cần thu tiền'

  ELSE 'Khác' End as payment_type,
  o.amount_total+cast(total_discount_amount as float64) - CAST(amount_tax as float64) as total_amount,
  cast(o.total_discount_amount as float64) as discount_amount,
  o.amount_total - CAST(amount_tax as float64) as net_amount,
  CAST(amount_tax as float64) as tax, --Thuế
  o.amount_total - CAST(amount_tax as float64) + CAST(amount_tax as float64) as final_amount
FROM
  byebeo.sale_order o
   left join byebeo.res_country_state s on o.state_id = CAST(s.id as string)
 LEFT JOIN byebeo.byebeo_district st on o.district_id = cast(st.id as string)
 left join byebeo.byebeo_wards w on o.wards_id = CAST(w.id as string)
 left join byebeo.byebeo_branch b on o.branch_id = cast(b.id as string)
 left join byebeo.stock_warehouse sw on o.shipping_warehouse_id = cast(sw.id as string)
 left join byebeo.res_users u on o.user_id = u.id 
 left join byebeo.res_partner p on CAST(u.partner_id as string) = CAST(p.id as string)
 left join byebeo.crm_team t on o.team_id = cast(t.id as string)
 left join byebeo.res_users u1 on o.marketing_id = CAST(u1.id as string)
 left join byebeo.res_partner p1 on CAST(u1.partner_id as string) = CAST(p1.id as string)
 left join byebeo.utm_source us on o.source_id = CAST(us.id as string) and o.company_id = us.company_id
 left join byebeo.crm_lead_channel lc on us.channel_id = lc.id
--  where o.name = 'S00784'


