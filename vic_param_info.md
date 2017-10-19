
# VIC parameters

This document contains information about our model setup.

We are using VIC.4.2.d., which is documented [here](http://vic.readthedocs.io/en/vic.4.2.d/).



## Global parameter file

Link for information about the [global parameter file](http://vic.readthedocs.io/en/vic.4.2.d/Documentation/GlobalParam/)




## Soil parameter file

Link for information about the [soil parameter file](http://vic.readthedocs.io/en/vic.4.2.d/Documentation/SoilParam/)

1:  run_cell - Run cell or not (jmg: clear what this should be)

2:  gridcel - Identifier (jmg: clear what this should be)

3:  lat - Latitude (jmg: clear what this should be)

4:  lon - Longitude (jmg: clear what this should be)

5:  infilt - Variable infiltration curve parameter (jmg: from global file or calibration)

6:  D1 - Fraction of Dsmax where non-linear baseflow begins (jmg: from global file or calibration)

7:  D2 - Maximum velocity of baseflow (jmg: from global file or calibration)

8:  D3 - Fraction of maximum soil moisture where non-linear baseflow occurs (jmg: from global file or calibration)

9:  D4 - Exponent used in baseflow curve, normally set to 2 (jmg: from global file or calibration)

10: expt1 - Exponent in Campbell's eqn for hydraulic conductivity (jmg: from global file or calibration)

11: expt2 - Exponent in Campbell's eqn for hydraulic conductivity (jmg: from global file or calibration)

12: expt3 - Exponent in Campbell's eqn for hydraulic conductivity (jmg: from global file or calibration)

13: Ksat1 - Saturated hydrologic conductivity (jmg: from global file, local data or calibration)

14: Ksat2 - Saturated hydrologic conductivity (jmg: from global file, local data or calibration)

15: Ksat3 - Saturated hydrologic conductivity (jmg: from global file, local data or calibration)

16: phi_s1 - Soil moisture diffusion parameter (jmg: from global file, local data or calibration)

17: phi_s2 - Soil moisture diffusion parameter (jmg: from global file, local data or calibration)

18: phi_s3 - Soil moisture diffusion parameter (jmg: from global file, local data or calibration)

19: init_moist1 - Initial layer moisture content (jmg: from global file)

20: init_moist2 -	Initial layer moisture content (jmg: from global file)

21: init_moist3 - Initial layer moisture content (jmg: from global file)

22: elev - Average elevation of grid cell (jmg: from dem)

23: depth1 - Thickness of each soil moisture layer (jmg: from global file or local data)

24: depth2 - Thickness of each soil moisture layer (jmg: from global file or local data)

25: depth3 - Thickness of each soil moisture layer (jmg: from global file or local data)

26: avg_T - Average soil temperature, used as the bottom boundary for soil heat flux solutions (jmg: from global file or local assumption)

27: dp - Soil thermal damping depth (jmg: from global file or local assumption)

28: bubble1 - Bubbling pressure of soil (jmg: not relevant I think)

29: bubble2 - Bubbling pressure of soil (jmg: not relevant I think)

30: bubble3 - Bubbling pressure of soil (jmg: not relevant I think)

31: quartz1 - Quartz content of soil (jmg: not relevant I think)

32: quartz2 -	Quartz content of soil  (jmg: not relevant I think)

33: quartz3 -	Quartz content of soil  (jmg: not relevant I think)

34: bulk_density1 - Bulk density of soil layer (jmg: global or local data?)

35: bulk_density2 - Bulk density of soil layer (jmg: global or local data?)

36: bulk_density3 - Bulk density of soil layer (jmg: global or local data?)

37: soil_density1 - Soil particle density (jmg: global or local data?)

38: soil_density2 - Soil particle density (jmg: global or local data?)

39: soil_density3 - Soil particle density (jmg: global or local data?)

40: off_gmt - Time offset "off_gmt=(grid_cell_longitude*24/360)" (jmg: from our longitude)

41: Wcr_FRACT1 - Fractional soil moisture content at the critical point (jmg: global or local data?)

42: Wcr_FRACT2 - Fractional soil moisture content at the critical point (jmg: global or local data?)

43: Wcr_FRACT3 - Fractional soil moisture content at the critical point (jmg: global or local data?)

44: Wpwp_FRACT1 - Fractional soil moisture content at the wilting point (jmg: global or local data?)

45: Wpwp_FRACT2 - Fractional soil moisture content at the wilting point (jmg: global or local data?)

46: Wpwp_FRACT3 - Fractional soil moisture content at the wilting point (jmg: global or local data?)

47: rough - Surface roughness of bare soil (jmg: standard value)

48: snow_rough - Surface roughness of snowpack (jmg: standard value)

49: annual_prec - Average annual precipitation (jmg: from meteo data)

50: resid_moist1 - Soil moisture layer residual moisture (jmg: global or local data?)

51: resid_moist2 - Soil moisture layer residual moisture (jmg: global or local data?)

52: resid_moist3 - Soil moisture layer residual moisture (jmg: global or local data?)

53: fs_active - If set to 1, then frozen soil algorithm is activated for the grid cell (jmg: we set this to 0)


## Vegetation parameter file

Link for information about the [vegetation parameter file](http://vic.readthedocs.io/en/vic.4.2.d/Documentation/VegParam/)

1: gridcel - Identifier (jmg: clear what this should be)

2: Nveg - Number of vegetation classes in a grid cell (jgm: irrelevant)

3: veg_class - Identifier (jmg: clear what this should be)

4: Cv - Fraction of area covered by a specific vegetation class (jmg: clear what this should be)

5: root_depth1 - Root depth for first layer (jmg: ???)

6: root_depth2 - Root depth for second layer (jmg: ???)

7: root_frac1 - Fraction of roots for first layer (jmg: ???)

8: root_frac2 - Fraction of roots for second layer (jmg: ???)

9-10: lai - Monthly leaf area index values


## Vegetation library file

Link for information about the [vegetation library file](http://vic.readthedocs.io/en/vic.4.2.d/Documentation/VegLib/)

[Here](https://github.com/jmgnve/IcanProj.jl/blob/master/data/veglib_param_example) is an example of a vegetation library file.
