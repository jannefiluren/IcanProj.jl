
file <- "../data/HPC_dataMx.RData"

load(file)

header <- c("regine",
            "hovednum",
            "pkt",
            "day",
            "month",
            "year",
            "snow depth(m)",
            "SWE (m)",
            "obs. rho (kg/m3)",
            "databasecode",
            "nr. days since Jan1",
            "hyd.year",
            "UTMy33",
            "UTMx33",
            "hoh(m)")

year   <- SnowData[, which(header == "year")]
month  <- SnowData[, which(header == "month")]
day    <- SnowData[, which(header == "day")]
xcoord <- SnowData[, which(header == "UTMx33")]
ycoord <- SnowData[, which(header == "UTMy33")]
height <- SnowData[, which(header == "hoh(m)")]
swe    <- SnowData[, which(header == "SWE (m)")]
hs     <- SnowData[, which(header == "snow depth(m)")]
rho    <- SnowData[, which(header == "obs. rho (kg/m3)")]

df <- data.frame(year, month, day, xcoord, ycoord, height, swe, hs, rho)

df <- df[complete.cases(df), ]

write.csv(df, file="../data/snowdata.csv", row.names = FALSE, quote = FALSE)

