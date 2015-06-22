import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import glob

path = "../../Dropbox (MIT)/Apps/iOSense/users/87630EE6-0386-4F28-BDCB-39AE7281460a/*.csv"


class dataProcessor:
    def __init__(self, userID, dataType):
        # user = userID
        # _dataType = dataType
        path = "../../Dropbox (MIT)/Apps/iOSense/users/"+userID+"/*."+dataType+".csv"
        print path
        files = glob.glob(path)
        csvs = [pd.DataFrame.from_csv(csv, index_col=False) for csv in files]
        print len(csvs)
        self.big_frame = self.combine_frames(csvs)
        print self.big_frame

    def fix_times(self, dataframe):
        # Sum up time stamps to give the actual times instead of the difference
        dataframe["timestamp"] = dataframe["timestamp"].cumsum()
        return dataframe

    def insert_skips(self, dataframe):
        # Adds in the duplicate rows that were skipped during compression
        for i in range(0, len(dataframe.index)-1):
            timeSkipped = int(dataframe.get_value(i+1, "numSkipped"))
            original_time = dataframe.get_value(i, "timestamp")
            if timeSkipped != 0:
                time_dif = (dataframe.get_value(i+1, "timestamp") - original_time)/(timeSkipped+1)
                for j in range(0, timeSkipped):
                    dataframe = dataframe.append(dataframe.ix[i], ignore_index=True)
                    # Set the timestamps for skipped rows to make sure no duplicate times
                    new_time = original_time+time_dif*(j+1)
                    dataframe.set_value(len(dataframe.index)-1, "timestamp", new_time)
        dataframe = dataframe.sort("timestamp").reset_index(drop=True)
        del dataframe["numSkipped"]
        return dataframe

    def process_frame(self, frame):
        # Fix the times and the skips
        frame = self.fix_times(frame)
        frame = self.insert_skips(frame)
        return frame

    def combine_frames(self, frames):
        # Processes and then combines all the csv files into one big data frame
        base = self.process_frame(frames[0])
        for i in range(1,len(frames)):
            to_add = self.process_frame(frames[i])
            base.append(to_add)
            base.reset_index(drop=True)
        return base.sort("timestamp").reset_index(drop=True)

    def make_csv(self, frame, path):
        # Make the bigger dataframe into a csv
        frame.to_csv(path, na_rep="nan")
proc = dataProcessor("5A218C93-D44E-49C1-99C0-2E8B5FC0F938", "Motion")
proc.make_csv(proc.big_frame, "../../frame.csv")
proc.big_frame.plot(x='timestamp')
plt.legend(loc='upper left', bbox_to_anchor=(1.1, 1.05), fancybox=True, shadow=True)
plt.savefig("motionPlot", bbox_inches="tight")
print proc.big_frame

