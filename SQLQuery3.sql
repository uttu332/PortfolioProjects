use PortfolioProject;

--total cases vs total deaths
select location,date,total_cases,total_deaths,round((total_deaths/total_cases)*100,2) as Death_Percentage
from CovidDeaths
where location like '%states%'
order by 1,2;

--total cases vs population
select location,date,population,total_cases,round((total_cases/population)*100,2) as PercentPopulationInfected
from CovidDeaths
--where location like '%states%'
order by 1,2;

--looking at countries with highest infection rate compared to population
select location,population,max(total_cases) as HighestInfectionCount,max(round((total_cases/population)*100,2)) as PercentPopulationInfected
from CovidDeaths
group by location,population
order by PercentPopulationInfected desc;

--looking at countries with highest death rates compared to population
select location,max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc;

--lets break things by continent
--looking at continents with highest death rates compared to population
select continent,max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc;

--Global Numbers
select date,SUM(new_cases)as total_cases,SUM(cast(new_deaths as int))as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from CovidDeaths
where continent is not null
group by date
order by 1,2 desc;

--showing population vs vaccinations

with PopVac (Continent,Location,Date,Population,New_Vaccinations,RollingPeopleVaccinated)as
(select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int))over(partition by dea.location order by dea.location,dea.date)as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
on dea.location=vac.location
and dea.date=vac.date
and dea.continent is not null)
select *,(RollingPeopleVaccinated/Population)*100 as PercentVaccinated
from PopVac;

--Use Temp
drop table if exists #PercentPeopleVaccinated
create table #PercentPeopleVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPeopleVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int))over(partition by dea.location order by dea.location,dea.date)as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
on dea.location=vac.location
and dea.date=vac.date
and dea.continent is not null


select *,(RollingPeopleVaccinated/Population)*100 as PercentVaccinated
from #PercentPeopleVaccinated;


create view PercentPeopleVaccinated as 
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int))over(partition by dea.location order by dea.location,dea.date)as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
on dea.location=vac.location
and dea.date=vac.date
and dea.continent is not null;


select * from 
PercentPeopleVaccinated;