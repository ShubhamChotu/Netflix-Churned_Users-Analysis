/* 
Netflix User's are churning frequently, so we are analyzing and finding insights & 
finding the reasons behind user's churn and the solutions to bring user's back!!!
*/


/* 
# Business Insight for Netflix 

* Through detailed churn analysis, we’ve identified key factors contributing to customer drop-off on Netflix. Specifically, we've uncovered:
- Under-engaged age groups less interested in content or platform experience.
- Subscription tiers that offer lower perceived value and drive dissatisfaction.
- Genre preferences differ by gender and region — for instance, action and thriller are highly preferred by male users in North America,
while romantic and drama genres dominate among female users in Europe and Asia.

* By addressing 70% of the root causes identified, Netflix has the opportunity to recover churned users and significantly reduce future churn.
Implementing targeted strategies based on these insights is projected to drive up to 25% business growth, improve user retention,
and optimize customer satisfaction across regions and demographics.

*/

SELECT * FROM netflix_customer_churn.netflix_customer_churn;


-- Return all the columns with dtype, Null, Kyes, etc
DESCRIBE netflix_customer_churn.netflix_customer_churn;



-- Who are buying Netflix subscription again
SELECT 
	customer_id,
    COUNT(*) AS Repeated
FROM netflix_customer_churn.netflix_customer_churn
GROUP BY customer_id
HAVING COUNT(*) > 1;



-- Number of people have churned & number of user's still enjoying Netflix
SELECT 
    churned,
    ROUND(100 * COUNT(*) / (SELECT COUNT(*) FROM netflix_customer_churn.netflix_customer_churn), 2) AS Percentage
FROM netflix_customer_churn.netflix_customer_churn
GROUP BY churned;



-- Which is the most favorite movie-genre by gender
WITH gender_preference AS (SELECT 
	gender,
	favorite_genre,
    ROUND(100 * COUNT(*) / (SELECT COUNT(*) FROM netflix_customer_churn.netflix_customer_churn),2) AS percentage
FROM netflix_customer_churn.netflix_customer_churn
GROUP BY gender, favorite_genre
),
final_result AS (
	SELECT 
	*,
	RANK() OVER (PARTITION BY gender ORDER BY percentage DESC) AS rank_position
	FROM gender_preference
)
SELECT 
	gender, favorite_genre, percentage
FROM final_result
WHERE rank_position = 1;



-- Where user's get bored from Netflix & has Churned
SELECT 
    region,
    COUNT(*) AS Total_Churned_User
FROM netflix_customer_churn.netflix_customer_churn
WHERE churned = 1
GROUP BY region
ORDER BY Total_Churned_User DESC;



-- Which is the most demaned subscription by region
WITH Regional_Subscription AS (SELECT 
    region,
    subscription_type,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY region), 2) AS Percentage
FROM netflix_customer_churn.netflix_customer_churn
GROUP BY region, subscription_type
),
Demanded_Subscription AS (
	SELECT 
	*,
	RANK() OVER (PARTITION BY region ORDER BY Percentage DESC) AS rank_position 
	FROM Regional_Subscription
)
SELECT 
	region, subscription_type, Percentage
FROM Demanded_Subscription 
WHERE rank_position = 1;



-- Where user's are still enjoying on Netflix & hasn't Churned
SELECT 
    region,
    COUNT(*) AS Total_Churned_User
FROM netflix_customer_churn.netflix_customer_churn
WHERE churned = 0
GROUP BY region
ORDER BY Total_Churned_User DESC;



-- Who are no longer intrested & interested from Netflix content
SELECT 
    gender,
    churned,
    COUNT(*) AS Total_Users
FROM netflix_customer_churn.netflix_customer_churn
GROUP BY gender, churned
ORDER BY gender, churned DESC;



-- What's the average watching hour for Churned & Non-Churned User's
SELECT 
	churned,
    gender,
    ROUND(AVG(watch_hours),2) AS Avg_Watching_Hour
FROM netflix_customer_churn.netflix_customer_churn
GROUP BY churned, gender
ORDER BY churned;



-- Which Subscription is unable to give satisfaction to the user's on Netflix
SELECT 
	subscription_type,
    churned,
    monthly_fee,
    COUNT(*) AS Total_Users
FROM netflix_customer_churn.netflix_customer_churn
GROUP BY subscription_type, churned, monthly_fee
ORDER BY subscription_type, churned;



