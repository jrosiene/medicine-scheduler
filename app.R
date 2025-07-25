library(shiny)
library(dplyr)
library(ggplot2)
library(lubridate)
library(scales)

#Define parse:
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


# --- UW Palette (purple to gold) ---
uw_palette <- c("#4B2E83", "#B7A57A") # Purple to Gold

# --- Your parser function here or source("parse.R") ---
# assignments <- parse_assignments_txt("assignments.txt")

# For demo, load assignments here:
assignments <- parse_assignments_txt("assignments.txt")
all_individuals <- sort(unique(assignments$Individual))

# Convert dates to Date objects (assuming year is 2025, adjust as needed)
assignments$DateObj <- mdy(paste(assignments$Date, "2025"))

ui <- fluidPage(
  titlePanel("Medicine Scheduler: Calendar Heatmap of Free People"),
  sidebarLayout(
    sidebarPanel(
      selectInput(
        "individuals",
        "Select individuals (leave blank for all):",
        choices = all_individuals,
        multiple = TRUE
      )
    ),
    mainPanel(
      h4("Calendar Heatmap: Number of People Free Each Day"),
      plotOutput("calendar_heatmap", height = "500px"),
      h4("Legend:"),
      tags$div(style="display:flex;align-items:center;",
               tags$div(style="width:30px;height:20px;background:#4B2E83;display:inline-block;"), " = Few free ",
               tags$div(style="width:30px;height:20px;background:#B7A57A;display:inline-block;margin-left:10px;"), " = Most free"
      )
    )
  )
)

server <- function(input, output, session) {
  output$calendar_heatmap <- renderPlot({
    # Who are we considering?
    selected <- input$individuals
    if (is.null(selected) || length(selected) == 0) {
      selected <- all_individuals
    }
    # For each date, count how many of the selected are free
    all_dates <- sort(unique(assignments$DateObj))
    free_counts <- sapply(all_dates, function(d) {
      busy <- assignments %>%
        filter(DateObj == d) %>%
        pull(Individual)
      sum(!(selected %in% busy))
    })
    df <- data.frame(
      Date = all_dates,
      Free = free_counts
    )
    # For calendar layout
    # For calendar layout: week of month
    df$Year <- year(df$Date)
    df$Month <- month(df$Date, label = TRUE, abbr = TRUE)
    df$Day <- day(df$Date)
    df$FirstOfMonth <- as.Date(paste(df$Year, month(df$Date), 1, sep = "-"))
    df$Wday <- wday(df$Date, week_start = 1)
    df$WeekOfMonth <- as.integer((df$Day + wday(df$FirstOfMonth, week_start = 1) - 2) / 7) + 1

    # Plot
    ggplot(df, aes(x = Wday, y = -WeekOfMonth, fill = Free)) +
      geom_tile(color = "white", size = 0.5) +
      geom_text(aes(label = Day), color = "black", size = 4) +
      scale_x_continuous(breaks = 1:7, labels = c("Mon","Tue","Wed","Thu","Fri","Sat","Sun")) +
      scale_fill_gradientn(colors = uw_palette, limits = c(0, length(selected)), name = "# Free") +
      facet_wrap(~Month, scales = "free_x") +
      theme_minimal(base_size = 16) +
      theme(
        axis.title = element_blank(),
        panel.grid = element_blank(),
        strip.text = element_text(face = "bold", size = 18)
      )
  })
}

shinyApp(ui, server)

