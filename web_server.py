from http.server import SimpleHTTPRequestHandler, HTTPServer
import os

os.chdir("/opt/srv/landing14/")
server = HTTPServer(('0.0.0.0', 8000), SimpleHTTPRequestHandler)
server.serve_forever()
