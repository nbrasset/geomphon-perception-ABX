#quick visualizations of acoustic dist effects 

data_i<-readr::read_csv("hindi_for_comparison/econ_0_loc_0_glob_0.csv")
data_k<-readr::read_csv("hindi_for_comparison/econ_1_loc_0_glob_1.csv")


summ_acc_i <- dplyr::group_by(data_i, Phone_NOTENG, Phone_ENG, Econ, Loc, Glob, acoustic_distance) %>% dplyr::summarize(acc=mean(response_var)) %>% dplyr::ungroup()
ggplot2::ggplot(summ_acc_i, ggplot2::aes(x=acoustic_distance, y=acc, label=paste(Phone_NOTENG, Phone_ENG, sep=":"))) + ggplot2::geom_text() + ggplot2::ggtitle("hindi only, econ_0_loc_0_glob_0") +ggplot2::xlim(-2,1)+ggplot2::ylim(0,.9)

summ_acc_k <- dplyr::group_by(data_k, Phone_NOTENG, Phone_ENG, Econ, Loc, Glob, acoustic_distance) %>% dplyr::summarize(acc=mean(response_var)) %>% dplyr::ungroup()
ggplot2::ggplot(summ_acc_k, ggplot2::aes(x=acoustic_distance, y=acc, label=paste(Phone_NOTENG, Phone_ENG, sep=":"))) + ggplot2::geom_text()+ggplot2::ggtitle("hindi only,econ_1_loc_0_glob_1")+ggplot2::xlim(-2,1)+ggplot2::ylim(0,.9)

data_j<-readr::read_csv("hindi_kab_for_comparison/econ_0_loc_0_glob_0.csv")
data_m<-readr::read_csv("hindi_kab_for_comparison/econ_1_loc_0_glob_1.csv")


summ_acc_j <- dplyr::group_by(data_j, Phone_NOTENG, Phone_ENG, Econ, Loc, Glob, acoustic_distance) %>% dplyr::summarize(acc=mean(response_var)) %>% dplyr::ungroup()
ggplot2::ggplot(summ_acc_j, ggplot2::aes(x=acoustic_distance, y=acc, label=paste(Phone_NOTENG, Phone_ENG, sep=":"))) + ggplot2::geom_text() + ggplot2::ggtitle("hindi and kab, econ_0_loc_0_glob_0") +ggplot2::xlim(-2,1)+ggplot2::ylim(0,.9)

summ_acc_m <- dplyr::group_by(data_m, Phone_NOTENG, Phone_ENG, Econ, Loc, Glob, acoustic_distance) %>% dplyr::summarize(acc=mean(response_var)) %>% dplyr::ungroup()
ggplot2::ggplot(summ_acc_m, ggplot2::aes(x=acoustic_distance, y=acc, label=paste(Phone_NOTENG, Phone_ENG, sep=":"))) + ggplot2::geom_text() + ggplot2::ggtitle("hindi and kab, econ_1_loc_0_glob_1") +ggplot2::xlim(-2,1)+ggplot2::ylim(0,.9)
