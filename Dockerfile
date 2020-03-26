FROM brainlife/freesurfer-with-atlases
RUN apt update -y && apt install -y wget
RUN (cd /opt && \
    wget https://www.dropbox.com/sh/14gkmfsd9v6jsbv/AABXlnWNvLce_vIqiuY1Y7oUa/ENIGMA_shape.tar.gz?dl=0 -O enigma.tgz &&\
    tar zxvf enigma.tgz && \rm enigma.tgz && sed -i s,FS=/home.*,FS=/usr/local/freesurfer/,g ENIGMA_shape/shape_group_run.sh &&\
    sed -i s,runDirectory=.*,runDirectory=/opt/ENIGMA_shape/,g ENIGMA_shape/shape_group_run.sh &&\
    ln -s /opt/ENIGMA_shape/shape_group_run.sh /bin/shape_group_run.sh && chmod 755 /bin/shape_group_run.sh && chmod 755 -R /opt/ENIGMA_shape)
