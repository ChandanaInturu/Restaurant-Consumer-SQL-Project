use restaurantsdb;

-- Objective: 
-- Using the WHERE clause to filter data based on specific criteria.

-- 1.List all details of consumers who live in the city of 'Cuernavaca'.
select * 
from consumers
where city = 'Cuernavaca';

-- 2. Find the Consumer_ID, Age, and Occupation of all consumers who are 'Students' AND are 'Smokers'.
select distinct Consumer_ID, Age, Occupation
from consumers
where occupation = 'Student' and smoker = "Yes";

select distinct Consumer_ID, Age, Occupation, smoker
from consumers
where occupation = 'Student' and smoker = "Yes";

-- 3. List the Name, City, Alcohol_Service, and Price of all restaurants that serve 'Wine & Beer' and have a 'Medium' price level.
select distinct Name, City, Alcohol_Service, Price
from restaurants
where alcohol_service = 'Wine & Beer' and price = 'Medium';

-- 4. Find the names and cities of all restaurants that are part of a 'Franchise'.
select distinct Name, City
from restaurants
where franchise = 'Yes';

select distinct Name, City, FRANCHISE
from restaurants
where franchise = 'Yes';

-- 5.	Show the Consumer_ID, Restaurant_ID, and Overall_Rating for all ratings where the Overall_Rating was 'Highly Satisfactory' 
-- (which corresponds to a value of 2, according to the data dictionary).

select distinct Consumer_ID, Restaurant_ID, Overall_Rating
from ratings
where Overall_Rating = 2;

-- Questions JOINs with Subqueries

-- 1. List the names and cities of all restaurants that have an Overall_Rating of 2 (Highly Satisfactory) from at least one consumer.
select distinct NAME, City
from restaurants
join ratings on restaurants.RESTAURANT_ID = ratings.RESTAURANT_ID
where OVERALL_RATING = 2;

select distinct NAME, City, OVERALL_RATING
from restaurants
join ratings on restaurants.RESTAURANT_ID = ratings.RESTAURANT_ID
where OVERALL_RATING = 2;

-- 2. Find the Consumer_ID and Age of consumers who have rated restaurants located in 'San Luis Potosi'.
select distinct consumers.CONSUMER_ID, consumers.AGE
from consumers
join ratings on consumers.CONSUMER_ID = ratings.CONSUMER_ID
join restaurants on ratings.RESTAURANT_ID = restaurants.RESTAURANT_ID
where restaurants.CITY = 'San Luis Potosi';

-- 3. List the names of restaurants that serve 'Mexican' cuisine and have been rated by consumer 'U1001'.
select distinct restaurants.NAME
from restaurants
join restaurant_cuisines on restaurants.RESTAURANT_ID = restaurant_cuisines.RESTAURANT_ID
join ratings on restaurants.RESTAURANT_ID = ratings.RESTAURANT_ID
where restaurant_cuisines.CUISINE = 'Mexican' and ratings.CONSUMER_ID = 'U1001';

-- 4. Find all details of consumers who prefer 'American' cuisine AND have a 'Medium' budget.
select *
from consumers
join consumer_preferences on consumers.CONSUMER_ID = consumer_preferences.CONSUMER_ID
where consumer_preferences.PREFERRED_CUISINE = 'American' and consumers.BUDGET = 'Medium';

-- 5. List restaurants (Name, City) that have received a Food_Rating lower than the average Food_Rating across all rated restaurants.
select distinct restaurants.NAME, restaurants.CITY
from restaurants
join ratings on restaurants.RESTAURANT_ID = ratings.RESTAURANT_ID
where ratings.FOOD_RATING < (select avg(FOOD_RATING) from ratings);

-- 6. Find consumers (Consumer_ID, Age, Occupation) 
-- who have rated at least one restaurant but have NOT rated any restaurant that serves 'Italian' cuisine.
SELECT DISTINCT c.Consumer_ID, c.Age, c.Occupation
FROM consumers c
WHERE c.Consumer_ID IN (
    SELECT DISTINCT Consumer_ID FROM ratings
)
AND c.Consumer_ID NOT IN (
    SELECT DISTINCT rat.Consumer_ID
    FROM ratings rat
    JOIN restaurant_cuisines rc ON rat.Restaurant_ID = rc.Restaurant_ID
    WHERE rc.Cuisine = 'Italian'
);

