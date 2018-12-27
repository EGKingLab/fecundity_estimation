library(tidyverse)
library(cowplot)
library(magick)
library(grid)
library(Cairo)
source("../Code/ggplot_theme.R")

# Figure 2
raw <- rasterGrob(image_read("IMG_2644.JPG"), interpolate = TRUE)
thresh <- rasterGrob(image_read("IMG_2644_thresh_53.JPG"), interpolate = TRUE)
load("coarse_CV.Rda")
load("fine_CV.Rda")

P1 <- plot_grid(raw, thresh,
                ncol = 2, nrow = 1,
                labels = c("a.", "b."),
                label_size = 10,
                label_colour = "white")
P2 <- plot_grid(coarse, fine,
                ncol = 2, nrow = 1,
                labels = c("c.", "d."),
                label_size = 10)
P <- plot_grid(P1, P2,
               nrow = 2)
ggsave(filename = "Figure_2.png", plot = P, width = 6.9, height = 6.9)
ggsave(filename = "Figure_2.pdf", plot = P, width = 6.9, height = 6.9)
ggsave(filename = "Figure_2.eps", plot = P, width = 6.9, height = 6.9,
       device = cairo_ps)


# Figure 3
load("egg_count_area.Rda") # p1
load("predicted_egg_count.Rda") # p2

P <- plot_grid(p1, p2,
               nrow = 2, ncol = 1,
               labels = c("a.", "b."),
               label_size = 10)
P
ggsave(filename = "Figure_3.png", plot = P, width = 4, height = 6.9)
ggsave(filename = "Figure_3.pdf", plot = P, width = 4, height = 6.9)
ggsave(filename = "Figure_3.eps", plot = P, width = 4, height = 6.9,
       device = cairo_ps)
