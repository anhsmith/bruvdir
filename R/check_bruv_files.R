check_folder_name_consistency <- function(campaign_name, campaign_path) {
  library(fs)
  library(stringr)
  library(dplyr)

  deployment_folders <- fs::dir_ls(campaign_path, type = "directory", regexp = paste0("^", campaign_name, "_S[0-9]{2}$"))

  inconsistent_folders <- list()

  for (deployment_folder in deployment_folders) {
    deployment_folder_name <- fs::path_file(deployment_folder)

    lr_folders <- fs::dir_ls(deployment_folder, recurse = TRUE, type = "directory",
                             regexp = "[/_](L|R)$")

    for (lr_folder in lr_folders) {
      lr_folder_name <- fs::path_file(lr_folder)

      short_pattern <- stringr::str_match(deployment_folder_name, paste0("^", campaign_name, "_(S[0-9]{2}_R[0-9]{2}_[^_]+)_"))[,2]

      full_lr_L <- paste0(deployment_folder_name, "_L")
      full_lr_R <- paste0(deployment_folder_name, "_R")

      short_lr_L <- paste0(short_pattern, "_L")
      short_lr_R <- paste0(short_pattern, "_R")

      if (!(lr_folder_name %in% c(full_lr_L, full_lr_R, short_lr_L, short_lr_R))) {
        inconsistent_folders <- c(inconsistent_folders, lr_folder)
      }
    }
  }

  if (length(inconsistent_folders) == 0) {
    message("\u2705 All L/R subfolder names consistent with deployment folders.")
  } else {
    message("❌ Inconsistent folder names found in these L/R folders:\n", paste(inconsistent_folders, collapse = "\n"))
  }
}


check_empty_lr_folders <- function(campaign_name, campaign_path) {
  lr_dirs <- fs::dir_ls(campaign_path, recurse = TRUE, type = "directory") %>%
    # Only keep *_L or *_R folders whose names start with the campaign name
    purrr::keep(~ {
      fname <- fs::path_file(.x)
      stringr::str_detect(fname, paste0("^", campaign_name, ".*_[LR][0-9]*$"))
    })

  empty_dirs <- lr_dirs[vapply(lr_dirs, function(d) {
    files <- tryCatch(fs::dir_ls(d), error = function(e) character(0))
    length(files) == 0
  }, logical(1))]

  if (length(empty_dirs) > 0) {
    message("❌ Empty L or R folders found:")
    print(empty_dirs)
  } else {
    message("✅ No empty L or R folders found.")
  }
}





check_duplicate_units_within_set <- function(campaign_name, campaign_path) {
  library(fs)
  library(stringr)
  library(dplyr)

  # List all set folders (e.g. FLD25_S01, FLD25_S02, etc.)
  set_folders <- fs::dir_ls(campaign_path, type = "directory",
                            regexp = paste0("^", campaign_name, "_S[0-9]{2}$"))

  duplicates_found <- list()

  for (set_folder in set_folders) {
    # Extract set folder name, e.g. "FLD25_S01"
    set_name <- fs::path_file(set_folder)

    # List all deployment folders inside this set folder
    deployment_folders <- fs::dir_ls(set_folder, type = "directory")

    # Extract unit IDs from deployment folder names
    # Assuming deployment folder names have the pattern: CAMPAIGN_S##_R##_UNITID_SITE
    # Example: FLD25_S01_R01_H12-01_EA01
    units <- stringr::str_extract(basename(deployment_folders), "(?<=_R[0-9]{2}_)[^_]+")

    # Count duplicates within this set
    unit_counts <- tibble(unit = units) %>%
      group_by(unit) %>%
      summarise(n = n()) %>%
      filter(n > 1)

    if (nrow(unit_counts) > 0) {
      duplicates_found[[set_name]] <- unit_counts
    }
  }

  if (length(duplicates_found) == 0) {
    message("\u2705 No duplicate unit IDs found within any set.")
  } else {
    message("❌ Duplicate unit IDs found within sets:")
    for (set_name in names(duplicates_found)) {
      message(paste0("Set ", set_name, ":"))
      print(duplicates_found[[set_name]])
    }
  }
}



check_duplicate_sites <- function(campaign_name, campaign_path) {
  library(fs)
  library(dplyr)
  library(stringr)
  library(purrr)

  extract_site_name <- function(folder_names) {
    known_tags <- c("FAIL", "PASS", "QC", "CHECK")
    sapply(folder_names, function(name) {
      parts <- unlist(strsplit(name, "_"))
      last_part <- tail(parts, 1)
      if (last_part %in% known_tags && length(parts) > 1) {
        site <- parts[length(parts) - 1]
      } else {
        site <- last_part
      }
      return(site)
    })
  }

  # Find all deployment folders (e.g. FLD25_S01_R01_H12-01_EA01 or similar)
  all_deployments <- dir_ls(campaign_path, recurse = TRUE, type = "directory") %>%
    keep(~ str_detect(basename(.x), paste0("^", campaign_name, "_S\\d+_R\\d+_H\\d+-\\d+_")))

  # Extract just the folder names (basenames)
  deployment_names <- basename(all_deployments)

  # Extract site names ignoring trailing tags
  sites <- extract_site_name(deployment_names)

  site_counts <- tibble(site = sites) %>%
    count(site) %>%
    filter(n > 1)

  if (nrow(site_counts) == 0) {
    message("\u2705 No duplicated site names found in campaign.")
    return(invisible(NULL))
  } else {
    message("❌ Duplicated site names found:")
    for (site in site_counts$site) {
      dup_deploys <- deployment_names[sites == site]
      message("Site '", site, "' occurs in deployments:")
      message(paste0("  ", dup_deploys, collapse = "\n"))
      message()
    }
    return(site_counts)
  }
}

