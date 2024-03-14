# `bruvdir`

This repository contains code for automatically creating a directory structure for stereo BRUV (baited remote undervideo video) video files, using a function contained in 'R/make_bruv_dir.R'.

The function has the following three arguments:

```
campaign_name = "BRUV"  # the campaign name
no_sets = 4             # the number of sets in the campaign
no_per_set = 6          # number of deployments per set
unit_name = "H12"       # name of BRUV units; prefix to BRUVID
```

The structure is as follows:

```
- CampaignID
    - CampaignID_SetNo_(optional-location-label)
        - CampaignID_SetNo_RepNo_BRUVID_(optional-site-label)
            - SetNo_RepNo_BRUVID_L
            - SetNo_RepNo_BRUVID_R
```

Here is an example of the structure for sets 4 and 5 of campaign 'FLD24', with location and site labels added:

```
- FLD24
    - FLD24_S04_AnchorIsland
        - FLD24_S04_R01_H12-01_AI01
            - S04_R01_H12-01_L
            - S04_R01_H12-01_R
        - FLD24_S04_R02_H12-01_AI02
            - S04_R02_H12-02_L
            - S04_R02_H12-02_R
        - FLD24_S04_R03_H12-03_AI03
            - S04_R03_H12-03_L
            - S04_R03_H12-03_R
        - FLD24_S04_R04_H12-04_AI04
            - S04_R04_H12-04_L
            - S04_R04_H12-04_R
        - FLD24_S04_R05_H12-05_AI05
            - S04_R05_H12-05_L
            - S04_R05_H12-05_R
        - FLD24_S04_R06_H12-06_AI06
            - S04_R06_H12-06_L
            - S04_R06_H12-06_R
    - FLD24_S05_EastAnchorIsland_LuncheonCove
        - FLD24_S05_R01_H12-01_EA01
            - S05_R01_H12-01_L
            - S05_R01_H12-01_R
        - FLD24_S05_R02_H12-02_EA02
            - S05_R02_H12-02_L
            - S05_R02_H12-02_R
        - FLD24_S05_R03_H12-03_EA03
            - S05_R03_H12-03_L
            - S05_R03_H12-03_R
        - FLD24_S05_R04_H12-04_LC04
            - S05_R04_H12-04_L
            - S05_R04_H12-04_R
        - FLD24_S05_R05_H12-05_LC05
            - S05_R05_H12-05_L
            - S05_R05_H12-05_R
        - FLD24_S05_R06_H12-06_LC07
            - S05_R06_H12-06_L
            - S05_R06_H12-06_R
```

The code does not add the optional location or site names; these must be added manually.
