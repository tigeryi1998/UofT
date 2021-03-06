# 3/2018 - UofT DSSC Challenge
# Logistic Regression + Data Vizualization

# Import Libraries, setwd
setwd("C:/Users/David/Desktop/UofT DSSC/Report")
library("ggplot2")
library(ggmap)
library(maps)
library(mapdata)

fuelmetrics <- read.csv("FuelStationsMetrics.csv")
fuelmetrics <-subset(fuelmetrics,State=="Ontario" & PopularityScore > 2)
dat <- read.csv("experiment_data.csv")
dat2<- subset(dat, AvgVol>1000)

pop_score <- dat$PopularityScore
pop_factor <- vector()

# Classify Data - popularity scores > 2 and popularity scores <= 2
for (i in seq(1,length(dat$PopularityScore))){
  if (pop_score[i] > 2){
    pop_factor[i] <- 1
  }
  else{
    pop_factor[i] <- 0
  }
}

dat$PopularityScore <- pop_factor  
dat$PopularityScore <- as.factor(dat$PopularityScore)

### Create logistic regression model
# variables
# PopularityScore (1 if PopularityScore greater than 1, 0 otherwise)
# AvgVol - average car valume around, mindistfuel - minimum distance to other fuelstation
# rad1fuel - number of fuel stations close by, HasDiesel - whether shop has diesel

# Clear from model A that popular gas stations are clustered together
fita <- glm(PopularityScore~AvgVol+mindistfuel+rad1fuel+HasDiesel,family=binomial,data=dat)
summary(fita)

# For those looking at building a new gas station may make more sense to consider
# just AvgVol and HasDiesel when selecting a site
fitb <- glm(PopularityScore~AvgVol+HasDiesel,family=binomial,data=dat)
summary(fitb)

# Assessing impact of AvgVol and has diesel on probability of being popular

# Having diesel fuel increases probability of being Popular by
coeff <- coefficients(fitb)
pi_HasDiesel <- exp(coeff['HasDiesel'])/(1+exp(coeff['HasDiesel']))
pi_HasDiesel

# Analysis showing the gas stations that are the most popular have diesel by a wide margin
xtabs(~HasDiesel+PopularityScore,data=dat)

# Increase in AvgVol by to 2000 from 1000 cars increases makes probability of being Popular by
pi_AvgVol1000 <- (exp(2000*coeff['AvgVol'])/(1+exp(2000*coeff['AvgVol'])) - exp(1000*coeff['AvgVol'])/(1+exp(1000*coeff['AvgVol'])))
pi_AvgVol1000

### Vizualizations

# Graph of relationship between avgvol and popularity scores
ggplot(dat2,aes(x=AvgVol,y=PopularityScore)) + geom_point() + geom_smooth()

# Map of all Gas Stations by Popularity Score
sbbox <- make_bbox(lon = fuelmetrics$Longitude, lat = fuelmetrics$Latitude, f = .1)
sq_map <- get_map(location = sbbox, maptype = "roadmap", source = "google")
ggmap(sq_map) + geom_point(data = fuelmetrics, mapping = aes(x = fuelmetrics$Longitude,
                                                             y = fuelmetrics$Latitude, color=fuelmetrics$PopularityScore)) + scale_colour_gradient(low="blue",high="red")
# Map of specific area of Toronto for analysis
fuelmetrics <- subset(fuelmetrics, Geohash != 'dpz2sn2')

sbbox <- make_bbox(lon = c(-79.65,-79.60,-79.55), lat = c(43.65,43.70,43.75), f = .1)
sq_map <- get_map(location = sbbox, maptype = "roadmap", source = "google")
ggmap(sq_map) + geom_point(data = fuelmetrics, mapping = aes(x = fuelmetrics$Longitude, 
                                                             y = fuelmetrics$Latitude, color=fuelmetrics$PopularityScore)) + scale_colour_gradient(low="blue",high="red")

