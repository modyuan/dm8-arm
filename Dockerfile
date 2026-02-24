FROM macrosan/kylin:v10-sp1 AS base

# After the installation is complete, you can delete the image to reduce its size
# BUILD_VERSION is 03134284458-20251113-301923-20178
# raw install package is dm8_20251114_HWarm920_kylin10_sp1_64.zip
ARG INSTALL_FILE="DMInstall.bin"

ENV DM_HOME=/opt/dmdbms/bin \
  SOFT_DIR=/soft \
  INSTALL_DIR=/opt/dmdbms \
  DATA_DIR=/opt/data \
  CONFIG_XML="db_install.xml" \
  CREATE_DB_FILE="db_instance.sh" 
ENV PATH=$PATH:$DM_HOME \
  LD_LIBRARY_PATH=$DM_HOME
   
# Add the installation file and configuration file to build the image
RUN mkdir /soft && mkdir /opt/dmdbms && groupadd -g 12349 dinstall && useradd -u 12345 -g dinstall -m -d /home/dmdba -s /bin/bash dmdba

COPY $INSTALL_FILE $CONFIG_XML $CREATE_DB_FILE  $SOFT_DIR/

# install db soft without init db instacne
# fix log4j.xml problem
RUN chmod a+x /soft/$INSTALL_FILE /soft/$CREATE_DB_FILE && \
    /soft/$INSTALL_FILE -q /soft/$CONFIG_XML && \
    rm -rf /soft/$INSTALL_FILE

RUN mkdir $DATA_DIR && chown dmdba:dinstall $DATA_DIR -R
WORKDIR /opt/dmdbms/bin

#defalut startup dmdb
CMD  ["/soft/db_instance.sh"]

