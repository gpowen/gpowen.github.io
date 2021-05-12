---
layout: page
title: Knowledge Mining
permalink: /km/
---

# Final Project

[Presentation](knowledgemining/KMPresentation.pptx)

[Main Code: Lexicon-Based Approaches](knowledgemining/KMProj.R)
[Secondary Code: Machine Learning Approaches](knowledgemining/KMCodeV2.R)

# Progress Report 1: Data

[CSV: #MeToo Tweets](knowledgemining/MeToo_tweets.csv)

- Data collected from [Kaggle](https://www.kaggle.com/mohamadalhasan/metoo-tweets-dataset)
- ~15,000 tweets over a 1 to 2 day period in 2019
- Primary variable of interest is "Tweet" being that this is a text analysis. Other variables include ID, Length, Date_Time, Source, Likes, Retweets, Lang
- Basic frequencies in addition to associations (n-grams), and ideally sentiment analysis will be covered
- Also extremely interested in pursuing STM in R, currently learning from [these](https://juliasilge.com/blog/sherlock-holmes-stm/) [blogs](https://juliasilge.com/blog/evaluating-stm/). I don't expect to be terribly proficient here as I am beginning down this path late in the process, but I think it's important to try. 
- No replication code from R at this time, will be the focus of Progress Report 2: Methods

# Progress Report 2: Methods

[R Script: Final Project, still WIP](knowledgemining/KMProj.R)

- Data is cleaned and being used for analysis. Currently still experimenting with methods (you will see some alternative methods that I am exploring in the RScript, primarily concerned with using tidytext rather than the tm package to clean the tweets for stop words, numbers, etc.; A lot of references I have consulted have been using tidytext rather than tm)
- Using wordcloud2 rather than wordcloud, much better looking
- Sentiment analysis has been done (!!), matched with the NRC Lexicon (so separates words further into sentiments such as anger, disgust, joy, trust, etc.) 
- Currently exploring options here for visualization, have a basic frequency bar chart included in the code for now
- Still WIP, but getting there

## Labs & Assignments

[Lab 1: Markdown Introduction](knowledgemining/Lab01.html)

[Lab 2: Markdown Debugging](knowledgemining/Lab02.html)

[Lab 3: Markdown Continued](knowledgemining/Lab03.html)

[Lab 4: Markdown Exercises](knowledgemining/Lab04.html)

[Assignment 4: Gentle Introduction to Machine Learning](knowledgemining/Assignment04.html)
