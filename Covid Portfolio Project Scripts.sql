USE PortfolioProject;
SELECT * FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3, 4;

SELECT * FROM PortfolioProject..CovidVaccinations
WHERE continent IS NOT NULL
ORDER BY 3, 4;

-- Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population 

FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2;

-- Looking at total cases vs total deaths
-- shows likelihood of dying if you get covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 AS 'death_percentage'

FROM PortfolioProject..CovidDeaths

WHERE location LIKE '%state%'
ORDER BY 1, 2;

-- Looking at total cases vs population
-- Shows what percentage of population got Covid
SELECT 
	location, 
	date, 
	total_cases, 
	population, 
	(total_cases / population)*100 AS 'percent population'
FROM PortfolioProject..CovidDeaths

WHERE location LIKE '%state%'
ORDER BY 1, 2;


-- Looking at countries w/ highest infection rate compared to Population
SELECT 
	location,
	population, 
	MAX(total_cases) AS 'Highest Infection Count', 
	MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%state%'
GROUP BY Location, Population
--HAVING location = 'United States'
ORDER BY PercentPopulationInfected desc;

-- Let's break things down by continent

-- Showing countries w/ highest death count per population

SELECT
	continent, 
	MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount desc; 

-- GLOBAL NUMBERS

SELECT 
	SUM(new_cases) AS 'total new cases',
	SUM(cast(new_deaths AS INT)) AS 'total new deaths',
	SUM(cast(new_deaths AS INT))/SUM(new_cases) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1, 2;



-- Looking at Total Populattion Vs Vaccinations

SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3;


-- USE CTE

WITH PopVsVac (Continent, Location, Population, New_Vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT 
	dea.continent, 
	dea.location,  
	dea.population, 
	vac.new_vaccinations,
	SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

--ORDER BY 2, 3
)

SELECT *, (RollingPeopleVaccinated/Population) * 100

FROM PopVsVac;

-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)


INSERT INTO #PercentPopulationVaccinated
SELECT 
	dea.continent, 
	dea.location,
	dea.date,
	dea.population, 
	vac.new_vaccinations,
	SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated;



-- Creating View to store data for later visualizations


USE PortfolioProject;
DROP VIEW IF EXISTS [PercentPopulationVaccinated]

Create View PercentPopulationVaccinated AS
SELECT 
	dea.continent, 
	dea.location,
	dea.date,
	dea.population, 
	vac.new_vaccinations,
	SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL



CREATE VIEW ContinentDeathCount AS
SELECT
	continent, 
	MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
--ORDER BY TotalDeathCount desc; 

