# Convert Textgrids to an ABXpy item file for doing
# word ABX (i.e., containing one column, word)
#
# Author: Ewan Dunbar

from __future__ import print_function
from __future__ import division

import sys
import argparse
import os.path as osp

def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs) # FIXME WRAP

def get_intervals(textgrid_fn, tier_name):
    intervals = []
    current_onset, current_offset, current_content = \
            None, None, None
    with open(textgrid_fn) as textgrid_hf:
        state = "WAITING_FOR_TIER"
        for line in textgrid_hf:
            line = line.strip()
            if state == "WAITING_FOR_TIER":
                if line == "\"IntervalTier\"":
                    state = "WAITING_FOR_TIER_2"
            elif state == "WAITING_FOR_TIER_2":
                if line == "\"" + tier_name + "\"":
                    state = "WAITING_FOR_TIERHEADER_1"
            elif state == "WAITING_FOR_TIERHEADER_1":
                state = "WAITING_FOR_TIERHEADER_2"
            elif state == "WAITING_FOR_TIERHEADER_2":
                state = "WAITING_FOR_TIERHEADER_3"
            elif state == "WAITING_FOR_TIERHEADER_3":
                state = "WAITING_FOR_ONSET"
            elif state == "WAITING_FOR_ONSET":
                try:
                    current_onset = float(line)
                    state = "WAITING_FOR_OFFSET"
                except ValueError:
                    state = "FINISHED"
            elif state == "WAITING_FOR_OFFSET":
                current_offset = float(line)
                state = "WAITING_FOR_CONTENT"
            elif state == "WAITING_FOR_CONTENT":
                current_content = line.split("\"")[1]
                intervals.append(
                    (current_onset, current_offset, current_content)
                )
                state = "WAITING_FOR_ONSET"
            elif state == "FINISHED":
                break
    return intervals

def print_abx_item_file_header():
    print("#file onset offset #item word")

def print_abx_item_file_line(filename, interval, item_number):
    file_basename = osp.splitext(filename)[0]
    print(file_basename + " " + str(interval[0]) + " " \
            + str(interval[1]) + " " + "i" + str(item_number) \
            + " " + interval[2])

def is_target_word(word, target_words):
    return word != "" \
            and ((target_words is None) or (word in target_words))

def BUILD_ARGPARSE():
    parser = argparse.ArgumentParser(
            description=__doc__,
            formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument('--excluded-words', help="List of word targets " \
            "to exclude, separated by comma (defaults to none)", default=[],
            type=str)
    parser.add_argument('--target-words', help="List of word targets " \
            "to include, separated by comma (defaults to all)", default=None,
            type=str)
    parser.add_argument('tier_name', help="Name of TextGrid tier",
            type=str)
    parser.add_argument('textgrids', help="TextGrid files", type=str,
            nargs="+")
    return parser

if __name__ == "__main__":
    parser = BUILD_ARGPARSE()
    args = parser.parse_args(sys.argv[1:])
    try:
        interval_lists = [get_intervals(f, args.tier_name) for f in args.textgrids]
    except Exception as e:
        eprint(
"""Problem reading TextGrids: <M>""".replace(
    "<M>", str(e)).replace(
    "\n", " "))
        sys.exit(1)
    print_abx_item_file_header()
    intervals = dict(zip(args.textgrids, interval_lists))
    item_number = 0
    for fn in intervals:
        for interval in intervals[fn]:
            if is_target_word(interval[2], args.target_words) \
            and not interval[2] in args.excluded_words:
                item_number += 1
                print_abx_item_file_line(fn, interval, item_number)

