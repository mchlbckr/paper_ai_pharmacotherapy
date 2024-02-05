
# Load libraries

library(readxl)
library(readr)
library(dplyr)
library(tidyr)
library(tidymodels)
library(doMC)
library(rpart.plot)


# Read and transform data

df <- read_xlsx("data/PatientenPoolReal -Überarbeitung 2023.xlsx", sheet = "data")
for (i in 8:55){
  df[,i] <- ifelse(!is.na(df[,i]) & df[,i] != "ja", "ja", df[,i] %>% pull())
  df[,i] <- replace_na(df[,i] %>% pull, "nein")
}

for (i in 69:84){
  df[,i] <- ifelse(!is.na(df[,i]) & df[,i] != "ja", "ja", df[,i] %>% pull())
  df[,i] <- replace_na(df[,i] %>% pull, "nein")
}

vars <- names(df)[69:84][which(sapply(df[69:84], function(x) mean(x == "ja"))> 0.1)]

# Create empty dataset for results
res <- data.frame(Variable = vars,
                  auc_train = numeric(length(vars)),
                  acc_train = numeric(length(vars)),
          auc = numeric(length(vars)),
          acc = numeric(length(vars)))


# Loop through medications/prescriptions to build predictive model for each one
for (tarvar in vars){

  cat(paste("\r", tarvar))
  
  # Create formular object
  model_formula <- as.formula(paste0("`",tarvar, "`~`",
                                     paste(names(df)[c(2:3,8:55)], 
                                           collapse = "`+`"),"`"))
  
  # Initial data splitting
  set.seed(123)
  df_split <- initial_split(df)
  
  # Create recipe and model
  rec <- recipe(model_formula, data = df)
  model <- decision_tree(
    mode = "classification",
    engine = "rpart",
    cost_complexity = tune(),
    tree_depth = tune(),
    min_n = tune()
  )
  
  
  
  # Bootstraping
  set.seed(123)
  boot <- bootstraps(df, times = 50)
  
  
  registerDoMC(cores = detectCores())
  
  # Combine into workflow
  wf <- workflow() %>%
    add_model(model) %>%
    add_recipe(ace)
  
  fit_bs <- wf %>% 
    tune_grid(resamples = boot,
              metrics = metric_set(roc_auc, accuracy, kap),
              grid = 50)
  
  
  # Retain best model
  model_best <- show_best(fit_bs, metric = "roc_auc")
  model_best2 <- show_best(fit_bs, metric = "accuracy")
  res$auc_train[res$Variable == tarvar] <- model_best$mean[1]
  res$acc_train[res$Variable == tarvar] <- model_best2$mean[1]
  final_model <- wf %>% finalize_workflow(select_best(fit_bs, metric = "roc_auc")) %>% last_fit(df_split, metrics = metric_set(roc_auc, accuracy, ppv, npv))
  res$auc[res$Variable == tarvar] <-final_model$.metrics[[1]] %>% filter(.metric == "roc_auc") %>% select(".estimate") %>% pull()
  res$acc[res$Variable == tarvar] <-final_model$.metrics[[1]] %>% filter(.metric == "accuracy") %>% select(".estimate") %>% pull()
  
  # Get best tree model
  tree <- wf %>% finalize_workflow(select_best(fit_bs, metric = "roc_auc")) %>% last_fit(df_split) %>% extract_fit_engine()
  
  
  # Plot final tree
  png(paste0("img/dt_",gsub("-","_",gsub("/","_",tarvar,fixed = TRUE),fixed = TRUE),".png"), width = 2000, height = 800, pointsize = 10, res = 500)
  wf %>% finalize_workflow(select_best(fit_bs, metric = "roc_auc")) %>% last_fit(df_split) %>% extract_fit_engine()%>% rpart.plot(roundint=FALSE, box.palette="RdBu", nn=TRUE)
  dev.off()


}

# Export results to csv
readr::write_csv(res,file = "results/res.csv")
