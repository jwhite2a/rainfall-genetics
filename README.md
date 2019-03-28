# rainfall-genetics
This repository details my extension to the 2018 APSC 101 Module 7 Project. The goal of the project is to design and optimize the parameters of a rainfall catchment system. Genetic optimization techniques are well suited for the problem because both continuous and discrete varibles are part of the system design. The details of the rainfall catchment system and model used to predict satisfaction can be found in the APSC project description.

---
## Contents
| Section | Description |
|-|-|
| [Usage](#usage) | How to run the optimization  |
| [Genetic Optimization](#genetic-optimization) | Details of Genetic Algorithm |
| [Rainfall Simulation](#rainfall-simulation) | Details of Rainfall Simulation |
| [Elevation Map](#elevation-map) | Details of Elevation Map |
| [Known Bugs and Extensions](#known-bugs-and-extensions) |  Future Work |

## Usage
1. Clone this project using `git clone https://github.com/jwhite2a/rainfall-genetics.git`
2. Open MATLAB. I can confirm this project works on MATLAB R2018a (win64). 
3. Ensure the [Global Optimization](https://www.mathworks.com/products/global-optimization.html) and [Curve Fitting Toolbox](https://www.mathworks.com/products/curvefitting.html) apps. Check your MATLAB installation, as these apps may come installed as defaults. 
4. Open MATLAB and add the clone git reposity to the project path. 
5. To run the simulation, run the `optimizeScript()` function (found in `/main/optimizeScript.m` in the Command Window or as part of another script. 

## Genetic Optimization
This project takes advantage of the `ga` MATLAB function. This function will minimize a specified objective function using genetic techniques. A total of 20 parameters are used in this project. Upper bounds, lower bounds and integer/continuous labels are specified for all parameters in `main/optimizeScript.m`.

## Rainfall Simulation
Two techniques are used to simulate rainfall data. Due to limitations in the avaliable data, only three year of daily rainfall logs were avaliable. 
### 1st Degree Markov Chains
The first step is to determine whether a given day will be wet or dry. From analysis of the rainfall data, 2x2 probability matrices were found for all 12 months of the year. These matrices were used to adjust the wet and dry probabilities each day of the simulation. A random number was chosen between 0 and 1 to determine whether to determine the wet/dry state of the day. If the random number was below the wet probability, the day would become dry.

### Gamma Distribution
If the day was determined to be wet, we must determine how much rain will fall. The three years of rainfall data will again be analysed to find distriubtions for the amount of rain. We find that a gamma distribution best fits the observed data. 12 distinct distriubtions again corresponding to the 12 months of the year were found. Similiar to the markov chain above, a random number will be chosen according to `gamrnd` to determine the expected rainfall. 

## Elevation Map
The elevation of various system compenents (i.e. the water tank, etc.) depends of their `x` and `y` coordinates on an elevation map. To improve the model accuracy, a curve will be fit to the contour map of the topography. Using a grid system, the elevation of intercept points was estimated. This data was fed into the `cftool` in MATLAB to fit a degree 8 polynomial.

## Known Bugs and Extensions
- Recalculate Markov chain and gamma dsitribution probabilities from additional data found at [Nootka Lightstation](http://climate.weather.gc.ca/climate_data/daily_data_e.html?hlyRange=1994-02-01%7C2001-12-13&dlyRange=1978-11-01%7C2019-03-15&mlyRange=1978-01-01%7C2007-02-01&StationID=261&Prov=BC&urlExtension=_e.html&searchType=stnProv&optLimit=yearRange&StartYear=1840&EndYear=2019&selRowPerPage=25&Line=1073&lstProvince=BC&timeframe=2&Day=13&Year=1982&Month=12#)
- Use continuous values optimization methods for continuous varibles like gradient descent(likely will yield better results)
- Bug related to inconsistant flowrate into cleaning system from watertower
