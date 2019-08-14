#Read data from the devices_data.xml file until we reach the last value. The value are return in a dictionnary variable


import xml.etree.ElementTree as ET



class devicesData():

	def __init__(self, strFilename = "devices_data.xml"):
		self.tree = ET.parse(strFilename)

	def updateDictionnary(self, devices_dict):
		bOtherDevices = True
		i = 0
		initial_dict = devices_dict

		while 1: #Infinite loop until we reached 256 try to read or until we reach the end of the xml file or until any other unknown error happens
			try:
				i = i+1
				device = "Device_" + str(i)

				strSerial 	= self.tree.find(device).attrib["strSerial"]
				color 		= self.tree.find(device).attrib["color"]
				name 		= self.tree.find(device).attrib["name"]
				shorthand 	= self.tree.find(device).attrib["shorthand"]
				try:
					port_temp	= self.tree.find(device).attrib["port_temp"]
				except:
					port_temp = 5000
				config_file = self.tree.find(device).attrib["config_file"]

				devices_dict[strSerial] = {'color': color,
								'name': name,
								'shorthand': shorthand,
								'config file': config_file,
								'port_temp': port_temp
								}
				if i >= 256: # To prevent an infinite loop
					print("Error, the devices_data dictionnary was not update to prevent an infinite loop.")
					return initial_dict
			except AttributeError: #the attribute Device_i does not exist : We reached the end of the list
				# print("End of devices list")
				return devices_dict
			except Exception as e: # Any other exception; we return the initial_dictionnary to prevent any bug.
				print("Error while parsing devices_data.xml : {}".format(e))
				return initial_dict
		
		


if __name__ == '__main__':
	device_dict = {}
	devicesData = devicesData("devices_data.xml")
	device_dict = devicesData.updateDictionnary(device_dict)
	print(device_dict)