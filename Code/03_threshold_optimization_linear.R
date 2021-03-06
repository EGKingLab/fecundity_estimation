# devtools::install_github("dgrtwo/broom")
library(doParallel)
library(tictoc)
library(tidyverse)
library(readxl)
library(cowplot)
library(broom)
library(forcats)
library(ggrepel)

coarse <- TRUE

# Load areas tibble
load("../Data/area_summation.Rda")

if (coarse) {
  outfile <- "../Data/threshold_optimization_linear_coarse.csv"
  reps <- 1000  # Reps at each proportion
  iters <- 1000 # Iterations for each CV
  prop_data <- seq(0.5, 1.0, by = 0.1)
  # prop_data <- 1
  prop_train <- seq(0.5, 0.9, by = 0.1)
  thresh_values <- seq(30, 150, by = 5)
} else {
  outfile <- "../Data/threshold_optimization_linear_fine.csv"
  reps <- 1000  # Reps at each proportion
  iters <- 1000 # Iterations for each CV
  prop_data <- seq(0.5, 1.0, by = 0.1)
  # prop_data <- 1
  prop_train <- seq(0.5, 0.9, by = 0.1)
  thresh_values <- seq(50, 60, by = 1)
}

# Areas estimated from thresholding, keep only rows corresponding to
# values for coarse or fine, respectively
areas <- areas %>% 
  filter(lower_thresh %in% thresh_values)

# Handcounts used in training
actual <- suppressWarnings(
  read_excel("../Data/feclife_with-image-ids.xlsx") %>% 
    filter(training_set == "yes")
)

# Filter areas that match training images
areas <- areas %>% 
  filter(cameraid %in% actual$cameraid)

areas$cameraid[!(areas$cameraid %in% actual$cameraid)]
actual$cameraid[!(actual$cameraid %in% areas$cameraid)]

actual <- actual %>% 
  select(cameraid, handcount, training_set)

M <- full_join(areas, actual, by = "cameraid")

# Load image dimensions and merge
img_size <- read_csv("../Data/image_dimensions.csv")

M <- left_join(M, img_size, by = "cameraid")

M %>% group_by(cameraid) %>% 
  tally()

#########################################################################

area_rarefaction <- function(M, lower,
                             prop_data,
                             prop_train,
                             iters = 1000){
  library(tidyverse)
  M_sub <- filter(M, lower_thresh == lower)
  
  # Subset for proportion of data used
  M_sub <- M_sub[sample(1:nrow(M_sub), trunc(prop_data * nrow(M_sub))), ]
  
  # Empty tibble to hold cross-validation output
  cv <- tibble(
    r = numeric(iters),
    rMSD = numeric(iters)
  )
  
  for (jj in 1:iters) {
    # Create list of rows for train/test
    samps <- sample(1:nrow(M_sub), trunc(prop_train * nrow(M_sub)))
    
    # Subset rows into train/test
    # For some reason 0 was getting changed to -Inf, fix that
    tr <- M_sub[samps, ]
    tr$handcount[is.infinite(tr$handcount)] <- 0
    tr$area[is.infinite(tr$area)] <- 0
    te <- M_sub[-samps, ]
    te$handcount[is.infinite(te$handcount)] <- 0
    te$area[is.infinite(te$area)] <- 0
    
    # Fit model on training set
    fm <- lm(handcount ~ I(area^0.5) + img_size - 1, tr)
    te$pred <- predict(fm, te)
    r <- cor(te$handcount, te$pred)
    rMSD <- sqrt(mean((te$handcount - te$pred) ^ 2))
    cv[jj, ] <- c(r, rMSD)
  }
  x <- matrix(c(mean(cv$r), mean(cv$rMSD)), nrow = 1)
  return(as.data.frame(x))
}

n_thresh <- length(unique(M$lower_thresh))
n_prop <- length(prop_data)
n_out <- n_thresh * n_prop * length(prop_train)
r <- 0
rMSD <- 0

CVs <- crossing(prop_data, prop_train, lower = unique(M$lower_thresh), r, rMSD)

message(paste("\n", nrow(CVs), "combinations to check.\n"))

## Check number of cores
cl <- makeCluster(20)
registerDoParallel(cl)
for (ii in 1:nrow(CVs)) {
  tic()
  message(paste("Testing",
                CVs$prop_data[ii],
                CVs$prop_train[ii],
                CVs$lower[ii]))
  
  x <- foreach(jj = 1:reps, .combine = 'rbind') %dopar% {
    library(tidyverse)
    area_rarefaction(M,
                     lower = CVs$lower[ii],
                     prop_data = CVs$prop_data[ii],
                     prop_train = CVs$prop_train[ii],
                     iters = iters)
  }
  CVs[ii, 4:5] <- colMeans(x)
  toc()
  message(paste(nrow(CVs) - ii), " remaining.")
  message("\n")
}
stopCluster(cl)

write_csv(CVs, path = outfile)

## Post-processing #####################################################

CVs <- read_csv(outfile) %>% 
  drop_na(r) %>% 
  mutate(lower_f = factor(lower),
         prop_train_f = factor(prop_train),
         prop_data_f = factor(prop_data))

CVs %>%
  filter(prop_train_f == 0.9) %>% 
  ggplot(aes(lower_f, rMSD, color = prop_data_f)) +
  geom_point()

CVs %>% 
  arrange(desc(r))

CVs %>% 
  arrange(rMSD)

## Figure

outfile <- "../Data/threshold_optimization_linear_coarse.csv"
CVs <- read_csv(outfile) %>% 
  drop_na(r) %>% 
  mutate(lower_f = factor(lower),
         prop_train_f = factor(prop_train),
         prop_data_f = factor(prop_data))
coarse <- CVs %>%
  filter(prop_train_f == 0.9) %>% 
  ggplot(aes(lower_f, rMSD, color = prop_data_f)) +
  geom_point(alpha = 0.5) +
  scale_color_discrete(name = "Prop. Data") +
  scale_x_discrete(breaks = seq(30, 150, by = 20)) +
  theme(legend.position = c(0.75, 0.2),
        legend.key.size = unit(0.5, 'lines'),
        legend.text = element_text(size = 9)) +
  labs(x = "Threshold Value", y = "Root Mean Squared Difference") +
  my_theme
save(coarse, file = "../Figures/coarse_CV.Rda")

outfile <- "../Data/threshold_optimization_linear_fine.csv"
CVs <- read_csv(outfile) %>% 
  drop_na(r) %>% 
  mutate(lower_f = factor(lower),
         prop_train_f = factor(prop_train),
         prop_data_f = factor(prop_data))
fine <- CVs %>%
  filter(prop_train_f == 0.9) %>% 
  ggplot(aes(lower_f, rMSD, color = prop_data_f)) +
  geom_point(alpha = 0.5) +
  theme(legend.position = "none") +
  labs(x = "Threshold Value", y = "Root Mean Squared Difference") +
  my_theme
save(fine, file = "../Figures/fine_CV.Rda")
