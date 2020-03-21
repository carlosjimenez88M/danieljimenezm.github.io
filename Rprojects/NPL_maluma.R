# =======================================
# =              NPL Maluma             =
# =           Daniel Jiménez            =
# =         Senior Data Scientist       =
# =                Chiper               =
# =             2020-03-21              =
# =======================================

## Intensión ----------------------------
# Se intenta determinar la intensión con la cual se dicen las expresiones de las canciones de reggaeton
# En el caso de Maluma se intentará deconstruir las relaciones entre sus letras y también hacer un gráfico
# de polaridad sobre sus frases.

##  ¿ Qué es NPL ? ------------------------
# Es una rama de las ciencia de la computación y de la inteligenvia artificial que intenta 
# combiar diferentes herramientas linguisticas para entender las expresiones del humano a nivel e palabras
#  Algunos de los elementos del NPL son :
# 1) Análisis de sentimientos 
# 2) Clasificación de textos 
# 3) Extracción de la información 

## Librerias -----------------------------

library(tidyverse);
library(tidytext);
library(stringr);
library(wordcloud)
library(broom);
library(dplyr);
library(scales);
library(tidyr)
library(tm);
library(SnowballC);
library(glue);
library(syuzhet);
library(gridExtra);
library(DT);
library(igraph);
library(ggraph);


