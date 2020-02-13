# =======================================
# =          NFL game attendance        =
# =           Daniel Jiménez            =
# =         Senior Data Scientist       =
# =                Chiper               =
# =             2020-02-13              =
# =======================================


## Unboarding -------------------------
#The data this week comes from Pro Football Reference team standings [https://github.com/rfordatascience/tidytuesday/blob/master/data/2020/2020-02-04/readme.md#data-dictionary]


# Libraries ---------------------------
library(tidyverse);
library(tidymodels);
library(moderndive);
library(GGally);
library(corrplot);
library(infer);
theme_set(theme_get())


## Load data ---------------

attendance <- read_csv("https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-02-04/attendance.csv")
standings <- read_csv("https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-02-04/standings.csv")




## Explore data ----------

attendance%>%
  head()

attendance%>%
  filter(year>2017)%>%
  group_by(team,year)%>%
  summarize(total=n())%>%
  arrange(desc(total))%>%
  ungroup()%>%
  ggplot(aes(team,total,fill=team))+
  geom_col(show.legend = FALSE)+
  coord_flip()+
  facet_wrap(~year,scales = 'free')


## New York and Los Angeles are the most frequency 

standings%>%
  head()

standings%>%
  filter(year>2017)%>%
  group_by(team,year)%>%
  summarize(total=n())%>%
  arrange(desc(total))%>%
  ggplot(aes(team,total,fill=team))+
  geom_col(show.legend = FALSE)+
  coord_flip()+
  facet_wrap(~year, scales = 'free')


## Join data


attendance_joined <- attendance %>%
  left_join(standings,
            by = c("year", "team_name", "team")
  )

## Quit NA`s  in weekly_attendance
attendance_joined%>%
  filter(!is.na(weekly_attendance))->attendance_joined

## EDA ---------

attendance_joined%>%
  select(total,weekly_attendance,wins,loss,points_differential,margin_of_victory,simple_rating,
         offensive_ranking,defensive_ranking)%>%
  ggpairs()


attendance_joined%>%
  select(total,weekly_attendance,wins,loss,points_differential,margin_of_victory,simple_rating,
         offensive_ranking,defensive_ranking)%>%cor()->Some_correlations
  
  

corrplot(Some_correlations,method = "pie")



## Some importants correlations 

attendance_joined%>%
  ggplot(aes(wins,points_differential))+
  geom_point()+
  geom_smooth(method = 'auto')+
  facet_wrap(~year)+
  labs(y='Points Differential',
       title = 'Linear relation between Wins and Points Differential ',
       subtitle = 'by year')


attendance_joined%>%
  ggplot(aes(wins,points_differential))+
  geom_point()+
  geom_smooth(method = 'auto')+
  facet_wrap(~team_name)+
  labs(y='Points Differential',
       title = 'Linear relation between Wins and Points Differential ',
       subtitle = 'by Team')


attendance_joined%>%
  ggplot(aes(loss,offensive_ranking))+
  geom_point()+
  geom_smooth(method = 'auto')+
  facet_wrap(~team_name)+
  labs(y='Offensive Ranking',
       title = 'Linear relation between Loss and Offensive Rankings',
       subtitle = 'by Team')



attendance_joined %>%
  filter(!is.na(weekly_attendance)) %>%
  ggplot(aes(fct_reorder(team_name, weekly_attendance),
             weekly_attendance,
             fill = playoffs
  )) +
  geom_boxplot(outlier.alpha = 0.5) +
  coord_flip() +
  labs(
    fill = NULL, x = NULL,
    y = "Weekly NFL game attendance"
  )




# Now validate margin of victory per team 
attendance_joined %>%
  distinct(team_name, year, margin_of_victory, playoffs)%>%
  ggplot(aes(margin_of_victory,fill=playoffs))+
  geom_histogram(position = "identity", alpha = 0.7)+
  facet_wrap(~team_name)


