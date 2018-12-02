from __future__ import print_function

import sys
import argparse
import os.path as osp

import numpy as np
import pandas as pd

import standard_format as sf
import python_speech_features as psf

from fastdtw import fastdtw
from scipy.stats.mstats import zscore

import scipy.io.wavfile

def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs) # FIXME WRAP

class AcousticFeatureError(RuntimeError):
    pass

def load_wav(filename, wav_sampling_rate):
    """ load_wav function test and read a wav files, and convert
    stereo channels into mono
    Parameters
    ----------

    fname : [string]
        wav input file name
    fs : [int]
        check if the sampling rate of the signal given by
        this variable, frequency in Hz
    Returns
    -------
    sig : [np.array]
        mono-channel signal
    """
    ## FIXME - this documentation
    found_sampling_rate, signal = scipy.io.wavfile.read(filename)
    if wav_sampling_rate != found_sampling_rate:
        # FIXME - this error message
        raise AcousticFeatureError('Error reading audio file {0}: '
                             'Sampling rate should be {1}, not {2}. '
                             'Please resample.'.format(
                             filename, wav_sampling_rate,
                             found_sampling_rate))
    if len(signal.shape) > 1:
        raise AcousticFeatureError("Stereo wav files not supported")
    return signal

def get_item(df, row, frame_tolerance):
    # FIXME - fragile column names
    if '_onset' in row.index and '_offset' in row.index \
       and '_time' in df.columns:
        rep = df[(df['_file'] == row['_file']) \
                 & (df['_time'] >= row['_onset'] - frame_tolerance) \
                 & (df['_time'] <= row['_offset'] + frame_tolerance)]
    else:
        rep = df[df['_file'] == row['_file']]
    meta = pd.DataFrame([row])
    result = rep.merge(meta, on='_file', how='left')
    result['_item_frame'] = range(rep.shape[0])
    return result

def dtw_euclidean(x, y):
    return fastdtw(x, y, dist=2)[0]

def dtw_norm_max_euclidean(x, y):
    dtw = fastdtw(x, y, dist=2)
    return dtw[0]/len(dtw[1])

def dtw_norm_both_euclidean(x, y):
    dtw = fastdtw(x, y, dist=2)
    return dtw[0]/(x.shape[0] + y.shape[0])

def get_item_1(df, row):
    info = pd.DataFrame([row[[c for c in row.keys() \
            if len(c) > 2 and c[-2:] == "_1"]]])
    info.columns = [c[:-2] for c in info.columns]
    item = info.merge(df, how='left')
    return item[[c for c in item.columns if c[0] == "F"]] # FIXME: should be using standard format

def get_item_2(df, row):
    info = pd.DataFrame([row[[c for c in row.keys() \
                            if len(c) > 2 and c[-2:] == "_2"]]])
    info.columns = [c[:-2] for c in info.columns]
    item = info.merge(df, how='left')
    return item[[c for c in item.columns if c[0] == "F"]] # FIXME: should be using standard format

def calculate_distances_all(pairs, reps, distance):
    return [distance(get_item_1(reps, r[1]), get_item_2(reps, r[1])) \
            for r in pairs.iterrows()] # FIXME - naming - conceptual??

def center_time(frame_numbers, frame_shift):
    return frame_numbers*frame_shift

def replace_content(d, new_content):
    result = d.copy()
    result[sf.content_keys(d)] = new_content
    return result

def file_to_speaker(f):
    return osp.splitext(osp.basename(f))[0].split("_")[0]

def wav_to_features(filename, wav_sampling_rate, feature_frame_shift,
        feature_window_length, nfilt, nceps):
    # FIXME - support configuration, support different feature functions
    signal = load_wav(filename, wav_sampling_rate)
    if nceps is not None:
        features_ = psf.mfcc(signal, wav_sampling_rate,
                feature_window_length, feature_frame_shift, nceps, nfilt,
                512, 133.3333, 6855.4976, 0.97, 0, True, np.hamming)
    else:
        features_ = psf.logfbank(signal, wav_sampling_rate,
                feature_window_length, feature_frame_shift, nfilt, 512,
                133.3333, 6855.4976, 0.97, np.hamming)
    # FIXME - customize column names
    features_df = pd.DataFrame(features_,
            columns=["F" + str(i) for i in range(1,features_.shape[1]+1)])
    # FIXME - use the (non-existent) standard_format API to set meta-columns 
    features_df['_frame_number'] =  range(features_.shape[0])
    # FIXME - this is safe to do independent of the treatment ONLY
    # because stft used zero-padding; if it had truncated, we would have
    # needed the feature function to give us back the times
    features_df['_time'] = center_time(features_df['_frame_number'],
            feature_frame_shift)
    features_df['_file'] = filename
    return features_df

