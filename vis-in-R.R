# R-Ladies Vienna Workshop
# 28.10.2026

# 1) Introduction

# Focus of workshop:
#     - visualisation for data in R 
#     - with the ggplot2 framework
#     - some additional data transformations with tidyverse
#     - fancy stuff like interactive plots and/or animated plots

# Code along. The code is available online on my github 
# page: https://github.com/patriciapuch in the repository "vis-in-R".

# Inspirational plots: https://r-graph-gallery.com/
# Overview: ggplot2 cheat sheet in RStudio or also here:
# https://rstudio.github.io/cheatsheets/data-visualization.pdf


# 2) Setup
#       - R and RStudio installed
#       - Wlan access
#       - install and load necessary packages for today

# packages for data transformations
# install.packages(c("dplyr", "tidyr"))

# packages for plotting and visualisations
# install.packages(c("ggplot2", "plotly","gganimate", "gifski"))

# load the packages 
library("dplyr")
library("tidyr")
library("ggplot2")
library("plotly")
library("gganimate")


# 3) Dataset: penguins (from datasets)
#    Alternative: install.packages("palmerpenguins"); library("palmerpenguins"); data("palmerpenguins")
#    and renaming of variables

# load data
data("penguins")
class(penguins)   # should be data.frame or tibble

# inspect data
str(penguins)
View(penguins)
? penguins

# remove missing data (NA) values with function drop_na
penguins_clean <- drop_na(penguins)

# summarise data with basic function summary
summary(penguins_clean)


# 4) Basic structure of ggplot2

ggplot(data = data, 
       aes(x = ..., 
           y = ..., 
           col = ..., 
           fill = ...,
           shape = ...,
           alpha = ...,
           group = ...,
           ...)) + 
  geom_ ... (size = ..., 
             col = ..., 
             ...) + 
  scale_ ... _ ...() + 
  facet_ ... () + 
  theme(...)




# 5) Basic visualizations with ggplot2


# Q1: How many penguins of each species are there?
ggplot(penguins_clean, 
       aes(x = species)) + 
  geom_bar() 

# Q2: Which species lives on which island?
ggplot(penguins_clean, 
       aes(x = island, 
           fill = species)) + 
  geom_bar()

# Q3: How heavy are penguins, and does it differ by species?
ggplot(penguins_clean, 
       aes(x = body_mass)) + 
  geom_histogram()

ggplot(penguins_clean, 
       aes(x = species, 
           y = body_mass, 
           fill = species)) + 
  geom_boxplot()


# Q4: Do penguins with longer flippers weigh more?
ggplot(penguins_clean, 
       aes(x = flipper_len, 
           y = body_mass, 
           colour = species)) +
  geom_point() + 
  geom_smooth(method = "lm")

# Q5: Are longer bills also deeper?
ggplot(penguins_clean,
       aes(x = bill_len, 
           y = bill_dep)) +
  geom_point() + 
  geom_smooth(method = "lm")         

ggplot(penguins_clean, 
       aes(x = bill_len, 
           y = bill_dep, 
           colour = species)) +
  geom_point() + 
  geom_smooth(method = "lm")          


# Q6: Is the relation of flipper length and body mass different betweens sexes?
ggplot(penguins_clean, 
       aes(x = bill_len, 
           y = bill_dep, 
           colour = species)) +
  geom_point() + 
  geom_smooth(method = "lm") +          
  facet_grid(cols = vars(sex))


# Q7: Does the relation of flipper length and body mass change over time?
p <- ggplot(penguins_clean, 
            aes(x = bill_len, 
                y = bill_dep, 
                colour = species)) +
  geom_point() +
  labs(title = "Year: {closest_state}") +
  transition_states(year)
animate(p)


# 6) Customizing your plot

# change labs
labs(title = "",
     subtitle = "",
     x = "", 
     y = "",
     colour = "", 
     caption = "")

# change themes and general formatting
theme_minimal(base_size = 14)
theme(legend.position = "bottom")

# change color concept with scale functions
scale_colour_viridis_d()                    
scale_fill_brewer(palette = "Set2")
scale_colour_manual(values = c(Adelie = "darkorange", Chinstrap = "purple", Gentoo = "cyan4"))

# change axis with scale functions
scale_y_continuous(labels = scales::label_comma())     # 5,000 -> 5000
scale_y_continuous(labels = scales::label_percent())   # 0.25 -> 25 %

# change fixed aesthetics of the plot
alpha = 0.5
size = 2

# save plots 
ggsave("pinguine.png", width = 8, height = 5, dpi = 300)




# 7) Interactive plots with plotly   

# rearrange the data with pivot_longer from tidyr package
peng_long <- pivot_longer(data = penguins_clean, 
                          cols = c(bill_len, bill_dep, flipper_len),
                          names_to = "measurement", 
                          values_to = "value")

# make normal ggplot
p <- ggplot(peng_long, aes(x = body_mass, 
                           y = value, 
                           colour = species,
                           shape = sex)) +
  geom_point() +
  facet_grid(rows = vars(measurement), 
             scales = "free_y")
p

# make ggplot interactive
ggplotly(p)


# show the same individual
peng <- mutate(penguins_clean, id = row_number())         
peng_long <- pivot_longer(data = peng, 
                          cols = c(bill_len, bill_dep, flipper_len),
                          names_to = "measurement", 
                          values_to = "value")

shared <- highlight_key(peng_long, ~id)
p <- ggplot(shared, aes(x = body_mass, 
                        y = value, 
                        colour = species,
                        shape = sex)) +
  geom_point() +
  facet_grid(rows = vars(measurement), scales = "free_y")
highlight(ggplotly(p), on = "plotly_click", off = "plotly_doubleclick")





##########################################################################################
# Extra plot: storms

library(maps)  
world <- map_data("world")     # from package maps

# load data set from package dplyr
data(storms)

# transform data
storms_2005 <- storms |>
  filter(year == 2005) |>
  mutate(time = ISOdatetime(year, month, day, hour, 0, 0))

p <- ggplot() +
  # plot countries on the map
  geom_polygon(data = world, aes(x = long, y = lat, group = group),
               fill = "grey90", colour = "white", linewidth = 0.2) +
  # plot storm paths
  geom_path(data = storms_2005,
            aes(x = long, y = lat, group = name, colour = wind),
            linewidth = 0.8, lineend = "round") +
  # choose color palette
  scale_colour_viridis_c(option = "inferno", direction = -1, name = "Wind (kn)") +
  # set coordinate system
  coord_cartesian(xlim = c(-110, -10), ylim = c(5, 55)) +
  # set labs
  labs(title = "Atlantic Hurricane Season 2005",
       x = NULL, 
       y = NULL) +
  # set general theme
  theme_minimal()
p

# set up the animation over variable time
anim <- p +
  transition_reveal(time) +
  labs(title = "Hurricane Season 2005: {format(frame_along, '%d. %B')}")

# animate plot
animate(anim, nframes = 200, fps = 10, width = 800, height = 500)
