# Values taken from https://github.com/ajwdewit/WOFOST_crop_parameters/blob/master/wheat.yaml

crop <- list(
  TSUMEM = 120,
  TSUM1 = 1000,
  TSUM2 = 950,
  Tbase = 0,
  DVSI = 0,
  DVSEND = 2,
  SLA = 0.00212, #ha/kg
  RML = 0.030, #/d
  RMO = 0.010, #/d
  RMR = 0.0150, #/d
  RMS = 0.0150, #/d
  FLTB = c(0.000, 0.650, #mass/mass
           0.100, 0.650,
           0.250, 0.700,
           0.500, 0.500,
           0.646, 0.300,
           0.950, 0.000,
           2.000, 0.000),
  FSTB = c(0.000, 0.350, #mass/mass
           0.100, 0.350,
           0.250, 0.300,
           0.500, 0.500,
           0.646, 0.700,
           0.950, 1.000,
           1.000, 0.000,
           2.000, 0.000),
  FRTB = c(0.000, 0.500, #mass/mass
            0.100, 0.500,
            0.200, 0.400,
            0.350, 0.220,
            0.400, 0.170,
            0.500, 0.130,
            0.700, 0.070,
            0.900, 0.030,
            1.200, 0.000,
            2.000, 0.000),
  FOTB = c(0.000, 0.000, #mass/mass
           0.950, 0.000,
           1.000, 1.000,
           2.000, 1.000),
  RGRLAI = 0.0082, #/d
  Q10 = 2.0, #unitless
  k = 0.6, 
  CVL = 0.685,
  CVO = 0.709,
  CVR = 0.694,
  CVS = 0.662
)

# Convert the partitioning coefficient into data frames
make_partition_df <- function(tbl) {
  data.frame(
    DVS = tbl[seq(1, length(tbl), by = 2)],
    Value = tbl[seq(2, length(tbl), by = 2)]
  )
}

FLTB_df <- make_partition_df(crop$FLTB)
FSTB_df <- make_partition_df(crop$FSTB)
FRTB_df <- make_partition_df(crop$FRTB)
FOTB_df <- make_partition_df(crop$FOTB)
