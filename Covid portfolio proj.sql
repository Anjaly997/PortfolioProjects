Use PortfolioProject;
Select * from dbo.CovidDeaths
where continent is not null
order by 3,4

ALTER TABLE CovidDeaths
ALTER COLUMN new_cases FLOAT;

ALTER TABLE CovidDeaths
ALTER COLUMN new_deaths FLOAT;

ALTER TABLE CovidDeaths
ALTER COLUMN total_deaths FLOAT;

ALTER TABLE CovidDeaths
ALTER COLUMN total_cases FLOAT;

Select * from dbo.covidvaccinations
order by 3,4;

Select location, date,total_cases,new_cases,total_deaths,population 
from CovidDeaths
order by 1,2

--Looking at te Total Cases Vs Total Deaths
--shows likelihood if you contract convid in your country

Select Location, date, total_cases,cast(total_deaths as int) as total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
order by 1,2
  

--Looking at theTotal cases vs Population
--Shows what percentage of population got covid

Select location, date, population,total_cases,(total_deaths/population)*100 as PercentPopulationInfected
from CovidDeaths
--where location like '%india%'
order by 1,2

--Looking at countries with highest infection rate compared to population
	
Select location,population,Max(total_cases) as HighestInfectionCount,max((total_cases/population))*100 as  PercentPopulationInfected
from CovidDeaths
--where location like '%india%'
Group by location,population
order by PercentPopulationInfected desc

--Showing the countries with the highest death count per Population

Select location, Max(total_deaths) as TotalDeathCount
from CovidDeaths
--where location like '%india%'
where continent is not null
Group by location
order by TotalDeathCount desc 

--LETS BREAK THINGS DOWN BY CONTINENT
--showing the continent with the highest death count per population

Select continent, Max(total_deaths) as TotalDeathCount
from CovidDeaths
--where location like '%india%'
where continent is not null
Group by continent
order by TotalDeathCount desc 


-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

--Looking at total Population vs Vaccinations

Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location ,dea.date) as Rollingpeoplevaccinated
from CovidDeaths dea
  join covidvaccinations vac
  on dea.location=vac.location
  and dea.date=vac.date
where dea.continent is not null
order by 2,3

-- USE CTE

with PopvsVac(Continet,Location,Date,Population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location ,dea.date) as Rollingpeoplevaccinated
from CovidDeaths dea
	join covidvaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
	where dea.continent is not null
	--order by 2,3
)
select*,( RollingPeopleVaccinated/population)*100
from PopvsVac


--temp table

Drop table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
 
INSERT INTO  #PercentPopulationVaccinated
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location ,dea.date) as Rollingpeoplevaccinated
from CovidDeaths dea
       join covidvaccinations vac
       on dea.location=vac.location
       and dea.date=vac.date
       --where dea.continent is not null
       --order by 2,3

select*,( RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

--Creating view for store data for later visualization

Create view PercentPopulationVaccinated as 
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location ,dea.date) as Rollingpeoplevaccinated
from CovidDeaths dea
	join covidvaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
	--where dea.continent is not null
	--order by 2,3

Select * from PercentPopulationVaccinated 
