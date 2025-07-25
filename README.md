# Medicine Scheduler

## Overview
This project provides tools for parsing, visualizing, and exploring medical staff shift assignments. It includes a parser for structured schedule data and a Shiny app for interactive exploration, including a calendar heatmap view using the University of Washington (UW) color palette.

## Files
- **assignments.txt**: A plain text file containing the detailed staff schedule. Each date is followed by alternating lines of shift names and assigned individuals.
- **Assignments _ Intrigma Scheduler.pdf**: The original PDF schedule document for reference.
- **parse.R**: Contains the `parse_assignments_txt` function, which parses `assignments.txt` into a tidy data frame for further analysis or visualization.
- **app.R**: The Shiny app for interactive exploration and calendar heatmap visualization of staff availability.

## Parsing the Schedule
To parse the schedule from `assignments.txt`, source the parser and run:

```r
source("parse.R")
assignments <- parse_assignments_txt("assignments.txt")
head(assignments)
```

This will produce a data frame with columns: `Date`, `Shift`, and `Individual`.

## Running the Shiny App
1. Ensure you have the required R packages:
   - `shiny`, `dplyr`, `ggplot2`, `lubridate`, `scales`
2. Place `app.R` and `parse.R` in your project directory.
3. Run the app in R:

```r
shiny::runApp("app.R")
```

The app allows you to:
- Select individuals and find dates when all are free.
- View a calendar heatmap where color intensity (UW purple to gold) reflects how many people are free each day.

## UW Color Palette
The calendar heatmap uses the official University of Washington colors:
- Purple: `#4B2E83`
- Gold: `#B7A57A`

## Example Usage
```r
# Parse assignments
df <- parse_assignments_txt("assignments.txt")

# Find all dates when both "Abay, Rebecca" and "LaMotte, Eric" are free
busy_dates <- df %>% filter(Individual %in% c("Abay, Rebecca", "LaMotte, Eric")) %>% pull(Date) %>% unique()
all_dates <- unique(df$Date)
free_dates <- setdiff(all_dates, busy_dates)
print(free_dates)
```

## License
This project is for educational and scheduling purposes. Please acknowledge the University of Washington color palette if reusing the visualization style. 