-- Lấy log thay đổi stage từ crm_lead_log_note
with cte as(
SELECT 
    NULL AS sale_order_id,
    a.change_date,
    a.lead_id,
    old_stage.name.en_US AS old_status,
    new_stage.name.en_US AS new_status
FROM (
    SELECT 
        clln.create_date AS change_date,
        clln.stage_id AS new_stage_id,
        LAG(clln.stage_id) OVER (PARTITION BY clln.lead_id ORDER BY clln.create_date) AS old_stage_id,
        clln.lead_id
    FROM 
        `byebeo.crm_lead_log_note` clln
) AS a
LEFT JOIN `byebeo.crm_stage` new_stage ON a.new_stage_id = new_stage.id
LEFT JOIN `byebeo.crm_stage` old_stage ON a.old_stage_id = old_stage.id
WHERE a.lead_id IS NOT NULL

UNION ALL

-- Lấy log thay đổi status_transfer từ sale_order thông qua mail_tracking_value
SELECT 
    mm.res_id AS sale_order_id,
    mm.create_date AS change_date,
    so.opportunity_id AS lead_id,
    mtv.old_value_char AS old_status,
    mtv.new_value_char AS new_status
FROM `byebeo.mail_message` mm
JOIN `byebeo.mail_tracking_value` mtv ON mtv.mail_message_id = mm.id
JOIN `byebeo.ir_model_fields` imf ON mtv.field_id = imf.id
JOIN `byebeo.ir_model` irm ON imf.model_id = irm.id
JOIN `byebeo.sale_order` so ON so.id = mm.res_id
WHERE irm.model = 'sale.order'
  AND imf.name = 'status_transfer'
  AND mm.model = 'sale.order'
  AND mtv.old_value_char IS DISTINCT FROM mtv.new_value_char
ORDER BY sale_order_id NULLS FIRST, change_date
)
SELECT * FROM cte where lead_id is not null