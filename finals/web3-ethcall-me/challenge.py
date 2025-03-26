import socketserver

from ctf_launchers.launcher import Launcher

class Challenge(Launcher):
    def __init__(self, request, client_address, server):
        super().__init__(request, client_address, server, project_location="challenge/contracts")


with socketserver.ThreadingTCPServer(('0.0.0.0', 12014), Challenge) as server:
    server.serve_forever()
