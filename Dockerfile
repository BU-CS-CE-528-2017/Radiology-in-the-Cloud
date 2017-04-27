FROM fnndsc/ubuntu-python3
COPY ./ .
ENTRYPOINT ["/server.py"]
