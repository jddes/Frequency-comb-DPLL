import xml.etree.ElementTree as ET

def getDevicesData(strFilename="devices_data.xml"):
    """ Read data from strFilename. Returns a dict of dict with one entry per device """
    devices_dict = dict()
    tree = ET.parse(strFilename)

    bOtherDevices = True
    deviceID = 0

    while 1: #Infinite loop until we reached 256 try to read or until we reach the end of the xml file or until any other unknown error happens
        try:
            deviceID += 1
            device_name = "Device_" + str(deviceID)

            MAC_addr    = tree.find(device_name).attrib["MAC_addr"]
            color       = tree.find(device_name).attrib["color"]
            name        = tree.find(device_name).attrib["name"]
            shorthand   = tree.find(device_name).attrib["shorthand"]
            config_file = tree.find(device_name).attrib["config_file"]

            devices_dict[MAC_addr] = {'color'      : color,
                                       'name'       : name,
                                       'shorthand'  : shorthand,
                                       'config file': config_file,
                                       }
            if deviceID >= 10e3: # just in case
                return devices_dict
        except AttributeError: #the attribute Device_i does not exist : We reached the end of the list
            # print("End of devices list")
            return devices_dict
        except Exception as e: # Any other exception; we return the initial_dictionnary to prevent any bug.
            print("Error while parsing devices_data.xml : {}".format(e))
            return devices_dict

if __name__ == '__main__':
    print(getDevicesData("devices_data.xml"))