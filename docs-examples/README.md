# Example Pipelines used in MongoDB Kafka Connector Documentation

Edit the files in the `source` directory. Do not edit files in the `examples` directory directly. Use the `build.py` script to generate the `examples` directory
from the `source` directory.

To build the `examples` directory, run the following commands from within the
`docs-examples/scripts` directory:

    pip install pipenv

    pipenv run python build.py
