SELECT*
FROM 
  covid_data.dbo.deaths
ORDER BY 3, 4

 /*
  SELECT*
FROM 
  covid_data.dbo.vac
ORDER BY 3, 4
 */

 SELECT
   location,
   population,
   date,
   total_cases,
   new_cases,
   total_deaths 
FROM
  covid_data.dbo.deaths
ORDER BY 1, 2

 -- total cases vs total deaths per location (%states%-USA)
SELECT
 location,
 population,
 date,
 total_cases,
 (total_deaths/total_cases)*100 AS death_percent,
 total_deaths  
FROM
  covid_data.dbo.deaths
WHERE
  location LIKE '%STATES%' 
ORDER BY 1, 2

---- % of population per country (%states%-USA)

SELECT
 location,
 population
 date,
 total_cases,
 (total_cases/population)*100 AS infection_rate,
 total_deaths
FROM
  covid_data.dbo.deaths
WHERE
  location LIKE '%STATES%' 
ORDER BY 1, 2
 ---- highest infection rate % compared to population 

 SELECT
 location,
 population,
 max(total_cases) as highest_infection_Rate,
 max((total_cases/population))*100 AS infection_rate
FROM
  covid_data.dbo.deaths
 -- location LIKE '%STATES%'
group by location, population
order by infection_rate DESC 

---- highest death count per country population  
---- IS NOT NULL used to return non continent values in location 


SELECT
  continent,
  location,
  MAX(CAST(total_deaths as int)) as total_death_count
FROM
  covid_data.dbo.deaths
 -- location LIKE '%STATES%'
group by continent, location
order by total_death_count DESC 


---- pulled NULL continent names from location 

SELECT
  a.location,
  a.continent,
  b.location,
  b.continent,
  ISNULL(a.location, b.location)
FROM 
  covid_data.dbo.deaths a
JOIN covid_data.dbo.deaths b
  ON a.location = b.location
 WHERE a.continent IS NULL

---- update deaths table with correct continents

UPDATE a
  SET continent =  ISNULL(a.location, b.location)
FROM 
  covid_data.dbo.deaths a
JOIN covid_data.dbo.deaths b
  ON a.location = b.location
WHERE a.continent IS NULL

---- highest death count by continent

SELECT
  continent,
  MAX(CAST(total_deaths as int)) as total_death_count
FROM
  covid_data.dbo.deaths
 -- location LIKE '%STATES%'
group by continent
order by total_death_count DESC 


---- GLOBAL NUMBERS

SELECT
 date,
 continent,
 total_cases,
 (total_deaths/total_cases)*100 AS death_percent,
 total_deaths  
FROM
  covid_data.dbo.deaths
WHERE 
  continent = 'World'
GROUP BY continent, total_cases, total_deaths, date
ORDER BY date DESC

--- WORLDWIDE CASES,DEATHS,DEATH%

SELECT
 SUM(new_cases) AS worldwide_cases,
 SUM(CAST(new_deaths as int)) AS worldwide_deaths,
 SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS death_percent
FROM
  covid_data.dbo.deaths
WHERE 
  continent IS NOT NULL 

  ---- total population vs vaccination

SELECT 
  dea.continent,
  dea.location,
  dea.date,
  dea.population,
  vac.new_vaccinations,
  SUM(CAST(vac.new_vaccinations AS bigint)) OVER (partition by dea.location ORDER BY
  dea.location, dea.date) AS rolling_vacs
FROM
  covid_data.dbo.deaths dea
JOIN covid_data.dbo.vac vac
  on dea.location = vac.location
  AND dea.date = vac.date
ORDER BY 2, 3

---- rolling vacs

WITH popvsVac (continent, location, date, population, new_vaccinations, rolling_vacs)
  AS 
  (
SELECT 
  dea.continent,
  dea.location,
  dea.date,
  dea.population,
  vac.new_vaccinations,
  SUM(CAST(vac.new_vaccinations AS bigint)) OVER (partition by dea.location ORDER BY
  dea.location, dea.date) AS rolling_vacs
 
FROM
  covid_data.dbo.deaths dea
JOIN covid_data.dbo.vac vac
  on dea.location = vac.location
  AND dea.date = vac.date
  WHERE 
  dea.continent IS NOT NULL 
  )

SELECT *,
  (rolling_vacs/population)*100 vac_percent
FROM 
  popvsVac

----
--DROP TABLE IF EXISTS #percent_pop_vac
CREATE TABLE #percent_pop_vac
(
  continent char(50),
  locaton char(50),
  date datetime,
  population numeric,
  new_vaccinations numeric,
  rolling_vacs numeric
  )


INSERT INTO #percent_pop_vac
SELECT 
  dea.continent,
  dea.location,
  dea.date,
  dea.population,
  vac.new_vaccinations,
  SUM(CAST(vac.new_vaccinations AS bigint)) OVER (partition by dea.location ORDER BY
  dea.location, dea.date) AS rolling_vacs
 
FROM
  covid_data.dbo.deaths dea
JOIN covid_data.dbo.vac vac
  on dea.location = vac.location
  AND dea.date = vac.date
  WHERE 
  dea.continent IS NOT NULL 

  SELECT *,
  (rolling_vacs/population)*100 vac_percent
FROM 
  #percent_pop_vac
  

  ----
CREATE VIEW PercentPopVac as
SELECT 
  dea.continent,
  dea.location,
  dea.date,
  dea.population,
  vac.new_vaccinations,
  SUM(CAST(vac.new_vaccinations AS bigint)) OVER (partition by dea.location ORDER BY
  dea.location, dea.date) AS rolling_vacs
FROM
  covid_data.dbo.deaths dea
JOIN covid_data.dbo.vac vac
  on dea.location = vac.location
  AND dea.date = vac.date
  
    ----VIEW - world wide

SELECT
 SUM(new_cases) AS worldwide_cases,
 SUM(CAST(new_deaths as int)) AS worldwide_deaths,
 SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS death_percent
FROM
  covid_data.dbo.deaths
WHERE 
  continent IS NOT NULL 

  ---- continent total death

SELECT 
  location,
  SUM(CAST(new_deaths as bigint)) as total_death_count
FROM covid_data.dbo.deaths
WHERE location in ('europe', 'north america', 'south america', 'asia', 'africa', 'oceania')
GROUP BY location
ORDER BY total_death_count DESC

 ---- highest infection rate % compared to population 

 SELECT
 location,
 population,
 max(total_cases) as highest_infection_Rate,
 max((total_cases/population))*100 AS infection_rate
FROM
  covid_data.dbo.deaths
 -- location LIKE '%STATES%'
group by location, population
order by infection_rate DESC 

---- dates

 SELECT
 date,
 location,
 population,
 max(total_cases) as highest_infection_Rate,
 max((total_cases/population))*100 AS infection_rate
FROM
  covid_data.dbo.deaths
 -- location LIKE '%STATES%'
group by location, population, date
order by infection_rate DESC 



  














  


 