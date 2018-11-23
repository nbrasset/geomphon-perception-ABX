library(magrittr)

all <- c()
for (f in dir(pattern="SCORE*")) {
  r <- readr::read_csv(f)
  r$`_filename` <- f
  all <- rbind(all, r)
}

readr::write_csv(all, "combined.csv")

summ <- all %>% dplyr::group_by(`_filename`) %>%
  dplyr::summarize(econ_med=median(econ),
                   loc_med=median(loc, na.rm=TRUE),
                   glob_med=median(glob, na.rm=TRUE))

readr::write_csv(summ, "summary.csv")
