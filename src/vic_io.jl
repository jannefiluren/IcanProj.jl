
using DataFrames

"""
Write global parameter file.
"""
function write_global_param(path_sim, path_forcing, startyear, endyear, timestep, output_force, full_energy)

    # Standard parameter part

    str_standard = """
    #######################################################################
    # VIC Model Parameters - 4.1.x
    #######################################################################
    # Id: global.param.sample,v 5.7.2.27 2012/02/07 19:03:02 vicadmin Exp 
    #######################################################################
    # Simulation Parameters
    #######################################################################
    NLAYER		3	# number of soil layers
    NODES		3	# number of soil thermal nodes 
    TIME_STEP 	$timestep	# model time step in hours (set to 24 if FULL_ENERGY = FALSE, set to < 24 if FULL_ENERGY = TRUE)
    SNOW_STEP	$timestep	# time step in hours for which to solve the snow model (should = TIME_STEP if TIME_STEP < 24)
    STARTYEAR	$startyear	# year model simulation starts
    STARTMONTH	01	# month model simulation starts
    STARTDAY	01 	# day model simulation starts
    STARTHOUR	00	# hour model simulation starts
    ENDYEAR 	$endyear	# year model simulation ends
    ENDMONTH	12	# month model simulation ends
    ENDDAY		31	# day model simulation ends
    FULL_ENERGY 	$full_energy	# TRUE = calculate full energy balance; FALSE = compute water balance only
    FROZEN_SOIL	FALSE	# TRUE = calculate frozen soils

    #######################################################################
    # Soil Temperature Parameters
    # VIC will choose appropriate values for QUICK_FLUX and IMPLICIT depending on values of FULL_ENERGY and FROZEN_SOIL; the user should only need to override VICs choices in special cases.
    # The other options in this section are only applicable when FROZEN_SOIL is TRUE and their values depend on the appliqqcation.
    #######################################################################
    #QUICK_FLUX	FALSE	# TRUE = use simplified ground heat flux method of Liang et al (1999); FALSE = use finite element method of Cherkauer et al (1999)
    #IMPLICIT	TRUE	# TRUE = use implicit solution for soil heat flux equation of Cherkauer et al (1999), otherwise uses original explicit solution.
    #QUICK_SOLVE	FALSE	# TRUE = Use Liang et al., 1999 formulation for iteration, but explicit finite difference method for final step.
    #NO_FLUX		FALSE	# TRUE = use no flux lower boundary for ground heat flux computation; FALSE = use constant flux lower boundary condition.  If NO_FLUX = TRUE, QUICK_FLUX MUST = FALSE
    #EXP_TRANS	FALSE	# TRUE = exponentially distributes the thermal nodes in the Cherkauer et al. (1999) finite difference algorithm, otherwise uses linear distribution
    #GRND_FLUX_TYPE	GF_410	# Options for ground flux:
    #			# GF_406 = use (flawed) formulas for ground flux, deltaH, and fusion from VIC 4.0.6 and earlier;
    #			# GF_410 = use formulas from VIC 4.1.0 (ground flux, deltaH, and fusion are correct; deltaH and fusion ignore surf_atten);
    #			# Default = GF_410
    #TFALLBACK	TRUE	# TRUE = when temperature iteration fails to converge, use previous time steps T value

    #######################################################################
    # Precip (Rain and Snow) Parameters
    # Generally these default values do not need to be overridden
    #######################################################################
    #SNOW_ALBEDO	USACE	# USACE = use traditional VIC algorithm based on US Army Corps of Engineers empirical snow albedo decay curves, using hard-coded dates for transitions from snow accumulation to melting; SUN1999 = use algorithm of Sun et al 1999, in which albedo decay depends on snow cold content (more appropriate for simulations outside the US).
    #SNOW_DENSITY	DENS_BRAS	# DENS_BRAS = use traditional VIC algorithm taken from Bras, 1990; DENS_SNTHRM = use algorithm taken from SNTHRM model.
    #BLOWING		FALSE	# TRUE = compute evaporative fluxes due to blowing snow
    #COMPUTE_TREELINE	FALSE	# Can be either FALSE or the id number of an understory veg class; FALSE = turn treeline computation off; VEG_CLASS_ID = replace any overstory veg types with the this understory veg type in all snow bands for which the average July Temperature <= 10 C (e.g. COMPUTE_TREELINE 10 replaces any overstory veg cover with class 10)
    #DIST_PRCP	FALSE	# TRUE = use distributed precipitation
    #PREC_EXPT	0.6	# exponent for use in distributed precipitation eqn (only used if DIST_PRCP is TRUE)
    #CORRPREC	FALSE	# TRUE = correct precipitation for gauge underqqcatch
    #MAX_SNOW_TEMP	0.5	# maximum temperature (C) at which snow can fall
    #MIN_RAIN_TEMP	-0.5	# minimum temperature (C) at which rain can fall

    #######################################################################
    # Turbulent Flux Parameters
    # Generally these default values do not need to be overridden
    #######################################################################
    #MIN_WIND_SPEED	0.1	# minimum allowable wind speed (m/s)
    #AERO_RESIST_CANSNOW	AR_406_FULL	# Options for aerodynamic resistance in snow-filled canopy:
    #			# AR_406 	= multiply by 10 for latent heat but do NOT multiply by 10 for sensible heat and do NOT apply stability correction (as in VIC 4.0.6); when no snow in canopy, use surface aero_resist for ET.
    #			# AR_406_LS 	= multiply by 10 for latent heat AND sensible heat and do NOT apply stability correction; when no snow in canopy, use surface aero_resist for ET.
    #			# AR_406_FULL 	= multiply by 10 for latent heat AND sensible heat and do NOT apply stability correction; additionally, always use overstory aero_resist for ET (as in 4.1.0).
    #			# AR_410 	= apply stability correction but do NOT multiply by 10 (as in VIC 4.1.0); additionally, always use overstory aero_resist for ET (as in 4.1.0).
    #			# Default 	= AR_406_FULL

    #######################################################################
    # Meteorological Forcing Disaggregation Parameters
    # Generally these default values do not need to be overridden
    #######################################################################
    #PLAPSE		TRUE	# This controls how VIC computes air pressure when air pressure is not supplied as an input forcing: TRUE = set air pressure to sea level pressure, lapsed to grid cell average elevation; FALSE = set air pressure to constant 95.5 kPa (as in all versions of VIC pre-4.1.1)
    #SW_PREC_THRESH		0	# Minimum daily precip [mm] that can cause dimming of incoming shortwave; default = 0.
    MTCLIM_SWE_CORR	FALSE    # This controls VICs estimates of incoming shortwave in the presence of snow; TRUE = adjust incoming shortwave for snow albedo effect; FALSE = do not adjust shortwave; default = TRUE
    #VP_ITER		VP_ITER_ALWAYS	# This controls VICs iteration between estimates of shortwave and vapor pressure:
    #			# VP_ITER_NEVER = never iterate; make estimates separately
    #			# VP_ITER_ALWAYS = always iterate once
    #			# VP_ITER_ANNUAL = iterate once for arid climates based on annual Precip/PET ratio
    #			# VP_ITER_CONVERGE = iterate until shortwave and vp stabilize
    #			# default = VP_ITER_ALWAYS
    #VP_INTERP	TRUE	# This controls sub-daily humidity estimates; TRUE = interpolate daily VP estimates linearly between sunrise of one day to the next; FALSE = hold VP constant for entire day
    #LW_TYPE		LW_TVA	# This controls the algorithm used to estimate clear-sky longwave radiation:
    #			# LW_TVA = Tennessee Valley Authority algorithm (1972)
    #			# other options listed in vicNl_def.h
    #			# default = LW_TVA (this was also the traditional VIC algorithm)
    #LW_CLOUD	LW_CLOUD_DEARDORFF	# This controls the algorithm used to estimate the influence of clouds on total longwave:
    #			# LW_CLOUD_BRAS = method from Bras textbook (this was the traditional VIC algorithm)
    #			# LW_CLOUD_DEARDORFF = method of Deardorff (1978)
    #			# default = LW_CLOUD_DEARDORFF
    OUTPUT_FORCE	$output_force

    #######################################################################
    # Miscellaneous Simulation Parameters
    # Generally these default values do not need to be overridden
    #######################################################################
    #CONTINUEONERROR	TRUE	# TRUE = if simulation aborts on one grid cell, continue to next grid cell

    #######################################################################
    # State Files and Parameters
    #######################################################################
    #INIT_STATE	/home/jmg/VIC-master/12.70/params/vic/state/STEHE.state_19481231	# Initial state path/file
    #STATENAME	/home/jmg/VIC-master/12.70/state/STEHE.state	# Output state file path/prefix.  The date (STATEYEAR,STATEMONTH,STATEDAY) will be appended to the prefix automatically in the format yyyymmdd.
    #STATEYEAR	2000	# year to save model state
    #STATEMONTH	12	# month to save model state
    #STATEDAY	31	# day to save model state
    #BINARY_STATE_FILE       FALSE	# TRUE if state file should be binary format; FALSE if ascii

    #######################################################################
    # Forcing Files and Parameters
    #
    #       All FORCING filenames are actually the pathname, and prefix
    #               for gridded data types: ex. DATA/forcing_
    #               Latitude and longitude index suffix is added by VIC
    #
    #	There must be 1 FORCE_TYPE entry for each variable (column) in the forcing file
    #
    #	If FORCE_TYPE is BINARY, each FORCE_TYPE must be followed by:
    #			SIGNED/UNSIGNED	SCALE_FACTOR
    #		For example (BINARY):
    #			FORCE_TYPE	PREC	UNSIGNED	40
    #		or (ASCII):
    #			FORCE_TYPE	PREC
    #######################################################################

    FORCING1	$(path_forcing)/forcing/data_
    GRID_DECIMAL	5
    N_TYPES		4
    FORCE_TYPE	PREC      SIGNED 100    
    FORCE_TYPE	TMIN      SIGNED   100
    FORCE_TYPE	TMAX      SIGNED   100
    FORCE_TYPE	WIND      SIGNED  100
    FORCE_FORMAT	BINARY	
    FORCE_ENDIAN    LITTLE 
    FORCE_DT	24	
    FORCEYEAR	$startyear	
    FORCEMONTH	1	
    FORCEDAY	1	
    FORCEHOUR	01	
    WIND_H          10.0    
    MEASURE_H       2.0     
    ALMA_INPUT	FALSE	

    #######################################################################
    # Land Surface Files and Parameters
    #######################################################################
    SOIL            $(path_sim)/params/soil_param	# Soil parameter path/file
    ARC_SOIL        FALSE   # TRUE = read soil parameters from ARC/INFO ASCII grids
    #SOIL_DIR        (soil param directory)   # Directory containing ARC/INFO ASCII grids of soil parameters - only valid if ARC_SOIL is TRUE
    BASEFLOW	NIJSSEN2001	# ARNO = columns 5-8 are the standard VIC baseflow parameters; NIJSSEN2001 = columns 5-8 of soil file are baseflow parameters from Nijssen et al (2001)
    JULY_TAVG_SUPPLIED	FALSE	# TRUE = final column of the soil parameter file will contain average July air temperature, for computing treeline; this will be ignored if COMPUTE_TREELINE is FALSE; FALSE = compute the treeline based on the average July air temperature of the forcings over the simulation period
    ORGANIC_FRACT	FALSE	# TRUE = simulate organic soils; soil param file contains 3*Nlayer extra columns, listing for each layer the organic fraction, and the bulk density and soil particle density of the organic matter in the soil layer; FALSE = soil param file does not contain any information about organic soil, and organic fraction should be assumed to be 0
    VEGLIB	        $(path_sim)/params/veglib_param	# Veg library path/file
    VEGPARAM        $(path_sim)/params/veg_param	# Veg parameter path/file
    ROOT_ZONES      2	# Number of root zones (must match format of veg param file)
    VEGPARAM_LAI 	TRUE    # TRUE = veg param file contains LAI information; FALSE = veg param file does NOT contain LAI information
    LAI_SRC 	LAI_FROM_VEGLIB    # LAI_FROM_VEGPARAM = read LAI from veg param file; LAI_FROM_VEGLIB = read LAI from veg library file
    SNOW_BAND	1 $(path_sim)/params/elev_band  # Number of snow bands; if number of snow bands > 1, you must insert the snow band path/file after the number of bands (e.g. SNOW_BAND 5 my_path/my_snow_band_file)

    #######################################################################
    # Lake Simulation Parameters
    # These need to be un-commented and set to correct values only when running lake model (LAKES is not FALSE)
    #######################################################################
    #LAKES		(put lake parameter path/file here)	# Lake parameter path/file
    #LAKE_PROFILE	FALSE	# TRUE = User-specified depth-area parameters in lake parameter file; FALSE = VIC computes a parabolic depth-area profile
    #EQUAL_AREA	FALSE	# TRUE = grid cells are from an equal-area projection; FALSE = grid cells are on a regular lat-lon grid
    #RESOLUTION	0.125	# Grid cell resolution (degrees if EQUAL_AREA is FALSE, km^2 if EQUAL_AREA is TRUE); ignored if LAKES is FALSE

    #######################################################################
    # Output Files and Parameters
    #######################################################################
    RESULT_DIR      $(path_sim)/results/	# Results directory path
    OUT_STEP        0       # Output interval (hours); if 0, OUT_STEP = TIME_STEP
    SKIPYEAR 	0	# Number of years of output to omit from the output files
    COMPRESS	FALSE	# TRUE = compress input and output files when done
    BINARY_OUTPUT $output_force	# TRUE = binary output files
    ALMA_OUTPUT	FALSE	# TRUE = ALMA-format output files; FALSE = standard VIC units
    MOISTFRACT 	FALSE	# TRUE = output soil moisture as volumetric fraction; FALSE = standard VIC units
    PRT_HEADER	FALSE   # TRUE = insert a header at the beginning of each output file; FALSE = no header
    PRT_SNOW_BAND   FALSE   # TRUE = write a snowband output file, containing band-specific values of snow variables; NOTE: this is ignored if N_OUTFILES is specified below.

    #######################################################################
    #
    # Output File Contents
    #
    # As of VIC 4.0.6 and 4.1.0, you can specify your output file names and
    # contents # in the global param file (see the README.txt file for more
    # information).
    #
    # If you do not specify file names and contents in the global param
    # file, VIC will produce the same set of output files that it has
    # produced in earlier versions, namely fluxes and snow files, plus
    # fdepth files if FROZEN_SOIL is TRUE and snowband files if
    # PRT_SNOW_BAND is TRUE.  These files will have the same contents and
    # format as in earlier versions.
    #
    # The OPTIMIZE and LDAS_OUTPUT options have been removed.  These
    # output configurations can be selected with the proper set of
    # instructions in the global param file.  (see the output.*.template
    # files included in this distribution for more information.)
    #
    # If you do specify the file names and contents in the global param file,
    # PRT_SNOW_BAND will have no effect.
    #
    # Format:
    #
    #   N_OUTFILES    <n_outfiles>
    #
    #   OUTFILE       <prefix>        <nvars>
    #   OUTVAR        <varname>       [<format>        <type>  <multiplier>]
    #   OUTVAR        <varname>       [<format>        <type>  <multiplier>]
    #   OUTVAR        <varname>       [<format>        <type>  <multiplier>]
    #
    #   OUTFILE       <prefix>        <nvars>
    #   OUTVAR        <varname>       [<format>        <type>  <multiplier>]
    #   OUTVAR        <varname>       [<format>        <type>  <multiplier>]
    #   OUTVAR        <varname>       [<format>        <type>  <multiplier>]
    #
    #
    # where
    #   <n_outfiles> = number of output files
    #   <prefix>     = name of the output file, NOT including latitude
    #                  and longitude
    #   <nvars>      = number of variables in the output file
    #   <varname>    = name of the variable (this must be one of the
    #                  output variable names listed in vicNl_def.h.)
    #   <format>     = (for ascii output files) fprintf format string,
    #                  e.g.
    #                    %.4f = floating point with 4 decimal places
    #                    %.7e = scientific notation w/ 7 decimal places
    #                    *    = use the default format for this variable
    #
    #   <format>, <type>, and <multiplier> are optional.  For a given
    #   variable, you can specify either NONE of these, or ALL of
    #   these.  If these are omitted, the default values will be used.
    #
    #   <type>       = (for binary output files) data type code.
    #                  Must be one of:
    #                    OUT_TYPE_DOUBLE = double-precision floating point
    #                    OUT_TYPE_FLOAT  = single-precision floating point
    #                    OUT_TYPE_INT    = integer
    #                    OUT_TYPE_USINT  = unsigned short integer
    #                    OUT_TYPE_SINT   = short integer
    #                    OUT_TYPE_CHAR   = char
    #                    *               = use the default type
    #   <multiplier> = (for binary output files) factor to multiply
    #                  the data by before writing, to increase precision.
    #                    *    = use the default multiplier for this variable
    #
    #######################################################################

    """

    # Write mtclim binary output

    str_mtclim = """

    N_OUTFILES    1

    OUTFILE       metdata        8 

    OUTVAR		OUT_PREC	* OUT_TYPE_USINT	40
    OUTVAR		OUT_AIR_TEMP	* OUT_TYPE_SINT		100
    OUTVAR		OUT_SHORTWAVE	* OUT_TYPE_USINT	50
    OUTVAR		OUT_LONGWAVE	* OUT_TYPE_USINT	80
    OUTVAR		OUT_PRESSURE	* OUT_TYPE_USINT	100
    OUTVAR		OUT_QAIR	* OUT_TYPE_USINT	100000
    OUTVAR		OUT_VP		* OUT_TYPE_USINT	100
    OUTVAR		OUT_WIND	* OUT_TYPE_USINT	100
    """

    if output_force == "FALSE"
        str = str_standard
    elseif output_force == "TRUE"
        str = str_standard * str_mtclim
    end

    fid = open(joinpath(path_sim, "params/global_param"), "w")

    write(fid, str)

    close(fid)

    return nothing

