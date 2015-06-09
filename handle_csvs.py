import pandas
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import glob

path="../../Dropbox (MIT)/Apps/iOSense/users/87630EE6-0386-4F28-BDCB-39AE7281460a/*.csv"

def fix_times(dataframe):
	#Sum up time stamps to give the actual times instead of the difference
    dataframe["timestamp"] = dataframe["timestamp"].cumsum()
    return dataframe

def insert_skips(dataframe):
	#Adds in the duplicate rows that were skipped during compression
    for i in range(0, len(dataframe.index)-1):
        timeSkipped = int(dataframe.get_value(i+1, "numSkipped"))
        if timeSkipped!=0:
            for j in range(0, timeSkipped):
                dataframe = dataframe.append(dataframe.ix[i], ignore_index=True)
    dataframe = dataframe.sort("timestamp").reset_index(drop=True)
    del dataframe["numSkipped"]
    return dataframe

def process_frame(frame):
	#Fix the times and the skips
    frame = fix_times(frame)
    frame = insert_skips(frame)
    return frame

def get_csvs(path):
	#Grabs all the csv files
    files = glob.glob(path)
    frames = [pd.DataFrame.from_csv(csv, index_col=False) for csv in files]
    return frames

def combine_frames(frames):
	#Processes and then combines all the csv files into one big data frame
    base = process_frame(frames[0])
    for i in range(1,len(frames)):
        to_add = process_frame(frames[i])
        base.append(to_add)
        base.reset_index(drop=True)
    return base.sort("timestamp").reset_index(drop=True)


all_csvs = get_csvs(path)
full_frame = combine_frames(all_csvs)
full_frame.to_csv("full.csv", na_rep="nan", index_lable="Index")