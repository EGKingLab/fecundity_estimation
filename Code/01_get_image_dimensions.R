library(tidyverse)
library(jpeg)

# Download images from Zenodo if necessary
# source("download_image_data.R")
download_egg_images("~/egg_images")

# Get list of images
# Set the base_path below to the location of your egg_images directory
base_path <- "~/egg_images"
flist <- list.files(base_path, pattern = ".JPG")

out <- tibble(cameraid = character(length(flist)),
              img_size = numeric(length(flist)))

for (ii in 1:length(flist)) {
  if (ii %% 100 == 0) message("Image ", ii)
  img_path <- paste0(base_path, "/", flist[ii])
  jpg <- readJPEG(img_path, native = TRUE)
  out[ii, "cameraid"] <- flist[ii]
  out[ii, "img_size"] <- max(dim(jpg))
}

out

write_csv(out, path = "../Data/image_dimensions.csv")
