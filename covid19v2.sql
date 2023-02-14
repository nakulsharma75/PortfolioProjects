--Covid 19 Data Exploration
--Skills used: Joins, Converting Data Types, Windows Functions, Aggregate Functions,CTE's, Temp Tables,Creating Views, 

Select *
From CovidDeaths
 Where continent is not null 
order by 3,4

--Select Date range that we are going to use

Select Location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
Where continent is not null 
order by 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country(Using India as country)

Select Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where location = 'India' and
continent is not null
order by 1,2

-- Total Cases vs Population
-- percentage of population infected with Covid (Using India as country)


Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
from CovidDeaths
where location ='India'
and continent is not null
order by 1,2

-- Countries with Highest Infection Rate compared to Population
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths
--Where location ='India'
Group by Location, Population
order by PercentPopulationInfected desc

-- Countries with Highest Death Count per Population

Select Location,MAX(cast(total_deaths as int)) as TotalDeaths
from CovidDeaths
where continent is not null
group by location
order by TotalDeaths desc

 --Contintents with the highest death count per population
 Select location,MAX(cast(total_deaths as int)) as TotalDeaths
from CovidDeaths
where continent is null
group by location
order by TotalDeaths desc

Select continent,MAX(cast(total_deaths as int)) as TotalDeaths
from CovidDeaths
where continent is not null
group by continent
order by TotalDeaths desc

-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, 
       SUM(cast(new_deaths as int)) as total_deaths, 
       SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths
--Where location like '%india%'
where continent is not null 
--Group By date
order by 1,2

--Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

select d.continent,d.location,d.date,d.population,v.new_vaccinations,
sum(convert(int,v.new_vaccinations)) over (Partition by d.location order by d.location,d.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from CovidDeaths d
join CovidVaccinations v
on d.location=v.location
and d.date=v.date
where d.continent is not null
order by 2,3

---- Using CTE to perform Calculation on Partition By in previous query

With popvsvac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select d.continent,d.location,d.date,d.population,v.new_vaccinations,
sum(convert(int,v.new_vaccinations)) over (Partition by d.location order by d.location,d.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from CovidDeaths d
join CovidVaccinations v
on d.location=v.location
and d.date=v.date
where d.continent is not null
--order by 2,3
)
select *,(RollingPeopleVaccinated/population)*100
from popvsvac

--Temp Table

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

insert into #PercentPopulationVaccinated
select d.continent,d.location,d.date,d.population,v.new_vaccinations,
sum(convert(int,v.new_vaccinations)) over (Partition by d.location order by d.location,d.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from CovidDeaths d
join CovidVaccinations v
on d.location=v.location
and d.date=v.date
where d.continent is not null
--order by 2,3

select *,(RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

-- Creating View to store data for later visualizations
create view PercentPopulation as
select d.continent,d.location,d.date,d.population,v.new_vaccinations,
sum(convert(int,v.new_vaccinations)) over (Partition by d.location order by d.location,d.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from CovidDeaths d
join CovidVaccinations v
on d.location=v.location
and d.date=v.date
where d.continent is not null
--order by 2,3

select*
from PercentPopulation








