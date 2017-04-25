FROM fnndsc/ubuntu-python3
COPY ./ .
ENTRYPOINT ["bash", "/entrypoint.sh"]
