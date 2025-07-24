rename_bruv_videos <- function(campaign_name, campaign_path, pad0 = FALSE) {
  require(fs)
  require(stringr)
  require(purrr)

  log_file <- file.path(campaign_path, paste0(campaign_name, "_rename_log.txt"))
  cat("Rename log for campaign", campaign_name, "\n", format(Sys.time()), "\n\n", file = log_file)

  # Find relevant set directories
  set_dirs <- dir_ls(campaign_path, type = "directory", recurse = FALSE)
  set_dirs <- set_dirs[str_detect(path_file(set_dirs), paste0("^", campaign_name, "_S\\d{2}$"))]

  for (set_dir in set_dirs) {
    lr_dirs <- dir_ls(set_dir, recurse = TRUE, type = "directory")
    lr_dirs <- lr_dirs[str_detect(path_file(lr_dirs), "_[LR]$")]

    # Group by deployment folder (parent of L/R folders)
    deployments <- unique(path_dir(lr_dirs))

    for (deployment_dir in deployments) {
      lr_subdirs <- dir_ls(deployment_dir, type = "directory")
      lr_subdirs <- lr_subdirs[str_detect(path_file(lr_subdirs), "_[LR]$")]

      total_renamed <- 0

      for (lr_dir in lr_subdirs) {
        cam <- str_sub(lr_dir, -1)  # "L" or "R"
        parent_dir <- deployment_dir
        parent_name <- path_file(parent_dir)

        vids <- dir_ls(lr_dir, regexp = "\\.MP4$", type = "file")
        already_renamed <- str_detect(path_file(vids), paste0("_", cam, "\\d+\\.MP4$"))
        vids_to_rename <- vids[!already_renamed]

        if (length(vids_to_rename) > 0) {

          if (pad0) {
            new_files <- path(parent_dir, paste0(parent_name, "_", cam, str_pad(seq_along(vids_to_rename), 2, "left", "0"), ".MP4"))
          } else {
            new_files <- path(parent_dir, paste0(parent_name, "_", cam, seq_along(vids_to_rename), ".MP4"))
          }

          file_move(vids_to_rename, new_files)

          for (i in seq_along(vids_to_rename)) {
            cat("[RENAMED]", vids_to_rename[i], "→", new_files[i], "\n", file = log_file, append = TRUE)
          }

          total_renamed <- total_renamed + length(vids_to_rename)
        }
      }

      # Print status for deployment
      if (total_renamed == 0) {
        message(sprintf("Deployment '%s': SKIPPED (all videos already renamed)", path_file(deployment_dir)))
        cat("[SKIPPED]", deployment_dir, "— all videos already renamed\n", file = log_file, append = TRUE)
      } else {
        message(sprintf("Deployment '%s': RENAMED %d files", path_file(deployment_dir), total_renamed))
      }
    }

    # Delete empty L/R folders after renaming
    maybe_empty_dirs <- dir_ls(set_dir, recurse = TRUE, type = "directory")
    maybe_empty_dirs <- maybe_empty_dirs[str_detect(path_file(maybe_empty_dirs), "_[LR]$")]

    for (dir in maybe_empty_dirs) {
      if (length(dir_ls(dir)) == 0) {
        dir_delete(dir)
        cat("[DELETED EMPTY DIR]", dir, "\n", file = log_file, append = TRUE)
      }
    }
  }

  cat("\nDone.\n", file = log_file, append = TRUE)
}
