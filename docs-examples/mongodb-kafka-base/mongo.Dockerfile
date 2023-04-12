FROM mongo:6.0.5

COPY config-replica.js /
COPY .bashrc /data/db/.bashrc
COPY requirements.txt /
RUN mkdir /scratch_space
ADD change_streams /tutorials/change_streams
ADD source_connector /tutorials/source_connector
ADD sink_connector /tutorials/sink_connector
ADD cdc_handler /tutorials/cdc_handler
ADD time_series /tutorials/time_series
ADD utils /usr/local/bin
RUN chmod +x /usr/local/bin/cx
RUN chmod +x /usr/local/bin/del
RUN chmod +x /usr/local/bin/kc
RUN chmod +x /usr/local/bin/status

RUN apt-get -y update
RUN apt-get -y upgrade
RUN apt-get install -y --no-install-recommends apt-utils
RUN apt-get install -y curl
RUN apt-get install -y python3-pip
RUN apt-get install -y nano
RUN apt-get install -y bsdmainutils
RUN apt-get install -y kafkacat
RUN apt-get install -y git
RUN apt-get install -y dos2unix
RUN git clone https://github.com/RWaltersMA/stockgenmongo.git


RUN dos2unix /usr/local/bin/*
RUN dos2unix /data/db/.bashrc
RUN pip3 install -r /requirements.txt
RUN pip3 install -r /stockgenmongo/requirements.txt