## Total
attendance_joined %>%
  distinct(team_name, year, margin_of_victory, playoffs)%>%
  ggplot(aes(margin_of_victory,fill=playoffs))+
  geom_histogram(position = "identity", alpha = 0.7)+
  labs(
    x = "Margin of victory",
    y = "Number of teams",
    fill = NULL
  )



## Importan question : Are there changes with the week of the season? By Julia Sigle


attendance_joined %>%
  mutate(week = factor(week)) %>%
  ggplot(aes(week, weekly_attendance, fill = week)) +
  geom_boxplot(show.legend = FALSE, outlier.alpha = 0.5) +
  labs(
    x = "Week of NFL season",
    y = "Weekly NFL game attendance"
  )



# I think that is necessary develop some Boostrap Method 


bootstrap_distribution <- attendance_joined %>% 
  specify(response = weekly_attendance) %>% 
  generate(reps = 1000) %>% 
  calculate(stat = "mean")


visualize(bootstrap_distribution)


percentile_ci <- bootstrap_distribution %>% 
  get_confidence_interval(level = 0.95, type = "percentile")


percentile_ci

visualize(bootstrap_distribution) + 
  shade_confidence_interval(endpoints = percentile_ci)

## Computing Standard Error
x_bar <-mean(bootstrap_distribution$stat)

standard_error_ci <- bootstrap_distribution %>% 
  get_confidence_interval(type = "se", point_estimate = x_bar)

standard_error_ci



visualize(bootstrap_distribution) + 
  shade_confidence_interval(endpoints = standard_error_ci)


# H0 : Not are differences between weeks and  attendance
# H1: Are differences between weeks and  attendance

# H0 is true 


attendance_df <- attendance_joined %>%
  filter(!is.na(weekly_attendance)) %>%
  select(
    weekly_attendance, team_name, year, week,
    margin_of_victory, strength_of_schedule, playoffs
  )

attendance_df

## Biuld Models

attendance_split <- attendance_df %>%
  initial_split(strata = playoffs)

nfl_train <- training(attendance_split)
nfl_test <- testing(attendance_split)


lm_spec <- linear_reg() %>%
  set_engine(engine = "lm")

lm_fit <- lm_spec %>%
  fit(weekly_attendance ~ .,
      data = nfl_train
  )

rf_spec <- rand_forest(mode = "regression") %>%
  set_engine("ranger")

rf_spec


rf_fit <- rf_spec %>%
  fit(weekly_attendance ~ .,
      data = nfl_train
  )

rf_fit



## Evaluations Models -------------
results_train <- lm_fit %>%
  predict(new_data = nfl_train) %>%
  mutate(
    truth = nfl_train$weekly_attendance,
    model = "lm"
  ) %>%
  bind_rows(rf_fit %>%
              predict(new_data = nfl_train) %>%
              mutate(
                truth = nfl_train$weekly_attendance,
                model = "rf"
              ))

results_test <- lm_fit %>%
  predict(new_data = nfl_test) %>%
  mutate(
    truth = nfl_test$weekly_attendance,
    model = "lm"
  ) %>%
  bind_rows(rf_fit %>%
              predict(new_data = nfl_test) %>%
              mutate(
                truth = nfl_test$weekly_attendance,
                model = "rf"
              ))


results_train %>%
  group_by(model) %>%
  rmse(truth = truth, estimate = .pred)



results_test %>%
  group_by(model) %>%
  rmse(truth = truth, estimate = .pred)




results_test %>%
  mutate(train = "testing") %>%
  bind_rows(results_train %>%
              mutate(train = "training")) %>%
  ggplot(aes(truth, .pred, color = model)) +
  geom_abline(lty = 2, color = "gray80", size = 1.5) +
  geom_point(alpha = 0.5) +
  facet_wrap(~train) +
  labs(
    x = "Truth",
    y = "Predicted attendance",
    color = "Type of model"
  )




nfl_folds <- vfold_cv(nfl_train, strata = playoffs)

rf_res <- fit_resamples(
  weekly_attendance ~ .,
  rf_spec,
  nfl_folds,
  control = control_resamples(save_pred = TRUE)
)

rf_res %>%
  collect_metrics()
