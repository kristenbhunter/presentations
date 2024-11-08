########################################################
# Script for
# Power Analysis for RCTs with Multiple Outcomes
# workshop
#
# Calculating needed sample sizes
#
# (C) 2022 Miratrix
# Updated November 2024
########################################################

###############################
# Setup
###############################

library( tidyverse )
library( ggthemes )
library( PUMP )

# For making nice plots
mytheme <- theme_minimal() +
    theme( legend.position = "bottom",
           legend.direction = "horizontal",
           legend.key.width = unit(1, "cm"),
           panel.border = element_blank() )


###############################
# Sample size example
###############################

# How many schools do we need for our multisite cluster randomized
# experiment?

# 4 classrooms per school
# 23 kids per classroom
ss1 <- pump_sample( d_m = "d3.2_m3fc2rc",
                    typesample = "K",
                    power.definition = "D1indiv",
                    MDES = 0.15,
                    target.power = 0.80,
                    alpha = 0.05,
                    nbar = 23, J = 4, Tbar = 0.5 )
ss1


# Looking at how number of classrooms per school matters
ss2 <- update_grid( ss1, J = c( 2, 4, 6 ) )
ss2


# Looking at ICC as well as class size.
ss3 <- update_grid( ss1,
                    J = c( 2, 3, 4, 5, 6 ),
                    ICC.2 = c( 0, 0.1, 0.2 ) )

plot( ss3, color = "ICC.2" )


# Fancier plot
plot( ss3, color = "ICC.2" ) +
    scale_y_continuous( limits = c(0, 200 ) ) +
    mytheme +
    scale_color_colorblind()


###############################
# Exercises
###############################

# We are going to use code from the above and modify it to explore the
# tradeoff between nbar (average classroom size) and number of schools
# needed.

# Question 1
# If we only sample 8 kids per classroom, how many schools do we need?
# (say we have 4 classrooms per school)

ss.q1 <- pump_sample( d_m = "d3.2_m3fc2rc",
                      typesample = "K",
                      power.definition = "D1indiv",
                      MDES = 0.15,
                      target.power = 0.80,
                      alpha = 0.05,
                      nbar = 8, J = 4, Tbar = 0.5 )
ss.q1

# Question 2
# Could we get away with 8 schools if our classrooms were big enough?

ss.q2 <- update_grid( ss1,
                      nbar = seq(10, 100, 10))
ss.q2

plot(ss.q2)

