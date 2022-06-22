/*
Covid 19 Data Exploration 
Specifically using the following queries: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions,
Creating Views, Converting Data Types
*/


-- Select Data that we are going to be starting with
--SELECT *
--FROM CovidDeaths
--WHERE continent is not null 
--ORDER BY 3,4 --Ordering by Location in ascending order then date, in that order.
 
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2 

--Working with data in Europe

SELECT location,
		date,
		total_cases,
		total_deaths,
		(total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE location = 'europe' --AND continent IS NOT NULL
ORDER BY 2


--Percentage infection
SELECT  location,
		date,
		total_cases,
		population,
		(total_cases/population)*100 AS InfectionRate
FROM CovidDeaths
WHERE location = 'europe'
ORDER BY 2

SELECT location,
	   population,
	   MAX(total_cases) AS HighestInfectionCount,
	   MAX((total_cases/population)*100) AS PercentagePopulationInfected
FROM CovidDeaths
GROUP BY location, population
ORDER BY PercentagePopulationInfected

-- Doing things by continent
-- Showing continents with highest count

SELECT continent,
	   MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount

SELECT SUM(new_cases) AS total_cases,
	   SUM(cast(new_deaths AS int)) AS total_deaths,
	   SUM(cast(new_deaths AS int))/SUM(New_Cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

--Population's reaction to vaccination

SELECT dea.continent, 
	   dea.location,
	   dea.date,
	   dea.population,
	   vac.new_vaccinations,
	   SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 1,2


---USING Common Table Expression (CTE) to perform operation on Partition
WITH PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(SELECT dea.continent, 
	   dea.location,
	   dea.date,
	   dea.population,
	   vac.new_vaccinations,
	   SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
) 

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopVsVac


--Performing the same operation on the partition using Temp table
DROP TABLE IF EXISTS #PercentageVaccinatedPopulace

CREATE TABLE #PercentageVaccinatedPopulace 
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO  #PercentageVaccinatedPopulace 
SELECT dea.continent, 
	   dea.location,
	   dea.date,
	   dea.population,
	   vac.new_vaccinations,
	   SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 1,2

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentageVaccinatedPopulace

