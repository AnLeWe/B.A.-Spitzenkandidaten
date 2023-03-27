#
# Code for table generation
#


## regression tables

load("Data/Estimation_Results_Pselect1_denom1.RData") # all parties
lm.out.all.1 <- all.results.smd[[1]]
lm.out.all.1.rs <- all.results.smd[[2]]
lm.out.all.2 <- all.results.pr[[1]]
lm.out.all.2.rs <- all.results.pr[[2]]

load("Data/Estimation_Results_Pselect2_denom1.RData") # only CS
lm.out.cs.1 <- all.results.smd[[1]]
lm.out.cs.1.rs <- all.results.smd[[2]]
lm.out.cs.2 <- all.results.pr[[1]]
lm.out.cs.2.rs <- all.results.pr[[2]]

load("Data/Estimation_Results_Pselect3_denom1.RData") # without CS
lm.out.small.1 <- all.results.smd[[1]]
lm.out.small.1.rs <- all.results.smd[[2]]
lm.out.small.2 <- all.results.pr[[1]]
lm.out.small.2.rs <- all.results.pr[[2]]




for (i.smdpr in 1:2){ # Loop over Erst- and Zweitstimme
  
  # all models
  print(c("Contamination on Erststimme (H2b)","Contamination on Zweitstimme  (H2a)")[i.smdpr])
  stargazer(lm.out2, lm.out2, lm.out1, lm.out1,
            title = c("Direct candidacy and party list placement on first votes", 
                      "Direct candidacy and party list placement on second votes")[i.smdpr],
            dep.var.labels = "Vote Share",
            #se = list(NULL, r.se2, NULL, r.se1),
            column.labels = c("OLS", "RSE", "OLS", "RSE"),
            star.cutoffs = c(0.05,0.01,0.001),
            align = TRUE,
            style = "apsr",
            #type = "html",
            out = c("table_1.txt", "table_2.txt")[i.smdpr]
            #column.separate = c(1,2),
            #ci = FALSE,
  )
  
  # models with cross.treat
  print(c("Contamination on Erststimme (H2b)","Contamination on Zweitstimme  (H2a)")[i.smdpr])
  stargazer(lm.out2, lm.out2, 
            title = c("Direct candidacy and party list placement on first votes", 
                      "Direct candidacy and party list placement on second votes")[i.smdpr],
            dep.var.labels = "Vote Share",
            column.labels = c("OLS", "RSE"),
            #se = list(NULL, r.se2),
            star.cutoffs = c(0.05,0.01,0.001),
            align = TRUE,
            style = "apsr",
            #type = "html",
            out = c("rtable_1.txt", "rtable_2.txt")[i.smdpr]
  )
}

# models all parties, only CDU & SPD, without CDU & SPD
print(c("Contamination on Erststimme (H2b)","Contamination on Zweitstimme  (H2a)")[i.smdpr])
stargazer(lm.out2, lm.out4, lm.out6,
          title = c("Direct candidacy and party list placement on first votes", 
                    "Direct candidacy and party list placement on second votes")[i.smdpr],
          dep.var.labels = "Vote Share",
          #se = list(r.se2, r.se4, r.se6),
          column.labels = c("All Parties", "Only CDU&SPD", "Without CDU&SPD"),
          star.cutoffs = c(0.05,0.01,0.001),
          align = TRUE,
          style = "apsr",
          #type = "html",
          out = c("ptable_1.txt", "ptable_2.txt")[i.smdpr]
)