end


"""
Read soil parameter file.
"""
function read_soil_params(path)
    
    df = readtable(joinpath(path, "params/soil_param"), separator = ' ', header = false)
    
    colnames = [:run_cell, :gridcel, :lat, :lon, :infilt, :D1, :D2, :D3, :D4,
    :expt1, :expt2, :expt3, :Ksat1, :Ksat2, :Ksat3, :phi_s1, :phi_s2, :phi_s3,
    :init_moist1, :init_moist2, :init_moist3, :elev, :depth1, :depth2, :depth3,
    :avg_T, :dp, :bubble1, :bubble2, :bubble3, :quartz1, :quartz2, :quartz3,
    :bulk_density1, :bulk_density2, :bulk_density3, :soil_density1, :soil_density2,
    :soil_density3, :off_gmt, :Wcr_FRACT1, :Wcr_FRACT2, :Wcr_FRACT3, :Wpwp_FRACT1,
    :Wpwp_FRACT2, :Wpwp_FRACT3, :rough, :snow_rough, :annual_prec, :resid_moist1, 
    :resid_moist2, :resid_moist3, :fs_active]
    
    names!(df, colnames)
    
    return df
    
end


"""
Write soil parameter file.
"""
function write_soil_params(path_sim, df)
    
    # Write parameters to file
    
    fid = open(joinpath(path_sim, "params/soil_param"), "w")
    
    for irow in 1:size(df,1)

        if df[:Wpwp_FRACT1][irow] < df[:resid_moist1][irow] / (1.0 - df[:bulk_density1][irow]/df[:soil_density1][irow])
            df[:Wpwp_FRACT1][irow] = 1.01 * df[:resid_moist1][irow] / (1.0 - df[:bulk_density1][irow]/df[:soil_density1][irow])
        end
        
        if df[:Wpwp_FRACT2][irow] < df[:resid_moist2][irow] / (1.0 - df[:bulk_density2][irow]/df[:soil_density2][irow])
            df[:Wpwp_FRACT2][irow] = 1.01 * df[:resid_moist2][irow] / (1.0 - df[:bulk_density2][irow]/df[:soil_density2][irow])
        end

        if df[:Wpwp_FRACT3][irow] < df[:resid_moist3][irow] / (1.0 - df[:bulk_density3][irow]/df[:soil_density3][irow])
            df[:Wpwp_FRACT3][irow] = 1.01 * df[:resid_moist3][irow] / (1.0 - df[:bulk_density3][irow]/df[:soil_density3][irow])
        end
        
        write(fid, @sprintf("%.0f ", df[:run_cell][irow]))
        write(fid, @sprintf("%.0f ", df[:gridcel][irow]))
        write(fid, @sprintf("%.5f ", df[:lat][irow]))
        write(fid, @sprintf("%.5f ", df[:lon][irow]))
        write(fid, @sprintf("%.4f ", df[:infilt][irow]))
        write(fid, @sprintf("%.4f ", df[:D1][irow]))
        write(fid, @sprintf("%.4f ", df[:D2][irow]))
        write(fid, @sprintf("%.4f ", df[:D3][irow]))
        write(fid, @sprintf("%.4f ", df[:D4][irow]))
        write(fid, @sprintf("%.4f ", df[:expt1][irow]))
        write(fid, @sprintf("%.4f ", df[:expt2][irow]))
        write(fid, @sprintf("%.4f ", df[:expt3][irow]))
        write(fid, @sprintf("%.4f ", df[:Ksat1][irow]))
        write(fid, @sprintf("%.4f ", df[:Ksat2][irow]))
        write(fid, @sprintf("%.4f ", df[:Ksat3][irow]))
        write(fid, @sprintf("%.4f ", df[:phi_s1][irow]))
        write(fid, @sprintf("%.4f ", df[:phi_s2][irow]))
        write(fid, @sprintf("%.4f ", df[:phi_s3][irow]))
        write(fid, @sprintf("%.4f ", df[:init_moist1][irow]))
        write(fid, @sprintf("%.4f ", df[:init_moist2][irow]))
        write(fid, @sprintf("%.4f ", df[:init_moist3][irow]))
        write(fid, @sprintf("%.4f ", df[:elev][irow]))
        write(fid, @sprintf("%.4f ", df[:depth1][irow]))
        write(fid, @sprintf("%.4f ", df[:depth2][irow]))
        write(fid, @sprintf("%.4f ", df[:depth3][irow]))
        write(fid, @sprintf("%.4f ", df[:avg_T][irow]))
        write(fid, @sprintf("%.4f ", df[:dp][irow]))
        write(fid, @sprintf("%.4f ", df[:bubble1][irow]))
        write(fid, @sprintf("%.4f ", df[:bubble2][irow]))
        write(fid, @sprintf("%.4f ", df[:bubble3][irow]))
        write(fid, @sprintf("%.4f ", df[:quartz1][irow]))
        write(fid, @sprintf("%.4f ", df[:quartz2][irow]))
        write(fid, @sprintf("%.4f ", df[:quartz3][irow]))
        write(fid, @sprintf("%.4f ", df[:bulk_density1][irow]))
        write(fid, @sprintf("%.4f ", df[:bulk_density2][irow]))
        write(fid, @sprintf("%.4f ", df[:bulk_density3][irow]))
        write(fid, @sprintf("%.4f ", df[:soil_density1][irow]))
        write(fid, @sprintf("%.4f ", df[:soil_density2][irow]))
        write(fid, @sprintf("%.4f ", df[:soil_density3][irow]))
        write(fid, @sprintf("%.4f ", df[:off_gmt][irow]))
        write(fid, @sprintf("%.4f ", df[:Wcr_FRACT1][irow]))
        write(fid, @sprintf("%.4f ", df[:Wcr_FRACT2][irow]))
        write(fid, @sprintf("%.4f ", df[:Wcr_FRACT3][irow]))
        write(fid, @sprintf("%.4f ", df[:Wpwp_FRACT1][irow]))
        write(fid, @sprintf("%.4f ", df[:Wpwp_FRACT2][irow]))
        write(fid, @sprintf("%.4f ", df[:Wpwp_FRACT3][irow]))
        write(fid, @sprintf("%.4f ", df[:rough][irow]))
        write(fid, @sprintf("%.4f ", df[:snow_rough][irow]))
        write(fid, @sprintf("%.4f ", df[:annual_prec][irow]))
        write(fid, @sprintf("%.4f ", df[:resid_moist1][irow]))
        write(fid, @sprintf("%.4f ", df[:resid_moist2][irow]))
        write(fid, @sprintf("%.4f ", df[:resid_moist3][irow]))
        write(fid, @sprintf("%.4f \n", df[:fs_active][irow]))
                
    end
    
    close(fid)
    
    return nothing
    
