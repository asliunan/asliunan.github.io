# Simple CHP Press Release Scraper
library(rvest)
library(dplyr)

# Scrape the first page to test
url <- "https://chp.org.tr/gundem/basin-aciklamalari?page=1"

# Read the HTML
html <- read_html(url)

# Try to find press release elements
# You may need to inspect the page source to find the correct selectors
press_items <- html %>% 
  html_elements(".haberBoxTitle, .news-item, article, .press-item")

# If no items found, try alternative selectors
if (length(press_items) == 0) {
  press_items <- html %>% 
    html_elements("div") %>% 
    .[grepl("title|date|content", html_attr(., "class"), ignore.case = TRUE)]
}

# Extract data
if (length(press_items) > 0) {
  press_data <- data.frame(
    title = press_items %>% html_elements("h1, h2, h3, .title") %>% html_text2(),
    date = press_items %>% html_elements(".date, time") %>% html_text2(),
    content = press_items %>% html_elements("p") %>% html_text2(),
    stringsAsFactors = FALSE
  )
  
  # Clean up the data
  press_data <- press_data %>%
    filter(!is.na(title) | !is.na(content)) %>%
    distinct()
  
  # Save to CSV
  write.csv(press_data, "chp_press_releases.csv", row.names = FALSE)
  
  cat("Found", nrow(press_data), "press releases\n")
  print(head(press_data))
} else {
  cat("No press releases found. You may need to adjust the selectors.\n")
  cat("Try inspecting the page source to find the correct HTML elements.\n")
} 