# =======================================
# =   Bob Ross painting by the numbers  =
# =           Daniel Jiménez            =
# =         Senior Data Scientist       =
# =            Merlin Jobs              =
# =             2019-08-12              =
# =======================================




# Libraries ---------------------------

library(tidyverse);
library(corrr);
library(janitor);
library(tidytext);
library(stringr);
library(DT);
library(igraph);
library(ggraph);
library(tm);
library(topicmodels);
library('wordcloud')
theme_set(theme_light())



# Load Dataset

bob_ross <- readr::read_csv("https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2019/2019-08-06/bob-ross.csv")

# Data Dictionary
# https://github.com/rfordatascience/tidytuesday/tree/master/data/2019/2019-08-06


# Exploratory Data Analysis ----------------------

bob_ross%>%
  glimpse()



bob_ross%>%
  clean_names()%>%
  gather(element, present, -episode,-title)%>%
  filter(present==1)%>%
  mutate(title=str_to_title(str_remove_all(title,'"')),
         element=str_to_title(str_replace(element,"_"," ")))%>%
  select(-present)->element_present


element_present%>%
  group_by(title)%>%
  tally()%>%
  arrange(desc(n))%>%
  mutate(title=fct_reorder(title,n))%>%
  head(20)%>%
  ggplot(aes(title,n))+
  geom_bar(stat = 'identity',fill='orange')+
  geom_text(aes(x=title,y=1,label=paste0("(",n,")",sep="")),
            hjust=0,vjust=.5,size=3, color='black')+ 
  coord_flip()+
  labs(x='count',title = 'Twenty most Active Episodes')


# top ten most common words

element_present%>%
  unnest_tokens(word,title)%>%
  filter(!word %in% stop_words$word) %>%
  count(word,sort = TRUE) %>%
  ungroup() %>%
  mutate(word = factor(word, levels = rev(unique(word)))) %>%
  head(20)%>%
  ggplot(aes(word,n, fill=word))+
  geom_bar(stat = 'identity')+
  geom_text(aes(label=n), position = position_stack(vjust = .5))+
  coord_flip()+
  guides(fill=FALSE)+
  labs(x='theme', y='count',title = 'The most common themes!')+
  theme(axis.title = element_text(color="blue"),
        plot.title = element_text(colour = "#7F3D17"))


# Episodes versus themes

bob_ross %>%
  janitor::clean_names() %>%
  gather(element, present, -episode, -title) %>%
  filter(present == 1) %>%
  mutate(title = str_to_title(str_remove_all(title, '"')),
         element = str_to_title(str_replace(element, "_", " "))) %>%
  select(-present) %>%
  extract(episode, c("season", "episode_number"), "S(.*)E(.*)", convert = TRUE,remove = FALSE) %>%
  arrange(season, episode_number)->bob_ross_gathered

bob_ross_gathered$element[bob_ross_gathered$element=='Tree']<-'Trees'

bob_ross_gathered%>%
  group_by(element)%>%
  count(sort = TRUE)%>%
  head(10)%>%
  ggplot(aes(reorder(element,n),n))+
  geom_col(fill='orange')+
  geom_text(aes(label=n),position = position_stack(vjust = .5))+
  coord_flip()+
  labs(x='elements',y='count', title='The most common element in Bob Ross')+
  theme(axis.title = element_text(color="blue"),
        plot.title = element_text(colour = "#7F3D17"))


# In wordcloud


bob_ross_gathered%>%
  group_by(element)%>%
  count(sort = TRUE)%>%
  ungroup()%>%
  with(wordcloud(element,n,colors=brewer.pal(8, "Dark2")))


# 
bob_ross_gathered%>%
  count(element,sort = TRUE)%>%
  head(30)%>%
  mutate(element=fct_reorder(element,n))%>%
  ggplot(aes(element,n))+
  geom_col()+
  coord_flip()+
  labs(y='count',title = 'Elements in Bob Ross')



# Relationship among themes


count_bigrams <- function(dataset) {
  dataset %>%
    unnest_tokens(bigram, element, token = "ngrams", n = 2) %>%
    separate(bigram, c("word1", "word2"), sep = " ") %>%
    filter(!word1 %in% stop_words$word,
           !word2 %in% stop_words$word) %>%
    count(word1, word2, sort = TRUE)
}


visualize_bigrams <- function(bigrams) {
  set.seed(2018)
  a <- grid::arrow(type = "closed", length = unit(.15, "inches"))
  bigrams %>%
    graph_from_data_frame() %>%
    ggraph(layout = "fr") +
    geom_edge_link(aes(edge_alpha = n), show.legend = FALSE, arrow = a) +
    geom_node_point(color = "lightblue", size = 5) +
    geom_node_text(aes(label = name), vjust = 1, hjust = 1) +
    theme_void()
}

visualize_bigrams_individual <- function(bigrams) {
  set.seed(2019)
  a <- grid::arrow(type = "closed", length = unit(.15, "inches"))
  bigrams %>%
    graph_from_data_frame() %>%
    ggraph(layout = "fr") +
    geom_edge_link(aes(edge_alpha = n), show.legend = FALSE, arrow = a,end_cap = circle(.07, 'inches')) +
    geom_node_point(color = "lightblue", size = 5) +
    geom_node_text(aes(label = name), vjust = 1, hjust = 1) +
    theme_void()
}


relations<- bob_ross_gathered%>%
  count_bigrams()


relations%>%
  filter(n > 20) %>%
  visualize_bigrams()



# What are the most crowdede paintings with the most elements in them?


bob_ross_gathered%>%
  add_count(episode)%>%
  arrange(desc(n))

#

bob_ross_gathered%>%
  group_by(season)%>%
  summarize(episodes=n_distinct(episode))%>%
  print(n=31)



bob_ross_gathered%>%
  add_count(season,episode, name='total_elements')%>%
  count(season,element,total_elements, sort=TRUE)%>%
  mutate(percent_elements= n/total_elements)%>%
  filter(element=='Trees'|element=='Deciduous'|element=='Conifer')%>%
  ggplot(aes(season,percent_elements))+
  geom_line()+
  facet_wrap(~element, scales = 'free',ncol = 1)+
  expand_limits(y=0)



  








