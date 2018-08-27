#!/usr/bin/env python
# -*- coding: utf-8 -*-

import experiment_runner
experiment_runner.runExperiment("geomphon_ABX_French_Aug_2018",
                                "geomphon_ABX_pilot_French_sequence.txt",
                                "geomphon_ABX_pilot_French_dict.txt",
                                disableRefresh=False,
                                audioExtList=[".ogg", ".mp3"],
                                videoExtList=[".ogg", ".mp4"],
                                allowUtilityScripts=True,
                                allowUsersToRelogin=True,
                                individualSequences=True)
    