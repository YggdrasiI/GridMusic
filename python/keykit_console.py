import cmd
import sys
import readline  # For history, do not remove
from OSC import OSCClient, OSCMessage, OSCClientError
from socket import gethostname
from time import sleep

# For reply's
from OSC import OSCServer
from threading import Thread

# Default values for connection
PY_CONSOLE_PORT = 3330
PY_CONSOLE_HOSTNAME = "0.0.0.0"


class KeykitShell(cmd.Cmd):
    intro = '''Welcome to the Keykit shell. Type help or ? to list commands.\n
    Connect to local keykit server with 'connect port'
    '''
    # prompt = 'keykit> '
    prompt = ''
    file = None

    remote_server_adr = (PY_CONSOLE_HOSTNAME, PY_CONSOLE_PORT)
    local_server_adr = (gethostname(), PY_CONSOLE_PORT + 1)

    def __init__(self, *args, **kwargs):
        cmd.Cmd.__init__(self, args, kwargs)
        self.client = None
        self.server = None
        # Start client and server with default values
        self.init()

    def init(self):
        # Client
        if(self.client is not None):
            self.client.close()
        self.client = OSCClient()
        try:
            self.client.connect(self.remote_server_adr)
        except ValueError:
            print("Connectiong failed. Invalid port?")

        # Server
        if self.server is not None:
            self.server.stop()
            self.server_thread.join()
        self.server = Server(self.local_server_adr)
        self.server_thread = Thread(target=self.server.start)
        self.server_thread.start()

        # Inform keykit programm to use this as target
        try:
            self.client.send(OSCMessage("/keykit/pyconsole/target",
                                        list(self.local_server_adr)))
        except OSCClientError:
            print("Sending of /target message failed.")

    # ----- internal shell commands -----
    def do_connect(self, arg):
        '''Connect to OSC-Server:                       connect [PORT] [HOSTNAME]
        Default PORT: %i
        Default HOSTNAME: %s
        '''
        # self.remote_server_adr[1] = int(parse(arg)[0])
        print("Typ: ", type(arg), arg)
        words = arg.split(' ')
        if len(words) > 1:
            self.remote_server_adr = (str(words[1]), int(words[0]))
        elif len(words) > 0:
            self.remote_server_adr = (self.remote_server_adr[0], int(words[0]))

        self.local_server_adr = (
            self.local_server_adr[0],
            self.remote_server_adr[1] + 1)
        self.init()

    do_connect.__doc__ %= (remote_server_adr[1], remote_server_adr[0])

    def do_verbose(self, arg):
        '''Set verbose level of Pyconsole.k:            verbose [0|1]'''
        try:
            self.client.send(
                OSCMessage("/keykit/pyconsole/verbose", [int(arg)]))
        except OSCClientError:
            print("Sending failed")

    # Dummy method for entry in help list
    def do_KEYKIT_COMMAND(self, arg):
        '''Any other cmd will be send to Keykit.        [keykit cmd]'''

    def do_bye(self, arg):
        '''Close keykit shell window and exit:          bye
        It mutes the output of keykit, too.'''
        print('Qutting keykit shell.')
        try:
            # self.client.send(OSCMessage("/keykit/pyconsole/in", ["stop()"]))
            self.client.send(OSCMessage("/keykit/pyconsole/in", ["alloff()"]))
        except OSCClientError:
            print("Sending failed")
        self.close()
        return True
    """
    def do_exit(self, arg):
        'Close keykit shell window and exit:  exit'
        return self.do_bye(arg)

    def do_quit(self, arg):
        'Close keykit shell window and exit:  quit'
        return self.do_bye(arg)
    """

    # ----- Input for osc message -----

    def default(self, line):
        try:
            self.client.send(OSCMessage("/keykit/pyconsole/in", [line]))
        except OSCClientError:
            print("Sending failed")

    def close(self):
        if self.file:
            self.file.close()
            self.file = None
        if(self.client is not None):
            self.client.close()
        if self.server is not None:
            self.server.stop()
            self.server_thread.join()

# -----------------------------------------
# Server for return of Keykits output.


class Server():

    def __init__(self, server_adr):
        self.server = OSCServer(server_adr)
        self.server.timeout = 0
        self.run = True
        self.timed_out = False
        # self.server.handle_timeout = types.MethodType(handle_timeout, server)
        self.server.handle_timeout = self.handle_timeout
        self.server.addMsgHandler("/quit", self.quit_callback)
        self.server.addMsgHandler("/keykit/pyconsole/out", self.print_callback)

    def handle_timeout(self):
        self.timed_out = True

    def each_frame(self):
        # clear timed_out flag
        self.server.timed_out = False
        # handle all pending requests then return
        while not self.server.timed_out and self.run:
            self.server.handle_request()
            sleep(1)

    def start(self):
        while self.run:
            print("Wait on client input...")
            self.each_frame()
            sleep(1)

    def stop(self):
        self.run = False
        self.server.close()

    # Callbacks
    def quit_callback(self, path, tags, args, source):
        self.run = False

    def print_callback(self, path, tags, args, source):
        print("%s%s" % ("\t", args[0]))


def parse(arg):
    'Convert a series of zero or more numbers to an argument tuple'
    return tuple(map(int, arg.split()))

if __name__ == '__main__':
    KeykitShell().cmdloop()
