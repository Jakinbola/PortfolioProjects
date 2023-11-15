/*Covid 19 Data Exploration

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types*/


Select * 
From CovidDeaths
Where continent is not null
Order by 3,4 

--Select Data that we are going to need: Location, date, total_cases, new_cases, total_deaths, population.

Select location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
Where continent is not null
Order by 1,2

/* Total Cases vs Total Deaths
   Shows likelihood of dying if you contract covid */


Select location, date, total_cases, new_cases, total_deaths, population, (Cast (total_deaths As Float)/Cast (total_cases As Float))*100 AS Death_Rate
From CovidDeaths
Where continent is not null
Order by 1,2

/*  Total Cases vs Population
    Shows the percentage of population infected with Covid */

Select location, date, total_cases, new_cases, total_deaths, population, ((Cast (total_cases As Float)/population)*100) As Infection_Rate
From CovidDeaths
Where continent is not null
Order by 1,2

-- Countries with Highest Infection Rate compared to Population

Select location, Max(total_cases) As HighestInfectionCount, population, (Max(Cast (total_cases As Float)/population)*100) As HighestInfection_Rate
From CovidDeaths
Where continent is not null
Group by location, population
Order by Infection_Rate Desc

-- Countries with Highest Death Count per Population

Select location, Max(total_deaths) As HighestDeathCount, population, (Max(Cast (total_deaths As Float)/population)*100) As HighestDeath_Rate
From CovidDeaths
Where continent is not null
Group by location, population
Order by HighestDeathCount Desc

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, Max(Cast(total_deaths As int)) As HighestDeathCount, Max(population) As population
From CovidDeaths
Where continent is not null
Group by continent
Order by HighestDeathCount Desc

/* Total Population vs Vaccinations
 Shows Percentage of Population that has recieved at least one Covid Vaccine*/

 Select cvd.continent, Cvd.location, Cvd.date, Cvd.total_cases, Cvd.total_deaths,Cvd.population, Vac.new_vaccinations,
 Sum(Convert(Float, Vac.new_vaccinations)) Over (Partition by Cvd.location order by Cvd.location, Cvd.date) As RollingPeopleVaccinated
 From CovidDeaths Cvd
 Join CovidVaccination Vac
 On Cvd.location = Vac.location
 and Cvd.date = Vac.date
 Where Cvd.continent is not null
 Order by 2,3

 -- Using CTE to perform Calculation on Partition By in previous query

 With PopVsVac (continent, location, date, total_cases, total_deaths, population, new_vaccinations, RollingPeopleVaccinated)
 As
 (
 Select cvd.continent, Cvd.location, Cvd.date, Cvd.total_cases, Cvd.total_deaths,Cvd.population, Vac.new_vaccinations,
 Sum(Convert(Float, Vac.new_vaccinations)) Over (Partition by Cvd.location order by Cvd.location, Cvd.date) As RollingPeopleVaccinated
 From CovidDeaths Cvd
 Join CovidVaccination Vac
 On Cvd.location = Vac.location
 and Cvd.date = Vac.date
 Where Cvd.continent is not null
-- Order by 2,3
 )

 Select *, (RollingPeopleVaccinated/population)*100 As RollingPeopleVaccinated_Perc
 From PopVsVac

 -- Using Temp Table to perform Calculation on Partition By in previous query

 Drop Table If Exists #PercentagePopulationVaccinated

 Create Table #PercentagePopulationVaccinated
 (continent nvarchar(255),
 location   nvarchar(255),
 date	    datetime,
 Population numeric,
 new_vaccination numeric,
 RollingPeopleVaccinated numeric
 )
 Insert into #PercentagePopulationVaccinated
 Select cvd.continent, Cvd.location, Cvd.date,Cvd.population, Vac.new_vaccinations,
 Sum(Convert(Float, Vac.new_vaccinations)) Over (Partition by Cvd.location order by Cvd.location, Cvd.date) As RollingPeopleVaccinated
 From CovidDeaths Cvd
 Join CovidVaccination Vac
 On Cvd.location = Vac.location
 and Cvd.date = Vac.date
 Where Cvd.continent is not null
-- Order by 2,3

 Select *, (RollingPeopleVaccinated/population)*100 As RollingPeopleVaccinated_Perc
 From #PercentagePopulationVaccinated

 -- Creating View to store data for later visualizations

 Create View PercentagePopulationVaccinated As
 Select cvd.continent, Cvd.location, Cvd.date,Cvd.population, Vac.new_vaccinations,
 Sum(Convert(Float, Vac.new_vaccinations)) Over (Partition by Cvd.location order by Cvd.location, Cvd.date) As RollingPeopleVaccinated
 From CovidDeaths Cvd
 Join CovidVaccination Vac
 On Cvd.location = Vac.location
 and Cvd.date = Vac.date
 Where Cvd.continent is not null
-- Order by 2,3



