#!/usr/bin/env python3.5

import http.server
from os import path
import cgi
import os

BASE_PATH = "/shared"

class UploadHandler(http.server.BaseHTTPRequestHandler):
    def extract_jobid(self):
        path_parts = path.split(self.path)
        print("PATH: %s" % repr(path_parts))
        if len(path_parts) != 2 or path_parts[0] != "/" or path_parts[1] == "":
            self.send_not_found("malformed path: should be in the form /jobid")
            return None

        return path_parts[1]

    def extract_jobid_filename(self):
        path_parts = path.split(self.path)

        if len(path_parts) != 2:
            self.send_not_found("malformed path: should be in the form /jobid/filename")
            return None

        if path_parts[0] == "/":
            return (self.extract_jobid(), None)
        else:
            return (path_parts[0][1:], path_parts[1])

    def do_POST(self):
        jobid = self.extract_jobid()
        if jobid is None:
            return None

        content_type, param_dict = cgi.parse_header(self.headers.get('Content-Type'))
        # NB: utf-8 is wrong, IIRC, but close enough
        param_dict['boundary'] = bytes(param_dict['boundary'], 'utf-8')
        if content_type != 'multipart/form-data':
            self.send_bad_request("not multipart")
            return

        formdata = cgi.parse_multipart(self.rfile, param_dict)
        files = formdata.get('filenames', None)
        if files is None:
            self.send_bad_request("no filenames specified")
            return

        contents = {}
        for filename in files:
            filename = str(filename, 'utf-8')
            file_contents = formdata.get(filename, None)
            if file_contents is None:
                self.send_bad_request("missing file for filename %s" % filename)
                return
            contents[filename] = file_contents[0]

        try:
            os.makedirs(path.join(BASE_PATH, jobid), exist_ok=True)
            for name, file_contents in contents.items():
                # TODO: santize path
                full_path = path.join(BASE_PATH, jobid, name)
                with open(full_path, 'wb') as f:
                    f.write(file_contents)
        except:
            # TODO: log this
            self.send_internal_server_error()
            raise
            return

        # TODO: return list of written files
        self.send_response(200, jobid)
        self.end_headers()

    def do_GET(self):
        (jobid, filename) = self.extract_jobid_filename()
        if jobid is None:
            return None
        # TODO: sanatize this
        job_dir = path.join(BASE_PATH, jobid)
        if not path.exists(job_dir):
            return self.send_not_found('no such job %s' % jobid)

        if filename is None:
            try:
                items = os.listdir(job_dir)
                self.send_response(200)
                self.end_headers()
                self.wfile.write("\n".join(items).encode('utf-8'))
            except:
                self.send_internal_error()
                raise
        else:
            full_path = path.join(job_dir, filename)
            if not path.exists(job_dir):
                return self.send_not_found('no such file %s in job %s' % (filename, jobid))

            try:
                self.send_response(200)
                self.send_header('Content-Type', 'application/octect-stream')
                with open(full_path, 'rb') as f:
                    contents = f.read()
                self.send_header('Content-Length', len(contents))
                self.end_headers()
                self.wfile.write(contents)
            except:
                self.send_interal_error()
                raise


    def send_not_found(self, msg=None):
        self.send_response(404, msg)
        self.end_headers()

    def send_bad_request(self, msg=None):
        self.send_response(400, msg)
        self.end_headers()

    def send_internal_error(self, msg=None):
        self.send_response(404, msg)
        self.end_headers()

if __name__ == "__main__":
    s = http.server.HTTPServer(('0.0.0.0', 8675), UploadHandler)
    s.serve_forever()
