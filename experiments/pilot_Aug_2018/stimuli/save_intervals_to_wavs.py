# Cut all labelled intervals in a TextGrid
#
# Author: Ewan Dunbar

from __future__ import print_function

from textgrid import TextGrid
from pydub import AudioSegment
import sys, argparse
import os
import os.path as osp
import pandas as pd

class TextGridError(RuntimeError):
    pass

def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs) # FIXME WRAP

def get_intervals(textgrid_fn, tier_name):
    tg = TextGrid()
    tg.read(textgrid_fn)
    try:
        tier_i = tg.getNames().index(tier_name)
    except ValueError:
        raise TextGridError("Cannot find tier named " + tier_name)
    return tg[tier_i]


def BUILD_ARGPARSE():
    parser = argparse.ArgumentParser(
            description=__doc__,
            formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument('--excluded-words',
            help="Comma-separated list of excluded words",
            type=str, default="")
    parser.add_argument('tier_name', help="Name of TextGrid tier",
            type=str)
    parser.add_argument('output_folder', help="Name of the output folder",
            type=str)
    parser.add_argument('table_filename', help="Name of the output table",
            type=str)
    parser.add_argument('textgrid_wavfile_pairs',
            help="Comma-separated pairs of filenames: <TextGrid>,<WavFile>",
            type=str, nargs="+")
    return parser


if __name__ == "__main__":
    parser = BUILD_ARGPARSE()
    args = parser.parse_args(sys.argv[1:])

    excluded_words = args.excluded_words.split(",")
    if not os.path.isdir(args.output_folder):
        os.makedirs(args.output_folder)
    columns_meta = ["orig_file", "indexnumber", "int_name", "int_filename"]
    meta_info = pd.DataFrame(columns = columns_meta)


    for tw in args.textgrid_wavfile_pairs:
        try:
            f_tg, f_wav = tw.split(",")
        except ValueError:
            eprint(
"""ERROR: Need to provide paired TextGrid/wave file names""".replace(
    "\n", " "))
            sys.exit(1)
        try:
            tier = get_intervals(f_tg, args.tier_name)
        except Exception as e:
            eprint(
"""Problem reading TextGrids: <M>""".replace(
    "<M>", str(e)).replace(
    "\n", " "))
            sys.exit(1)
        try:
            audio = AudioSegment.from_wav(f_wav)
        except Exception as e:
            eprint(
"""Problem reading audio file: <M>""".replace(
    "<M>", str(e)).replace(
    "\n", " "))
            sys.exit(1)

        interval_basename = osp.splitext(osp.basename(f_wav))[0]

        index_number = 1
        for interval in tier:
            label = interval.mark.strip()
            if label != "" and label not in excluded_words:
                item_basename = "_".join([interval_basename,
                                          str(index_number)])
                item_filename = item_basename + ".wav"

                start_time_ms = int(interval.minTime*1000)
                end_time_ms = int(interval.maxTime*1000)
                segment = audio[start_time_ms:(end_time_ms+1)]
                segment.export(args.output_folder + "/" + item_filename,
                               format="wav")

                row_index = meta_info.shape[0]
                meta_info.loc[row_index] = [f_wav, index_number, label,\
                                            item_basename]
                index_number += 1

    meta_info.to_csv(args.table_filename, index=False)



