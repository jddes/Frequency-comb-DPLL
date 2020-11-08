import os
import datetime
import json
import common

class TextReport():
    """ This will take care of all the writing to the text report file """
    def __init__(self, mac_address="00000000", loadFromFolder=None):
        assert ':' not in mac_address, "mac_address must be a string, and contain only alphanumeric chars (no ':')"
        self.dateTimeFormat = "%Y-%m-%d__%H_%M_%S"
        self.items = list()

        if loadFromFolder is None:
            baseFolder        = 'I:\\Data\\RP_test_reports'
            self.reportFolder = os.path.join(baseFolder, mac_address + "__" + self._getDateTimeString())
            common.make_sure_path_exists(baseFolder)
            common.make_sure_path_exists(self.reportFolder)
        else:
            self.loadFromReportFolder(loadFromFolder)

    def getFilename(self):
        return os.path.join(self.reportFolder, "report.txt")

    def _getDateTimeString(self):
        now = datetime.datetime.now()
        return now.strftime(self.dateTimeFormat)

    def saveTestResult(self, result_dict, temperature):
        """ augments the result_dict with the current time & temperature,
        then writes the new result to the report file """
        augmented_dict = result_dict.copy()
        augmented_dict["Zynq temperature [degC]"] = round(temperature*100.)/100.
        augmented_dict["datetime"] = self._getDateTimeString()

        self._saveTestResult(augmented_dict)

    def _saveTestResult(self, result_dict):
        """ Implements the actual write to the file """
        self.items.append(result_dict)
        with open(self.getFilename(), "w") as f:
            json.dump(self.items, f, indent=4)

    def loadFromReportFolder(self, reportFolder):
        self.reportFolder = reportFolder
        self.items = json.load(self.getFilename())

    def findTestByName(self, test_name):
        """ Returns the dict corresponding to a particular test """
        for d in self.items:
            if d["test_name"] == test_name:
                return d

        return None
