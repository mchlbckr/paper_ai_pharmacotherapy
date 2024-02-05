# Artificial intelligence in pharmacotherapy – mission (im-)possible?  

This is the git repository contaning code and data used for the results of the paper Artificial intelligence in pharmacotherapy – mission (im-)possible?  by Michael Bücker, Kreshnik Hoti, and Olaf Rose.


## Background 

Artificial intelligence (AI) has hardly been used in optimizing pharmacotherapy. This study aimed to explore barriers and limits and discuss approaches to overcome them. 

## Methods 

Data of a previous study on medication therapy optimization was updated and adapted for the purpose of this study: predicting medication based on multiple diagonses. 74% of  the data was being used for training and 26% for testing. Decision trees were chosen as the underlying model due to their simplicity and interpretability. Overfitting was controlled by bootstrapping, hyperparameters were optimized. Areas under the curve and accuracies were calculated. 

## Results 

The cohort consisted of 101 elderly patients with polymedication and multiple diagnoses. High prediction accuracy was achieved for the cardiovascular drug classes of ACE-inhibitors/angiotensin receptor blockers, mineralocorticoid-receptor antagonists, and nitroglycerin. 

## Conclusion 

The model showed promising results and left space for potential overwriting, in case of sudden therapy changes on safety alerts or new guidelines. Laboratory data and vital signs could not be used for decision-making, as they were influenced by the used drugs and not measured for all patients. An identified problem is the limited availability of optimized therapy plans. 