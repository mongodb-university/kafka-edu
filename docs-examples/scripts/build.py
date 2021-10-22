import os, fnmatch
import shutil

REPLACE_CONSTANT="MONGODB_KAFKA_CONNECTOR_VERSION"
SRC_DIR = "../source"
BUILD_DIR = "../examples"
UNSUPPORTED_DIR = "../unsupported"
ABS_SRC = os.path.abspath(SRC_DIR)
ABS_UNSUPPORTED = os.path.abspath(UNSUPPORTED_DIR)
NOT_SUPPORTED = None
# v1.3-v1.0 are not supported because v1.4 introduces CDC Handlers
# replace map is constructed from: https://www.confluent.io/hub/mongodb/kafka-connect-mongodb 
REPLACE_MAP = {
    "v1.6": "1.6.1",
    "v1.5": "1.5.1",
    "v1.4": "1.4.0",
    "v1.3": NOT_SUPPORTED,
    "v1.2": NOT_SUPPORTED,
    "v1.1": NOT_SUPPORTED,
    "v1.0": NOT_SUPPORTED
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

def copyPipelineSource(dst, replace):
    destination = shutil.copytree(ABS_SRC, dst) 
    findReplace(dst, REPLACE_CONSTANT, replace, "[Dd]ocker*")

def copyUnsupportedREADME(dst, replace):
    destination = shutil.copytree(ABS_UNSUPPORTED, dst) 
    findReplace(dst, REPLACE_CONSTANT, replace, "README.md")

def generateTutorials():
    try:
        shutil.rmtree(os.path.abspath(BUILD_DIR))
    except FileNotFoundError:
        pass
    for k,v in REPLACE_MAP.items():
        abs_dst = os.path.abspath(os.path.join(BUILD_DIR, k))
        if v is NOT_SUPPORTED:
            copyUnsupportedREADME(abs_dst, k)
        else:
            copyPipelineSource(abs_dst, v)

if __name__ == "__main__":
    generateTutorials()
