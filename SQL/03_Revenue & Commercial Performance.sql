-- Revenue & Commercial Performance

select 
p.product_category_name as product_category,
count(distinct oi.order_id) as total_orders,
sum(oi.price) as total_revenue
from products p
join order_items oi
on p.product_id = oi.product_id
group by p.product_category_name
order by total_revenue asc;

select 
p.product_category_name as product_category,
count(distinct oi.order_id) as total_orders,
sum(oi.price) as total_revenue
from products p
join order_items oi
on p.product_id = oi.product_id
group by p.product_category_name
order by total_revenue desc; -- 40% revenue come from top 5 categories 
-- relogios_presentes	watches_gifts ကorder နည်းပေမယ့် revenue များ
-- cama_mesa_banho	bed_table_bath ပြောင်းပြန် order တော့များ revenue က watches နဲ့သိပ်မကွာ order 67% ပိုများ
-- next high order vol vs high order val
-- pcs is very high vol purchase 181 order only

-- High order <> High Revenue

select 
	coalesce (p.product_category_name, 'unknown') as product_category,
	count (distinct oi.order_id) as total_orders,
	sum(oi.price) as total_revenue,
	sum(oi.price) / count(distinct oi.order_id) as avg_order_value -- **
from products p
join order_items oi
on p.product_id = oi.product_id
group by coalesce (p.product_category_name, 'unknown')
order by avg_order_value desc; -- revenue per order , beleza saude က ့high vol rev driver, pcs က high- value low vol category

create view vw_category_revenue AS
select coalesce(p.product_category_name, 'unknown') as product_category,
count(distinct oi.order_id) as total_orders,
sum(oi.price) as total_revenue,
sum(oi.price) / count(distinct oi.order_id) as revenue_per_order,
sum(oi.price) * 100.0 / sum(sum(oi.price)) over () as revenue_share_pct 
from products p
join order_items oi
on p.product_id = oi.product_id
group by coalesce (p.product_category_name, 'unknown');

select * from vw_category_revenue
order by total_revenue desc; -- query like မခေါ်ပဲ create view ပီး powerbi ကလှမ်းခေါ် တာ


-- Monthly revenue by category
-- Which categories are growing, stable, or declining over time?

select 
format(cast(o.order_purchase_timestamp as datetime), 'yyyy-MM') as sales_month,
coalesce(p.product_category_name, 'Unknown') as product_category,
sum(oi.price) as monthly_revenue,
count(distinct oi.order_id) as total_orders
from orders o
join order_items oi
on o.order_id = oi.order_id
join products p
on oi.product_id = p.product_id
group by
format(cast(o.order_purchase_timestamp as datetime), 'yyyy-MM'),
coalesce(p.product_category_name, 'Unknown')
order by
sales_month,
monthly_revenue desc;

exec sp_help 'orders';

-- pcs outlier check

SELECT TOP 20 -- check actual products and price distribution
    oi.product_id,
    oi.price,
    oi.freight_value,
    p.product_category_name
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
WHERE p.product_category_name = 'pcs'
ORDER BY oi.price DESC;

SELECT
    MIN(oi.price) AS min_price,
    MAX(oi.price) AS max_price,
    AVG(oi.price) AS avg_price,
    COUNT(*) AS item_rows
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
WHERE p.product_category_name = 'pcs';











