# This makes a container for the gear. Replace the first path next to the second COPY function 
# below with a path to your local compiled matlab function

FROM neurodebian:xenial
MAINTAINER Ozzy(ozenctaskin@hotmail.com)

#Initialize flywheel v0 and move the required files into the container 
ENV FLYWHEEL /flywheel/v0/
RUN mkdir -p ${FLYWHEEL}
COPY manifest.json run ${FLYWHEEL}
COPY invivoTemplate.nii.gz /opt/invivoTemplate.nii.gz
COPY invivoTemplate-WithSkull.nii.gz /opt/invivoTemplate-WithSkull.nii.gz
COPY 2x2x2resampled_invivoTemplate.nii.gz /opt/2x2x2resampled_invivoTemplate.nii.gz
COPY Woofsurfer.zip /opt/Woofsurfer.zip
COPY exvivo_warp_files.zip /opt/exvivo_warp_files.zip
RUN chmod +x /flywheel/v0/run

RUN apt-get update \
    && apt-get install -y build-essential git libexpat1-dev libssl-dev zlib1g-dev \
    libncurses5-dev libbz2-dev liblzma-dev \
    libsqlite3-dev libffi-dev tcl-dev linux-headers-generic libgdbm-dev \
    libreadline-dev tk tk-dev openssl openssl-dev* wget curl
RUN wget https://www.python.org/ftp/python/3.7.8/Python-3.7.8.tgz
RUN tar -xvf Python-3.7.8.tgz
RUN cd Python-3.7.8; ./configure --enable-shared; make; make test; make install

# Steps from here are to enable other libraries in linux to 
# access the shared python libraries.
RUN cd /usr/local/lib/; cp libpython3.so /usr/lib64/; cp libpython3.so /usr/lib; cp libpython3.7m.so.1.0 /usr/lib64/; cp libpython3.7m.so.1.0 /usr/lib/; cd /usr/lib64; ln -s libpython3.7m.so.1.0 libpython3.7m.so; cd /usr/lib; ln -s libpython3.7m.so.1.0 libpython3.7m.so

# Install required packages    
RUN apt-get update \
    && apt-get install -y \
    git \
    python3-pip \
    zip \
    unzip \
    fsl-core \
    ants

# Install python packages
RUN pip3 install --upgrade pip
RUN pip3 install nibabel==2.5.1 matplotlib imageio

# Clone the altAnts    
RUN git clone https://github.com/cookpa/altAntsBrainExtraction.git 
RUN mv altAntsBrainExtraction/* usr/lib/ants/

# Set the entrypoint  
ENTRYPOINT /flywheel/v0/run
