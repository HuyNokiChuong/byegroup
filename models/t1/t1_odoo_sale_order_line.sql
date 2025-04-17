SELECT 
o.create_lead, ---Ngày tạo lead
o.date_open_lead, ---Ngày giao lead
o.date_order, ---Ngày đặt hàng
ol.id,
ol.order_id,
o.name,
o.order_type,
o.receiver_name, ---Tên người nhận
o.receiver_phone, ---Số điện thoại người nhận
s.name as city,
st.name as district,
w.name as ward,
o.address,
o.shipping_provider, ---Đơn vị vận chuyển
b.name as branch_name, ---Chi nhánh gửi
sw.name as warehouse_name, ---Kho vận chuyển
o.transfer_code, ---Mã vận đơn
o.note_for_customer,
o.picking_policy, ---Chính sách vận chuyển
o.effective_date, ---Ngày hiệu lực
o.commitment_date, ---Ngày giao hàng dự kiến
CASE o.delivery_status
  WHEN 'pending' then 'Chưa giao'
  WHEN 'starter' then 'Đã bắt đầu'
  WHEN 'partial' then 'Đã giao 1 phần'
  WHEN 'full' then 'Đã giao hết'
END as delivery_status,
ol.name as product_name, ---tên saaaản phẩm
ol.product_uom, --Số lượng
ol.qty_delivered, --số lượng đã giao
ol.qty_invoiced, --số lượng xuất hóa đơn
ol.price_unit, --đơn giá
ol.is_discount_line,
ol.discount_amount, --Giảm giá
ol.price_subtotal, --Thành tiền, chưa bao gồm thuế
 FROM byebeo.sale_order_line ol
 left join byebeo.sale_order o on ol.order_id = o.id
 left join byebeo.res_country_state s on o.state_id = CAST(s.id as string)
 LEFT JOIN byebeo.byebeo_district st on o.district_id = cast(st.id as string)
 left join byebeo.byebeo_wards w on o.wards_id = CAST(w.id as string)
 left join byebeo.byebeo_branch b on o.branch_id = cast(b.id as string)
 left join byebeo.stock_warehouse sw on o.shipping_warehouse_id = cast(sw.id as string)
 left join byebeo.res_users u on o.user_id = CAST(u.id as string)
 left join byebeo.crm_team t on o.team_id = cast(t.id as string)
 left join byebeo.res_users u1 on o.marketing_id = CAST(u1.id as string)
--  where o.name = 'S00789'