def BUILD_ARGPARSE():
    parser = argparse.ArgumentParser(
            description=__doc__,
            formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument('--frame-rate', help="Feature frame rate in seconds",
            type=float, default=0.01)
    parser.add_argument('--window-size', help="FFT window width in seconds",
            type=float, default=0.025)
    parser.add_argument('--normalize-global', help="Z-score over all files",
                dest='normalize', action='store_const', const="global")
    parser.add_argument('--normalize-by-speaker',
                help="Z-score within speaker (speaker id is assumed to be " +
                "everything in the filename up to the first '_')",
                dest='normalize', action='store_const', const="speaker")
    parser.set_defaults(normalize="none")
    parser.add_argument('--nceps', help="Convert to this number of cepstral " \
            "coefficients (uses filterbank features if unspecified)", type=int,
            default=None)
    parser.add_argument('--representation-file', help="Name of a CSV " \
            "in which to save the feature representations of the items" \
            "(not saved by default)", type=str, default=None)
    parser.add_argument('--distance-function', help="Name of a distance "\
            "function (default is 'dtw_norm_max_euclidean')", type=str,
            default="dtw_norm_max_euclidean")
    parser.add_argument('pair_file', help="Pair file", type=str)
    parser.add_argument('wav_sampling_rate', help="Audio file sampling rate",
            type=int)
    parser.add_argument('output_file', nargs='?', help="Output file",
            type=str, default=None)
    return parser

if __name__ == "__main__":
    parser = BUILD_ARGPARSE()
    args = parser.parse_args(sys.argv[1:])
    try:
        pairs = sf.read(args.pair_file)
    except Exception as e:
        eprint(
"""Issue with pair file (<F>): <M>""".replace(
    "<F>", str(args.pair_file)).replace(
    "<M>", str(e)).replace(
    "\n", " "))
        sys.exit(1)

    try:
        distance_fn = globals()[args.distance_function]
    except Exception as e:
        eprint(
"""Issue with distance function (<F>): <M>""".replace(
    "<F>", str(args.distance_function)).replace(
    "<M>", str(e)).replace(
    "\n", " "))
        sys.exit(1)


    # FIXME - fragile - no checks
    pairs = sf.munge_df(pairs)

    # Blithely stack item_1 on top of item_2 - no checks
    # are made to see if the columns really meaningfully overlap;
    # we just expect '_file' to be available later on
    items_1 = pairs[[c for c in pairs.columns if len(c) > 2 and c[-2:] == "_1"]]
    items_1.columns = [c[:-2] for c in items_1.columns]
    items_2 = pairs[[c for c in pairs.columns if len(c) > 2 and c[-2:] == "_2"]]
    items_2.columns = [c[:-2] for c in items_2.columns]
    if set(items_1.columns) != set(items_2.columns):
        eprint(
"""Issue with pair file (<F>):
columns don't match""".replace(
    "<F>", str(args.pair_file)))
        sys.exit(1)

    items = pd.concat([items_1, items_2], sort=True).drop_duplicates()

    corpus = items['_file'].unique()
    file_reps = [wav_to_features(w, args.wav_sampling_rate, args.frame_rate, \
                                args.window_size, 40, args.nceps) \
                 for w in corpus]
    file_rep_df = pd.concat(file_reps)
    # Normalize over corpus
    if args.normalize == "global":
        file_rep_df = replace_content(file_rep_df,
                                      zscore(sf.content(file_rep_df)))
    if args.normalize == "speaker":
        file_rep_df["_speaker"] = [file_to_speaker(f) for f in file_rep_df["_file"]]
        file_rep_df = file_rep_df.groupby("_speaker")\
                   .apply(lambda d: replace_content(d, zscore(sf.content(d))))
        if "_speaker" in items.columns:
            items = items.drop("_speaker", 1) # FIXME - Yes, really!
    item_reps = [get_item(file_rep_df, r[1], args.frame_rate/2) \
                 for r in items.iterrows()]
    item_rep_df = pd.concat(item_reps)
    if args.representation_file:
        item_rep_df.to_csv(args.representation_file, index=False)
    reps = items.merge(item_rep_df, how='left')
    distances = calculate_distances_all(pairs, reps, distance_fn)
    pairs['distance'] = distances
#    store_distances(distances)
    if args.output_file is None:
        pairs.to_csv(sys.stdout, index=False)
    else:
        pairs.to_csv(args.output_file, index=False)