end


"""
Read flux files.
"""
function read_fluxes(path_sim, file)
    
    df = readtable(joinpath(path_sim, file), separator = '\t', header = false)
    
    # Water balance mode on daily time step
    
    ncols = size(df, 2)
    
    if ncols == 25
        
        colnames = [:year, :month, :day, :prec, :evap,
        :runoff, :baseflow, :wdew, :soil_liq1, :soil_liq2,
        :soil_liq3, :net_short, :r_net, :evap_canop, :transp_veg,
        :evap_bare, :sub_canop, :sub_snow, :aero_resist, :surf_temp,
        :albedo, :rel_humid, :in_long, :air_temp, :wind]
        
        names!(df, colnames)
        
        df[:time] = DateTime.(df[:year], df[:month], df[:day])
        
    end
    
    # Water balance mode on sub-daily time step
    
    if ncols == 26
        
        colnames = [:year, :month, :day, :hour, :prec, :evap,
        :runoff, :baseflow, :wdew, :soil_liq1, :soil_liq2,
        :soil_liq3, :net_short, :r_net, :evap_canop, :transp_veg,
        :evap_bare, :sub_canop, :sub_snow, :aero_resist, :surf_temp,
        :albedo, :rel_humid, :in_long, :air_temp, :wind]
        
        names!(df, colnames)
        
        df[:time] = DateTime.(df[:year], df[:month], df[:day], df[:hour])
        
    end
    
    # Energy balance mode on daily time step
    
    if ncols == 31
        
        colnames = [:year, :month, :day, :prec, :evap,
        :runoff, :baseflow, :wdew, :soil_liq1, :soil_liq2,
        :soil_liq3, :rad_temp, :net_short, :r_net, :latent,
        :evap_canop, :transp_veg, :evap_bare, :sub_canop, :sub_snow,
        :sensible, :grnd_flux, :deltah, :fusion, :aero_resist,
        :surf_temp, :albedo, :rel_humid, :in_long, :air_temp,
        :wind]
        
        names!(df, colnames)
        
        df[:time] = DateTime.(df[:year], df[:month], df[:day])
        
    end
    
    # Energy balance mode on sub-daily time step
    
    if ncols == 32
        
        colnames = [:year, :month, :day, :hour, :prec, :evap,
        :runoff, :baseflow, :wdew, :soil_liq1, :soil_liq2,
        :soil_liq3, :rad_temp, :net_short, :r_net, :latent,
        :evap_canop, :transp_veg, :evap_bare, :sub_canop, :sub_snow,
        :sensible, :grnd_flux, :deltah, :fusion, :aero_resist,
        :surf_temp, :albedo, :rel_humid, :in_long, :air_temp,
        :wind]
        
        names!(df, colnames)
        
        df[:time] = DateTime.(df[:year], df[:month], df[:day], df[:hour])
        
    end
    
    return df    
    
