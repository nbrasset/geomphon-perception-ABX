mkdir -p deploy \
  && cp -R geomphon-LMEDS_v-c925d74/* deploy/ \
  && mkdir deploy/tests/geomphon_ABX_English_pilot \
  && cp -R experiment_scripts/common/* deploy/tests/geomphon_ABX_English_pilot \
  && cp experiment_scripts/english/*.txt deploy/tests/geomphon_ABX_English_pilot \
  && cp experiment_scripts/english/geomphon_ABX_English_pilot.cgi deploy/cgi-bin/ \
  && mkdir deploy/tests/geomphon_ABX_English_pilot/audio_and_video \
  && cp stimuli/*  deploy/tests/geomphon_ABX_English_pilot/audio_and_video \
  && mkdir deploy/tests/geomphon_ABX_French_pilot \
  && cp -R experiment_scripts/common/* deploy/tests/geomphon_ABX_French_pilot \
  && cp experiment_scripts/french/*.txt deploy/tests/geomphon_ABX_French_pilot/ \
  && cp experiment_scripts/french/geomphon_ABX_French_pilot.cgi deploy/cgi-bin/ \
  && mkdir deploy/tests/geomphon_ABX_French_pilot/audio_and_video \
  && cp stimuli/*  deploy/tests/geomphon_ABX_French_pilot/audio_and_video \
  && mkdir deploy/tests/geomphon_ABX_French_RISC_pilot \
  && cp -R experiment_scripts/common/* \
      deploy/tests/geomphon_ABX_French_RISC_pilot \
  && cp experiment_scripts/french/geomphon_ABX_pilot_French_sequence.txt \
      deploy/tests/geomphon_ABX_French_RISC_pilot/ \
  && cp experiment_scripts/french_risc/geomphon_ABX_French_RISC_dict.txt \
      deploy/tests/geomphon_ABX_French_RISC_pilot/ \
  && cp experiment_scripts/french_risc/geomphon_ABX_French_RISC_pilot.cgi \
      deploy/cgi-bin/ \
  && mkdir deploy/tests/geomphon_ABX_French_RISC_pilot/audio_and_video \
  && cp stimuli/*  deploy/tests/geomphon_ABX_French_RISC_pilot/audio_and_video

   
