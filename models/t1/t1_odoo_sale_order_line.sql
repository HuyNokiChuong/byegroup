SELECT 
  DATETIME_ADD(datetime(o.create_lead), INTERVAL 7 HOUR) AS create_lead,  -- Ngày tạo lead + 7h
  DATETIME_ADD(datetime(o.date_open_lead), INTERVAL 7 HOUR) AS date_open_lead,  -- Ngày giao lead + 7h
  DATETIME_ADD(datetime(o.date_order), INTERVAL 7 HOUR) AS date_order, -- Ngày đặt hàng + 7h
ol.id,
ol.order_id,
o.name,
o.order_type,
o.state,
o.receiver_name, ---Tên người nhận
o.receiver_phone, ---Số điện thoại người nhận
s.name as city,
st.name as district,
w.name as ward,
o.address,
o.shipping_provider, ---Đơn vị vận chuyển
o.delivery_date,
b.name as branch_name, ---Chi nhánh gửi
sw.name as warehouse_name, ---Kho vận chuyển
o.transfer_code, ---Mã vận đơn
o.note_for_customer,
o.picking_policy, ---Chính sách vận chuyển
rc.name as company_name,
DATETIME_ADD(datetime(o.effective_date), INTERVAL 7 hour) as effective_date, ---Ngày hiệu lực
DATETIME_ADD(datetime(o.commitment_date), INTERVAL 7 hour) as commitment_date, ---Ngày giao hàng dự kiến
CASE o.delivery_status
  WHEN 'pending' then 'Chưa giao'
  WHEN 'starter' then 'Đã bắt đầu'
  WHEN 'partial' then 'Đã giao 1 phần'
  WHEN 'full' then 'Đã giao hết'
END as delivery_status,
IFNULL(p1.name, 'Không thấy tên người chạy') as marketing_employee_name,
IFNULL(lc.name, 'Nguồn khác') as source_name_category,
IFNULL(us.name, 'Organic') as source_name,
ol.name as product_name, ---tên saaaản phẩm
pm.General_Name as product_name_1,
pm.Standardized_Name as product_name_2,
pm.Variants as product_variant,
ol.product_uom_qty, --Số lượng
ol.qty_delivered, --số lượng đã giao
ol.qty_invoiced, --số lượng xuất hóa đơn
ol.price_unit, --đơn giá
ol.is_discount_line,
ol.price_unit * ol.product_uom_qty as total_amount,
ol.discount_amount as discount_amount, --Giảm giá
ol.price_subtotal as net_amount, --Thành tiền, chưa bao gồm thuế
ol.price_tax as tax, ---- Thuế
ol.price_subtotal + price_tax as final_amount,
pt.list_price as cogs,
ol.price_subtotal-pt.list_price as gross_margin
 FROM byebeo.sale_order_line ol
 left join byebeo.sale_order o on ol.order_id = o.id
 left join byebeo.res_country_state s on CAST(o.state_id as string) = CAST(s.id as string)
 LEFT JOIN byebeo.byebeo_district st on CAST(o.district_id as string) = cast(st.id as string)
 left join byebeo.byebeo_wards w on CAST(o.wards_id as string) = CAST(w.id as string)
 left join byebeo.byebeo_branch b on CAST(o.branch_id as string) = cast(b.id as string)
 left join byebeo.stock_warehouse sw on CAST(o.shipping_warehouse_id as string) = cast(sw.id as string)
 left join byebeo.res_users u on CAST(o.user_id as string) = cast(u.id as string) 
 left join byebeo.crm_team t on CAST(o.team_id as string) = cast(t.id as string)
 left join byebeo.res_users u1 on CAST(o.marketing_id as string) = CAST(u1.id as string)
 left join byebeo.res_partner p1 on CAST(u1.partner_id as string) = CAST(p1.id as string)
 left join byebeo.utm_source us on CAST(o.source_id as string) = CAST(us.id as string) and o.company_id = us.company_id
 left join byebeo.crm_lead_channel lc on us.channel_id = lc.id
 left join byebeo.res_company rc on o.company_id = rc.id
 left JOIN byebeo.product_product pp ON ol.product_id = pp.id
 left JOIN byebeo.product_template pt ON pp.product_tmpl_id = pt.id
 left join {{ ref('t1_product_mapping')}} pm on ol.name = pm.Original_Name

--  where o.name = 'S00357'