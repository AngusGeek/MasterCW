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

--Q4
WITH usa(population,land_area) AS
 (SELECT SUM(CAST(mcd.population AS BIGINT))AS population,
         SUM(CAST(mcd.land_area AS BIGINT))AS land_area
  FROM mcd
 )
 SELECT state.name AS name,
        SUM(CAST(mcd.population AS BIGINT))AS population,
        ROUND(CAST(SUM(CAST(mcd.population AS BIGINT))*100.0/usa.population) AS BIGINT,2) AS pc_population,
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
