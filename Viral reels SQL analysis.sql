Create database viral_reels;
use viral_reels;

select * from reels_analysis;

# 1. Which niches generate the highest revenue potential 
# 	 per video based on weighted performance factors?

select niche, count(*) as total_videos, 
round(avg(views_total),2) as Avg_views,
round(avg(hook_strength_score),2) as Avg_hook_strength,
round(avg(retention_rate),2) as Avg_retention_rate,
	round(
    (round(avg(views_total),2)*0.6+
	 round(avg(hook_strength_score),2)*0.3+
     round(avg(retention_rate),2)*0.1),2) 
		as Revenue_rate
from reels_analysis
group by niche
order by Revenue_rate desc
limit 5;

# 2. Which video durations (short/medium/long) produce the most 
# 	“late viral” videos that scale views after hour 1?

SELECT duration_categories, ROUND(AVG(duration_sec),2) AS Avg_duration,COUNT(*) AS Total_videos,
    SUM(CASE
        WHEN growth_category = 'late_viral' THEN 1
        ELSE 0
    END) AS count_of_late_viral,
ROUND(sum(growth_category='late_viral') /count(*)*100,2) AS Pct_of_late_viral
FROM reels_analysis
GROUP BY duration_categories
ORDER BY pct_of_late_viral DESC ;

# 3. Identify high-retention videos with below the average first-hour views
# 	→ missed monetization opportunities

SELECT *
FROM reels_analysis
WHERE views_first_hour <= (SELECT 
            AVG(views_first_hour)
        FROM reels_analysis)
ORDER BY retention_rate DESC
LIMIT 5; 


# 4. Which music types deliver the best long-tail revenue potential (late viral growth)?

SELECT music_type, COUNT(*) AS total_videos,ROUND(AVG(growth_percentage),2) AS Avg_growth_PCT, 
SUM(growth_category = 'late_viral') AS late_viral_videos
FROM reels_analysis
GROUP BY music_type
ORDER BY late_viral_videos DESC;

# 5. What upload days or times correlate with the highest ROI-per-view video patterns?

SELECT dayname(upload_time) AS Upload_day, 
	round(round(avg(views_total),2)*0.6+
		round(avg(hook_strength_score),2)*0.3+
		round(avg(retention_rate),2)*0.1,2 )
			AS ROI
FROM reels_analysis
GROUP BY Upload_day
ORDER BY ROI desc;

# 6. Find the “Top 3 performers” in each niche based on complete performance score.

WITH Ranked AS
(
SELECT niche, views_total,video_id, 
rank() over(partition by niche order by views_total desc) as ranking
FROM reels_analysis
)
SELECT *
FROM ranked
WHERE ranking <= 3
ORDER BY niche , views_total DESC;


# 7. Detect underperforming niches (below-median total views).

SELECT niche, ROUND(AVG(views_total),2) AS AVG_views
FROM reels_analysis
GROUP BY niche
HAVING AVG_views < (SELECT 
        AVG(views_total)
    FROM reels_analysis)
;

# 8. Find niches that convert high hook strength into actual high retention.

WITH hook_table as 
(SELECT 
    niche,
    ROUND(AVG(hook_strength_score), 2) AS hook_strength,
    ROUND(AVG(retention_rate), 2) AS Retention
FROM reels_analysis
GROUP BY niche
)
SELECT *
FROM hook_table
WHERE retention > hook_strength; 

#9. Top 3 music types for every niche (based on total views)

WITH music_ranking as 

	(SELECT niche , music_type,views_total, 
		RANK() OVER(partition by niche order by views_total desc) AS Ranking
		FROM reels_analysis)
SELECT *
FROM music_ranking
WHERE Ranking < 4
ORDER BY niche , views_total DESC;


select * from reels_analysis;
