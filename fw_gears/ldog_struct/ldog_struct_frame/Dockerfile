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
RUN chmod +x /flywheel/v0/run

# Install required packages    
RUN apt-get update \
    && apt-get install -y \
    git \
    python3 \
    python3-pip \
    zip \
    unzip \
    fsl-core \
    ants

# Install python packages
RUN pip3 install --upgrade pip
RUN pip3 install nibabel matplotlib imageio

# Clone the altAnts    
RUN git clone https://github.com/cookpa/altAntsBrainExtraction.git 
RUN mv altAntsBrainExtraction/* usr/lib/ants/

# Set the entrypoint  
ENTRYPOINT /flywheel/v0/run



