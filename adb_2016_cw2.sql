--SELECT: state_name(state), name(place)

--name(place):
--1: ends in City
--2: type column not 'city'

--order by state_name,name
--Q1
SELECT state.name,
       place.name
FROM state JOIN place ON state.code = place.state_code
WHERE place.name LIKE '%City' AND place.type <> 'city'
ORDER BY state.name,place.name;

--Big city: type(place) = city; population >=100000
--List state_name,no_big_city,big_city_population
--Ordered by state_name
--States:
--1: big-cities>=5 or number of people in big_cities>=1000000
--Q2
SELECT state.name,
        COUNT(place.name) AS no_big_city,
        SUM(place.population) AS big_city_population
FROM state JOIN place ON state.code = place.state_code
WHERE place.type = 'city'AND place.population >= 100000
GROUP BY state.name
HAVING  COUNT(place.name)>5 OR SUM(place.population)>=1000000
ORDER BY state.name;

--Return type,place,mcd,county
--type: value of the type column in place, mcd, or county
--place: the number of times the voule of type appears in place table.
--mcd
--county
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
Place(type, place) AS
(
SELECT type,
       COUNT(place.type)AS place
FROM place
GROUP BY type
),
Mcd(type, mcd) AS
(
SELECT type,
       COUNT(type)AS mcd
FROM mcd
GROUP BY type
),
County(type, county) AS
(
SELECT type,
       COUNT(type)AS county
FROM county
GROUP BY type
)
SELECT Type.type,
       COALESCE(Place.place, 0) as place,
       COALESCE(Mcd.mcd, 0) as mcd,
       COALESCE(County.county, 0) as county
FROM Type LEFT JOIN Place  ON Type.type = Place.type
          LEFT JOIN Mcd on Type.type = Mcd.type
          LEFT JOIN County on Type.type = County.type
GROUP BY Type.type, Place.place, Mcd.mcd, County.county
ORDER BY Type.type


--Q4
 WITH usa(population,land_area) AS
  (SELECT SUM(mcd.population)AS population,
          SUM(mcd.land_area)AS land_area
   FROM mcd
  )
  SELECT state.name as name,
         SUM(mcd.population)AS population,
         ROUND(SUM(mcd.population)*100.0/usa.population,2) AS pc_population,
         SUM(mcd.land_area)AS land_area,
         ROUND(SUM(mcd.land_area)*100.0/usa.land_area,2) AS pc_land_area
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
                   ROUND(CAST(3956* (
                          atan2(sqrt(
                         power(sin(radians(zip.latitude - place.latitude)),2)+
                         cos(radians(place.latitude)) * cos(radians(zip.latitude)) *
                         power(sin(radians(zip.longitude - place.longitude)),2)),
                         sqrt(1-(power(sin(radians(zip.latitude - place.latitude)),2)+
                         cos(radians(place.latitude)) * cos(radians(zip.latitude)) *
                         power(sin(radians(zip.longitude - place.longitude)),2)) )))
                         AS numeric),2) AS distance
            FROM place JOIN zip  on place.state_code  = zip.state_code
            WHERE place.state_code = 6 AND zip.state_code = 6 ) AS computation_query
       WHERE distance<=5
       ORDER BY distance)AS rank_query
WHERE rank =1
ORDER BY zip_code, name





-----
SELECT zip.zip_code AS zip_code,
             zip.zip_name AS zip_name
      FROM zip
      WHERE zip.state_code = 6

SELECT zip.zip_code AS zip_code,
             zip.zip_name AS zip_name,
             place.name AS name
      FROM place JOIN zip  on place.state_code  = zip.state_code
      WHERE place.state_code = 6
