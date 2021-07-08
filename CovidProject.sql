select *
from PortfolioProject..coviddeaths
where continent is not null
order by 3,4

--select *
--from PortfolioProject..covidvaccinations
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..coviddeaths
where continent is not null
order by 1,2

--Looking at Total Cases Vs Total Deaths
-- Exploring death rate over time and Location

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..coviddeaths
where location like '%States%'
and continent is not null
order by 1,2

--Looking at Total Cases Vs Population
--Shows percentage of population that has contracted Covid-19

select location, date, total_cases, population, (total_cases/population)*100 as percent_population_infected
from PortfolioProject..coviddeaths
where location like '%States%'
and continent is not null
order by 1,2

--Looking at Countries with highest infection rate compared to population

select location, population, max(total_cases) as Highest_inf_count, max((total_cases/population))*100 as percent_population_infected
from PortfolioProject..coviddeaths
--where location like '%States%'
group by location, population
order by percent_population_infected desc

--Looking at Countries with Highest Death Count per Population

select location, max(cast(total_deaths as int)) as total_death_count
from PortfolioProject..coviddeaths
--where location like '%States%'
where continent is not null
group by location
order by total_death_count desc

-- Deaths by Continent

select continent, max(cast(total_deaths as int)) as total_death_count
from PortfolioProject..coviddeaths
--where location like '%States%'
where continent is not null
group by continent
order by total_death_count desc

-- Deaths by Continent (alternative) use prior

select location, max(cast(total_deaths as int)) as total_death_count
from PortfolioProject..coviddeaths
--where location like '%States%'
where continent is null
group by location
order by total_death_count desc


--Global Covid Figures over time

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..coviddeaths
--where location like '%States%'
where continent is not null
group by date
order by 1,2

-- Global covid figures

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..coviddeaths
--where location like '%States%'
where continent is not null
--group by date
order by 1,2

--Vaccination Data, Total Population Vs. Vaccination
--USE CTE
with PopvsVac (continent, location, date, population, new_vaccinations, rolling_vac_count)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) over
(Partition by dea.location order by dea.location, dea.date) as rolling_vac_count
--, (rolling_vac_count/population)*100
From PortfolioProject..coviddeaths dea
Join PortfolioProject..covidvaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2,3
)
Select *, (rolling_vac_count/population)*100 as percent_rolling_vac
from PopvsVac

--Temp Table
DROP table if exists #PercentPopVac
create table #PercentPopVac
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
rolling_vac_count numeric
)

insert into #PercentPopVac
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) over
(Partition by dea.location order by dea.location, dea.date) as rolling_vac_count
--, (rolling_vac_count/population)*100
From PortfolioProject..coviddeaths dea
Join PortfolioProject..covidvaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2,3

Select *, (rolling_vac_count/population)*100 as percent_rolling_vac
from #PercentPopVac

-- Creating view to store data for later visualizations

create view PercentPopVac as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) over
(Partition by dea.location order by dea.location, dea.date) as rolling_vac_count
--, (rolling_vac_count/population)*100
From PortfolioProject..coviddeaths dea
Join PortfolioProject..covidvaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2,3

select *
from PercentPopVac