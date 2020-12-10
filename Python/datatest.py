import scipy
import glob
import csv
from EVM import EVM


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

def get_array_from_path(glob_path):
    array = None
    for path in glob_path:
        if array:
            array.extend(get_value_lists(get_data(path)))
        else:
            array = get_value_lists(get_data(path))
    return array

def train(evm, pos_name, neg_name, multiple_pos, multiple_neg):
    if multiple_pos:
        positive = get_array_from_path(glob.glob("data/*" + pos_name + ".txt"))
    else:
        positive = get_array_from_path(glob.glob("data/" + pos_name + ".txt"))

    if multiple_neg:
        negative = get_array_from_path(glob.glob("data/*" + neg_name + ".txt"))
    else:
        negative = get_array_from_path(glob.glob("data/" + neg_name + ".txt"))

    evm.train(positives=positive, negatives=negative)

def predict_to_csv(evm, test_dict):
    samples = get_array_from_path(glob.glob("data/" + test_dict["test"] + ".txt"))
    probabilities = []
    for sample in samples:
        probabilities.append(evm.probabilities([sample])[0])

    with open('p'+ test_dict["positive"] + 'n' + test_dict["negative"] + 't' + test_dict["test"] + '.csv', mode='w') as csv_file:
        csv_writer = csv.writer(csv_file, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)
        for probability in probabilities:
            csv_writer.writerow(probability)


test_dict = {}
test_dict["positive"] = "719"
test_dict["negative"] = "sid-580"
test_dict["test"] = "sid-1837"
evm = EVM(tailsize=44, cover_threshold=0.7, distance_function=scipy.spatial.distance.euclidean)
train(evm, test_dict["positive"], test_dict["negative"], True, True)

predict_to_csv(evm, test_dict)