-- 7. List restaurants (Name) that have received ratings from consumers older than 30.
select distinct restaurants.NAME
from restaurants
join ratings on restaurants.RESTAURANT_ID = ratings.RESTAURANT_ID
join consumers on ratings.CONSUMER_ID = consumers.CONSUMER_ID
where consumers.AGE > 30;

-- 8. Find the Consumer_ID and Occupation of consumers whose preferred cuisine is 'Mexican' 
-- and who have given an Overall_Rating of 0 to at least one restaurant (any restaurant).
select distinct consumers.CONSUMER_ID, consumers.OCCUPATION
from consumers
join consumer_preferences on consumers.CONSUMER_ID = consumer_preferences.CONSUMER_ID
join ratings on consumers.CONSUMER_ID = ratings.CONSUMER_ID
where consumer_preferences.PREFERRED_CUISINE = 'Mexican' and ratings.OVERALL_RATING = 0;

-- 9. List the names and cities of restaurants that serve 'Pizzeria' cuisine 
-- and are located in a city where at least one 'Student' consumer lives.
select distinct restaurants.NAME, restaurants.CITY
from restaurants
join restaurant_cuisines on restaurants.RESTAURANT_ID = restaurant_cuisines.RESTAURANT_ID
WHERE restaurant_cuisines.CUISINE = 'Pizzeria'
AND restaurants.City IN (
      SELECT DISTINCT City
      FROM consumers
      WHERE Occupation = 'Student'
  );

-- 10. Find consumers (Consumer_ID, Age) who are 'Social Drinkers' and have rated a restaurant that has 'No' parking.
select distinct consumers.CONSUMER_ID, consumers.AGE
from consumers
join ratings on consumers.CONSUMER_ID = ratings.CONSUMER_ID
join restaurants on ratings.RESTAURANT_ID = restaurants.RESTAURANT_ID
where consumers.DRINK_LEVEL = 'Social Drinkers' and restaurants.PARKING = 'No';

-- Questions Emphasizing WHERE Clause and Order of Execution

-- 1. List Consumer_IDs and the count of restaurants they've rated, but only for consumers who are 'Students'. 
-- Show only students who have rated more than 2 restaurants.
SELECT ratings.Consumer_ID, COUNT(DISTINCT ratings.Restaurant_ID) AS Rated_Restaurants
FROM ratings
JOIN consumers ON ratings.Consumer_ID = consumers.Consumer_ID
WHERE consumers.Occupation = 'Student'
GROUP BY ratings.Consumer_ID
HAVING COUNT(DISTINCT ratings.Restaurant_ID) > 2;

-- 2.	We want to categorize consumers by an 'Engagement_Score' which is their Age divided by 10 (integer division). 
-- List the Consumer_ID, Age, and this calculated Engagement_Score, but only for consumers 
-- whose Engagement_Score would be exactly 2 and who use 'Public' transportation.
SELECT Consumer_ID, Age, FLOOR(Age / 10) AS Engagement_Score
FROM consumers
WHERE FLOOR(Age / 10) = 2
  AND Transportation_Method = 'Public';

-- 3.	For each restaurant, calculate its average Overall_Rating. Then, list the restaurant Name, City, and its calculated average Overall_Rating, 
-- but only for restaurants located in 'Cuernavaca' AND whose calculated average Overall_Rating is greater than 1.0.
SELECT restaurants.Name, restaurants.City, ROUND(AVG(ratings.Overall_Rating), 2) AS Avg_Overall_Rating
FROM restaurants
JOIN ratings ON restaurants.Restaurant_ID = ratings.Restaurant_ID
WHERE restaurants.City = 'Cuernavaca'
GROUP BY restaurants.Name, restaurants.City
HAVING AVG(ratings.Overall_Rating) > 1.0;

-- 4. Find consumers (Consumer_ID, Age) who are 'Married' and whose Food_Rating for any restaurant is equal to their Service_Rating for that 
-- same restaurant, but only consider ratings where the Overall_Rating was 2.
SELECT DISTINCT consumers.Consumer_ID, consumers.Age
FROM consumers
JOIN ratings ON consumers.Consumer_ID = ratings.Consumer_ID
WHERE consumers.Marital_Status = 'Married'
  AND ratings.Overall_Rating = 2
  AND ratings.Food_Rating = ratings.Service_Rating;

