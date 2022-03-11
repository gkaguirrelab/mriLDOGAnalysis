# This makes a container for the gear. Replace the first path next to the second COPY function 
# below with a path to your local compiled matlab function

FROM neurodebian:xenial
MAINTAINER Ozzy(ozenctaskin@hotmail.com)

#Copy everything into a container
ENV FLYWHEEL /flywheel/v0/
RUN mkdir -p ${FLYWHEEL}
COPY manifest.json run ${FLYWHEEL}
RUN chmod +x /flywheel/v0/run
COPY regressMotion/ /opt/regressMotion 
RUN chmod +x /opt/regressMotion/*  

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
    software-properties-common
# Install required packages    
RUN apt-get update \
    && apt-get install -y \
    wget \
    python3-pip \
    zip \
    unzip \
    fsl-core

# Download and install MCR on call
RUN wget https://ssd.mathworks.com/supportfiles/downloads/R2020a/Release/5/deployment_files/installer/complete/glnxa64/MATLAB_Runtime_R2020a_Update_5_glnxa64.zip
RUN mkdir matlabins
RUN unzip MATLAB_Runtime_R2020a_Update_5_glnxa64.zip -d /matlabins/
RUN /matlabins/install -mode silent -agreeToLicense yes

RUN python3.7 -m pip install --upgrade pip
RUN pip install numpy
RUN python3.7 -m pip install 'nibabel==2.5.1' 'numpy==1.18.1'

# Set the entrypoint  
ENTRYPOINT /flywheel/v0/run