## Cargar letra ---------------------------
cuatro_babys<-c("Ya no sé que hacer
No sé con cuál quedarme
Todas saben en la cama maltratarme
Me tienen bien, de sexo me tienen bien
Estoy enamorado de cuatro babies
Siempre me dan lo que quiero
Chingan cuando yo les digo
Ninguna me pone pero
Dos son casadas
Hay una soltera
La otra medio psycho y si no la llamo se desespera
Estoy enamorado de cuatro babies
Siempre me dan lo que quiero
Chingan cuando yo les digo
Ninguna me pone pero
Dos son casadas
Hay una soltera
La otra medio psycho y si no la llamo se desespera
La primera se desespera
Se encojona si se lo hecho afuera
La segunda tiene la funda
Y me paga pa' que se lo hunda
La tercera me quita el estrés
Polvos corridos, siempre echamos tres
A la cuenta de una le bajo la luna
Pero ella quiere con Maluma y conmigo a la vez
Estoy enamorado de las cuatro
Siempre las busco después de las cuatro
A las cuatro les encanta en cuatro
Y yo nunca fallo como el 24
De los Lakers siempre es la gorras
De chingar ninguna se enzorra
Estoy metio en un lío, ya estoy confundio
Porque ninguna de mi mente se borra
Me pongo las gafas Cartier saliendo del aeropuerto
Vestio de Osiris, zapatos en pie
Tú tienes tú mi cuenta de banco y el número de la Master Card
Tú eres mi mujer oficial
Me tiene enamorado ese culote con ese pelo rubio
Pero tengo otra pelinegra que siempre quiere chichar
A veces hasta le llega al estudio
La peliroja chichando es la más que se moja
Le encojona que me llame y no lo coja
Peleamos y me bota la ropa y tengo que llamar a cotorra pa' que la recoja
Tengo una chiquitita nalgona con el pelo corto
Me dice papi vente adentro, si me preña (Bryant Myers)
Estoy enamorado de cuatro babies
Siempre me dan lo que quiero
Chingan cuando yo les digo
Ninguna me pone pero
Dos son casadas
Hay una soltera
La otra medio psycho y si no la llamo se desespera
Estoy enamorado de cuatro babies
Siempre me dan lo que quiero
Chingan cuando yo les digo
Ninguna me pone pero
Dos son casadas
Hay una soltera
La otra medio psycho y si no la llamo se desespera
Ya estoy metio en un lío
A todas yo quiero darle
Me tienen bien confundio
Ya no sé ni con cuál quedarme
Y es que todas maman bien
Todas me lo hacen bien
Todas quieren chingarme encima de billetes de cien
Me tienen en un patín
Comprando en San Valentín
Ya me salieron más caras que un reloj de Ulysses Nardin
Es que la babies están bunny ninguna las 4 se ha hecho completas
Dos tienen maridos y ninguna de las dos al marido respetan
Cuatro chimbitas
Cuatro personalidades
Dos me hablan bonito
Dos dicen maldades
Diferentes nacionalidades
Pero cuando chingan gritan todas por iguales
Quiere que la lleve pa' medallo
Quiere que la monte en carros del año
Que a una la coja
A la otra la apriete
Y a las otras 2 les dé juntas en el baño
Digan qué más quieren hacer
El dirty las va a entretener
En la casa gigante y un party en el yate que él quiere tener
No sé si me entiendes bebé
Estoy enamorado de cuatro babies
Siempre me dan lo que quiero
Chingan cuando yo les digo
Ninguna me pone pero
Dos son casadas
Hay una soltera
La otra medio psycho y si no la llamo se desespera
Estoy enamorado de cuatro babies
Siempre me dan lo que quiero
Chingan cuando yo les digo
Ninguna me pone pero
Dos son casadas
Hay una soltera
La otra medio psycho y si no la llamo se desespera
N-noriel
Bryant Myers
Dirty boy, Maluma
Versatility, muchachos
Nosotros somos los capos del trap
Mr. Myers
Trap cap
Maluma
Santana, the golden boy
Bryant Myers
Dimelo star baby
Mera you
Yi (Jaja)
Dimelo Gata")

## Proceso de limpieza de los datos --------------------------
# Como en todo procesod de ciencia de datos hay que tener una fase de 
# depuración, pero en el caso del text mining, lo que se intenta hacer es 
# normalizar las palabras y quitarle los caracteres especiales.

cuatro_babys_2<-tolower(cuatro_babys) # Mínusculas todas las palabras
cuatro_babys_2 <- gsub("[[:punct:]]","",cuatro_babys_2) # Quitar signos de puntuación
cuatro_babys_2 <- gsub("\\w*[0-9]+\\w*\\s*", "",cuatro_babys_2) # Quitar Números 
cuatro_babys_2 <- stringr::str_replace_all(cuatro_babys_2, "\\p{quotation mark}", "")
cuatro_babys_2 <- gsub("\\n", " ",cuatro_babys_2)
cuatro_babys_2 <- stringr::str_replace_all(cuatro_babys_2,"[\\s]+", " ")
cuatro_babys_2 <- stringr::str_replace_all(cuatro_babys_2," $", "")
cuatro_babys_2 <- removeWords(cuatro_babys_2, words = stopwords("spanish"))
cuatro_babys_2





## Estructura de la canción ------------------
# Lo primero que hay que hacer es organizar el texto o la arquitectura de la canción
# en one token per row (Robinson 2020), el objetivo de esto es poder analizar las letras que se 
# tienen a través de una consistencia.

cuatro_babys_df <- dplyr::tibble(line=1:114, text= cuatro_babys_2)

# para poder comprender mejor el texto es necesario partirlo en tokens individuales por 
# linea de la canción 
cuatro_babys_df%>%
  unnest_tokens(word,text)


# Lo que me impresiona es que solo usa la palabra sexo 114 veces



## Análisis del Texto ----------------

# Primero  se evalua las frecuencia de las palabras

cuatro_babys_df%>%
  unnest_tokens(word,text)%>%
  count(word, sort = TRUE)


## Plot de  las palabras más usadas
cuatro_babys_df%>%
  unnest_tokens(word,text)%>%
  count(word, sort = TRUE)%>%
  filter(n > 700)%>%
  mutate(word = fct_reorder(word,n))%>%
  ggplot(aes(word,n))+
  geom_point(aes(size=n, color= factor(word)))+
  geom_text(aes(label=n), size=2)+
  guides(size=FALSE, color=FALSE)+
  labs(x='Palabras',
       y= 'Frecuencia',
       title = 'Top de las palabras más usadas',
       subtitle = 'en cuatro babys')+
  coord_flip()




cuatro_babys_df


## Text mining ------------------

maluma_corpus <- Corpus(VectorSource(cuatro_babys_df))
maluma_corpus_clean <- tm_map(maluma_corpus, tolower)
maluma_corpus_clean <- tm_map(maluma_corpus_clean, removeNumbers)
maluma_corpus_clean <- tm_map(maluma_corpus_clean, removePunctuation)
maluma_corpus_clean <- tm_map(maluma_corpus_clean, stripWhitespace)
stopwords(kind='es')
maluma_corpus_clean <- tm_map(maluma_corpus_clean, removeWords, stopwords(kind = "es"))
maluma_tdm <- TermDocumentMatrix(maluma_corpus_clean, control = list(stopwords = TRUE))
maluma_tdm <- as.matrix(maluma_tdm)
maluma_tdm <- DocumentTermMatrix(maluma_tdm, control = list(minWordLength = 1, stopwords = TRUE))
Maluma_corpus_stem <- tm_map(maluma_corpus_clean, stemDocument)
Maluma_corpus_stem <- tm_map(Maluma_corpus_stem, stemCompletion, dictionary = maluma_corpus_clean)

## Nube de palabras 

wordcloud(maluma_corpus_clean, max.words = 100, random.order = F, colors = brewer.pal(name = "Dark2", n = 8))
Maluma_tdm <- TermDocumentMatrix(Maluma_corpus_stem)
Maluma_mat <- as.matrix(Maluma_tdm)
dim(Maluma_mat)

Maluma_mat <- Maluma_mat %>% rowSums() %>% sort(decreasing = TRUE)
Maluma_mat <- data.frame(palabra = names(Maluma_mat), frec = Maluma_mat)
quartz()
wordcloud(
  words = Maluma_mat$palabra, 
  freq = Maluma_mat$frec, 
  max.words = 200, 
  random.order = F, 
  colors=brewer.pal(name = "Dark2", n = 8)
)



## Asociación entre palabras -----------



maluma_bigrams<-cuatro_babys_df%>%
  unnest_tokens(bigram,text, token = 'ngrams',n=5)
  
maluma_bigrams%>%
  count(bigram, sort=TRUE)



bigrams_separated <- maluma_bigrams %>%
  separate(bigram, c("word1", "word2"), sep = " ")

bigrams_filtered <- bigrams_separated %>%
  filter(!word1 %in% stop_words$word) %>%
  filter(!word2 %in% stop_words$word)


bigram_counts <- bigrams_filtered %>% 
  count(word1, word2, sort = TRUE)

bigrams_united <- bigrams_filtered %>%
  unite(bigram, word1, word2, sep = " ")


bigram_graph <- bigram_counts %>%
  filter(n > 200) %>%
  graph_from_data_frame()

bigram_graph
library(ggraph)
set.seed(2017)

ggraph(bigram_graph, layout = "fr") +
  geom_edge_link() +
  geom_node_point() +
  geom_node_text(aes(label = name), vjust = 1, hjust = 1)



set.seed(2016)

a <- grid::arrow(type = "closed", length = unit(.15, "inches"))

ggraph(bigram_graph, layout = "fr") +
  geom_edge_link(aes(edge_alpha = n), show.legend = FALSE,
                 arrow = a, end_cap = circle(.07, 'inches')) +
  geom_node_point(color = "lightblue", size = 5) +
  geom_node_text(aes(label = name), vjust = 1, hjust = 1) +
  theme_void()





count_bigrams <- function(dataset) {
  dataset %>%
    unnest_tokens(bigram, text, token = "ngrams", n = 2) %>%
    separate(bigram, c("word1", "word2"), sep = " ") %>%
    filter(!word1 %in% stop_words$word,
           !word2 %in% stop_words$word) %>%
    count(word1, word2, sort = TRUE)
}

visualize_bigrams <- function(bigrams) {
  set.seed(2016)
  a <- grid::arrow(type = "closed", length = unit(.15, "inches"))
  
  bigrams %>%
    graph_from_data_frame() %>%
    ggraph(layout = "fr") +
    geom_edge_link(aes(edge_alpha = n), show.legend = FALSE, arrow = a) +
    geom_node_point(color = "lightblue", size = 5) +
    geom_node_text(aes(label = name), vjust = 1, hjust = 1) +
    theme_void()
}


bigram_counts%>%
  visualize_bigrams()





## Análisis de sentimientos ---------
cuatro_babys_2
library(sentiment)
Maluma_class_emo <- classify_emotion(cuatro_babys_df, algorithm="bayes", prior=3.0)
Maluma_class_pola <- classify_polarity(cuatro_babys_df, algorithm="bayes")

Maluma_class_emo%>%
  head()

emotion <- Maluma_class_emo[, 7]
emotion[is.na(emotion)] <- "unknown"
polarity <- Maluma_class_pola[, 4]

Maluma_sentiment_dataframe <- data.frame(text=cuatro_babys_df, emotion=emotion, 
                                       polarity=polarity, stringsAsFactors=FALSE)
head(Maluma_sentiment_dataframe, 5)

Maluma_sentiment_df = data.frame(text=cuatro_babys_df, emotion=emotion,
                               polarity=polarity, stringsAsFactors=FALSE)

# Separamos el texto segun las emociones
emotion_Maluma = levels(factor(Maluma_sentiment_df$emotion))
emotion_length = length(emotion_Maluma)
emotion_Maluma.docs = rep('', emotion_length)

emotion_Maluma.docs = removeWords(emotion_Maluma.docs, stopwords('es'))
corpus = Corpus(VectorSource(emotion_Maluma.docs))
tdm = TermDocumentMatrix(corpus)
tdm = as.matrix(tdm)
colnames(tdm) = emotion_Maluma



