import os
import datetime
import json
import common

class TextReport():
    """ This will take care of all the writing to the text report file """
    def __init__(self, mac_address="00000000"):
        assert ':' not in mac_address, "mac_address must be a string, and contain only alphanumeric chars (no ':')"
        self.dateTimeFormat = "%Y-%m-%d__%H_%M_%S"
        self.items = list()

        baseFolder = 'I:\\Data\\RP_test_reports'
        common.make_sure_path_exists(baseFolder)
        common.make_sure_path_exists(os.path.join(baseFolder, mac_address+self._getDateTimeString()))

    def _getDateTimeString(self):
        now = datetime.datetime.now()
        return now.strftime(self.dateTimeFormat)

    def saveTestResult(self, result_dict, temperature):
        """ augments the result_dict with the current time & temperature,
        then writes the new result to the report file """
        augmented_dict = result_dict.copy()
        augmented_dict["Zynq temperature"] = temperature
        augmented_dict["datetime"] = self._getDateTimeString()

        self._saveTestResult(augmented_dict)

    def _saveTestResult(self, result_dict):
        """ Implements the actual write to the file """
        self.items.append(result_dict)
        with open("report.txt", "w") as f:
            json.dump(self.items, f)
