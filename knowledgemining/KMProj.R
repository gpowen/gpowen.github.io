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
# install.packages("syuzhet")
# install.packages("SentimentAnalysis")
library(syuzhet)
library(SentimentAnalysis)

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
v <- sort(rowSums(m),decreasing=TRUE)
d <- data.frame(word = names(v), freq=v)
head(d, 50)

# Frequency

top20 <- d %>% slice(1:20) 

ggplot(top20, aes(x=reorder(word, -freq), y=freq)) +
  geom_bar(fill = "#0073C2FF", stat = "identity") +
  geom_text(aes(label = freq), vjust = -0.3) + 
  xlab("Word") +
  ylab("Frequency") +
  theme(axis.text=element_text(size=7))

## Wordcloud2

wordcloud2(data = top20)

# Cont.

sent <- analyzeSentiment(tdm, language = "english")
sent <- sent[,1:4]
sent <- as.data.frame(sent)
head(sent)

summary(sent$SentimentGI)

# NRC Emotions

mydf <- data.frame(text = sapply(cleanset, paste, collapse = " "), stringsAsFactors = FALSE)

sent2 <- get_nrc_sentiment(mydf$text)

# Let's look at the corpus as a whole again:

sent3 <- as.data.frame(colSums(sent2))
names(sent3)[names(sent3) == "colSums(sent2)"] <- "Count"
sent3$Emotion <- row.names(sent3)
colnames(sent3)<-c("Count","Emotion")
ggplot(sent3[1:8,], aes(x = Emotion, y = Count, fill = Emotion)) + geom_bar(stat = "identity") + theme_minimal() + theme(legend.position="none", panel.grid.major = element_blank()) + labs( x = "Emotion", y = "Total Count") + ggtitle("Emotions of #MeToo Tweets According to the NRC Lexicon") + theme(plot.title = element_text(hjust=0.5))
ggplot(sent3[9:10,], aes(x = Emotion, y = Count, fill = Emotion)) + geom_bar(stat = "identity") + theme_minimal() + theme(legend.position="none", panel.grid.major = element_blank()) + labs( x = "Emotion", y = "Total Count") + ggtitle("Sentiment of #MeToo Tweets According to the NRC Lexicon") + theme(plot.title = element_text(hjust=0.5))

# mydf (cleaned text) into corpus

corp1 <- Corpus(VectorSource(mydf))

nrc_positive <- get_sentiments("nrc") %>%
  filter(sentiment == "positive")

d %>%
  inner_join(nrc_positive) %>%
  count(word, sort = TRUE)

# Tidytext Methods (Alternative)

# Remove http elements
metootweets$stripped_text <- gsub("http.*","", metootweets$Tweet)
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
    "x80",
    "x806",
    "x99s",
    "x9f",
    "x94",
    "it2",
    "gt",
    "i2",
    "x9",
    "x9d",
    "x99",
    "x99t",
    "x99re",
    "h.i.v2",
    "yt",
    "ar2",
    "x98when"
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
  head(100)

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

nrc_words <- top_words %>%
  inner_join(get_sentiments("nrc"), by = "word")

nrc_words 

# Groups and lists words by sentiment according to NRC Lexicon, turn into data frame for visualization

top100sent <- nrc_words %>%
  group_by(sentiment) %>%
  tally %>%
  arrange(desc(n))

ggplot(nrc_words, aes(x = word, y = n, fill = sentiment)) + geom_bar(stat = "identity") + theme_minimal() + theme(legend.position="top", panel.grid.major = element_blank()) + labs( x = "Word", y = "Count", fill = "Sentiment") + ggtitle("Top #MeToo Words by Sentiment") + theme(plot.title = element_text(hjust=0.5))

ggplot(nrc_words, aes(x = reorder(word, -n), y = n, fill = sentiment)) + geom_bar(stat = "identity") + theme_minimal() + theme(legend.position="top", panel.grid.major = element_blank()) + labs( x = "Word", y = "Count", color = "Sentiment") + ggtitle("Top #MeToo Words by Sentiment") + theme(plot.title = element_text(hjust=0.5))


## Sentiment plotting (WIP)

quickplot(sentiment, data=sentiment_df, weight=n, geom="bar", fill=sentiment, ylab="count")+ggtitle("#MeToo Tweet sentiment")