-- Delivery and Logistics Performance

-- Delivery time
with delivery_date as (
	select
		order_id,
		order_purchase_timestamp,
		order_delivered_customer_date,
		order_estimated_delivery_date,

		Datediff(
			Day,
			order_purchase_timestamp,
			order_delivered_customer_date
		) as delivery_days
		from orders
		where order_status = 'delivered'
		and order_delivered_customer_date is not null
)

select
	count(*) as delivered_orders,
	min(delivery_days) as minimum_delivery_days,
	avg(cast(delivery_days as decimal (10,2))) as average_delivery_days,
	max(delivery_days) as maximum_delivery_days
	from delivery_date;

-- Median delivery time

with delivery_date as (
	select
		order_id,
		order_purchase_timestamp,
		order_delivered_customer_date,
		order_estimated_delivery_date,

		Datediff(
			Day,
			order_purchase_timestamp,
			order_delivered_customer_date
		) as delivery_days
		from orders
		where order_status = 'delivered'
		and order_delivered_customer_date is not null
)
select distinct
	PERCENTILE_CONT(0.5)
		within group(
		order by delivery_days
		) over () as median_delivery_days
from delivery_date;

-- ontime delivery rate (rules ပြန်ချိန်းရန်လို)

with delivery_date as (
	select
		order_id,
		order_delivered_customer_date,
		order_estimated_delivery_date,

		case
		when order_delivered_customer_date <= order_estimated_delivery_date
		then 'on time'
		else 'late'
		end as delivery_status
	from orders
	where order_status = 'delivered'
		and order_delivered_customer_date is not null
		and order_estimated_delivery_date is not null
)
select
	delivery_status, count(*) as order_count,
	cast(
		count(*) * 100.0 /
		sum(count(*)) over ()
		as decimal(10,2)
	) as order_share_pct
from delivery_date
group by delivery_status
order by
case when delivery_status = 'on time' then 1
else 2
end; -- 88644, 7826

-- how late are late orders?

with delivery_date as (
	select order_id,
	datediff(
	day,
	order_estimated_delivery_date,
	order_delivered_customer_date
	) as delivery_delay_days
	from orders
	where order_status = 'delivered'
	and order_delivered_customer_date is not null
	and order_estimated_delivery_date is not null
	)

	select count(*) as late_orders,
		min(delivery_delay_days) as minimum_delay_days,
		avg(cast(delivery_delay_days as decimal(10,2))) as average_delay_days,
		max(delivery_delay_days) as maximum_delay_days
	from delivery_date
	where delivery_delay_days >0; -- 6534 -- calculate with old rule

-- ontime delivery rate (rules ချိန်းပြီး Actual delivery date <= Estimated delivery date)

with delivery_date as (
	select
		order_id,
		cast(order_delivered_customer_date as date) as actual_delivery_date,
		cast(order_estimated_delivery_date as date) as estimated_delivery_date,

		case
		when cast(order_delivered_customer_date as date) <= cast(order_estimated_delivery_date as date)
		then 'on time'
		else 'late'
		end as delivery_status
	from orders
	where order_status = 'delivered'
		and order_delivered_customer_date is not null
		and order_estimated_delivery_date is not null
)
select
	delivery_status, count(*) as order_count,
	cast(
		count(*) * 100.0 /
		sum(count(*)) over ()
		as decimal(10,2)
	) as order_share_pct
from delivery_date
group by delivery_status
order by
case when delivery_status = 'on time' then 1
else 2
end; 

-- recalculate delay

with delivery_date as (
	select order_id,
	datediff(
	day,
	cast(order_estimated_delivery_date as date),
	cast(order_delivered_customer_date as date)
	) as delivery_delay_days
	from orders
	where order_status = 'delivered'
	and order_delivered_customer_date is not null
	and order_estimated_delivery_date is not null
	)

	select count(*) as late_orders,
		min(delivery_delay_days) as minimum_delay_days,
		avg(cast(delivery_delay_days as decimal(10,2))) as average_delay_days,
		max(delivery_delay_days) as maximum_delay_days
	from delivery_date
	where delivery_delay_days >0;

--  Delivery delay severity

with delivery_date as (
	select order_id,
	datediff(
	day,
	cast(order_estimated_delivery_date as date),
	cast(order_delivered_customer_date as date)
	) as delivery_delay_days
	from orders
	where order_status = 'delivered'
	and order_delivered_customer_date is not null
	and order_estimated_delivery_date is not null
	),

	delay_buckets as (
	select
		case
			when delivery_delay_days between 1 and 3
				then '1-3 days'
			when delivery_delay_days between 4 and 7
				then '4-7 days'
			when delivery_delay_days between 8 and 14
				then '8-14 days'
			when delivery_delay_days between 15 and 30
				then '15-30 days'
				else '+31 days'
				end as delay_bucket
	from delivery_date
	where delivery_delay_days > 0
	)
select
	delay_bucket,
	count(*) as late_order_count,
	cast(
		count(*) * 100.0 /
		sum(count(*)) over()
		as decimal(10,2)
	)as late_order_share_pct,
	case delay_bucket
		when '1-3 days' then 1
		when '4-7 days' then 2
		when '8-14 days' then 3
		when '15-30 days' then 4
		else 5
		end as sort_order
from delay_buckets
group by delay_bucket
order by sort_order;

-- monthly performance

with delivery_date as (
	select
		order_id,
		order_purchase_timestamp,
		cast(order_delivered_customer_date as date) as actual_delivery_date,
		cast(order_estimated_delivery_date as date) as estimated_delivery_date,

		case
		when cast(order_delivered_customer_date as date) <= cast(order_estimated_delivery_date as date)
		then 1
		else 0
		end as is_on_time

		from orders
		where order_status = 'delivered'
		and order_delivered_customer_date is not null
		and order_estimated_delivery_date is not null
)
select
	year(order_purchase_timestamp) as purchase_year,
	month(order_purchase_timestamp) as purchase_month,
	count(*) as delivered_orders,
	sum(is_on_time) as on_time_orders,
	cast(
		sum(is_on_time) * 100.0 /count(*)
		as decimal(10,2)
	)as on_time_rate_pct
from delivery_date
group by
	year(order_purchase_timestamp),
	month(order_purchase_timestamp)
	order by
		purchase_year,
		purchase_month;

