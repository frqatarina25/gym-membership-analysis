-- Verify Import
USE gym_database;
GO

SELECT *
FROM gym_data;

-- 1. Which member type has the most attendance?
SELECT membership_type, COUNT(*) AS count_membership_type
FROM gym_data
GROUP BY membership_type
ORDER BY membership_type ASC;

-- 2. Which days of the week have the most attendance
SELECT  DATENAME(weekday, visit_date) AS visit_day, COUNT(*) AS total_visited_days
FROM gym_data
GROUP BY DATENAME(weekday, visit_date);


-- 3. Which workout type is most popular?
SELECT DISTINCT workout_type, COUNT(*) AS total_workout_type
FROM gym_data
GROUP BY workout_type;

-- 4. Which calories burned the most in each workout_type, based on the average of duration of each workout type? (CTE)
WITH avg_duration AS (
    SELECT workout_type,
           AVG(workout_duration_minutes) AS avg_duration_minutes
    FROM gym_data
    WHERE attendance_status = 'Present'
    GROUP BY workout_type
)
SELECT g.workout_type,
       ad.avg_duration_minutes,
       ROUND(AVG(calories_burned / workout_duration_minutes) * ad.avg_duration_minutes, 2) AS calories_for_avg_duration
FROM gym_data g
JOIN avg_duration ad
    ON g.workout_type = ad.workout_type
WHERE g.attendance_status = 'Present'
GROUP BY g.workout_type, ad.avg_duration_minutes
ORDER BY calories_for_avg_duration DESC;

-- 5. Which workout type is most popular for men and women?
SELECT gender, workout_type, COUNT(*) AS count_workout_type
FROM gym_data
GROUP BY gender, workout_type
ORDER BY gender, workout_type ASC;

-- 6. Do membership types prefer different workout types?
SELECT membership_type, workout_type, COUNT(*) AS total_membership
FROM gym_data
GROUP BY membership_type, workout_type
ORDER BY membership_type ASC;


-- 7. What timings are the most popular? And how old are they?
SELECT 
    CASE 
        WHEN DATEPART(HOUR, check_in_time) BETWEEN 6 AND 11 THEN 'Morning'
        WHEN DATEPART(HOUR, check_in_time) BETWEEN 12 AND 17 THEN 'Afternoon'
        WHEN DATEPART(HOUR, check_in_time) BETWEEN 18 AND 21 THEN 'Evening'
        ELSE 'Night'
    END AS time_of_day,
    CASE 
        WHEN age BETWEEN 13 AND 19 THEN 'Teen'
        WHEN age BETWEEN 20 AND 29 THEN 'Young Adult'
        WHEN age BETWEEN 30 AND 39 THEN 'Adult'
        WHEN age BETWEEN 40 AND 49 THEN 'Middle Age'
        ELSE 'Senior'
    END AS age_group,
    COUNT(*) AS total_checkins
FROM gym_data
WHERE attendance_status = 'Present'
GROUP BY 
    CASE 
        WHEN DATEPART(HOUR, check_in_time) BETWEEN 6 AND 11 THEN 'Morning'
        WHEN DATEPART(HOUR, check_in_time) BETWEEN 12 AND 17 THEN 'Afternoon'
        WHEN DATEPART(HOUR, check_in_time) BETWEEN 18 AND 21 THEN 'Evening'
        ELSE 'Night'
    END,
    CASE 
        WHEN age BETWEEN 13 AND 19 THEN 'Teen'
        WHEN age BETWEEN 20 AND 29 THEN 'Young Adult'
        WHEN age BETWEEN 30 AND 39 THEN 'Adult'
        WHEN age BETWEEN 40 AND 49 THEN 'Middle Age'
        ELSE 'Senior'
    END
ORDER BY time_of_day, total_checkins DESC;

-- 8. Are certain workouts more popular at specific check in times?
SELECT 
    CASE 
        WHEN DATEPART(HOUR, check_in_time) BETWEEN 6 AND 11 THEN 'Morning'
        WHEN DATEPART(HOUR, check_in_time) BETWEEN 12 AND 17 THEN 'Afternoon'
        WHEN DATEPART(HOUR, check_in_time) BETWEEN 18 AND 21 THEN 'Evening'
        ELSE 'Night'
    END AS time_of_day,
    workout_type,
    COUNT(*) AS total_checkins
FROM gym_data
WHERE attendance_status = 'Present'
GROUP BY 
    CASE 
        WHEN DATEPART(HOUR, check_in_time) BETWEEN 6 AND 11 THEN 'Morning'
        WHEN DATEPART(HOUR, check_in_time) BETWEEN 12 AND 17 THEN 'Afternoon'
        WHEN DATEPART(HOUR, check_in_time) BETWEEN 18 AND 21 THEN 'Evening'
        ELSE 'Night'
    END,
    workout_type
ORDER BY time_of_day, workout_type;

-- 9. Does age influence their workout types?
SELECT 
    CASE 
        WHEN age BETWEEN 13 AND 19 THEN 'Teen'
        WHEN age BETWEEN 20 AND 29 THEN 'Young Adult'
        WHEN age BETWEEN 30 AND 39 THEN 'Adult'
        WHEN age BETWEEN 40 AND 49 THEN 'Middle Age'
        ELSE 'Senior'
    END AS age_group,
    workout_type,
    COUNT(*) AS total_sessions
FROM gym_data
WHERE attendance_status = 'Present'
GROUP BY 
    CASE 
        WHEN age BETWEEN 13 AND 19 THEN 'Teen'
        WHEN age BETWEEN 20 AND 29 THEN 'Young Adult'
        WHEN age BETWEEN 30 AND 39 THEN 'Adult'
        WHEN age BETWEEN 40 AND 49 THEN 'Middle Age'
        ELSE 'Senior'
    END,
    workout_type
ORDER BY age_group, total_sessions DESC;

-- 10. Which membership type do each age group have?
SELECT
    membership_type,
    CASE 
        WHEN age BETWEEN 13 AND 19 THEN 'Teen'
        WHEN age BETWEEN 20 AND 29 THEN 'Young Adult'
        WHEN age BETWEEN 30 AND 39 THEN 'Adult'
        WHEN age BETWEEN 40 AND 49 THEN 'Middle Age'
        ELSE 'Senior'
    END AS age_group,
    COUNT(*) AS total_members
FROM gym_data
GROUP BY 
    membership_type,
    CASE 
        WHEN age BETWEEN 13 AND 19 THEN 'Teen'
        WHEN age BETWEEN 20 AND 29 THEN 'Young Adult'
        WHEN age BETWEEN 30 AND 39 THEN 'Adult'
        WHEN age BETWEEN 40 AND 49 THEN 'Middle Age'
        ELSE 'Senior'
    END
ORDER BY membership_type, age_group;


-- 11. Total number of attendance
SELECT COUNT(*) AS total_attendance
FROM gym_data;

-- 12. Total number of present + absent
SELECT COUNT(*) AS total_attendance,
COUNT(CASE WHEN attendance_status = 'Absent' THEN 1 END) AS total_absent,
COUNT(CASE WHEN attendance_status = 'Present' THEN 1 END) AS total_present
FROM gym_data;
