with phone as(
  
SELECT distinct(phone) phone, name, city from byebeo.res_partner where length(phone) > 1 
-- and phone = '0945137555'
),
p_sale as(
  SELECT receiver_phone phone,
  sum(net_amount) as sale_contribution,
  COUNT(distinct(order_id)) as transaction_count,
  SUM(product_uom_qty) as total_item,
  sum(net_amount)/COUNT(distinct(order_id)) as aov,
  sum(product_uom_qty)/count(distinct order_id) as ipt,    
   from {{ref('t1_odoo_sale_order_line')}}
   GROUP BY receiver_phone
),
first_time as (
  SELECT ROW_NUMBER() OVER (PARTITION BY receiver_phone ORDER BY date_order) as ro,
  receiver_phone phone,
  date_order
  FROM {{ref('t1_odoo_sale_order_line')}}
)
,
latest_time as (
  SELECT ROW_NUMBER() OVER (PARTITION BY receiver_phone ORDER BY date_order desc) as ro,
  receiver_phone phone,
  date_order
  FROM {{ref('t1_odoo_sale_order_line')}}
)
SELECT p.*,
    ft.date_order as first_order_date,
    lt.date_order as latest_order_date,
    date_diff(current_date(),date(lt.date_order),day) as last_order_in_day,
    cast(s.sale_contribution as int64) as sale_contribution,
    s.transaction_count,
    s.aov,
    s.total_item,
    s.ipt,
    CASE WHEN date_diff(current_date(), date(lt.date_order), week) <= 6 then '00-06 tuần'
        when date_diff(current_date(), date(lt.date_order), week) > 6 AND date_diff(current_date(), date(lt.date_order), week) <= 12 then '06-12 tuần'
        when date_diff(current_date(), date(lt.date_order), week) > 12 AND date_diff(current_date(), date(lt.date_order), week) <= 18 then '12-18 tuần'
        when date_diff(current_date(), date(lt.date_order), week) > 18 AND date_diff(current_date(), date(lt.date_order), week) <= 24 then '18-24 tuần'
        when date_diff(current_date(), date(lt.date_order), week) > 24 then '> 24 tuần'
        ELSE 'Chưa từng sử dụng dịch vụ'
        end as rfm_r,
    CASE WHEN s.transaction_count > 4 then 'Sử dụng dịch vụ > 4 lần'
        when s.transaction_count >= 2 and s.transaction_count <= 4 then 'Sử dụng dịch vụ > 2 lần và < 4 lần'
        when s.transaction_count < 2 then 'Sử dụng dịch vụ < 2 lần'
        ELSE 'Chưa từng sử dụng dịch vụ'
        end as rfm_f,
    CASE 
        WHEN s.sale_contribution >= 10000000 then 'Sử dụng trên 10tr'
        WHEN s.sale_contribution >= 5000000 and s.sale_contribution < 10000000 then 'Sử dụng trên 5tr đến 10tr'
        WHEN s.sale_contribution >= 3000000 and s.sale_contribution < 50000000 then 'Sử dụng trên 3tr đến 5tr'
        WHEN s.sale_contribution >= 1000000 and s.sale_contribution < 30000000 then 'Sử dụng trên 1tr đến 3tr'
        WHEN s.sale_contribution >= 500000 and s.sale_contribution < 1000000 then 'Sử dụng trên 500k đến 1tr'
        WHEN s.sale_contribution < 500000 then 'Sử dụng < 500k'
        ELSE 'Chưa từng sử dụng dịch vụ'
        end as rfm_m,
    CASE
        WHEN s.sale_contribution >= 10000000 and s.transaction_count > 4 then 'Platinum'
        WHEN s.sale_contribution >= 10000000 and s.transaction_count > 2 and date_diff(current_date(), date(lt.date_order), week) <= 24 then 'Platinum'
        WHEN s.sale_contribution >= 5000000 and s.transaction_count > 4 and date_diff(current_date(), date(lt.date_order), week) <= 24 then 'Platinum'
        WHEN s.sale_contribution >= 10000000 and s.transaction_count < 4 then 'Gold'
        WHEN s.sale_contribution >= 5000000 and s.transaction_count > 4 and date_diff(current_date(), date(lt.date_order), week) > 24 then 'Gold'
        WHEN s.sale_contribution >= 5000000 and s.transaction_count < 4 and date_diff(current_date(), date(lt.date_order), week) <= 24 then 'Gold'
        WHEN s.sale_contribution >= 3000000 and s.transaction_count > 4 then 'Gold'
        WHEN s.sale_contribution >= 3000000 and s.transaction_count > 2 and date_diff(current_date(), date(lt.date_order), week) <= 24 then 'Gold'
        WHEN s.sale_contribution >= 1000000 and s.transaction_count > 4 and date_diff(current_date(), date(lt.date_order), week) <= 24 then 'Gold'
        WHEN s.sale_contribution >= 5000000 and s.transaction_count < 2 and date_diff(current_date(), date(lt.date_order), week) > 24 then 'Silver'
        WHEN s.sale_contribution >= 3000000 and s.transaction_count > 2 and date_diff(current_date(), date(lt.date_order), week) > 24 then 'Silver'
        WHEN s.sale_contribution >= 3000000 and s.transaction_count < 2 then 'Silver'
        WHEN s.sale_contribution >= 1000000 and s.transaction_count > 4 and date_diff(current_date(), date(lt.date_order), week) > 24 then 'Silver'
        WHEN s.sale_contribution >= 1000000 and s.transaction_count > 2 then 'Silver'
        WHEN s.sale_contribution >= 1000000 and s.transaction_count < 2 and date_diff(current_date(), date(lt.date_order), week) <= 24 then 'Silver'
        WHEN s.sale_contribution >= 500000 and s.transaction_count > 2 and date_diff(current_date(), date(lt.date_order), week) <= 24 then 'Silver'
        WHEN s.transaction_count is null then 'Chưa từng sử dụng dịch vụ'
        ELSE 'Bronze'
        END as customer_level,
    CASE 
        WHEN date_diff(current_date(), date(lt.date_order), day) > 120 then '1 điểm'
        when date_diff(current_date(), date(lt.date_order), day) > 90 then '2 điểm'
        when date_diff(current_date(), date(lt.date_order), day) > 60 then '3 điểm'
        when date_diff(current_date(), date(lt.date_order), day) > 30 then '4 điểm'
        when date_diff(current_date(), date(lt.date_order), day) <= 30 then '5 điểm'
        else '1 điểm'
        end as recency_score,
    CASE 
        WHEN date_diff(current_date(), date(lt.date_order), day) > 120 then '1 điểm'
        when date_diff(current_date(), date(lt.date_order), day) > 104 then '2.1 điểm' 
        when date_diff(current_date(), date(lt.date_order), day) > 97 then '2.2 điểm'
        when date_diff(current_date(), date(lt.date_order), day) > 90 then '2.3 điểm'
        when date_diff(current_date(), date(lt.date_order), day) > 74 then '3.1 điểm'
        when date_diff(current_date(), date(lt.date_order), day) > 67 then '3.2 điểm'
        when date_diff(current_date(), date(lt.date_order), day) > 60 then '3.3 điểm'
        when date_diff(current_date(), date(lt.date_order), day) > 44 then '4.1 điểm'
        when date_diff(current_date(), date(lt.date_order), day) > 37 then '4.2 điểm'
        when date_diff(current_date(), date(lt.date_order), day) > 30 then '4.3 điểm'
        when date_diff(current_date(), date(lt.date_order), day) > 28 then '5.1 điểm'
        when date_diff(current_date(), date(lt.date_order), day) > 14 then '5.2 điểm'
        when date_diff(current_date(), date(lt.date_order), day) > 7 then '5.3 điểm'
        when date_diff(current_date(), date(lt.date_order), day) <= 7 then '5.4 điểm'
        else '1 điểm'
        end as recency_score_detail
    FROM phone p
    left join p_sale s on s.phone = p.phone
    left join latest_time lt on lt.phone = p.phone and lt.ro = 1
    left join first_time ft on ft.phone = p.phone and ft.ro = 1



