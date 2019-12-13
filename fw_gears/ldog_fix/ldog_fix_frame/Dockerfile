# This makes a container for the gear. Replace the first path next to the second COPY function 
# below with a path to your local compiled matlab function

FROM ubuntu:latest
MAINTAINER Ozzy(ozenctaskin@hotmail.com)

#Copy everything into a container
ENV FLYWHEEL /flywheel/v0/
RUN mkdir -p ${FLYWHEEL}
COPY manifest.json run ${FLYWHEEL}
RUN chmod +x /flywheel/v0/run
RUN apt-get update -y
RUN apt-get install python3 -y
RUN apt-get install zip unzip -y
    
# Set the entrypoint  
ENTRYPOINT /flywheel/v0/run



