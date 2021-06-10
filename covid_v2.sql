--SELECT *
--FROM PortfolioProject..CovidDeaths

--SELECT * 
--FROM PortfolioProject..CovidVaccinations

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2


SELECT Max(total_deaths) as totalDeMortos
FROM PortfolioProject..CovidDeaths
WHERE Location = 'Brazil'

-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid
SELECT Location, population, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'


-- Looking at Countries with Highest Infection rate compared to Population

SELECT 
	Location, population, Max(total_cases) as HighestInfectionCount ,Max((total_cases/population)*100) AS PercentPopulationInfected
FROM 
	PortfolioProject..CovidDeaths
GROUP BY 
	Location, Population
ORDER BY
	PercentPopulationInfected DESC



-- Showing countries with highest death count per population

SELECT 
	Location, Max(cast(total_deaths as int)) as TotalDeathCount
FROM 
	PortfolioProject..CovidDeaths
WHERE 
	continent is not null
GROUP BY 
	Location
ORDER BY 
	TotalDeathCount DESC



-- By Continent

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount DESC


-- Global Numbers


SELECT 
	date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
	SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM
	PortfolioProject..CovidDeaths
WHERE  
	 New_Cases != 0 AND continent IS NOT NULL
GROUP BY 
	date
order by 1,2



-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	,SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.Location, dea.Date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER by 2,3



-- USE CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) 
AS(
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
		,SUM(CONVERT(float, vac.new_vaccinations)) 
		OVER (Partition by dea.Location, dea.Date ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
		--,--(RollingPeopleVaccinated/population)*100
	FROM PortfolioProject..CovidDeaths dea
	JOIN PortfolioProject..CovidVaccinations vac
		ON dea.location = vac.location
		and dea.date = vac.date
	WHERE dea.continent is not null
	--ORDER by 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100 AS PecentageOfPeopleVacinated
FROM PopvsVac



--TEMP TABLE

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	,SUM(CONVERT(float, vac.new_vaccinations)) 
	OVER (Partition by dea.Location, dea.Date ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
	--,--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER by 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100 AS PecentageOfPeopleVacinated
FROM #PercentPopulationVaccinated


DROP TABLE if exists #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinates as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	,SUM(CONVERT(float, vac.new_vaccinations)) 
	OVER (Partition by dea.Location, dea.Date ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
	--,--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER by 2,3

SELECT * FROM PercentPopulationVaccinates