load("landuse.RData")

# Aggregate land use. OBS! Results are in km2
agg1km <- cells[,c(1,9:21)]
agg5km <- aggregate(cells[,9:21], by=list(ind_5km=cells$ind_5km), FUN=sum)
agg10km <- aggregate(cells[,9:21], by=list(ind_10km=cells$ind_10km), FUN=sum)
agg25km <- aggregate(cells[,9:21], by=list(ind_25km=cells$ind_25km), FUN=sum)
agg50km <- aggregate(cells[,9:21], by=list(ind_50km=cells$ind_50km), FUN=sum)

# LAI and canopy height in the order forest1-12, other
LAI <- c(1.4,4.3,6.7,9.1,0.9,2.4,2.3,4.4,0.1,0.2,0.3,0.4,0)
hcan <- c(7.5,12.3,16.8,22,7.5,11.6,17,17.2,4.9,8.4,12.2,18.3,0)

for(name in c("agg1km","agg5km","agg10km","agg25km","agg50km")){
  #print(length(which(get(name)[-1,]>0)))
  #print(max(apply(get(name)[,-1], 1, function(x) length(which(x>0)))))
  print(mean(apply(get(name)[,-1], 1, function(x) length(which(x>0)))))
}

