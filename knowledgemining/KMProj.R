rm(list = ls())
getwd()
setwd("/Users/g9owe/Documents/R/KM/FinalProj")
options(max.print=100000)

## Libraries (Add as needed.)
library(tm)
library(ggplot2)
library(ggpubr)
theme_set(theme_pubr())
library(RColorBrewer)
library(dplyr)
library(wordcloud2)
library(devtools)
# install.packages("tidytext")
# install.packages("rlang")
library(tidytext)
# install.packages("stringr")
# install.packages("textdata")
library(textdata)
devtools::install_github("lchiffon/wordcloud2")
# install.packages("ggridges")
library(ggridges)

## Load in CSV of MeToo Tweets

metootweets <- read.csv("D:\\Users\\g9owe\\Documents\\R\\KM\\FinalProj\\MeToo_tweets.csv")

## TM Package: Corpus building, TDM, etc.

## Build corpus from comments column

corpus <- iconv(metootweets$Tweet)
corpus <- Corpus(VectorSource(corpus))

## Clean text; make lowercase, punctuation, numbers, finally cleaned set

inspect(corpus[1:5]) # For verification

corpus <- tm_map(corpus, tolower)

corpus <- tm_map(corpus, removePunctuation)

corpus <- tm_map(corpus, removeNumbers)

cleanset <- tm_map(corpus, removeWords, stopwords('english'))

removeURL <- function(x) gsub('http[[:alnum:]]*', '', x)
cleanset <- tm_map(cleanset, content_transformer(removeURL))

cleanset <- tm_map(cleanset, stripWhitespace)

## Term document matrix ("d" = data frame)

tdm <- TermDocumentMatrix(cleanset)
m <- as.matrix(tdm)
v <- sort(rowSums(m),decreasing=TRUE) # Memory hangups can occur here if comments are excessive
d <- data.frame(word = names(v), freq=v)
head(d, 50)

## Wordcloud2

wordcloud2(data = d)

# Experimenting with shape (Not working right now due to bugs.)

figPath = system.file("FinalProj/Twit.png",package = "wordcloud2")
wordcloud2(d, figPath = "Twit.png", size = 1.5, color = "skyblue")

wordcloud2(d, figPath = "Twit.png", size = 1.5, color = "skyblue")

# Tidytext Methods (Alternative)

# Remove http elements
metootweets$stripped_text <- gsub("http.*","",  metootweets$Tweet)
metootweets$stripped_text <- gsub("https.*","", metootweets$stripped_text)

# Clean up tweets part 1

metootweets_clean <- metootweets %>%
  dplyr::select(stripped_text) %>%
  unnest_tokens(word, stripped_text)

# Plot Top 15 Words (stop words not removed, just as a tester)

metootweets_clean %>%
  count(word, sort = TRUE) %>%
  top_n(15) %>%
  mutate(word = reorder(word, n)) %>%
  ggplot(aes(x = word, y = n)) +
  geom_col() +
  xlab(NULL) +
  coord_flip() +
  labs(x = "Count",
       y = "Unique words",
       title = "Count of unique words found in tweets")

# TidyText Stopwords

data("stop_words")
head(stop_words)

nrow(metootweets_clean) # Checking for total words

cleaned_tweet_words <- metootweets_clean %>%
  anti_join(stop_words)

nrow(cleaned_tweet_words) # Reduced words by nearly half

# New dataframe

tweet_words <- metootweets %>%
  select(Tweet,
         Date_Time) %>%
  unnest_tokens(word, text)


# Custom stop words

my_stop_words <- tibble(
  word = c(
    "https",
    "t.co",
    "rt",
    "amp",
    "rstats",
    "gt"
  ),
  lexicon = "twitter"
)


all_stop_words <- stop_words %>%
  bind_rows(my_stop_words)

suppressWarnings({
  no_numbers <- cleaned_tweet_words %>%
    filter(is.na(as.numeric(word)))
})

cleaned_tweets <- no_numbers %>%
  anti_join(all_stop_words, by = "word")

tibble(
  total_words = nrow(cleaned_tweet_words),
  after_cleanup = nrow(cleaned_tweets)
)

top_words <- cleaned_tweets %>%
  group_by(word) %>%
  tally %>%
  arrange(desc(n)) %>%
  head(10)

top_words

# Plot V2

cleaned_tweets %>%
  count(word, sort = TRUE) %>%
  top_n(15) %>%
  mutate(word = reorder(word, n)) %>%
  ggplot(aes(x = word, y = n)) +
  geom_col() +
  xlab(NULL) +
  coord_flip() +
  labs(x = "Count",
       y = "Unique words",
       title = "Count of unique words found in tweets")

# Sentiment matching with NRC Lexicon

nrc_words <- cleaned_tweets %>%
  inner_join(get_sentiments("nrc"), by = "word")

nrc_words 

# Groups and lists words by sentiment according to NRC Lexicon, turn into data frame for visualization

sentiment_df <- nrc_words %>%
  group_by(sentiment) %>%
  tally %>%
  arrange(desc(n))

## Sentiment plotting (WIP)

quickplot(sentiment, data=sentiment_df, weight=n, geom="bar", fill=sentiment, ylab="count")+ggtitle("#MeToo Tweet sentiment")