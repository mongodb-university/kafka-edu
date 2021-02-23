import os
import pymongo
from bson.json_util import dumps
client = pymongo.MongoClient('mongodb://mongo1,mongo2,mongo3')
db = client.get_database(name='Tutorial1')
with db.orders.watch() as stream:
    print('\nChange Stream is opened on the Tutorial1.orders namespace.  Currently watching ...\n\n')
    for change in stream:
        print(dumps(change, indent=2))