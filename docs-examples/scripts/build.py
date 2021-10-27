'''Script to build versioned MongoDB Kafka Connector examples.'''

import os
import fnmatch
import shutil

REPLACE_CONSTANT="MONGODB_KAFKA_CONNECTOR_VERSION"
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
    "v1.6": {IS_SUPPORTED:True, CONFLUENT_VERSION:"1.6.1"},
    "v1.5": {IS_SUPPORTED:True, CONFLUENT_VERSION:"1.5.1"},
    "v1.4": {IS_SUPPORTED:True, CONFLUENT_VERSION:"1.4.0"},
    "v1.3": {IS_SUPPORTED:False, CONFLUENT_VERSION:"1.3.0"},
    "v1.2": {IS_SUPPORTED:False, CONFLUENT_VERSION:"1.2.0"},
    "v1.1": {IS_SUPPORTED:False, CONFLUENT_VERSION:"1.1.0"},
    "v1.0": {IS_SUPPORTED:False, CONFLUENT_VERSION:None}
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

def copy_replace_pipeline_source(dst, replace):
    '''Copy pipeline source and replace a string constant.'''
    shutil.copytree(SRC_DIR, dst)
    recursively_find_replace(dst, REPLACE_CONSTANT, replace, DOCKER_UNIX_PATTERN)

def copy_replace_unsupported_dir(dst, replace):
    '''Copy unsupported template and replace a string constant.'''
    shutil.copytree(UNSUPPORTED_DIR, dst)
    recursively_find_replace(dst, REPLACE_CONSTANT, replace, README_UNIX_PATTERN)

def generate_tutorials():
    '''Generate examples for supported and unsupported versions of the connector.'''
    try:
        shutil.rmtree(os.path.abspath(RELATIVE_BUILD_DIR))
    except FileNotFoundError:
        pass
    for connector_version, support_dict in REPLACE_MAP.items():
        abs_dst = os.path.abspath(os.path.join(RELATIVE_BUILD_DIR, connector_version))
        if support_dict[IS_SUPPORTED]:
            copy_replace_pipeline_source(abs_dst, support_dict[CONFLUENT_VERSION])
        else:
            copy_replace_unsupported_dir(abs_dst, connector_version)

if __name__ == "__main__":
    generate_tutorials()
