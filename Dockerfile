FROM python:3
COPY ./ .
ENTRYPOINT ["bash", "/entrypoint.sh"]