end


"""
Read snow files.
"""
function read_snow(path_sim, file)

    df = readtable(joinpath(path_sim, file), separator = '\t', header = false)

    # Water balance mode on daily time step
    
    ncols = size(df, 2)
    
    if ncols == 7
        
        colnames = [:year, :month, :day, :swe, :snow_depth, :snow_canopy, :snow_cover]
        
        names!(df, colnames)
        
        df[:time] = DateTime.(df[:year], df[:month], df[:day])
        
    end

    # Water balance mode on sub-daily time step
    
    if ncols == 8
        
        colnames = [:year, :month, :day, :hour, :swe, :snow_depth, :snow_canopy, :snow_cover]
        
        names!(df, colnames)
        
        df[:time] = DateTime.(df[:year], df[:month], df[:day], df[:hour])
        
    end

    # Energy balance mode on daily time step
    
    if ncols == 17
        
        colnames = [:year, :month, :day, :swe, :snow_depth, :snow_canopy, :snow_cover,
                    :advection, :deltacc, :snow_flux, :rfrz_energy, :melt_energy, :adv_sens, :latent_sub,
                    :snow_surf_temp, :snow_pack_temp, :snow_melt]

        names!(df, colnames)
        
        df[:time] = DateTime.(df[:year], df[:month], df[:day])
        
    end

    # Energy balance mode on sub-daily time step
    
    if ncols == 18
        
        colnames = [:year, :month, :day, :hour, :swe, :snow_depth, :snow_canopy, :snow_cover,
                    :advection, :deltacc, :snow_flux, :rfrz_energy, :melt_energy, :adv_sens, :latent_sub,
                    :snow_surf_temp, :snow_pack_temp, :snow_melt]

        names!(df, colnames)
        
        df[:time] = DateTime.(df[:year], df[:month], df[:day], df[:hour])
        
    end

    return df
    
