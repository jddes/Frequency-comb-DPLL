import os

# From: http://stackoverflow.com/questions/273192/create-directory-if-it-doesnt-exist-for-file-write
def make_sure_path_exists(path):
    try:
        os.makedirs(path)
    except OSError as exception:
        if exception.errno != errno.EEXIST:
            raise