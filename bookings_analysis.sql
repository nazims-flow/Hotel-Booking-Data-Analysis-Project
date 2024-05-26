
-- Q1 What is the overall cancellation rate for hotel bookings?

SELECT SUM(is_canceled) as canceled_bookings,
	   SUM(is_canceled)*100.0/(SELECT COUNT(*)  FROM bookings ) as cancellation_rate
	   FROM bookings
	   WHERE is_canceled = 1
	   
--optimized query is_canceled can be directly sum as 1 is treated as TRUE and 0 as FALSE
SELECT 
    COUNT(*) AS total_bookings,
    SUM(is_canceled) AS canceled_bookings,
    (SUM(is_canceled) * 100.0 / COUNT(*)) AS cancellation_rate
FROM 
    bookings;
	
-- Q2 Which countries are the top contributors to hotel bookings?

SELECT *
FROM(
SELECT country,
	   COUNT(*) as total_bookings,
	   DENSE_RANK() OVER(ORDER BY COUNT(*) DESC) as dn
	   FROM bookings
	   WHERE country is NOT NULL
	   GROUP BY 1
) as ranked_countries
WHERE dn<6      
	
-- Q3 What are the main market segments booking the hotels, such as leisure or corporate? 

SELECT market_segment,
       COUNT(*) as count_bookings
	   FROM bookings
       GROUP BY 1
       ORDER BY 2 DESC
	   
	   
-- Q4 Is there a relationship between deposit type (e.g., non-refundable, refundable) and the likelihood of cancellation?
SELECT deposit_type,
	   is_canceled,
	   COUNT(*) as no_of_bookings
       FROM bookings 
	   GROUP BY 1 ,2
	   ORDER BY 1, 2
	 
-- Q5 How long do guests typically stay in hotels on average?

-- since only the no. of days stayed in weekends in mentioned so
SELECT AVG(stays_in_weekend_nights) AS average_length_of_stay
FROM bookings;

-- Q6 What meal options (e.g., breakfast included, half-board) are most preferred by guests?

SELECT meal,
       COUNT(*) count_of_bookings
       FROM bookings
       GROUP BY 1
	   ORDER BY 2 DESC
-- Q7 Do bookings made through agents exhibit different cancellation rates or booking durations compared to direct bookings?
WITH booking_counts AS(
     SELECT 
	     CASE 
	        WHEN agent is NOT NULL THEN 'Agent'
	        ELSE 'Direct'
         END as booking_type,
		 COUNT(*) as total_bookings,
	     SUM(is_canceled) as canceled_bookings
	 FROM bookings
	 GROUP BY 1
)
SELECT
		booking_type,
		total_bookings,
		canceled_bookings,
		(canceled_bookings*100.0)/total_bookings as cancellation_rate
		FROM booking_counts
		
--Q8 How do prices vary across different hotels and room types? Are there any seasonal pricing trends?
-- Price Variation Across Hotels
SELECT 
    hotel,
    AVG(price) AS avg_price,
    MIN(price) AS min_price,
    MAX(price) AS max_price
FROM bookings
GROUP BY 1
	
-- Seasonal Pricing Trends
SELECT 
    EXTRACT(MONTH FROM booking_date) AS booking_month,
    AVG(price) AS average_price
FROM 
    bookings
GROUP BY 1   
ORDER BY 1	

--Q9 What percentage of bookings require car parking spaces,
--and does this vary by hotel location or other factors?

SELECT 
    hotel,
    COUNT(*) AS total_bookings,
    SUM(required_car_parking_spaces) AS total_required_parking_spaces,
    (SUM(required_car_parking_spaces) * 100.0 / COUNT(*)) AS percentage_required
FROM bookings
GROUP BY 1;

SELECT 
    country,
    COUNT(*) AS total_bookings,
    SUM(required_car_parking_spaces) AS total_required_parking_spaces,
    (SUM(required_car_parking_spaces) * 100.0 / COUNT(*)) AS percentage_required
FROM bookings  
GROUP BY 1
ORDER BY 4 DESC

--Q10 What are the main reservation statuses (e.g., confirmed, canceled, checked-in), 
--and how do they change over time?

SELECT DISTINCT(reservation_status )
FROM bookings

SELECT EXTRACT(MONTH FROM booking_date) as booking_month,
	   reservation_status,
	   COUNT(*) as status_count
       FROM bookings
	   GROUP BY 1 , 2
	   ORDER BY 1
	   
--Q11 What is the distribution of guests based on the number of adults, children,
--and stays on weekend nights? Guest Distribution Query	  
SELECT 
    SUM(adults) AS total_adults,
    SUM(children) AS total_children,
    SUM(adults + children) AS total_guests,
    SUM(stays_in_weekend_nights) AS total_weekend_nights,
    SUM(CASE WHEN stays_in_weekend_nights > 0 THEN adults+children 
		ELSE 0 END) AS guests_at_weekend_nights
FROM bookings;

--Q12 Which email domains are most commonly used for making hotel bookings?
SELECT SUBSTRING(email FROM '@(.+)$') AS email_domain,
       COUNT(*) AS domain_count
FROM bookings
GROUP BY email_domain
ORDER BY domain_count DESC;


--Q13 Are there any frequently occurring names in hotel bookings, 
--and do they exhibit any specific booking patterns?

SELECT name,
       COUNT(*) as no_of_bookings,
	   MIN(booking_date) as first_booking,
	   MAX(booking_date) as last_booking,
	   AVG(price) as avg_price_paid
	   FROM bookings
	   GROUP BY 1
	   ORDER BY 2 DESC

	
--Q14 Which market segments contribute the most revenue to the hotels?

SELECT market_segment,
       ROUND(SUM(price)::NUMERIC ,2 )as total_revenue,
	   DENSE_RANK() OVER(ORDER BY SUM(price) DESC) as dn
	   FROM bookings
	   GROUP BY 1

--Q15 How do booking patterns vary across different seasons or months of the year?

SELECT EXTRACT(Month FROM booking_date) as booking_month,
       COUNT(*) as total_monthly_booking,
	   AVG(price) AS avg_booking_price
	   FROM bookings
	   GROUP BY 1
	   ORDER BY 1

SELECT * FROM bookings

SELECT COUNT(*) FROM bookings