end


"""
Read vic forcings.
"""
function read_vic_forcing(file)

    prec = Float64[]
    tmin = Float64[]
    tmax = Float64[]
    wind = Float64[]

    fid = open(file, "r")

    while !eof(fid)

        push!(prec, convert(Float64, read(fid, Int16))/100.0)
        push!(tmin, convert(Float64, read(fid, Int16))/100.0)
        push!(tmax, convert(Float64, read(fid, Int16))/100.0)
        push!(wind, convert(Float64, read(fid, Int16))/100.0)
        
    end

    close(fid)

    return prec, tmin, tmax, wind

end


"""
Write vic forcings.
"""
function write_vic_forcing(file, prec, tmin, tmax, wind)

    fid = open(file, "w")

    for i in 1:length(prec)

        write(fid, round(Int16, 100*prec[i]))
        write(fid, round(Int16, 100*tmin[i]))
        write(fid, round(Int16, 100*tmax[i]))
        write(fid, round(Int16, 100*wind[i]))

    end

    close(fid)

    return nothing

end


"""
Read mtclim output.
"""
function read_mtclim(file)

    #=
    OUTVAR		OUT_PREC	    * OUT_TYPE_USINT	40      incoming precipitation [mm]
    OUTVAR		OUT_AIR_TEMP        * OUT_TYPE_SINT	100     air temperature [C]
    OUTVAR		OUT_SHORTWAVE	    * OUT_TYPE_USINT	50      incoming shortwave [W/m2]
    OUTVAR		OUT_LONGWAVE        * OUT_TYPE_USINT	80      incoming longwave [W/m2]
    OUTVAR		OUT_PRESSURE	    * OUT_TYPE_USINT	100     near surface atmospheric pressure [kPa]
    OUTVAR		OUT_QAIR	    * OUT_TYPE_USINT	100000  specific humidity [kg/kg]
    OUTVAR		OUT_VP		    * OUT_TYPE_USINT	100     near surface vapor pressure [kPa]
    OUTVAR		OUT_WIND	    * OUT_TYPE_USINT	100     near surface wind speed [m/s]
    =#

    prec = []
    tair = []
    iswr = []
    ilwr = []
    pres = []
    qair = []
    vp = []
    wind = []

    fid = open(file, "r")

    while !eof(fid)

        push!(prec , convert(Float64, read(fid, UInt16))/40.0)
        push!(tair , convert(Float64, read(fid, Int16))/100.0)
        push!(iswr , convert(Float64, read(fid, UInt16))/50.0)
        push!(ilwr , convert(Float64, read(fid, UInt16))/80.0)
        push!(pres , convert(Float64, read(fid, UInt16))/100.0)
        push!(qair , convert(Float64, read(fid, UInt16))/100000.0)
        push!(vp ,   convert(Float64, read(fid, UInt16))/100.0)
        push!(wind , convert(Float64, read(fid, UInt16))/100.0)

    end

    close(fid)

    return prec, tair, iswr, ilwr, pres, qair, vp, wind

