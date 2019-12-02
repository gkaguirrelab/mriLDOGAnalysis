# This makes a container for the gear. Replace the first path next to the second COPY function 
# below with a path to your local compiled matlab function

FROM gkaguirrelab/mri_analyze:v3
MAINTAINER Ozzy(ozenctaskin@hotmail.com)

#Copy everything into a container
ENV FLYWHEEL /flywheel/v0/
RUN mkdir -p ${FLYWHEEL}
COPY manifest.json run ${FLYWHEEL}
COPY invivoTemplate.nii.gz /opt/invivoTemplate.nii.gz
COPY 2x2x2resampled_invivoTemplate.nii.gz /opt/2x2x2resampled_invivoTemplate.nii.gz
RUN chmod +x /flywheel/v0/run
RUN pip3 install pandas
    
# Set the entrypoint  
ENTRYPOINT /flywheel/v0/run



