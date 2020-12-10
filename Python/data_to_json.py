import glob
import json

def get_data(filename):
    s = open(filename, 'r').read()
    splitted = s.split()

    head = splitted[0]
    data_matrix = []
    data_row = {}
    for value in splitted:
        if value == head:
            if data_row:
                data_matrix.append(data_row)
                data_row = {}
        else:
            splitted_value = value.split(':')
            data_row.update({int(splitted_value[0]) : float(splitted_value[1])})

    data_matrix.append(data_row)
    return data_matrix

def get_value_lists(data):
    lists = []
    for row in data:
        lists.append(list(row.values()))

    return lists

def get_sitution(filename):
    return filename[5:8]

def get_id(filename):
    return filename[9:-4]

path = glob.glob("data/*.txt")
data_list = []
for file in path:
    data_dict = {}
    data_dict["situation"] = get_sitution(file)
    data_dict["id"] = get_id(file)
    data_dict["data"] = get_value_lists(get_data(file))
    data_list.append(data_dict)

with open("data.json", 'w') as outfile:
    json.dump(data_list, outfile)