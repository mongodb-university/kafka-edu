# Stock Generation app for MongoDB

This application will create sample data -- randomly generated company names, stock symbols, and other information -- and continuously insert it into MongoDB. 

To start generating data into the local MongoDB cluster that is created with the Kafka tutorial, launch the following commmand:

```
docker run --network kafka-edu_localnet stockgenmongo:0.1
```




## Details
The Docker container launches a python application called, "stockgen.py".  This application accepts the following parameters:

| Command line parameter | Description  | Default |
|--|--|--|
|-s  | Number of company symbols  | 5 |
|-c  | MongoDB Connection String  | mongodb://mongo1:27017,mongo2:27018,mongo3:27019/?replicaSet=rs0 |

The company names are generated from reading three text files, adjectives.txt, nouns.text and endings.txt.  You can modify these files to generate more unique names.

