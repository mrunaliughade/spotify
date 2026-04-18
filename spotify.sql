-- Creating table
DROP TABLE IF EXISTS spotify;

CREATE TABLE spotify (
    artist        VARCHAR(255),
    track         VARCHAR(255),
    album         VARCHAR(255),
    album_type    VARCHAR(50),
    danceability  FLOAT,
    energy        FLOAT,
    loudness      FLOAT,
    speechiness   FLOAT,
    acousticness  FLOAT,
    instrumentalness FLOAT,
    liveness      FLOAT,
    valence       FLOAT,
    tempo         FLOAT,
    duration_min  FLOAT,
    title         VARCHAR(255),
    channel       VARCHAR(255),
    views         FLOAT,
    likes         BIGINT,
    comments      BIGINT,
    licensed      BOOLEAN,
    official_video BOOLEAN,
    stream        BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);

-- EDA

SELECT COUNT(*) FROM spotify;

SELECT COUNT(DISTINCT artist) FROM spotify;

SELECT COUNT(DISTINCT album) FROM spotify;

SELECT DISTINCT album_type FROM spotify;

SELECT MAX(duration_min) FROM spotify;
SELECT MIN(duration_min) FROM spotify;

SELECT * FROM spotify
WHERE duration_min = 0;

DELETE FROM spotify
WHERE duration_min = 0;

SELECT DISTINCT channel FROM spotify;

SELECT DISTINCT most_played_on FROM spotify;

-- Q1: Retrieve the names of all tracks that have more than 1 billion streams
SELECT track
FROM spotify
WHERE stream > 1000000000;

-- Q2: List all albums along with their respective artists
SELECT DISTINCT album, artist
FROM spotify
ORDER BY 1;

-- Q3: Get the total number of comments for tracks where licensed = TRUE
SELECT SUM(comments) AS total_comments
FROM spotify
WHERE licensed = TRUE;

-- Q4: Find all tracks that belong to the album type single
SELECT track
FROM spotify
WHERE album_type = 'single';

-- Q5: Count the total number of tracks by each artist
SELECT artist, COUNT(*) AS total_tracks
FROM spotify
GROUP BY artist
ORDER BY 2 DESC;

-- Q6: Average danceability per album
SELECT album, AVG(danceability) AS avg_danceability
FROM spotify
GROUP BY album
ORDER BY 2 DESC;

-- Q7: Top 5 tracks with the highest energy values
SELECT track, MAX(energy)
FROM spotify
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- Q8: Tracks with views and likes where `official_video = TRUE`
SELECT track,
       SUM(views) AS total_views,
       SUM(likes) AS total_likes
FROM spotify
WHERE official_video = TRUE
GROUP BY 1
ORDER BY 2 DESC;

-- Q9:Total views per album
SELECT album,
       track,
       SUM(views) AS total_views
FROM spotify
GROUP BY 1, 2
ORDER BY 3 DESC;

-- Q10:Tracks streamed more on Spotify than YouTube
SELECT * FROM (
    SELECT 
        track,
        COALESCE(SUM(CASE WHEN most_played_on = 'Youtube' THEN stream END), 0) AS streamed_on_youtube,
        COALESCE(SUM(CASE WHEN most_played_on = 'Spotify' THEN stream END), 0) AS streamed_on_spotify
    FROM spotify
    GROUP BY 1
) AS t1
WHERE streamed_on_spotify > streamed_on_youtube
  AND streamed_on_youtube <> 0;

-- Q11:Top 3 most-viewed tracks per artist using window functions
WITH ranking_artist AS (
    SELECT 
        artist,
        track,
        SUM(views) AS total_views,
        DENSE_RANK() OVER (PARTITION BY artist ORDER BY SUM(views) DESC) AS rank
    FROM spotify
    GROUP BY 1, 2
    ORDER BY 1, 3 DESC
)
SELECT *
FROM ranking_artist
WHERE rank <= 3;

-- Q12: Tracks where liveness is above the dataset average
SELECT track, artist, liveness
FROM spotify
WHERE liveness > (SELECT AVG(liveness) FROM spotify);

-- Q13: Energy difference (highest vs lowest) per album using a CTE
WITH cte AS (
    SELECT 
        album,
        MAX(energy) AS highest_energy,
        MIN(energy) AS lowest_energy
    FROM spotify
    GROUP BY 1
)
SELECT 
    album,
    highest_energy - lowest_energy AS energy_diff
FROM cte
ORDER BY 2 DESC;

-- Q14: Tracks where energy-to-liveness ratio > 1.2
SELECT track, artist,
       energy,
       liveness,
       energy / liveness AS energy_liveness_ratio
FROM spotify
WHERE liveness > 0
  AND (energy / liveness) > 1.2
ORDER BY energy_liveness_ratio DESC;

-- Q15: Cumulative sum of likes ordered by views using window functions
SELECT track,
       views,
       likes,
       SUM(likes) OVER (ORDER BY views ASC) AS cumulative_likes
FROM spotify
ORDER BY views ASC;

-- Query Optimization
-- Before index
EXPLAIN ANALYZE
SELECT artist, track, views
FROM spotify
WHERE artist = 'Gorillaz'
  AND most_played_on = 'Youtube'
ORDER BY stream DESC
LIMIT 25;

-- Creating index on artist
CREATE INDEX idx_artist ON spotify(artist);

-- After index
EXPLAIN ANALYZE
SELECT artist, track, views
FROM spotify
WHERE artist = 'Gorillaz'
  AND most_played_on = 'Youtube'
ORDER BY stream DESC
LIMIT 25;







