
select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2



--converting datatype from varchar to float
alter table CovidDeaths  
alter column total_deaths float

alter table CovidDeaths
alter column total_cases float



--total cases vs population
select location, date, total_cases, population, (total_cases/population)*100 as PercentageInfected
from PortfolioProject..CovidDeaths
where continent is not null
where location like '%lanka%'
order by 1,2



--looking at the countries which has the higes infected rate
select location, population, max(total_cases) as HighestInfectedCount, max((total_cases/population)*100) as PercentageInfected
from PortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by PercentageInfected desc



--showing countries with highest death count per population 
select location, max(total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc



--showing continents with highest death count 
select location, max(total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is null
group by location
order by TotalDeathCount desc



--global cases wrt date
select date, sum(new_cases) TotalCases, sum(cast(new_deaths as int)) TotalDeaths
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2



--looking at total population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(convert(float, vac.new_vaccinations)) over (partition by dea.location order by dea.date, 
	dea.location) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3



--using cte to find population vaccinated percentage
with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(convert(float, vac.new_vaccinations)) over (partition by dea.location order by dea.date, 
	dea.location) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)

select *, RollingPeopleVaccinated/population*100 as PercentagePopulationVaccinated
from PopvsVac



--using temp table to find population vaccinated percentage
drop table if exists #PercentagePolulationVaccinated
create table #PercentagePolulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentagePolulationVaccinated
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(convert(float, vac.new_vaccinations)) over (partition by dea.location order by dea.date, 
	dea.location) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *, RollingPeopleVaccinated/population*100 as PercentagePopulationVaccinated
from #PercentagePolulationVaccinated



--creating view to store data for visualizations
create view PercentagePopulationVaccinated as
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(convert(float, vac.new_vaccinations)) over (partition by dea.location order by dea.date, 
	dea.location) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *
from PercentagePopulationVaccinated