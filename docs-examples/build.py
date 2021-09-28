import os, fnmatch
import shutil

REPLACE_CONSTANT="MONGODB_KAFKA_CONNECTOR_VERSION"
SRC_DIR = "source"
BUILD_DIR = "built_examples"
# v1.3 not included in replace map as v1.3 does not include CDC Handler
# replace map was constructed from: https://www.confluent.io/hub/mongodb/kafka-connect-mongodb 
REPLACE_MAP = {
    "v1.6": "1.6.1",
    "v1.5": "1.5.1",
    "v1.4": "1.4.0",
}

#https://stackoverflow.com/questions/4205854/python-way-to-recursively-find-and-replace-string-in-text-files
def findReplace(directory, find, replace, filePattern):
    for path, dirs, files in os.walk(os.path.abspath(directory)):
        for filename in fnmatch.filter(files, filePattern):
            filepath = os.path.join(path, filename)
            with open(filepath) as f:
                s = f.read()
            s = s.replace(find, replace)
            with open(filepath, "w") as f:
                f.write(s)

def copyThenReplace(src, dst, replace):
    destination = shutil.copytree(src, dst) 
    findReplace(dst, REPLACE_CONSTANT, replace, "[Dd]ocker*")

try:
    shutil.rmtree(os.path.join(BUILD_DIR))
except FileNotFoundError:
    pass

for k,v in REPLACE_MAP.items():
    abs_src = os.path.abspath(SRC_DIR)
    abs_dst = os.path.abspath(os.path.join(BUILD_DIR, k))
    copyThenReplace(abs_src, abs_dst, v)
