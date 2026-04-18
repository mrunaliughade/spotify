# Spotify Data Analysis using SQL

## Overview

I built this project to sharpen my advanced SQL skills on a real-world dataset. The dataset contains Spotify track information — things like artist, album, audio features (danceability, energy, tempo, etc.), and engagement metrics across Spotify and YouTube. The goal was to go from raw data all the way to actionable insights, while also getting hands-on with query optimization.

---

## Tech Stack

- **Database:** PostgreSQL
- **Tools:** pgAdmin 4
- **SQL Concepts Used:** DDL, DML, Aggregations, Subqueries, Joins, Window Functions, CTEs

---

## Database Schema

```sql
DROP TABLE IF EXISTS spotify;

CREATE TABLE spotify (
    artist           VARCHAR(255),
    track            VARCHAR(255),
    album            VARCHAR(255),
    album_type       VARCHAR(50),
    danceability     FLOAT,
    energy           FLOAT,
    loudness         FLOAT,
    speechiness      FLOAT,
    acousticness     FLOAT,
    instrumentalness FLOAT,
    liveness         FLOAT,
    valence          FLOAT,
    tempo            FLOAT,
    duration_min     FLOAT,
    title            VARCHAR(255),
    channel          VARCHAR(255),
    views            FLOAT,
    likes            BIGINT,
    comments         BIGINT,
    licensed         BOOLEAN,
    official_video   BOOLEAN,
    stream           BIGINT,
    energy_liveness  FLOAT,
    most_played_on   VARCHAR(50)
);
```

---

## Project Steps

### 1. Exploratory Data Analysis (EDA)

Before writing any business queries, I explored the dataset to understand its structure and clean out bad data — specifically tracks with a `duration_min` of 0, which were invalid records.

### 2. Business Queries

I categorised the queries into three levels:

**Easy** — basic retrieval, filtering, and aggregations  
**Medium** — grouping, conditional aggregations, multi-column analysis  
**Advanced** — window functions, CTEs, subqueries

### 3. Query Optimization

After writing the advanced queries, I used `EXPLAIN ANALYZE` to profile performance, then created an index on the `artist` column. This brought execution time down from **~7ms to 0.153ms** — a ~97% improvement.

---

## Business Problems Solved

1. Retrieve all tracks with more than 1 billion streams
2. List all albums with their respective artists
3. Get total comments for tracks where `licensed = TRUE`
4. Find all tracks that belong to the `single` album type
5. Count total tracks by each artist
6. Average danceability per album
7. Top 5 tracks with the highest energy values
8. Tracks with views and likes where `official_video = TRUE`
9. Total views per album
10. Tracks streamed more on Spotify than YouTube
11. Top 3 most-viewed tracks per artist using window functions
12. Tracks where liveness is above the dataset average
13. Energy difference (highest vs lowest) per album using a CTE
14. Tracks where energy-to-liveness ratio > 1.2
15. Cumulative sum of likes ordered by views using window functions

---

## Query Optimization

I ran `EXPLAIN ANALYZE` on a query filtering by `artist` before and after adding an index:

```sql
-- Creating index
CREATE INDEX idx_artist ON spotify(artist);
```

| Metric         | Before Index | After Index |
| -------------- | ------------ | ----------- |
| Execution Time | ~7 ms        | 0.153 ms    |
| Planning Time  | 0.17 ms      | 0.152 ms    |

The index made a significant difference and reinforced why indexing matters in production-level database work.

---

## Dataset

[Kaggle — Spotify Dataset](https://www.kaggle.com/datasets/sanjanchaudhari/spotify-dataset)
