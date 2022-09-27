SELECT *
FROM PortfolioProject..CovidDeaths
order by 3, 4;

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--order by 1 DESC

Select Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
order by 1, 2

-- Looking at the Total Cases vs Total Deaths
-- Shows likelihood of dying from COVID-19

SELECT SUM(total_cases) as TotalCasesinAfghanistan
FROM PortfolioProject..CovidDeaths
Where continent is not Null and Location = 'Afghanistan'

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
Where continent is not Null and location like '%states%'
order by 1, 2


-- Looking at Total Cases  vs Population
Select Location, date,population, total_cases,  (total_cases/population)*100 as CasesPercentage
from PortfolioProject..CovidDeaths
Where continent is not Null and location like '%states%'
order by 1, 2

SELECT location, Max(cast(total_deaths as int)) AS TotalDeaths
FROM PortfolioProject..CovidDeaths
Where continent is not Null
Group by location 
Order by TotalDeaths Desc


-- Looking at Countries with highest infection rate as compared to the Population
Select Location,population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%states%'
Where continent is not Null
Group by Location, population
order by PercentPopulationInfected DESC

--Showing Countries with Highest Deat Count per Population
Select location, Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
Where continent is not Null
Group by location
order by TotalDeathCount Desc


-- Let's Break Things Down by Continent

--Showing continents with the highest death counts per population
Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc


-- Global Numbers

Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/sum(new_cases) * 100 as DeathPercentage
From PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
--group by date
order by 1, 2


--Looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2, 3


-- Use CTE
with PopvsVac (Continent, Location, Date, Population,new_vaccinations, CummulativeVaccinations)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as CummulativeVaccinations
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)

Select *, (CummulativeVaccinations/Population)*100 as PercentageVacPerPopulation
from PopvsVac
order by PercentageVacPerPopulation desc


--Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated 
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime, 
Population numeric,
New_vaccinations numeric,
CummulativeVaccinations numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as CummulativeVaccinations
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2, 3

Select *, (CummulativeVaccinations/Population)*100 as PercentageVacPerPopulation
from #PercentPopulationVaccinated
--order by PercentageVacPerPopulation desc


--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as CummulativeVaccinations
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3

select * from PortfolioProject..PercentPopulationVaccinated