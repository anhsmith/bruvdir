find_empty_folders <- function(root_dir) {
  # Get all subdirectories
  all_dirs <- list.dirs(root_dir, recursive = TRUE, full.names = TRUE)

  # Identify lowest-level directories (those that do not contain subdirectories)
  lowest_level_dirs <- all_dirs[!all_dirs %in% dirname(all_dirs)]

  # Check which of these directories are empty
  empty_dirs <- lowest_level_dirs[sapply(lowest_level_dirs, function(d) length(list.files(d, all.files = TRUE, no.. = TRUE)) == 0)]

  return(empty_dirs)
}
