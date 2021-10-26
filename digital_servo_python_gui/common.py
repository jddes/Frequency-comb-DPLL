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

def test_findMostLikelyLANBroadcastIPAddress():
    ipv4Addresses = ["192.168.2.10", "192.168.1.10", "10.1.1.25"]
    assert(findMostLikelyLANBroadcastIPAddress_inner(ipv4Addresses) == "192.168.1.255")

def findMostLikelyLANBroadcastIPAddress():
    """ list all possible IPv4 addresses and choose the most likely candidate for the subnet on which the red pitaya is
    heuristics used:
       -choose the subnet that has the lowest third byte: eg if there are both 192.168.1.10 and 192.168.2.10, chooose 129.168.1.10 as the correct one
       -prefer if the address starts with 192.168 (not actually implemented yet)
    """
    listAddr = socket.getaddrinfo(socket.gethostname(), None)
    ipv4Addresses = [sockaddr[0] for (family, _, _, _, sockaddr) in listAddr if family == socket.AF_INET]
    return findMostLikelyLANBroadcastIPAddress_inner(ipv4Addresses)

def findMostLikelyLANBroadcastIPAddress_inner(ipv4Addresses):

    # move addresses that start with 192.168.x.y at the top of the list:
    priorityList    = [ip for ip in ipv4Addresses if ip.startswith('192.168')]
    nonPriorityList = [ip for ip in ipv4Addresses if not ip.startswith('192.168')]

    # sort according to third byte's value:
    third_bytes_value = lambda x: int(x.split('.')[2])
    priorityList.sort(   key = third_bytes_value)
    nonPriorityList.sort(key = third_bytes_value)
    fullList = priorityList + nonPriorityList

    for ip in fullList:
        print('IP candidate: %s' % ip)

    addrCandidate = fullList[0]
    print('Chosen local IP: %s' % addrCandidate)


    # Take this machine's IP address and transform into broadcast address for the whole subnet (change last byte to 255)
    addrSplit = addrCandidate.split('.')
    addrSplit[3] = '255'
    strBroadCastAddress = '.'.join(addrSplit)

    print('Chosen broadcast IP: %s' % strBroadCastAddress)

    return strBroadCastAddress

if __name__ == '__main__':
    test_findMostLikelyLANBroadcastIPAddress()