-- Which is the most demanded device for Users to watch
SELECT 
	device,
    COUNT(*) AS Total_Users
FROM netflix_customer_churn.netflix_customer_churn
GROUP BY device
ORDER BY device;



-- What percentage of user's are loosing intrest in Netflix by device
SELECT 
    device,
    ROUND(100 * SUM(CASE WHEN churned = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS Churn_Percentage
FROM netflix_customer_churn.netflix_customer_churn
GROUP BY device
ORDER BY Churn_Percentage DESC;



-- Which is more and less favorite Genre on Netflix
SELECT 
	favorite_genre,
    churned,
    COUNT(*) AS Total_Users
FROM netflix_customer_churn.netflix_customer_churn
GROUP BY favorite_genre, churned
ORDER BY favorite_genre, churned;



-- Which is the most favorite genre by region 
WITH Favorite_Genre AS (SELECT 
	region,
    favorite_genre,
    COUNT(*) AS Total_Users,
    RANK() OVER (PARTITION BY region ORDER BY COUNT(*) DESC) as `rank`
FROM netflix_customer_churn.netflix_customer_churn
GROUP BY region, favorite_genre
)
SELECT 
	region, favorite_genre
FROM Favorite_Genre
WHERE `rank` = 1;



-- Average Watching hour by each Gender
SELECT 
	gender,
    ROUND(AVG(watch_hours),2) AS Avg_Watching_Hours
FROM netflix_customer_churn.netflix_customer_churn
GROUP BY gender;



-- Adding a column in the Database
ALTER TABLE netflix_customer_churn.netflix_customer_churn
ADD COLUMN age_group VARCHAR(10);

-- Turn on the safe mode inside the SQL Update Query 
SET SQL_SAFE_UPDATES = 0;

-- Updating the column with given values
UPDATE netflix_customer_churn.netflix_customer_churn
SET age_group = 
  CASE
    WHEN age BETWEEN 18 AND 25 THEN '18-25'
    WHEN age BETWEEN 26 AND 40 THEN '26-40'
    WHEN age > 40 THEN '40+'
    END;
    
-- Turn Off the safe mode inside the SQL Update Query
SET SQL_SAFE_UPDATES = 1;



-- Which age_group doesn't have time to enjoy on Netfilx
SELECT 
	age_group,
    churned,
    ROUND(100 * COUNT(*) / (SELECT COUNT(*) FROM netflix_customer_churn.netflix_customer_churn), 2) AS Percentage
FROM netflix_customer_churn.netflix_customer_churn
GROUP BY age_group, churned
ORDER BY age_group, churned;



-- What age_group is no longer interested in Netflix by region 
WITH Age_Group_Churned AS (SELECT 
	region,
    age_group,
    ROUND(100 * COUNT(*) / (SELECT COUNT(*) FROM netflix_customer_churn.netflix_customer_churn), 2) AS Percentage
FROM netflix_customer_churn.netflix_customer_churn
WHERE churned = 1
GROUP BY region, age_group
),
Final_Result AS (
	SELECT 
	*,
	RANK() OVER (PARTITION BY region ORDER BY Percentage DESC) AS `rank`
	FROM Age_Group_Churned
)
SELECT 
	region, age_group, Percentage
FROM Final_Result 
WHERE `rank` = 1;



-- Number of profile relation with churned and non-churned users
SELECT 
	number_of_profiles,
    churned,
    ROUND(100 * COUNT(*) / (SELECT COUNT(*) FROM netflix_customer_churn.netflix_customer_churn),2) AS percentage
FROM netflix_customer_churn.netflix_customer_churn
GROUP BY number_of_profiles, churned
ORDER BY number_of_profiles, churned;



-- Which is most feverable payment by region
WITH favorite_payment_method AS (SELECT 
		region,
		payment_method,
		ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY region), 2) AS region_percentage
		FROM netflix_customer_churn.netflix_customer_churn
		GROUP BY region, payment_method
		ORDER BY region, payment_method
),
final_result AS (
		SELECT 
		*, 
		RANK() OVER (PARTITION BY region ORDER BY region_percentage DESC) AS `rank`
		FROM favorite_payment_method
)
SELECT 
	region, payment_method, region_percentage
FROM final_result 
WHERE `rank` = 1;

-- Thank you for exploring my analysis!