using PyPlot


# Methods for computing actual evapotranspiration from po

schreiber(pet_div_p) = 1 - exp(-pet_div_p)

pike(pet_div_p) = 1 / sqrt(1 + (1/pet_div_p)^2)

budyko(pet_div_p) = sqrt(pet_div_p * (1 - exp(-pet_div_p)) * tanh(1/pet_div_p))

zhang(pet_div_p, w) = (1 + w*pet_div_p) / (1 + w*pet_div_p + 1/pet_div_p)


pet_div_p = collect(0.001:0.001:1)

plot(pet_div_p, schreiber.(pet_div_p), label = "schreiber")
plot(pet_div_p, pike.(pet_div_p), label = "pike")
plot(pet_div_p, budyko.(pet_div_p), label = "budyko")
plot(pet_div_p, zhang.(pet_div_p, 0.3), label = "zhang (w = 0.3)")

axvspan(0.2, 0.3, alpha=0.5, color="gray")

xlabel("PET/P")
ylabel("ET/P")
legend()






