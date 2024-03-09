make_bruv_dir <- function(
    campaign_name = "BRUV",
    no_sets = 4,
    no_per_set = 6,
    unit_name = "H12"
    ) {

  # make campaign folder
  dir.create(campaign_name)


  for( i in 1:no_sets ) {

    # choose set name S01
    set_name <- paste0("S0", i)

    # create set folder BRUV/BRUV_S01
    dir.create(
      paste0(
        campaign_name, "/", # BRUV/
        campaign_name, "_", # BRUV_
        set_name            # S01
      )
    )

    for( j in 1:no_per_set ) {

      # choose rep name S01_R01_H12-01
      rep_name <- paste0(
         set_name,
          "_R0", j,
          "_", unit_name, "-", "0", j
      )

      dir.create(
        path = paste0(
          campaign_name,"/",                 # BRUV/
          campaign_name, "_", set_name, "/", # BRUV_S01/
          campaign_name, "_", rep_name       # BRUV_S01_R01_H12-01
          )
      )

      dir.create(
        path = paste0(
          campaign_name,"/",                 # BRUV/
          campaign_name, "_", set_name, "/", # BRUV_S01/
          campaign_name, "_", rep_name, "/", # BRUV_S01_R01_H12-01/
          rep_name, "_L"                     # S01_R01_L
        )
      )

      dir.create(
        path = paste0(
          campaign_name,"/",                 # BRUV/
          campaign_name, "_", set_name, "/", # BRUV_S01/
          campaign_name, "_", rep_name, "/", # BRUV_S01_R01_H12-01/
          rep_name, "_R"                     # S01_R01_R
        )
      )

    }
    }
}