-- 5. List Consumer_ID, Age, and the Name of any restaurant they rated, but only for consumers who are 'Employed' 
-- and have given a Food_Rating of 0 to at least one restaurant located in 'Ciudad Victoria'.
SELECT DISTINCT consumers.Consumer_ID, consumers.Age, restaurants.Name
FROM consumers
JOIN ratings ON consumers.Consumer_ID = ratings.Consumer_ID
JOIN restaurants ON ratings.Restaurant_ID = restaurants.Restaurant_ID
WHERE consumers.Occupation = 'Employed'
  AND ratings.Food_Rating = 0
  AND restaurants.City = 'Ciudad Victoria';

-- Advanced SQL Concepts: Derived Tables, CTEs, Window Functions, Views, Stored Procedures

-- 1.	Using a CTE, find all consumers who live in 'San Luis Potosi'. 
-- Then, list their Consumer_ID, Age, and the Name of any Mexican restaurant they have rated with an Overall_Rating of 2.

WITH SanLuisConsumers AS (
    SELECT Consumer_ID, Age
    FROM consumers
    WHERE City = 'San Luis Potosi'
)
SELECT DISTINCT sl.Consumer_ID, sl.Age, restaurants.Name as Restaurant_Names
FROM SanLuisConsumers sl
JOIN ratings ON sl.Consumer_ID = ratings.Consumer_ID
JOIN restaurants ON ratings.Restaurant_ID = restaurants.Restaurant_ID
JOIN restaurant_cuisines ON restaurants.Restaurant_ID = restaurant_cuisines.Restaurant_ID
WHERE restaurant_cuisines.Cuisine = 'Mexican'
  AND ratings.Overall_Rating = 2;

-- 2. For each Occupation, find the average age of consumers. Only consider consumers who have made at least one rating. 
-- (Use a derived table to get consumers who have rated).

SELECT Occupation, ROUND(AVG(Age), 2) AS Avg_Age
FROM (
    SELECT DISTINCT consumers.Consumer_ID, consumers.Age, consumers.Occupation
    FROM consumers
    JOIN ratings ON consumers.Consumer_ID = ratings.Consumer_ID
) rated_consumers
GROUP BY Occupation;

-- 3. Using a CTE to get all ratings for restaurants in 'Cuernavaca', rank these ratings within each restaurant based on Overall_Rating 
-- (highest first). Display Restaurant_ID, Consumer_ID, Overall_Rating, and the RatingRank.

WITH CuernavacaRatings AS (
    SELECT restaurants.Restaurant_ID, ratings.Consumer_ID, ratings.Overall_Rating
    FROM restaurants
    JOIN ratings ON restaurants.Restaurant_ID = ratings.Restaurant_ID
    WHERE restaurants.City = 'Cuernavaca'
)
SELECT Restaurant_ID, Consumer_ID, Overall_Rating,
       RANK() OVER (PARTITION BY Restaurant_ID ORDER BY Overall_Rating DESC) AS RatingRank
FROM CuernavacaRatings;

-- 4. For each rating, show the Consumer_ID, Restaurant_ID, Overall_Rating, 
-- and also display the average Overall_Rating given by that specific consumer across all their ratings.

SELECT ratings.Consumer_ID, ratings.Restaurant_ID, ratings.Overall_Rating,
       ROUND(AVG(ratings.Overall_Rating) OVER (PARTITION BY ratings.Consumer_ID), 2) AS Avg_By_Consumer
FROM ratings;

-- 5.	Using a CTE, identify students who have a 'Low' budget. Then, for each of these students, 
-- list their top 3 most preferred cuisines based on the order they appear in the Consumer_Preferences table 
-- (assuming no explicit preference order, use Consumer_ID, Preferred_Cuisine to define order for ROW_NUMBER).

WITH LowBudgetStudents AS (
    SELECT Consumer_ID
    FROM consumers
    WHERE Occupation = 'Student' AND Budget = 'Low'
),
RankedCuisines AS (
    SELECT lbs.Consumer_ID, cp.Preferred_Cuisine,
           ROW_NUMBER() OVER (PARTITION BY lbs.Consumer_ID ORDER BY cp.Preferred_Cuisine) AS rn
    FROM LowBudgetStudents lbs
    JOIN consumer_preferences cp ON lbs.Consumer_ID = cp.Consumer_ID
)
SELECT Consumer_ID, Preferred_Cuisine
FROM RankedCuisines
WHERE rn <= 3;

