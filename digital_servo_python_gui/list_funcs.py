# -*- coding: utf-8 -*-
"""
Created on Sun Aug 25 16:52:37 2019

@author: JD
"""

def remove_def(func_definition):
    return func_definition.strip()[len('def '):]

funcs = []

funcs_with_comms_in_sl = open('list of functions in SuperLaserLand.py that interact with the socket.txt', 'r').readlines()
funcs_with_comms_in_sl = [remove_def(line) for line in funcs_with_comms_in_sl]
funcs_with_comms_in_sl = [line[:line.find('(')] for line in funcs_with_comms_in_sl]
funcs_with_comms_in_mw = []

with open('XEM_GUI_MainWindow.py', 'r') as f:
    for line in f.readlines():
        if line.startswith('\tdef '):
            current_func = remove_def(line)
            # if current_func == 'isplayDAC(self):':
                 #print(line)
                # print(current_func)
            funcs.append(line.strip('\n'))
            # print(line.strip('\n'))
        
        for func_name in funcs_with_comms_in_sl:
            if func_name in line:
                # print(current_func)
                funcs_with_comms_in_mw.append(current_func)
                break

funcs_with_comms_in_mw_unique = list(dict.fromkeys(funcs_with_comms_in_mw))
# print('\n'.join(funcs_with_comms_in_sl))            
# print('\n'.join(funcs_with_comms_in_mw))
print('\n'.join(funcs_with_comms_in_mw_unique))
