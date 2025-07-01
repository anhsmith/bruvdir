check_folder_name_consistency <- function(campaign_name, campaign_path) {
  library(fs)
  library(stringr)
  library(dplyr)

  # All *_L and *_R folders under campaign
  lr_dirs <- dir_ls(campaign_path, recurse = TRUE, type = "directory") %>%
    .[str_detect(path_file(.), "(_L|_R)$") & str_detect(., campaign_name)]

  # Function to check one path
  check_path <- function(p) {
    # Break into parts
    path_parts <- str_split(p, "/|\\\\")[[1]]
    path_parts <- path_parts[nzchar(path_parts)]

    # Try to get the relevant levels: campaign folder / set folder / deployment folder / L|R folder
    if (length(path_parts) < 4) return(NULL)

    set_folder        <- path_parts[length(path_parts) - 2]
    deployment_folder <- path_parts[length(path_parts) - 1]
    lr_folder         <- path_parts[length(path_parts)]

    # Extract expected parts
    set_id   <- str_extract(set_folder, paste0(campaign_name, "_S\\d{2}"))
    rep_id   <- str_extract(deployment_folder, "R\\d{2}")
    unit_id  <- str_extract(deployment_folder, "H\\d{2}-\\d{2}")

    expected_lr_prefix <- str_extract(lr_folder, paste0("S\\d{2}_R\\d{2}_H\\d{2}-\\d{2}"))

    # Make sure parts all exist and match
    if (is.na(set_id) | is.na(rep_id) | is.na(unit_id) | is.na(expected_lr_prefix)) {
      return(p)
    }

    full_expected <- paste0(set_id, "_", rep_id, "_", unit_id)
    actual_prefix <- str_sub(lr_folder, 1, str_length(full_expected))

    if (actual_prefix != full_expected) {
      return(p)
    } else {
      return(NULL)
    }
  }

  # Run check across all L/R folders
  bad_paths <- unlist(lapply(lr_dirs, check_path))

  if (length(bad_paths) > 0) {
    message("❌ Inconsistent folder names found in these L/R folders:")
    print(bad_paths)
  } else {
    message("✅ All L/R subfolder names consistent with deployment folders.")
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

  deployment_dirs <- dir_ls(campaign_path, recurse = TRUE, type = "directory") %>%
    .[str_detect(., paste0("/", campaign_name, "_S\\d{2}/", campaign_name, "_S\\d{2}_R\\d{2}_H\\d{2}-\\d{2}_.+"))]

  df <- tibble(
    path = deployment_dirs,
    set = str_extract(path, paste0(campaign_name, "_S\\d{2}")),
    unit = str_extract(path, "H\\d{2}-\\d{2}")
  )

  dup_units <- df %>%
    group_by(set, unit) %>%
    filter(n() > 1) %>%
    arrange(set, unit)

  if (nrow(dup_units) > 0) {
    message("❌ Duplicate unit IDs found within sets:")
    print(dup_units)
  } else {
    message("✅ No duplicate unit IDs within sets.")
  }
}


check_duplicate_sites <- function(campaign_name, campaign_path) {
  library(fs)
  library(stringr)
  library(dplyr)

  deployment_dirs <- dir_ls(campaign_path, recurse = TRUE, type = "directory") %>%
    .[str_detect(path_file(.), paste0("^", campaign_name, "_S\\d{2}_R\\d{2}_H\\d{2}-\\d{2}_.+"))]

  deployment_info <- tibble(
    path = deployment_dirs,
    folder = path_file(deployment_dirs),
    site = str_extract(folder, "(?<=_)[^_]+$"),
    opcode = folder
  )

  dup_sites <- deployment_info %>%
    count(site) %>%
    filter(n > 1)

  if (nrow(dup_sites) > 0) {
    message("❌ Duplicated site names found:")
    for (s in dup_sites$site) {
      opcodes <- deployment_info %>%
        filter(site == s) %>%
        pull(opcode)
      message(paste0("Site '", s, "' occurs in deployments:"))
      print(opcodes)
    }
  } else {
    message("✅ No duplicated site names found.")
  }
}

run_all_QA_checks <- function(campaign_name, campaign_path) {
  check_folder_name_consistency(campaign_name, campaign_path)
  check_empty_lr_folders(campaign_name, campaign_path)
  check_duplicate_units_within_set(campaign_name, campaign_path)
  check_duplicate_sites(campaign_name, campaign_path)
}

