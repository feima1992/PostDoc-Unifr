# %% collection of basic functions
import os
import re
# %% search_file
def search_file(top_dir, include_strs=[], exclude_strs=[]):
    '''
    search all files inside a top dir

    Parameters
    ----------
    top_dir : string
        path string of top dir.
    include_strs : list of string, optional
        include strings, output should match all of them. The default is [].
    exclude_strs : list of string, optional
        exclude strings, output should not match any of them. The default is [].

    Returns
    -------
    file_list : list
        list containning paths to access the matched files.

    '''
    file_list = []
    for root, dirs, files in os.walk(top_dir, followlinks=True):
        for file in files:
            full_path = os.path.abspath(os.path.join(root, file))
            if all(map(lambda x: re.findall(x, full_path), include_strs)):
                file_list.append(full_path)
    for exclude_str in exclude_strs:
        file_list = list(filter(lambda file_name: not re.findall(
            exclude_str, file_name), file_list))
    return file_list