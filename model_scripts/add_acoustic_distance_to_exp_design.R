`%>%` <- magrittr::`%>%`

exp_design_hindi <- readr::read_csv("exp_design_Hindi.csv")
exp_design_hk <- readr::read_csv("exp_design_HK.csv")
exp_design_kabardian <- dplyr::setdiff(exp_design_hk, exp_design_hindi)

stimuli_info_july <- readr::read_csv(
  "../experiments/pilot_july_2018/stimuli/item_meta_information_with_distances.csv")
stimuli_info_aug <- readr::read_csv(
  "../experiments/pilot_Aug_2018/stimuli/item_meta_information_with_distances.csv")

results_july <- readr::read_csv(
  "../experiments/pilot_july_2018/results.csv") %>%
  dplyr::mutate(response=ifelse(first_sound == 1, "A", "B")) %>%
  dplyr::filter(startsWith(tripletid, "tripl")) %>%
  dplyr::mutate(tripletid=sub("^triplet_", "", tripletid)) %>%
  dplyr::left_join(stimuli_info_july) %>%
  dplyr::mutate(CORR_ANS=ifelse(presentation_order == "AB", "A", "B")) %>%
  dplyr::mutate(user_correct=response==CORR_ANS) %>%
  dplyr::mutate(delta_mfcc=distance_normed_mfcc__dtw_pathlength_TGT-
                           distance_normed_mfcc__dtw_pathlength_OTH)
results_aug <- readr::read_csv(
  "../experiments/pilot_Aug_2018/anon_output/results.csv") %>%
  dplyr::mutate(response=ifelse(first_sound == 1, "A", "B")) %>%
  dplyr::filter(startsWith(tripletid, "stimul")) %>%
  dplyr::left_join(stimuli_info_aug) %>%
  dplyr::mutate(user_correct=response==CORR_ANS) %>%
  dplyr::mutate(delta_mfcc=distance_normed_mfcc__dtw_pathlength_TGT-
                           distance_normed_mfcc__dtw_pathlength_OTH)
  
accuracy_by_tripletid_july <- results_july %>%
  dplyr::mutate(phone_1=ifelse(`Target phone` < `Other phone`,
                               `Target phone`, `Other phone`),
                phone_2=ifelse(`Other phone` < `Target phone`,
                               `Target phone`, `Other phone`),
                pair=paste0(phone_1, ":", phone_2)) %>%
  dplyr::group_by(tripletid, delta_mfcc, pair) %>%
  dplyr::summarize(acc=mean(user_correct)) %>%
  dplyr::ungroup()

accuracy_by_tripletid_aug <- results_aug %>%
  dplyr::mutate(phone_1=ifelse(phone_TGT < phone_OTH,
                               phone_TGT, phone_OTH),
                phone_2=ifelse(phone_OTH < phone_TGT,
                               phone_TGT, phone_OTH),
                pair=paste0(phone_1, ":", phone_2)) %>%
  dplyr::group_by(tripletid, delta_mfcc, pair) %>%
  dplyr::summarize(acc=mean(user_correct)) %>%
  dplyr::ungroup()

results_all <- dplyr::bind_rows(results_july, results_aug)
m_all <- lme4::glmer(user_correct ~ 1 + delta_mfcc + (1|subject_id) +
                       (1|tripletid),
                     data=results_all, family="binomial")

accuracy_by_tripletid <- dplyr::bind_rows(
  accuracy_by_tripletid_july,
  accuracy_by_tripletid_aug) %>%
  dplyr::mutate(z=boot::logit(acc))

ggplot2::ggplot(accuracy_by_tripletid,
                ggplot2::aes(y=z, x=delta_mfcc, label=pair)) +
  ggplot2::geom_text() +
  ggplot2::geom_abline(intercept=lme4::fixef(m_all)[1],
                       slope=lme4::fixef(m_all)[2])

acoustic_distances <- unique(c(results_aug$delta_mfcc,
                               results_july$delta_mfcc))
acoustic_distances <- acoustic_distances[!is.na(acoustic_distances)]

# Doing this by hand from looking at the graphic:
acoustic_distance_types <- list()
acoustic_distance_types[[5]] <- acoustic_distances[acoustic_distances <= -1]
acoustic_distance_types[[4]] <- acoustic_distances[(acoustic_distances > -1) &
                                             (acoustic_distances <= -0.7)]
acoustic_distance_types[[3]] <- acoustic_distances[(acoustic_distances > -0.7) &
                                             (acoustic_distances <= -0.4)]

acoustic_distance_types[[2]] <- acoustic_distances[(acoustic_distances > -0.4) &
                                             (acoustic_distances <= 0)]
acoustic_distance_types[[1]] <- acoustic_distances[(acoustic_distances > 0) &
                                             (acoustic_distances <= 0.6)]


set.seed(2)
exp_design_hindi <- exp_design_hindi %>%
  dplyr::mutate(
   `Acoustic distance`=
     purrr::map_dbl(
      acoustic_distance_types[exp_design_hindi$`Acoustic distance category`],
      ~ sample(., 1))) %>%
  dplyr::select(-`Acoustic distance category`)
exp_design_kabardian <- exp_design_kabardian %>%
  dplyr::mutate(
   `Acoustic distance`=
     purrr::map_dbl(
      acoustic_distance_types[exp_design_kabardian$`Acoustic distance category`],
      ~ sample(., 1))) %>%
  dplyr::select(-`Acoustic distance category`)
exp_design_hk <- dplyr::bind_rows(exp_design_hindi, exp_design_kabardian)
set.seed(NULL)

readr::write_csv(exp_design_hindi,
                 "exp_design_Hindi_with_acoustic_distance.csv")
readr::write_csv(exp_design_hk,
                 "exp_design_HK_with_acoustic_distance.csv")


