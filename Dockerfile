FROM fedora:25
MAINTAINER radiology-in-the-cloud

RUN mkdir /opt/fnndsc
COPY ["transform.sh", "/opt/fnndsc"]

CMD ["/opt/fnndsc/transform.sh"]