end


"""
Read vegetation parameter file and return as dataframe.
"""
function read_veg_param(path)

    # Standard file name

    file = "params/veg_param"

    # Empty dataframe

    df = DataFrame(gridcel = [],
                   Nveg = [],
                   veg_class = [],
                   Cv = [],
                   root_depth1 = [],
                   root_depth2 = [],
                   root_frac1 = [],
                   root_frac2 = [],
                   lai1 = [],
                   lai2 = [],
                   lai3 = [],
                   lai4 = [],
                   lai5 = [],
                   lai6 = [],
                   lai7 = [],
                   lai8 = [],
                   lai9 = [],
                   lai10 = [],
                   lai11 = [],
                   lai12 = [])

    # Read file

    str = readlines(joinpath(path, file))

    i = 1

    while i < length(str)

        # Read gridcel and number of vegetation classes

        tmp = parse.(split(str[i]))

        gridcel = tmp[1]
        Nveg = tmp[2]

        for j = 1:2:(2*Nveg-1)

            # Process row with vegetation class ...

            tmp = parse.(split(str[i+j]))

            veg_class = tmp[1]
            Cv = tmp[2]
            root_depth = tmp[3:4]
            root_frac = tmp[5:6]

            # Process row with leaf area index

            tmp = parse.(split(str[i+j+1]))
            
            lai = tmp
            
            # Add all together

            row = vcat(gridcel, Nveg, veg_class, Cv, root_depth, root_frac, lai)

            push!(df, row)
            
        end

        i += 2*Nveg + 1

    end

    return df

