FROM fedora:25
MAINTAINER radiology-in-the-cloud

RUN mkdir /opt/fnndsc
COPY ["transform.sh", "/opt/fnndsc"]

CMD ["/bin/bash", g"/opt/fnndsc/transform.sh"]
