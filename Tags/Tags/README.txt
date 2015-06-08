
------------------------------------------------
Data logging pipeline
------------------------------------------------

We currently have a data logging pipeline, but it needs a number of enhancements. We have no code to actually read the data we've written.

DropboxUploader:
	-if you hand this a local path and a path within dropbox, it will upload the file there; this class should be good as is

DBPebbleMonitor:
	-this encapsulates everything relating to the Pebble watch; it sends an internal notification each time it receives data

DBSensorMonitor:
	-this subscribes to the feeds from all the phone's sensors; it's pretty ugly, but has a nice ability to filter for significant changes
	-its basic purpose is to stream dictionaries describing changed data to a configurable callback
	-.m file contains a list of all the sensor keys we're collecting and the units in which they're reported
	-will eventually need the ability to turn on/off collection of different properties
	-will eventually need ability to toggle between high- and medium-resolution GPS data (high resolution uses more batter)

DBBackgrounder:
	-this class is just a hack to let us run in the background by pretending to be a music player
	-apparently this isn't necessary if you do it right--the GetFit@MIT app managed to keep collecting in the background

DBLoggingManager:
	-a glue class that takes in pebble and phone sensor data and sends it to DBDataLogger

DBDataLogger:
	-this is the tricky, ugly, one that does everything in its power to compress the massive stream of data
	***-to split things into multiple collections, we probably want multiple DBDataLogger instances, rather than just one
		-if we do that, it shouldn't be too painful to get stuff working, and hopefully the details below shouldn't be necessary
	***
	-the basic idea is that we send it dictionaries of data, it buffers them in an array, and eventually it flushes the buffer to a csv file
		-note that it converts each dictionary to an array, so that the fields can be ordered consistently
			-it has to know all the dictionary keys ahead of time so that it can have consistent arrays
	-the scary part is how it goes from these arrays to lines in a csv file.
		-this needs massive compression, so it takes several steps:
			-if the value of a field is the same as it was in the previous row, it doesn't write anything
				-if the last array was [0, 5, "foo"], and this one is [0, 4, "foo"], we write ",4,,"
				-technically it's not checking against the previous row--it's checking against the last value of that field that it wrote, so it can skip an arbitrarily long number of values
			-however, it always writes the 1st and last rows in the file, so there's confusing logic ("forceWrite" et al) to make this happen
			-if all of the values are the same as the last time step, it doesn't even write a row
				-instead, it just keeps track of how many rows it's skipped
				-when something finally changes, it writes, as the 1st element of the new row, how many of the previous row it skipped
			-since unix timestamps are long, we don't want to write one in each row; we therefore only write the difference between the current timestamp and previous timestamp in each row
				-except that we write the absolute timestamp in the first data row of the file
	-this needs to use encryption
		-so the output stream it writes to should go to a string, rather than a file directly
			-we'll encrypt the string and then write it to a file

------------------------------------------------
GUI
------------------------------------------------

TODO write about how this works



