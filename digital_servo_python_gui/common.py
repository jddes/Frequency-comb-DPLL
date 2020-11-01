import os
import errno
import socket

# From: http://stackoverflow.com/questions/273192/create-directory-if-it-doesnt-exist-for-file-write
def make_sure_path_exists(path):
    try:
        os.makedirs(path)
    except OSError as exception:
        if exception.errno != errno.EEXIST:
            raise

def findMostLikelyLANBroadcastIPAddress():
    """ list all possible IPv4 addresses and choose the most likely candidate for the subnet on which the red pitaya is
    heuristics used:
       -choose the subnet that has the lowest third byte: eg if there are both 192.168.1.10 and 192.168.2.10, chooose 129.168.1.10 as the correct one
       -prefer if the address starts with 192.168 (not actually implemented yet)
    """
    addrCandidate = '192.168.0.255'

    listAddr = socket.getaddrinfo(socket.gethostname(), None)
    min_third_byte = 255

    for addr_tuple in listAddr:
        (family, _, _, _, sockaddr) = addr_tuple
        if family == socket.AF_INET:
            # this is IPv4
            print('IP candidate: %s' % sockaddr[0])
            third_byte = int(sockaddr[0].split('.')[2])
            if third_byte <= min_third_byte:
                min_third_byte = third_byte
                addrCandidate = sockaddr[0]
    print('Chosen local IP: %s' % addrCandidate)
    try:
        listAddr = socket.getaddrinfo(socket.gethostname(), None)
        min_third_byte = 255

        for addr_tuple in listAddr:
            (family, _, _, _, sockaddr) = addr_tuple
            if family == socket.AF_INET:
                # this is IPv4
                print('IP candidate: %s' % sockaddr[0])
                third_byte = int(sockaddr[0].split('.')[2])
                if third_byte <= min_third_byte:
                    min_third_byte = third_byte
                    addrCandidate = sockaddr[0]
        print('Chosen local IP: %s' % addrCandidate)

    except:
        print("findMostLikelyLANBroadcastIPAddress():Exception trying to find correct broadcast automatically.")
        #pass

    # Take this machine's IP address and transform into broadcast address for the whole subnet (change last byte to 255)
    addrSplit = addrCandidate.split('.')
    addrSplit[3] = '255'
    strBroadCastAddress = '.'.join(addrSplit)

    print('Chosen broadcast IP: %s' % strBroadCastAddress)

    return strBroadCastAddress