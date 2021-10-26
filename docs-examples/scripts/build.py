'''Script to build versioned MongoDB Kafka Connector examples'''

import os
import fnmatch
import shutil

REPLACE_CONSTANT="MONGODB_KAFKA_CONNECTOR_VERSION"
SRC_DIR = "../source"
BUILD_DIR = "../examples"
UNSUPPORTED_DIR = "../unsupported"
ABS_SRC = os.path.abspath(SRC_DIR)
ABS_UNSUPPORTED = os.path.abspath(UNSUPPORTED_DIR)
UNSUPPORTED_REPLACE_REGEX = "README.md"
SOURCE_REPLACE_REGEX = "[Dd]ocker*"

IS_SUPPORTED = "is_supported"
CONFLUENT_VERSION = "confluent_hub_version"

# v1.3-v1.0 are not supported because v1.4 introduces CDC Handlers
# replace map constructed from: https://www.confluent.io/hub/mongodb/kafka-connect-mongodb
REPLACE_MAP = {
    "v1.6": {IS_SUPPORTED:True, CONFLUENT_VERSION:"1.6.1"},
    "v1.5": {IS_SUPPORTED:True, CONFLUENT_VERSION:"1.5.1"},
    "v1.4": {IS_SUPPORTED:True, CONFLUENT_VERSION:"1.4.0"},
    "v1.3": {IS_SUPPORTED:False, CONFLUENT_VERSION:None},
    "v1.2": {IS_SUPPORTED:False, CONFLUENT_VERSION:None},
    "v1.1": {IS_SUPPORTED:False, CONFLUENT_VERSION:None},
    "v1.0": {IS_SUPPORTED:False, CONFLUENT_VERSION:None}
}

def recursively_find_replace(directory, find, replace, file_pattern):
    '''Recursively find a string in a directory'''
    for path, _, files in os.walk(os.path.abspath(directory)):
        for filename in fnmatch.filter(files, file_pattern):
            filepath = os.path.join(path, filename)
            with open(filepath, "r", encoding="UTF-8") as f_1:
                file_contents = f_1.read()
            file_contents = file_contents.replace(find, replace)
            with open(filepath, "w", encoding="UTF-8") as f_2:
                f_2.write(file_contents)

def copy_replace_pipeline_source(dst, replace):
    '''copy and replace pipeline source code'''
    shutil.copytree(ABS_SRC, dst)
    recursively_find_replace(dst, REPLACE_CONSTANT, replace, SOURCE_REPLACE_REGEX)

def copy_replace_unsupported_dir(dst, replace):
    '''copy and replace unsupported template'''
    shutil.copytree(ABS_UNSUPPORTED, dst)
    recursively_find_replace(dst, REPLACE_CONSTANT, replace, UNSUPPORTED_REPLACE_REGEX)

def generate_tutorials():
    '''generate docs examples and READMEs for unsupported files'''
    try:
        shutil.rmtree(os.path.abspath(BUILD_DIR))
    except FileNotFoundError:
        pass
    for connector_version, support_dict in REPLACE_MAP.items():
        abs_dst = os.path.abspath(os.path.join(BUILD_DIR, connector_version))
        if support_dict[IS_SUPPORTED]:
            copy_replace_pipeline_source(abs_dst, support_dict[CONFLUENT_VERSION])
        else:
            copy_replace_unsupported_dir(abs_dst, connector_version)

if __name__ == "__main__":
    generate_tutorials()
