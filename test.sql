--Q1
SELECT state.name,
       place.name
FROM state JOIN place ON state.code = place.state_code
WHERE place.name LIKE '%City' AND place.type <> 'city'
ORDER BY state.name,place.name;

--Q2
SELECT state.name,
        COUNT(place.name) AS no_big_city,
        SUM(place.population) AS big_city_population
FROM state JOIN place ON state.code = place.state_code
WHERE place.type = 'city'AND place.population >= 100000
GROUP BY state.name
HAVING  COUNT(place.name)>5 OR SUM(place.population)>=1000000
ORDER BY state.name;

--Q3
WITH Type(type) AS
 (SELECT type
  FROM(SELECT type
       FROM place
       WHERE type IS NOT NULL
       UNION ALL
       SELECT type
       FROM mcd
       WHERE type IS NOT NULL
       UNION ALL
       SELECT type
       FROM county
       WHERE type IS NOT NULL
     ) as sub_query
  GROUP BY type
 ),
PlaceTemp(type, place) AS
(
SELECT type,
       COUNT(place.type)AS place
FROM place
GROUP BY type
),
McdTemp(type, mcd) AS
(
SELECT type,
       COUNT(type)AS mcd
FROM mcd
GROUP BY type
),
CountyTemp(type, county) AS
(
SELECT type,
       COUNT(type)AS county
FROM county
GROUP BY type
)
SELECT Type.type,
       COALESCE(PlaceTemp.place, 0) as place,
       COALESCE(McdTemp.mcd, 0) as mcd,
       COALESCE(CountyTemp.county, 0) as county
FROM Type LEFT JOIN PlaceTemp  ON Type.type = PlaceTemp.type
          LEFT JOIN McdTemp on Type.type = McdTemp.type
          LEFT JOIN CountyTemp on Type.type = CountyTemp.type
GROUP BY Type.type, PlaceTemp.place, McdTemp.mcd, CountyTemp.county
ORDER BY Type.type


--Q4
WITH usa(population,land_area) AS
 (SELECT SUM(CAST(mcd.population AS BIGINT))AS population,
         SUM(CAST(mcd.land_area AS BIGINT))AS land_area
  FROM mcd
 )
 SELECT state.name AS name,
        SUM(CAST(mcd.population AS BIGINT))AS population,
        ROUND(SUM(CAST(mcd.population AS BIGINT))*100.0/usa.population,2) AS pc_population,
        SUM(CAST(mcd.land_area AS BIGINT))AS land_area,
        ROUND(SUM(CAST(mcd.land_area AS BIGINT))*100.0/usa.land_area,2) AS pc_land_area
 FROM state JOIN mcd ON state.code = mcd.state_code, usa
 GROUP BY state.name,usa.population,usa.land_area
 ORDER BY state.name;

--Q5
SELECT state_name,
       county_name,
       population
FROM (SELECT state.name AS state_name,
             county.name AS county_name,
             population,
             RANK()OVER(PARTITION BY state.name ORDER BY population DESC) AS rank
      FROM state JOIN county ON state.code = county.state_code
      )AS subQuery
 WHERE rank<=5
 ORDER BY state_name,
          population DESC;

--Q6

SELECT zip_code,
       zip_name,
       name,
       distance
FROM (SELECT zip_code,
             zip_name,
             name,
             distance,
             RANK()OVER(PARTITION BY name ORDER BY distance) AS rank
             FROM (SELECT zip.zip_code AS zip_code,
                   zip.zip_name AS zip_name,
                   place.name AS name,
                   ROUND(3956*ACOS(SIN(RADIANS(place.latitude))* SIN(RADIANS(zip.latitude))+
                  COS(RADIANS(place.latitude))* COS(RADIANS(zip.latitude))* COS(RADIANS(place.longitude) - RADIANS(zip.longitude))) ,2) AS distance
            FROM place JOIN zip  on place.state_code  = zip.state_code
            WHERE place.state_code = 6 AND zip.state_code = 6 ) AS computation_query
       WHERE distance<=5)AS rank_query
WHERE rank =1
ORDER BY zip_code, name;
