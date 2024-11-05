########################################################
# Script for
# Power Analysis for RCTs with Multiple Outcomes
# workshop
#
# Code to generate figures in the slides
#
# (C) 2022 Miratrix
# Updated November 2024
########################################################

library(PUMP)
library(ggthemes)
library(tidyverse)

###############################
# Key power graph
###############################

m1 <- pump_mdes( d_m = "d3.2_m3fc2rc",
                 power.definition = "D1indiv",
                 target.power = 0.80,
                 nbar = 23, J = 2, K = 12,
                 Tbar = 0.5 )

m2 <- update_grid( m1, J = c( 2, 4, 6 ), K = 4:20 )

mytheme <- theme_minimal() +
  theme( legend.position = "bottom",
         legend.direction = "horizontal",
         legend.key.width = unit(1, "cm"),
         panel.border = element_blank() )

plot( m2, color = "J" ) +
  expand_limits( y = 0 ) +
  mytheme +
  scale_color_colorblind()


###############################
# Notation for the pump package
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

###############################
# Same experiment, but using FIRC
###############################

m2 <- update( m1, d_m = "d2.1_m2fr" )
summary( m2 )

###############################
# Two scenarios show a big difference
###############################

m3 <- update_grid( m1,
                   d_m = c( "d2.1_m2fr", "d2.1_m2fc" ),
                   omega.2 = seq( 0, 1, length.out = 7 ) )


###############################
# The amount of cross site variation is critical
###############################

plot( m3, color = "d_m" ) +
  expand_limits( y = 0 ) +
  mytheme +
  scale_color_colorblind()

###############################
# Necessary sample size for specific scenario
###############################

ss1 <- pump_sample( d_m = "d3.2_m3fc2rc",
                    typesample = "K",
                    power.definition = "D1indiv",
                    MDES = 0.15,
                    target.power = 0.80,
                    alpha = 0.05,
                    nbar = 23, J = 4, Tbar = 0.5 )

###############################
# But it’s better to see a range across scenarios
###############################

ss2 <- update_grid( ss1, J = c( 2, 4, 6 ) )

###############################
# Or a fancy plot across even more scenarios!
###############################

ss3 <- update_grid( ss1,
                    J = c( 2, 3, 4, 5, 6 ),
                    ICC.2 = c( 0, 0.1, 0.2 ) )

plot( ss3, color = "ICC.2" )


###############################
# ICC is a killer, and we missed it the first go-around!
###############################

plot( ss3, color = "ICC.2" ) +
  scale_y_continuous( limits = c(0, 200 ) ) +
  mytheme +
  scale_color_colorblind()

###############################
# Our multisite experiment (with 1 outcome)
###############################

p1 <- pump_power(
  d_m = "d2.1_m2fc",     # choice of design and model
  MDES = 0.1,            # assumed effect size
  M = 1,                 # number of outcomes
  J = 10,                # number of schools/blocks
  nbar = 275,            # average number of students per school
  Tbar = 0.50,           # proportion of students treated per school
  alpha = 0.05,          # significance level
  numCovar.1 = 5,        # number of covariates at level 1
  R2.1 = 0.1,            # assumed R^2 of level 1 covariates
  ICC.2 = 0.05,          # intraclass correlation
  rho = 0.4              # test statistic correlation
)



###############################
# Our multisite experiment (with multiple outcomes)
###############################

p2 <- pump_power(
  d_m = "d2.1_m2fc",     # choice of design and model
  MTP = "BF",            # multiple testing procedure
  MDES = rep( 0.10, 5 ), # assumed effect size
  M = 5,                 # number of outcomes
  J = 10,                # number of schools/blocks
  nbar = 275,            # average number of students per school
  Tbar = 0.50,           # proportion of students treated per school
  alpha = 0.05,          # significance level
  numCovar.1 = 5,        # number of covariates at level 1
  R2.1 = 0.1,            # assumed R^2 of level 1 covariates
  ICC.2 = 0.05,          # intraclass correlation
  rho = 0.4              # test statistic correlation
)


###############################
# What if only 3 of my 5 outcomes are actually impacted by treatment?
###############################

p3 <- update(p2, numZero = 3)
summary(p3)


###############################
# Q: What sample size do I need to have an 80% chance to find significance
# on at least one outcome?
###############################

ss1 <- pump_sample(
  target.power = 0.8,        # target power
  power.definition = "min1", # power definition
  typesample = "J",          # type of sample size procedure
  tol = 0.01,                # tolerance
  d_m = "d2.1_m2fc", MTP = "BF",
  MDES = 0.1, M = 3, nbar = 350, Tbar = 0.50, alpha = 0.05,
  numCovar.1 = 5, R2.1 = 0.1, ICC.2 = 0.05, rho = 0.4
)


###############################
# Assessing sensitivity
###############################

pgrid <- update_grid(
  pow,
  # vary parameter values
  rho = seq( 0, 0.9, by = 0.1),
  # compare multiple MTPs
  MTP = c( "BF", "HO", "BH")
)

plot( pgrid, var.vary = 'rho' )
