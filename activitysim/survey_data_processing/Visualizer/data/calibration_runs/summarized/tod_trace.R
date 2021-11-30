library(tidyverse)


util = read_csv("F:\\Projects\\Clients\\MetCouncilASIM\\tasks\\metc-asim-model\\output\\trace.mandatory_tour_scheduling.vectorize_tour_scheduling.tour_1.work.interaction_sample_simulate.eval.raw.csv")


check = util %>%
  filter(tour_id == 591121680) %>%
  


ggplot(util, aes(x = end, y = `total utility`, color = duration)) + geom_point()
