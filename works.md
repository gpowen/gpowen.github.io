---
layout: page
title: Works
permalink: /works/
---

### Data Visualization Final Project
Ideally would use Shiny here (as seen below, Assignment 7). For now, the raw code and outputs:

```markdown
rm(list = ls())
getwd()
gc()

## Preliminary steps, authentication etc.

library(dplyr)
library(RColorBrewer)
library(tuber) # youtube API
library(tm)
library(wordcloud)
library(ggplot2)
library(ggpubr)
theme_set(theme_pubr())

## Authentication

yt_oauth("ID here", "secret ID here")

## Get comments for a single video

test_comments <- get_all_comments(video_id="6SwiSpudKWI")

## Build corpus from comments column

corpus <- iconv(test_comments$textOriginal)
corpus <- Corpus(VectorSource(corpus))

## Clean text; make lowercase, punctuation, numbers, finally cleaned set

inspect(corpus[1:5]) ## for verification

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
v <- sort(rowSums(m),decreasing=TRUE) ## memory hangups can occur here if comments are excessive
d <- data.frame(word = names(v), freq=v)
head(d, 50)

## Wordcloud

set.seed(1234)
wordcloud (words=d$word, freq = d$freq, min.freq = 1,
           max.words=200, random.order=FALSE, rot.per=0.35,
           colors=brewer.pal(8, "Dark2"))

## Saving and cleaning data.frame in preparation for bar graph

star <- d ## LOONA Star
genie <- d ## SNSD Genie

star <- d %>% slice(1:20) ## cuts observations down to 20
genie <- d %>% slice(1:20) 

## Bar graph ggplot2
  
plot1 <- ggplot(genie, aes(x=word, y=freq)) + geom_bar(stat='identity') + labs(title="LOONA - 'Star': Top 20 Keywords") ## Basic graph

bluesnew <- brewer.pal(9, "Blues")
bluesnew <- colorRampPalette(bluesnew)(20)
bluesnew ## lists all hexcodes 

plot1 <- ggplot(genie, aes(x=reorder(word, -freq), y=freq)) + geom_bar(stat='identity', aes(fill = as.factor(freq))) + labs(title="LOONA - 'Star': Top 20 Keywords") +
  xlab("Keyword") +
  ylab("Frequency") +
  theme(legend.position="none") +
  scale_fill_manual(values=c("#F7FBFF", "#ECF4FB", "#E1EDF8", "#D7E6F4", "#CDE0F1", "#C1D9ED", "#B0D2E7", "#A0CAE1", "#8BBFDC", "#75B3D8", "#62A8D2", "#519CCB", "#4090C5", "#3282BD", "#2474B6", "#1966AD", "#0E59A2", "#084B94", "#083D7F", "#08306B"))

print(plot1) ## Final plot
```


### Assignment 7
Publishing test Shiny applications to GitHub:

<iframe width="1000" height="475" src="https://gpowen.shinyapps.io/Shiny03_BaseDataset/"></iframe>
<iframe width="1000" height="600" src="https://gpowen.shinyapps.io/Shiny04_mtcars/"></iframe> 
