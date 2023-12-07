
# libaries
library(tidyverse)
library(ggplot2)
# read csv and plot Area vs. FrameTime for each mouse
df <- read.csv("fileTable.csv", header = TRUE, sep = ",") %>%
    # filter ComponentId == 1
    filter(ComponentId == 1) %>%
    # average Area by group and FrameTime
    group_by(mouse,group, FrameTime) %>%
    summarise(AreaMean = mean(Area), AreaSD = sd(Area), AreaSE = sd(Area)/sqrt(n()))
df %>%
    # plot FrameTime vs. Area
    ggplot(aes(x = FrameTime, y = AreaMean, group = group, color = group)) +
    geom_line() +
    geom_point() +
    # add mean and sd
    geom_errorbar(aes(ymin = AreaMean - AreaSD, ymax = AreaMean + AreaSD), width = 0.01) +
    # set xlim to o-1
    xlim(0,1) +
    # set xlabel (Time (s))
    xlab("Time (s)") +
    # set ylabel (Area (pixels))
    ylab("Largest component area (pixels)") +
    # facet by mouse
    facet_wrap(~mouse)

# read csv and plot Area vs. FrameTime for each group
df <- read.csv("fileTable.csv", header = TRUE, sep = ",") %>%
    # filter ComponentId == 1
    filter(ComponentId == 1) %>%
    # average Area by group and FrameTime
    group_by(group, FrameTime) %>%
    summarise(AreaMean = mean(Area), AreaSD = sd(Area), AreaSE = sd(Area)/sqrt(n()))
df %>%
    # plot FrameTime vs. Area
    ggplot(aes(x = FrameTime, y = AreaMean, group = group, color = group)) +
    geom_line() +
    geom_point() +
    # add mean and sd
    geom_errorbar(aes(ymin = AreaMean - AreaSD, ymax = AreaMean + AreaSD), width = 0.01) +
    # set xlim to o-1
    xlim(0,1) +
    # set xlabel (Time (s))
    xlab("Time (s)") +
    # set ylabel (Area (pixels))
    ylab("Largest component area (pixels)")

# read csv and plot MeanIntensity vs. FrameTime for each mouse
df <- read.csv("fileTable.csv", header = TRUE, sep = ",") %>%
    # filter ComponentId == 1
    filter(ComponentId == 1) %>%
    # average MeanIntensity by group and FrameTime
    group_by(mouse,group, FrameTime) %>%
    summarise(MeanIntensityMean = mean(MeanIntensity), MeanIntensitySD = sd(MeanIntensity), MeanIntensitySE = sd(MeanIntensity)/sqrt(n()))
df %>%
    # plot FrameTime vs. MeanIntensity
    ggplot(aes(x = FrameTime, y = MeanIntensityMean, group = group, color = group)) +
    geom_line() +
    geom_point() +
    # add mean and sd
    geom_errorbar(aes(ymin = MeanIntensityMean - MeanIntensitySD, ymax = MeanIntensityMean + MeanIntensitySD), width = 0.01) +
    # set xlim to o-1
    xlim(0,1) +
    # set xlabel (Time (s))
    xlab("Time (s)") +
    # set ylabel (MeanIntensity (AU))
    ylab("Largest component mean intensity") +
    # facet by mouse
    facet_wrap(~mouse)

# read csv and plot MeanIntensity vs. FrameTime for each group
df <- read.csv("fileTable.csv", header = TRUE, sep = ",") %>%
    # filter ComponentId == 1
    filter(ComponentId == 1) %>%
    # average MeanIntensity by group and FrameTime
    group_by(group, FrameTime) %>%
    summarise(MeanIntensityMean = mean(MeanIntensity), MeanIntensitySD = sd(MeanIntensity), MeanIntensitySE = sd(MeanIntensity)/sqrt(n()))
df %>%
    # plot FrameTime vs. MeanIntensity
    ggplot(aes(x = FrameTime, y = MeanIntensityMean, group = group, color = group)) +
    geom_line() +
    geom_point() +
    # add mean and sd
    geom_errorbar(aes(ymin = MeanIntensityMean - MeanIntensitySD, ymax = MeanIntensityMean + MeanIntensitySD), width = 0.01) +
    # set xlim to o-1
    xlim(0,1) +
    # set xlabel (Time (s))
    xlab("Time (s)") +
    # set ylabel (MeanIntensity (AU))
    ylab("Largest component mean intensity")