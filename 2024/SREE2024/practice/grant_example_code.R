
# Grant Example R Code

#### Grant Example 1 ####

library( PUMP )
g1 <- pump_mdes( d_m = "d1.1_m1c",
                 alpha = 0.10, 
                 target.power = 0.80,
                 nbar = 4500,
                 Tbar = 0.58,
                 R2.1 = 0.10, numCovar.1 = 5 )

# Convert to the original metric by multiplying by assumed
# control-side standard deviation.
# For a binary outcome, the standard deviation is:
# sqrt( p*(1-p) )
g1$Adjusted.MDES * sqrt( 0.2 * (1-0.2) )

# Their formula, by hand (level 1 models are easy to do directly)
2.49 * sqrt( 0.2 * (1-0.2) * (1-0.1) / ( 0.58 * (1-0.58) * 4500 ) )


# For subgroup, we just modify sample size
g1_sub <- pump_mdes( d_m = "d1.1_m1c",
                     alpha = 0.10, 
                     target.power = 0.80,
                     nbar = 945,
                     Tbar = 0.58,
                     R2.1 = 0.10, numCovar.1 = 5 )
g1_sub$Adjusted.MDES * sqrt(0.2 * (1-0.2) )



#### Grant Example 2 ####


# We used Optimal Design for Multi-level and Longitudinal Research (Raudenbush et al., 2011) to estimate power. In these estimates, we assumed that we will recruit 48 schools from two districts, with each school having an average of 3 classrooms, and that we will test 10 children from each classroom initially and retain a minimum of 6 children per classroom (18 per school) through the course of the study. Separate estimates were made for the growth models and the model testing program effects on second grade reading comprehension.

# schools, classrooms, students (6 students per classroom is worst case attrition)


# The original grant actually did power analysis as a two level model,
# ignoring the classroom
base_model <- pump_mdes( d_m = "d2.2_m2rc",
                         target.power = 0.80, alpha = 0.05,
                         J = 48, nbar = 18, Tbar = 0.5,
                         ICC.2 = 0.10,
                         R2.2 = 0.60, numCovar.2 = 1 )
summary( base_model )

models <- update_grid( base_model,
                       ICC.2 = c( 0.08, 0.10 ),
                       R2.2 = c( 0.60, 0.80 ) )
models

plot( models, color = "R2.2" )

# Three level modeling -- an aside.
#
# We can also do a three level model analysis, but then we need to
# estimate the ICC of classrooms in school.  If students are randomly
# assigned to classrooms, this would correspond to "teacher effects."
# This would go hand-in-hand with less variation at the school level,
# since the school-level ICC estimate would include this classroom
# variation.
#
# In particular, the overall variation that would "look like" school
# variation would be:
#
# ICC.aggregated = ICC.3 + ICC.2 / J
#
# For us, we then will set ICC.3 to half what it was, and then ICC.2
# will be (3/2)ICC.3 = 0.15.  This gives 0.05 + 0.15 / 3 = 0.10, like
# above.
#
# We would also need to specify classroom and school level covariates.
# We will assume we can achieve the same level of classroom prediction
# as school.

base_model2 <- pump_mdes( d_m = "d3.3_m3rc2rc",
                          target.power = 0.80, alpha = 0.05,
                          K = 48, J = 3, nbar = 6, Tbar = 0.5,
                          ICC.2 = 0.15,
                          ICC.3 = 0.05,
                          R2.2 = 0.60, numCovar.2 = 1,
                          R2.3 = 0.60, numCovar.3 = 1 )
summary( base_model2 )

# for comparison: near the same, except for degrees of freedom issues.
base_model

models2 <- update_grid( base_model2,
                        ICC.3 = c( 0.04, 0.05 ),
                        ICC.2 = c( 0, 0.10, 0.20 ) )
models2

library( tidyverse )
plot( models2, color = "ICC.2" )

# We see classroom clustering could be a real concern if the
# classrooms have large random effects.  But this would go against the
# pilot data of not seeing much variation of entire schools.



#### Grant Example 3 ####

pow3 = pump_power_grid( d_m = "d3.2_m3rr2rc",
                        nbar = 35, J = 8, K = 14, 
                        Tbar = 0.50,
                        MDES = c( 0.20, 0.40, 0.60 ),
                        ICC.2 = seq( 0.01, 0.80, by=0.01 ),
                        ICC.3 = c( 0.05, 0.10 ),
                        omega.3 = 1 )

# The grant has a fancy figure not easily made with the default
# plotting.  We have to use tidyverse plot on the results

ggplot( pow3, aes( ICC.2, D1indiv, 
                   lty = as.factor( ICC.3 ),
                   color = as.factor( MDES ) ) ) +
    geom_smooth( method="loess", formula = y ~ x ) +
    theme_minimal() +
    labs( y = "Power", x = "ICC (classroom)",
          color = "MDES", lty="tx var" )

pow3 %>% filter( (MDES == 0.60 & ICC.2 == 0.80) |
                     (MDES == 0.40 & (abs(ICC.2 - 0.36)<0.001)) |
                     (MDES == 0.20 & ICC.2 == 0.01) ) %>%
    arrange( -ICC.2) %>%
    dplyr::select( -MTP, -d_m ) %>%
    knitr::kable( digits = 2)




#### Grant Example 4 (Example 1, revisited) ####


library( PUMP )
g1_m <- pump_mdes( d_m = "d1.1_m1c",
                 M = 4,
                 MTP = "HO",
                 power.definition = "min2",
                 alpha = 0.10, 
                 target.power = 0.80,
                 nbar = 4500,
                 Tbar = 0.58,
                 R2.1 = 0.10, numCovar.1 = 5,
                 rho = 0.5 )
summary( g1_m )
update( g1_m, power.definition = "min1" )

summary( g1 )

g1_m_full <- update_grid( g1_m,
                        rho = c( 0, 0.5, 0.8 ),
                        numZero = c(0,1,2),
                        power.definition = c("D1indiv", "min1", "min2" ) )

g1_m_full$MDE = g1_m_full$Adjusted.MDES * sqrt(0.20*(1-0.20))
g1_m_full
plot( g1_m_full, color = "rho" )
