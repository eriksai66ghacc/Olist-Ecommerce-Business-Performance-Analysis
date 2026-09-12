-- 1. overall review score

select
	count(*) as total_reviews,
	cast(
		avg(cast(review_score as decimal(10,2)))
		as decimal(10,2)
	)as average_review_score,
	
	sum(case 
	when review_score in (4,5) then 1
	else 0
	end) as positive_reviews,

	cast(
		sum(case
		when review_score in (4,5) then 1
		else 0
		end
		) * 100.0 / count(*)
		as decimal(10,2)
	) as positive_review_pct,

	sum(case
		when review_score in (1,2) then 1
		else 0 end
	)as negative_reviews,
	
	cast(sum(
		case when review_score in (1,2) then 1
		else 0
	end) *100.0 /count (*)
	as decimal (10,2)
	) as negative_review_pct
	
	from order_reviews
	where review_score is not null; -- 77.07% + 14.69% = 91.76%, so the remaining 8.24% are 3-star/neutral reviews.

	--review score distribution

	select
		review_score,
		count(*) as review_count,
		cast(
			count (*) * 100.0/
			sum(count(*)) over()
			as decimal(10,2)
			) as review_share_pct
	from order_reviews
	where review_score is not null
	group by review_score
	order by review_score;

	-- delivery vs review score

	select 
		case
			when cast (o.order_delivered_customer_date as date)
			<= cast(o.order_estimated_delivery_date as date)
			then 'on time'
			else 'late'
			end as delivery_status,

			count(*) as reviewed_orders,

			cast(
				avg(cast(r.review_score as decimal(10,2)))
				as decimal(10,2)
			) as average_review_score
	from orders o
	inner join order_reviews r
	on o.order_id = r.order_id
	where o.order_status = 'delivered'
	and o.order_delivered_customer_date is not null
	and o.order_estimated_delivery_date is not null
	and r.review_score is not null

	group by
		case
			when cast(o.order_delivered_customer_date as date)
			<= cast(o.order_estimated_delivery_date as date)
			then 'on time'
			else 'late'
			end;

-- monthly customer satisfaction

select 
	year(r.review_creation_date) as review_year,
	MONTH(r.review_creation_date) as review_month,

	count(*) as review_count,

	cast(avg(cast(r.review_score as decimal(10,2)))
	as decimal (10,2)
	) as average_review_score
from order_reviews r

where r.review_score is not null
group by year(review_creation_date),
month(review_creation_date)

order by review_year,
review_month;

-- for Bi visual review score

select 
review_score, count(*) as review_count,
cast(count(*) * 100.0 / sum(count(*)) over() as decimal (10,2)) as review_share_pct
from order_reviews
where review_score is not null
group by review_score
order by review_score;

-- investigate december 2016

select 
year(o.order_purchase_timestamp) as purchase_year,
month(o.order_purchase_timestamp) as purchase_month,
count(*) as delivered_orders,
sum(
	case
	when o.order_delivered_customer_date <= o.order_estimated_delivery_date
	then 1
	else 0
	end
) as on_time_orders
from orders o
where o.order_status = 'delivered'
group by
	year(o.order_purchase_timestamp),
	month(o.order_purchase_timestamp)
	order by
	purchase_year,purchase_month;

	-- 45 december reviews

select 
year(r.review_creation_date) as review_year,
month(r.review_creation_date) as review_month,
count(*)as total_reviews,

sum(
	case
	when o.order_delivered_customer_date <= o.order_estimated_delivery_date
	then 1
	else 0
	end
) as on_time_orders,

sum(
	case
	when o.order_delivered_customer_date > o.order_estimated_delivery_date
	then 1
	else 0
	end
) as late_orders,

cast(
	avg(cast(r.review_score as decimal(10,2)))
	as decimal(10,2)
) as average_review_score

from order_reviews r
inner join orders o
on r.order_id = o.order_id

where r.review_score is not null
and year(r.review_creation_date) = 2016
and month(r.review_creation_date) in (11,12)

group by 
year(r.review_creation_date),
month(r.review_creation_date)

order by
review_year,
review_month;

-- 45 reviews detail

select 
year(r.review_creation_date) as review_year,
month(r.review_creation_date) as review_month,
r.review_score,
count(*) as review_count
from order_reviews  r
where
r.review_score is not null
and year(r.review_creation_date) = 2016
and month(r.review_creation_date) in (11,12)
group by
year(r.review_creation_date),
month(r.review_creation_date),
r.review_score
order by
review_year,
review_month,
r.review_score;

-- check details comments on december 2016

select * from order_reviews r
where review_score =1
and year(r.review_creation_date) = 2016
and month(r.review_creation_date) = 12
order by r.review_creation_date;
