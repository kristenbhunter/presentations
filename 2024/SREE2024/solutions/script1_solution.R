########################################################
# Script for
# Power Analysis for RCTs with Multiple Outcomes
# workshop
#
# Calculating MDES, and comparing two kinds of model for the same
# design of a multisite randomized trial.
#
# (C) 2022 Miratrix
# Updated November 2024
########################################################

###############################
# Setup
###############################

# If you haven't installed PUMP, uncomment and run this line:
# install.packages( "PUMP" )

library( here )
library( tidyverse )
library( ggthemes )
library( PUMP )

# What does PUMP offer?
pump_info()

# for later plots, you can ignore this
mytheme <- theme_minimal() +
  theme( legend.position = "bottom",
         legend.direction = "horizontal",
         legend.key.width = unit(1, "cm"),
         panel.border = element_blank() )

###############################
# initial MDES calculation
###############################

m1 <- pump_mdes(
    d_m =  "d2.1_m2fc",    # choice of design and model
    target.power = 0.80,   # What desired chance of success?
    power.definition = "D1indiv", # definition of power for multiple outcomes
    J = 20,                # number of schools/blocks
    nbar = 50,             # number of students in each block
    Tbar = 0.50,           # proportion of students treated per school
    alpha = 0.05,          # significance level
    numCovar.1 = 5,        # number of covariates at level 1
    R2.1 = 0.6,            # assumed R^2 of level 1 covariates
    ICC.2 = 0.20,          # intraclass correlation of schools
    omega.2 = 1            # variation of impact estimates as proportion of ICC.2
)

summary( m1 )


###############################
# Exercise
###############################

# Change the script to calculate MDES for
# 30 classrooms, 23 kids per classroom
# 90% power

# OPTION 1
m.solution <- pump_mdes(
  d_m =  "d2.1_m2fc",    # choice of design and model
  target.power = 0.90,   # what desired chance of success?
  power.definition = "D1indiv", # definition of power for multiple outcomes
  J = 30,                # number of classrooms/blocks
  nbar = 23,             # number of students in each block/classroom
  Tbar = 0.50,           # proportion treated
  alpha = 0.05,          # significance level
  numCovar.1 = 5,        # number of covariates at level 1 (students)
  R2.1 = 0.6,            # assumed R^2 of level 1 covariates (students)
  ICC.2 = 0.20,          # intraclass correlation of level 2 (classrooms)
  omega.2 = 1            # variation of impact estimates as proportion of ICC.2
)

summary( m.solution )


# OPTION 2
m.solution <- update(m1,
  target.power = 0.90,   # What desired chance of success?
  J = 30,                # number of classrooms/blocks
  nbar = 23              # number of students in each block
)

summary( m.solution )

###############################
# Comparing multisite models
###############################

m2 <- update( m1, d_m = "d2.1_m2fr" )
summary( m2 )

m3 <- pump_mdes( d_m = "d2.1_m2fc",
                 target.power = 0.80,
                 power.definition = "D1indiv",
                 Tbar = 0.5,
                 nbar = 50, J = 20,
                 R2.1 = 0.70,
                 numCovar.1 = 5,
                 ICC.2 = 0.20,
                 omega.2 = 1 )
summary( m3 )


m4 <- update_grid( m1,
                   d_m = c( "d2.1_m2fr", "d2.1_m2fc" ),
                   omega.2 = seq( 0, 1, length.out = 7 ) )


m4

plot( m4, color = "d_m" ) +
      expand_limits( y = 0 ) +
      mytheme +
      scale_color_colorblind()


ggsave( file = "omega_sensitivity_plot.pdf", width = 2.5, height = 3 )








