parse_assignments_txt <- function(file_path) {
  lines <- readLines(file_path)
  date_idx <- grep("^[A-Za-z]{3} \\d{1,2}$", lines)
  all_assignments <- list()

  for (i in seq_along(date_idx)) {
    date_line <- lines[date_idx[i]]
    start <- date_idx[i] + 1
    end <- if (i < length(date_idx)) date_idx[i+1] - 1 else length(lines)
    day_lines <- lines[start:end]
    day_lines <- day_lines[day_lines != ""]
    n <- length(day_lines)
    if (n %% 2 != 0) {
      warning(paste("Odd number of lines for date", date_line, "- skipping last unmatched line."))
      day_lines <- day_lines[-n]
      n <- n - 1
    }
    if (n == 0) next
    shifts <- day_lines[seq(1, n, by = 2)]
    names  <- day_lines[seq(2, n, by = 2)]
    df <- data.frame(
      Date = rep(date_line, length(shifts)),
      Shift = shifts,
      Individual = names,
      stringsAsFactors = FALSE
    )
    # Clean up tabs and whitespace
    df$Shift <- trimws(gsub("\t", "", df$Shift))
    df$Individual <- trimws(gsub("\t", "", df$Individual))
    all_assignments[[length(all_assignments) + 1]] <- df
  }
  assignments_df <- dplyr::bind_rows(all_assignments)
  assignments_df
}