end


"""
Write vegetation parameter file given as a dataframe.
"""
function write_veg_params(path, df)

    fid = open(joinpath(path, "params/veg_param"), "w")

    for gridcel in unique(df[:gridcel])

        irow = findin(df[:gridcel], gridcel)

        df_tmp = df[irow, :]

        Nveg = df_tmp[:Nveg][1]

        write(fid, @sprintf("%.0f %.0f\n", gridcel, Nveg))
        
        for row in eachrow(df_tmp)

            write(fid, @sprintf("%6.0f %0.3f %0.2f %0.2f %0.2f %0.2f\n", 
                                row[:veg_class], row[:Cv], row[:root_depth1], row[:root_depth2], row[:root_frac1], row[:root_frac2]))

            write(fid, @sprintf("       %-0.3f %0.3f %0.3f %0.3f %0.3f %0.3f %0.3f %0.3f %0.3f %0.3f %0.3f %0.3f\n",
                                row[:lai1], row[:lai2], row[:lai3], row[:lai4], row[:lai5], row[:lai6], 
                                row[:lai7], row[:lai8], row[:lai9], row[:lai10], row[:lai11], row[:lai12]))

        end

    end

    close(fid)

end


"""
Read all snow files in a directory.
"""
function read_all_snow(path)

    files = readdir(path)

    files = filter(x->contains(x, "snow"), files)

    df_tmp = read_snow(path, files[1])

    ifirst = find(names(df_tmp) .== :swe)[1]
    ilast = find(names(df_tmp) .== :snow_melt)[1]

    data = convert(Array, df_tmp[ifirst:ilast])/length(files)

    for i in 2:length(files)
        @show i
        df_tmp = read_snow(path, files[i])
        data += convert(Array, df_tmp[ifirst:ilast])/length(files)
    end

    df = DataFrame(data)

    names!(df, names(df_tmp[ifirst:ilast]))

    df[:time] = df_tmp[:time]

    return df

end


"""
Read all flux files in a directory.
"""
function read_all_fluxes(path)

    files = readdir(path)

    files = filter(x->contains(x, "fluxes"), files)

    df_tmp = read_fluxes(path, files[1])

    ifirst = find(names(df_tmp) .== :prec)[1]
    ilast = find(names(df_tmp) .== :wind)[1]

    data = convert(Array, df_tmp[ifirst:ilast])/length(files)

    for i in 2:length(files)
        @show i
        df_tmp = read_fluxes(path, files[i])
        data += convert(Array, df_tmp[ifirst:ilast])/length(files)
    end

    df = DataFrame(data)

    names!(df, names(df_tmp[ifirst:ilast]))

    df[:time] = df_tmp[:time]

    return df

end