-- 6. Consider all ratings made by 'Consumer_ID' = 'U1008'. For each rating, show the Restaurant_ID, Overall_Rating, 
-- and the Overall_Rating of the next restaurant they rated (if any), ordered by Restaurant_ID 
-- (as a proxy for time if rating time isn't available). Use a derived table to filter for the consumer's ratings first. 

WITH U1008Ratings AS (
    SELECT Restaurant_ID, Overall_Rating,
           LEAD(Overall_Rating) OVER (ORDER BY Restaurant_ID) AS Next_Rating
    FROM ratings
    WHERE Consumer_ID = 'U1008'
)
SELECT * FROM U1008Ratings;

-- 7. Create a VIEW named HighlyRatedMexicanRestaurants that shows the Restaurant_ID, Name, 
-- and City of all Mexican restaurants that have an average Overall_Rating greater than 1.5.

CREATE OR REPLACE VIEW HighlyRatedMexicanRestaurants AS
SELECT restaurants.Restaurant_ID, restaurants.Name, restaurants.City
FROM restaurants 
JOIN restaurant_cuisines ON restaurants.Restaurant_ID = restaurant_cuisines.Restaurant_ID
JOIN ratings ON restaurants.Restaurant_ID = ratings.Restaurant_ID
WHERE restaurant_cuisines.Cuisine = 'Mexican'
GROUP BY restaurants.Restaurant_ID, restaurants.Name, restaurants.City
HAVING AVG(ratings.Overall_Rating) > 1.5;

select * from HighlyRatedMexicanRestaurants;

-- 8.	First, ensure the HighlyRatedMexicanRestaurants view from Q7 exists. 
-- Then, using a CTE to find consumers who prefer 'Mexican' cuisine, list those consumers (Consumer_ID) 
-- who have not rated any restaurant listed in the HighlyRatedMexicanRestaurants view.

WITH MexicanLovers AS (
    SELECT DISTINCT consumer_preferences.Consumer_ID
    FROM consumer_preferences
    WHERE consumer_preferences.Preferred_Cuisine = 'Mexican'
)
SELECT MexicanLovers.Consumer_ID
FROM MexicanLovers 
WHERE MexicanLovers.Consumer_ID NOT IN (
    SELECT DISTINCT ratings.Consumer_ID
    FROM ratings
    JOIN HighlyRatedMexicanRestaurants hr ON ratings.Restaurant_ID = hr.Restaurant_ID
);

-- 9. Create a stored procedure GetRestaurantRatingsAboveThreshold that accepts a Restaurant_ID and a minimum Overall_Rating as input. 
-- It should return the Consumer_ID, Overall_Rating, Food_Rating, and Service_Rating for that restaurant 
-- where the Overall_Rating meets or exceeds the threshold.

DELIMITER //
CREATE PROCEDURE GetRestaurantRatingsAboveThreshold(IN rest_id VARCHAR(10), IN min_rating INT)
BEGIN
    SELECT Consumer_ID, Overall_Rating, Food_Rating, Service_Rating
    FROM ratings
    WHERE Restaurant_ID = rest_id
      AND Overall_Rating >= min_rating;
END //
DELIMITER ;
-- Example:
CALL GetRestaurantRatingsAboveThreshold(132583, 2);

-- 10.	Identify the top 2 highest-rated (by Overall_Rating) restaurants for each cuisine type. 
-- If there are ties in rating, include all tied restaurants. 
-- Display Cuisine, Restaurant_Name, City, and Overall_Rating.

WITH CuisineRatings AS (
    SELECT rc.Cuisine, restaurants.Name AS Restaurant_Name, restaurants.City, ratings.Overall_Rating,
           DENSE_RANK() OVER (PARTITION BY rc.Cuisine ORDER BY ratings.Overall_Rating DESC) AS rnk
    FROM restaurant_cuisines rc
    JOIN restaurants ON rc.Restaurant_ID = restaurants.Restaurant_ID
    JOIN ratings ON restaurants.Restaurant_ID = ratings.Restaurant_ID
)
SELECT Cuisine, Restaurant_Name, City, Overall_Rating
FROM CuisineRatings
WHERE rnk <= 2;

-- 11. First, create a VIEW named ConsumerAverageRatings that lists Consumer_ID and their average Overall_Rating. 
-- Then, using this view and a CTE, find the top 5 consumers by their average overall rating. For these top 5 consumers, 
-- list their Consumer_ID, their average rating, and the number of 'Mexican' restaurants they have rated.

CREATE OR REPLACE VIEW ConsumerAverageRatings AS
SELECT Consumer_ID, ROUND(AVG(Overall_Rating), 2) AS Avg_Overall_Rating
FROM ratings
GROUP BY Consumer_ID;

WITH TopConsumers AS (
    SELECT Consumer_ID, Avg_Overall_Rating
    FROM ConsumerAverageRatings
    ORDER BY Avg_Overall_Rating DESC
    LIMIT 5
)
SELECT TopConsumers.Consumer_ID, TopConsumers.Avg_Overall_Rating,
       COUNT(DISTINCT ratings.Restaurant_ID) AS Mexican_Restaurants_Rated
FROM TopConsumers
JOIN ratings ON TopConsumers.Consumer_ID = ratings.Consumer_ID
JOIN restaurant_cuisines ON ratings.Restaurant_ID = restaurant_cuisines.Restaurant_ID
WHERE restaurant_cuisines.Cuisine = 'Mexican'
GROUP BY TopConsumers.Consumer_ID, TopConsumers.Avg_Overall_Rating;

-- 12. Create a stored procedure named GetConsumerSegmentAndRestaurantPerformance that accepts a Consumer_ID as input.
-- The procedure should:
-- 1.	Determine the consumer's "Spending Segment" based on their Budget:
○	'Low' -> 'Budget Conscious'
○	'Medium' -> 'Moderate Spender'
○	'High' -> 'Premium Spender'
○	NULL or other -> 'Unknown Budget'
-- 2.	For all restaurants rated by this consumer:
○	List the Restaurant_Name.
○	The Overall_Rating given by this consumer.
○	The average Overall_Rating this restaurant has received from all consumers (not just the input consumer).
○	A "Performance_Flag" indicating if the input consumer's rating for that restaurant is 'Above Average', 'At Average', or 'Below Average' compared to the restaurant's overall average rating.
○	Rank these restaurants for the input consumer based on the Overall_Rating they gave (highest rating = rank 1).

DELIMITER //
CREATE PROCEDURE GetConsumerSegmentAndRestaurantPerformance(IN p_Consumer_ID VARCHAR(10))
BEGIN
    -- Step 1: Determine the consumer's spending segment
    DECLARE spending_segment VARCHAR(50);

    SELECT CASE
               WHEN Budget = 'Low' THEN 'Budget Conscious'
               WHEN Budget = 'Medium' THEN 'Moderate Spender'
               WHEN Budget = 'High' THEN 'Premium Spender'
               ELSE 'Unknown Budget'
           END
    INTO spending_segment
    FROM consumers
    WHERE Consumer_ID = p_Consumer_ID;

    -- Step 2: Return restaurant performance for this consumer
    SELECT
        spending_segment AS Spending_Segment,
        r.Name AS Restaurant_Name,
        rat.Overall_Rating AS Consumer_Rating,
        ROUND(avg_r.Avg_Overall_Rating, 2) AS Avg_Restaurant_Rating,
        CASE
            WHEN rat.Overall_Rating > avg_r.Avg_Overall_Rating THEN 'Above Average'
            WHEN rat.Overall_Rating = avg_r.Avg_Overall_Rating THEN 'At Average'
            ELSE 'Below Average'
        END AS Performance_Flag,
        RANK() OVER (ORDER BY rat.Overall_Rating DESC) AS Consumer_Rank
    FROM ratings rat
    JOIN restaurants r ON rat.Restaurant_ID = r.Restaurant_ID
    JOIN (
        SELECT Restaurant_ID, AVG(Overall_Rating) AS Avg_Overall_Rating
        FROM ratings
        GROUP BY Restaurant_ID
    ) avg_r ON rat.Restaurant_ID = avg_r.Restaurant_ID
    WHERE rat.Consumer_ID = p_Consumer_ID
    ORDER BY rat.Overall_Rating DESC;
END //

DELIMITER ;
-- Example
CALL GetConsumerSegmentAndRestaurantPerformance('U1001');


drop procedure GetConsumerSegmentAndRestaurantPerformance;












