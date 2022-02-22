'''Script to build versioned MongoDB Kafka Connector examples.'''

import os
import fnmatch
import shutil

REPLACE_CONSTANT="MONGODB_KAFKA_CONNECTOR_VERSION"
REPLACE_CONSTANT_ALT="MONGODB_KAFKA_CONNECTOR_VERSION_ALT"
RELATIVE_SRC_DIR = "../source"
RELATIVE_BUILD_DIR = "../examples"
RELATIVE_UNSUPPORTED_DIR = "../unsupported"
SRC_DIR = os.path.abspath(RELATIVE_SRC_DIR)
UNSUPPORTED_DIR = os.path.abspath(RELATIVE_UNSUPPORTED_DIR)
README_UNIX_PATTERN = "README.md"
DOCKER_UNIX_PATTERN = "[Dd]ocker*"

IS_SUPPORTED = "is_supported"
CONFLUENT_VERSION = "confluent_hub_version"

# v1.3-v1.0 are not supported because v1.4 introduces CDC Handlers
# The following dictionary captures connector version information from this website:
# https://www.confluent.io/hub/mongodb/kafka-connect-mongodb
REPLACE_MAP = {
    "v1.7": "1.7.0",
    "v1.6": "1.6.1",
    "v1.5": "1.5.1",
    "v1.4": "1.4.0",
    "v1.3": None,
    "v1.2": None,
    "v1.1": None,
    "v1.0": None
}

def recursively_find_replace(directory, find, replace, file_pattern):
    '''Recursively searches directories for all occurrences of a string and replaces them.'''
    for path, _, files in os.walk(os.path.abspath(directory)):
        for filename in fnmatch.filter(files, file_pattern):
            filepath = os.path.join(path, filename)
            with open(filepath, "r", encoding="UTF-8") as input_file:
                file_contents = input_file.read()
            file_contents = file_contents.replace(find, replace)
            with open(filepath, "w", encoding="UTF-8") as output_file:
                output_file.write(file_contents)

def copy_replace_pipeline_source(dst, replace_confluent, replace_connector):
    '''Copy source directory and replace all occurrences of a string constant with kafka version.'''
    shutil.copytree(SRC_DIR, dst)
    recursively_find_replace(dst, REPLACE_CONSTANT, replace_confluent, DOCKER_UNIX_PATTERN)
    recursively_find_replace(dst, REPLACE_CONSTANT_ALT, replace_connector, README_UNIX_PATTERN)

def copy_replace_unsupported_dir(dst, replace):
    '''Copy unsupported template and replace all occurrences of a string constant with kafka version.'''
    shutil.copytree(UNSUPPORTED_DIR, dst)
    recursively_find_replace(dst, REPLACE_CONSTANT, replace, README_UNIX_PATTERN)

def generate_tutorials():
    '''Generate examples for supported and unsupported versions of the connector.'''
    try:
        shutil.rmtree(os.path.abspath(RELATIVE_BUILD_DIR))
    except FileNotFoundError:
        pass
    for connector_version, confluent_version in REPLACE_MAP.items():
        abs_dst = os.path.abspath(os.path.join(RELATIVE_BUILD_DIR, connector_version))
        if confluent_version:
            copy_replace_pipeline_source(abs_dst, confluent_version, connector_version)
        else:
            copy_replace_unsupported_dir(abs_dst, connector_version)

if __name__ == "__main__":
    generate_tutorials()
