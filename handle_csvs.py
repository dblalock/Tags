import pandas
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import glob

path="../../Dropbox (MIT)/Apps/iOSense/users/87630EE6-0386-4F28-BDCB-39AE7281460a/*.csv"
class dataProcessor:
    def get_csvs(path):
        #Grabs all the csv files
        files = glob.glob(path)
        frames = [pd.DataFrame.from_csv(csv, index_col=False) for csv in files]
        return frames
    def construct_path(userId, dataType):
        return "../../Dropbox (MIT)/Apps/iOSense/users"+userID+"/*."+dataType+".csv"
    def __init__(self, userID, dataType):
        bigFrame = pd.DataFrame
        user = userID
        _dataType = dataType
        path = construct_path(userID, dataType)
        csvs = get_csvs(path)
    def fix_times(dataframe):
        #Sum up time stamps to give the actual times instead of the difference
        dataframe["timestamp"] = dataframe["timestamp"].cumsum()
        return dataframe
    def insert_skips(dataframe):
        #Adds in the duplicate rows that were skipped during compression
        for i in range(0, len(dataframe.index)-1):
            timeSkipped = int(dataframe.get_value(i+1, "numSkipped"))
            original_time = dataframe.get_value(i, "timestamp")
            if timeSkipped!=0:
                time_dif = (dataframe.get_value(i+1, "timestamp") - original_time)/(timeSkipped+1)
                for j in range(0, timeSkipped):
                    dataframe = dataframe.append(dataframe.ix[i], ignore_index=True)
                    #Set the timestamps for each of the skipped rows to make sure no duplicate times
                    new_time = original_time+time_dif*(j+1)
                    dataframe.set_value(len(dataframe.index)-1, "timestamp", new_time)
        dataframe = dataframe.sort("timestamp").reset_index(drop=True)
        del dataframe["numSkipped"]
        return dataframe
    def process_frame(frame):
        #Fix the times and the skips
        frame = fix_times(frame)
        frame = insert_skips(frame)
        return frame
    def combine_frames(frames):
    #Processes and then combines all the csv files into one big data frame
    base = process_frame(frames[0])
    for i in range(1,len(frames)):
        to_add = process_frame(frames[i])
        base.append(to_add)
        base.reset_index(drop=True)
    return base.sort("timestamp").reset_index(drop=True)

proc = dataProcessor()