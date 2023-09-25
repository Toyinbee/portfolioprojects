SELECT  sum(new_cases)as total_cases, sum(cast(new_deaths as int )) as total_deaths,sum(cast(new_deaths as int ))/sum(new_cases )*100 as deathpercentage
FROM [portfolio project]..covidDeaths
--where location= 'Nigeria'
where continent is not null
--group by date
order by 1,2


Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
FROM [portfolio project]..covidDeaths
--Where location like ='nigeria'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc



Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
FROM [portfolio project]..covidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc






Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
FROM [portfolio project]..covidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc
