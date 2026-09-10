select * from orders
select * from customers

with customer_orders as -- one time နဲ့ repeat cust ကိုခွဲ, သူတို့ရဲ့ အရေအတွက်ကိုရှာ, ရှာဖို့ delivered ပီးသားထဲမှာပဲရှာ
(
select 
c.customer_unique_id, -- 1. cust_unique_id ကိုသုံး
count(distinct o.order_id) as order_count --2. order count လုပ်တာ unique သုံး
from customers c
inner join orders o
on c.customer_id = o.customer_id
where o.order_status = 'delivered' -- ၃. ပို့ပေးပီးသားထဲကပဲရှာ
group by c.customer_unique_id
) -- result က cust_uni_id နဲ့ order_count ထွက်လာမယ်, ၉၃၃၅၈

select 
case when order_count = 1 then 'one time customer' -- အပေါ်က order count ကိုလှမ်းခေါ် ပီး 1 လား 1 ထက်များလားစစ်
else 'repeat customer' -- data တော့၀င်ပီ အရေအတွက်က မသိရ,count လုပ်ဖို့လို
end as customer_type, -- စစ်ပီးထွက်လာတဲ့ result ကို နာမည်ပေး, label only
count(*) as customer_count, -- အပေါက cte ကို count .. 93358 rows
cast (count(*) * 100.0 / sum(count(*)) over () as decimal (10,2) -- one tim cust (89624 x 100.0 / 93358)  = 96% , repeat cust (3734 x 100.0 / 93358) = 3.9 %
) as customer_share_pct -- % ထွက်လာပီ
from customer_orders
group by
case when order_count = 1 then 'one time customer'
else 'repeat customer'
end
order by customer_count desc;


-- Revenue from repeat customers

with customer_orders as (
select c.customer_unique_id, count(distinct o.order_id) as order_count from customers c -- cust join order
inner join orders o
on c.customer_id = o.customer_id
where o.order_status = 'delivered'
group by c.customer_unique_id
),
customer_type_cte as 
(
select 
customer_unique_id,
case
when order_count = 1 then 'one time customer'
else 'repeat customer'
end as customer_type -- columne name
from customer_orders
),
customer_revenue_cte as (
select ct.customer_unique_id,ct.customer_type, sum(oi.price) as customer_revenue from customer_type_cte ct -- ၁ဦးချင်းစီ revenue ကိုတွက်
inner join customers c -- cte join cust, cust join order, ord join ord item
on ct.customer_unique_id = c.customer_unique_id
inner join orders o
on c.customer_id = o.customer_id
inner join order_items oi
on o.order_id = oi.order_id
where o.order_status = 'delivered'
group by
ct.customer_unique_id, ct.customer_type
)
select 
customer_type, COUNT(*) as customer_count,sum(customer_revenue) as total_revenue, -- revenue ကိုအကုန်ပြန်ပေါင်း တွက်
cast(
sum(customer_revenue) * 100.0 / sum(sum(customer_revenue)) over() as decimal (10,2)) as revenue_share_pct,
cast(avg(customer_revenue) as decimal(10,2)
)as avg_revenue_per_customer
from customer_revenue_cte
group by customer_type
order by case
when customer_type = 'one time customer' then 1
else 2
end;


-- time between purchases

with customer_orders as (
select
	c.customer_unique_id, o.order_id,o.order_purchase_timestamp,
	lag(o.order_purchase_timestamp) over (
	partition by c.customer_unique_id
	order by o.order_purchase_timestamp
	) as previous_purchase_timestamp
	from customers c
inner join orders o
on c.customer_id = o.customer_id
where o.order_status = 'delivered'
)
select 
	customer_unique_id, order_id, order_purchase_timestamp, previous_purchase_timestamp,
	DATEDIFF(
		day, previous_purchase_timestamp, order_purchase_timestamp
	) as days_between_purchases
from customer_orders
where previous_purchase_timestamp is not null
order by
		customer_unique_id, order_purchase_timestamp; -- order delivery

-- Average days between purchases
with customer_orders as (
select
	c.customer_unique_id, o.order_id,o.order_purchase_timestamp,
	lag(o.order_purchase_timestamp) over (
	partition by c.customer_unique_id
	order by o.order_purchase_timestamp
	) as previous_purchase_timestamp
	from customers c
inner join orders o
on c.customer_id = o.customer_id
where o.order_status = 'delivered'
),
purchase_intervals as (
	select
	customer_unique_id, order_id,
	DATEDIFF(
		day,
		previous_purchase_timestamp, order_purchase_timestamp
	) as days_between_purchases
	from customer_orders
	where previous_purchase_timestamp is not null
)

select 
	count (*) as repeat_purchase_intervals,
	min(days_between_purchases) as minimum_days,
	AVG(cast(days_between_purchases as decimal(10,2))) as average_days,
	MAX(days_between_purchases) as maximum_days
from purchase_intervals;

-- median days between purchases

with customer_orders as (
select
	c.customer_unique_id, o.order_id,o.order_purchase_timestamp,
	lag(o.order_purchase_timestamp) over (
	partition by c.customer_unique_id
	order by o.order_purchase_timestamp
	) as previous_purchase_timestamp
	from customers c
inner join orders o
on c.customer_id = o.customer_id
where o.order_status = 'delivered'
),
purchase_intervals as (
	select
	customer_unique_id, order_id,
	DATEDIFF(
		day,
		previous_purchase_timestamp, order_purchase_timestamp
	) as days_between_purchases
	from customer_orders
	where previous_purchase_timestamp is not null
)
select distinct
	PERCENTILE_CONT(0.5)
		within group(
		order by days_between_purchases
		) over() as median_days_between_purchases
	from purchase_intervals;

-- Calculate repeat-purhcase buckets

with customer_orders as (
select
	c.customer_unique_id, o.order_id,o.order_purchase_timestamp,
	lag(o.order_purchase_timestamp) over (
	partition by c.customer_unique_id
	order by o.order_purchase_timestamp
	) as previous_purchase_timestamp
	from customers c
inner join orders o
on c.customer_id = o.customer_id
where o.order_status = 'delivered'
),
purchase_intervals as (
	select
	customer_unique_id, order_id,
	DATEDIFF(
		day,
		previous_purchase_timestamp, order_purchase_timestamp
	) as days_between_purchases
	from customer_orders
	where previous_purchase_timestamp is not null
),
interval_buckets as (
	select
		case
			when days_between_purchases <= 30 then '0-30 days'
			when days_between_purchases <= 60 then '31-60 days'
			when days_between_purchases <= 90 then '61-90 days'
			when days_between_purchases <= 180 then '91-180 days'
			when days_between_purchases <= 365 then '181-365 days'
			else '366+ days'
			end as purchase_interval
			from purchase_intervals
)
select purchase_interval,
		count(*) as interval_count,
		cast(
		count(*) *100.0 / sum(count(*)) over()
		as decimal (10,2)
		) as interval_share_pct,
		case purchase_interval
		when '0-30 days' then 1
		when '31-60 days' then 2
		when '61-90 days' then 3
		when '91-180 days' then 4
		when '181-365 days' then 5
		else 6
		end as sort_order
from interval_buckets
group by purchase_interval
order by sort_order;