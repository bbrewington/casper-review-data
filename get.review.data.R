################################################################################
# Using R package rvest, scrape review data off of mattress website casper.com #
################################################################################

library(lubridate)
library(rvest)

get.all.reviews <- function(index){
     get.page.data <- function(page){
          # Extract elements from reviews on page
          page.html <- read_html(page)
          reviews.title <- page.html %>% html_nodes("header > .review-title.body--serif") %>% html_text() %>% gsub("\\n","",.)
          reviews.name <- page.html %>% html_nodes(".review-name") %>% html_text() %>% gsub("(Verified Casper Owner)|\\n","",.)
          reviews.date <- page.html %>% html_nodes(".review-date") %>% html_text() %>% gsub("\\n","",.) %>% mdy()
          reviews.body <- page.html %>% html_nodes(".js-review-text-body") %>% html_text()
          reviews.sleep.hrs <- page.html %>% html_nodes(".review-hours-number") %>% html_text() %>% as.numeric(.)
          reviews.sleep.type <- page.html %>% html_nodes(".review-partner-label") %>% html_text()
          
          # Return data frame of review data
          data.frame(reviews.title = reviews.title, reviews.name = reviews.name,
                     reviews.date = reviews.date, reviews.body = reviews.body,
                     reviews.sleep.hrs = reviews.sleep.hrs, reviews.sleep.type = reviews.sleep.type)
     }
     # Initialize session & go to page 1
     page <- paste0("https://www.casper.com/mattresses/reviews/",index,"?order=desc&rating=&utf8=%E2%9C%93")
     # Extract data from page
     get.page.data(page)
}

#Get # of review pages
num.pages <- read_html("https://www.casper.com/mattresses/reviews/1?order=desc&rating=&utf8=%E2%9C%93") %>% html_nodes(".last a") %>% html_attr("href") %>% substr(nchar("/mattresses/reviews/_"),nchar("/mattresses/reviews/___")) %>% as.numeric()

# Get review data **THIS IS CAUSING A BUG; SEE BELOW**
lapply(1:num.pages, get.all.reviews)

#####
# TO-DO's
# 1) Fix bug: Error in data.frame(reviews.title = reviews.title, 
#    reviews.name = reviews.name,  : arguments imply differing number of rows: 15, 14
#
# 2) Find a way to get reviews.age (isn't a mandatory field, so sometimes returns less elements than the other fields)
#    reviews.age <- page.html %>% html_nodes(".review-age") %>% html_text() %>% gsub("(\\n)|[A-Za-z ]", "", .) %>% as.numeric()

#####
# REFERENCE
# 4 star reviews - https://casper.com/mattresses/reviews?utf8=%E2%9C%93&rating=4&order=desc
# 1 star reviews - https://casper.com/mattresses/reviews?utf8=%E2%9C%93&rating=1&order=desc
# all reviews - https://casper.com/mattresses/reviews?utf8=%E2%9C%93&rating=5&order=desc

# next page selector "#reviews > div.reviews-pagination.r-section-wrapper > div > nav > span.next > a"

# Get link to last review page
# page.html %>% html_nodes(".last a") %>% html_attr("href")

# Get link to next review page
# page.html %>% html_nodes(".next a") %>% html_attr("href")
