select * from coviddeaths

where continent != '';



select location, date, total_cases, new_cases, total_deaths, population 

from coviddeaths
order by 1,2 ASC

;

select location, date, total_cases, new_cases, total_deaths,
(total_deaths/total_cases)*100  DeathPercentage
from coviddeaths
Where location like '%Indi%'
order by 2 ASC
;

select location, date, total_cases, new_cases, total_deaths, population,
(total_cases/population)*100  InfectedPopulationPercent
from coviddeaths
Where location like '%Indi%'
order by 1,2
;

select location,population, MAX(total_cases)highest_cases, max(total_deaths) highest_deaths, 
max(total_cases/population)*100  InfectedPopulationPercent
from coviddeaths
Group by location, population

order by InfectedPopulationPercent DESC

;

/*This is showing countries with highest deaths*/

SELECT location, MAX(CAST(total_deaths AS UNSIGNED)) AS highest_deaths 
FROM coviddeaths 
where continent != ''
GROUP BY location 
ORDER BY highest_deaths DESC;

/*Lets break Covid deaths by Continent*/

SELECT location, MAX(CAST(total_deaths AS UNSIGNED)) AS highest_deaths 
FROM coviddeaths 
where continent = ''
and location != 'High income'
GROUP BY location 
ORDER BY highest_deaths DESC;

/*Global Numbers*/
select sum(new_cases) total_Cases,sum(new_deaths) total_death, sum(new_deaths)/sum(new_cases)*100 deathpercent
/*(total_deaths/total_cases)*100 as DeathPercentage*/
from coviddeaths
Where continent != '' 
order by 1,2;

-- Looking at Total Population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) OVER (Partition By dea.location order by dea.location,dea.date ) as RollingVaccinated
from coviddeaths as dea
join covidvaccines as vac 
on dea.location=vac.location
and dea.date=vac.date
Where dea.continent != '' 
order by 2,3;

-- USE CTE 
with PopvsVac (Continent, Location, Date, Population, New_Vaccinations,RollingVaccinated)
as (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) OVER (Partition By dea.location order by dea.location,dea.date ) as RollingVaccinated
from coviddeaths as dea
join covidvaccines as vac 
on dea.location=vac.location
and dea.date=vac.date
Where dea.continent != '' 
order by 2,3
)

Select *, (RollingVaccinated/Population)*100 from PopvsVac;

-- Temp Table

drop table if exists PercentPopulationVaccinated;
Create Table PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingVaccinated numeric
);
Insert into PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) OVER (Partition By dea.location order by dea.location,dea.date ) as RollingVaccinated
from coviddeaths as dea
join covidvaccines as vac 
on dea.location=vac.location
and dea.date=vac.date
Where dea.continent != '' 
order by 2,3;
Select *, (RollingVaccinated/Population)*100 from PercentPopulationVaccinated;

-- Create View to store data for later Visualization

Create View PercentPopulationVaccinated2 as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) OVER (Partition By dea.location order by dea.location,dea.date ) as RollingVaccinated
from coviddeaths as dea
join covidvaccines as vac 
on dea.location=vac.location
and dea.date=vac.date
Where dea.continent != '' 
order by 2,3;

