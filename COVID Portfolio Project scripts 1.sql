SELECT *
FROM [Portfolo Project]..[Covid Deaths]
ORDER BY 3,4

--SELECT *
--FROM [Portfolo Project]..[Covid Vaccinations]
--ORDER BY 3,4

-- Select Data we will use
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolo Project]..[Covid Deaths]
ORDER BY 1,2

-- Looking at the total cases vs total deaths
-- Shows likelihood of death if you contracted COVID in your country AT ANY TIME
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
FROM [Portfolo Project]..[Covid Deaths]
WHERE location like '%states%'
ORDER BY 1,2


-- Looking at the Total Cases vs Population
-- Shows what % of population tested positive for COVID AT ANY TIME

SELECT Location, date, population, total_cases, (total_cases/population)*100 as Sick_Percentage
FROM [Portfolo Project]..[Covid Deaths]
WHERE location like '%states%'
ORDER BY 1,2

-- Looking at countries with highest Infection Rate compared to Population

SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as Sick_Percentage
FROM [Portfolo Project]..[Covid Deaths]
-- WHERE location like '%states%'
GROUP BY Location, population
ORDER BY Sick_Percentage DESC

-- Showing Countries with Highest Death Count

SELECT Location, MAX(CAST(total_deaths AS INT)) as TotalDeathCount
FROM [Portfolo Project]..[Covid Deaths]
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC

-- Break data down by Continent

SELECT location, MAX(CAST(total_deaths AS INT)) as TotalDeathCount
FROM [Portfolo Project]..[Covid Deaths]
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Showing Continents with highest death count

SELECT location, MAX(CAST(total_deaths AS INT)) as TotalDeathCount
FROM [Portfolo Project]..[Covid Deaths]
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


-- Global Numbers

SELECT SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths as INT)) AS Total_Deaths, (SUM(CAST(new_deaths as INT))/SUM(new_cases))*100 as Death_Percentage
FROM [Portfolo Project]..[Covid Deaths]
WHERE continent IS NOT NULL
-- GROUP BY date
ORDER BY 1,2

-- Exploring other table

SELECT *
FROM [Portfolo Project]..[Covid Vaccinations]

-- Joining Tables!

SELECT * 
FROM [Portfolo Project]..[Covid Deaths] dea
JOIN [Portfolo Project]..[Covid Vaccinations] vac
	ON dea.location = vac.location
	AND dea.date = vac.date

-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CAST(vac.new_vaccinations AS INT)) 
	OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM [Portfolo Project]..[Covid Deaths] dea
JOIN [Portfolo Project]..[Covid Vaccinations] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- Use CTE Option

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CAST(vac.new_vaccinations AS INT)) 
	OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM [Portfolo Project]..[Covid Deaths] dea
JOIN [Portfolo Project]..[Covid Vaccinations] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
-- ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


-- The Temp Table Method

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CAST(vac.new_vaccinations AS INT)) 
	OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM [Portfolo Project]..[Covid Deaths] dea
JOIN [Portfolo Project]..[Covid Vaccinations] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
-- ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


-- Create View to store data for later vizzes

Create View PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CAST(vac.new_vaccinations AS INT)) 
	OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM [Portfolo Project]..[Covid Deaths] dea
JOIN [Portfolo Project]..[Covid Vaccinations] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
-- ORDER BY 2,3


Select *
FROM PercentPopulationVaccinated

