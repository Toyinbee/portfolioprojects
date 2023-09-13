SELECT *
FROM [portfolio project]..covidDeaths
Where continent is not null
order by 3,4


SELECT *
FROM [portfolio project]..covidVaccinations
order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
FROM [portfolio project]..covidDeaths
Where continent is not null 
order by 1,2

SELECT *
FROM [portfolio project]..covidVaccinations
order by 3,4


--Total cases vs Total deaths

SELECT Location,Date,Total_Cases,Total_Deaths,(CONVERT(float, Total_Deaths) / CONVERT(float, Total_Cases)) * 100 AS DeathPercentage
FROM [portfolio project]..covidDeaths
WHERE Location='nigeria'
AND Continent IS NOT NULL
ORDER BY 1, 2;


--Total cases vs population

SELECT location, date,population, total_cases, (total_cases/population)*100 as percentpopulation_infected
FROM [portfolio project]..covidDeaths
--where location= 'Nigeria'
order by 1,2


--countires with the highest infection rate compared to population

SELECT location, population, max(total_cases)as highestinfectedcount,max (total_cases/population)*100 as percentpopulation_infected
FROM [portfolio project]..covidDeaths
--where location= 'Nigeria'
group by location,population
order by percentpopulation_infected desc

--countries with highest death count per population

SELECT location,max(cast(total_deaths as int)) as TotalDeathcount
FROM [portfolio project]..covidDeaths
--where location= 'Nigeria'
where continent is not null
group by location
order by TotalDeathcount desc

--highest death count by continent

SELECT continent,max(cast(total_deaths as int)) as TotalDeathcount
FROM [portfolio project]..covidDeaths
--where location= 'Nigeria'
where continent is not null
group by continent
order by TotalDeathcount desc

--highest death count by location

SELECT location,max(cast(total_deaths as int)) as TotalDeathcount
FROM [portfolio project]..covidDeaths
--where location= 'Nigeria'
where continent is not null
group by location
order by TotalDeathcount desc


--GLOBAL NUMBERS

SELECT  sum(new_cases)as total_cases, sum(cast(new_deaths as int )) as total_deaths,sum(cast(new_deaths as int ))/sum(new_cases )*100 as deathpercentage
FROM [portfolio project]..covidDeaths
--where location= 'Nigeria'
where continent is not null
--group by date
order by 1,2



--total population vs vaccinations

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rollingpeopleVaccinated
FROM [portfolio project]..covidDeaths dea
JOIN [portfolio project]..covidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3;


-- Using CTE to perform Calculation on Partition By in previous query

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) AS
(
    SELECT
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        vac.new_vaccinations,
        SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
    FROM [portfolio project]..covidDeaths dea
    JOIN [portfolio project]..covidVaccinations vac
        ON dea.location = vac.location
        AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
)
SELECT
    *,
    (RollingPeopleVaccinated / Population) * 100 AS PercentageVaccinated
FROM PopvsVac;




-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
 FROM [portfolio project]..covidDeaths dea
    JOIN [portfolio project]..covidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [portfolio project]..covidDeaths dea
    JOIN [portfolio project]..covidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

select*
from PercentPopulationVaccinated
