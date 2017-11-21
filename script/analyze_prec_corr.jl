using PyPlot


# Correction factor for snow (tair < -1.5)

pcorr_snow(wind) =  100 / (100 - 11.95*wind + wind*wind*0.55)

# Correction factor for mixed precipitation (-1.5 < tair < 0.5)

pcorr_mixed(wind) = 100 / (100 - 8.16*wind + wind*wind*0.45)

# Correction factor for rain (tair > 0.5)

pcorr_rain(wind) = 100 / (100 - 4.37*wind + wind*wind*0.35)


# Plot results

wind = 0.1:0.01:10

plot(wind, pcorr_snow.(wind), label = "Snow")
plot(wind, pcorr_mixed.(wind), label = "Mixed")
plot(wind, pcorr_rain.(wind), label = "Rain")

legend()

xlabel("Wind speed (m/s)")
ylabel("Precipitation correction factor")

