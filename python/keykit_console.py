import cmd
import sys
import readline  # For history, do not remove
from OSC import OSCClient, OSCMessage, OSCClientError
from socket import gethostname
from time import sleep

# For reply's
from OSC import OSCServer
from threading import Thread

# Constans
from keykit_language import *

################################################
# Attention, the is no passwort protected, etc.
# Non-local IPs open your whole system!
# Be careful and do not shoot you in the foot
################################################

# Default values for connection
PY_CONSOLE_PORT = 3330
PY_CONSOLE_HOSTNAME = "0.0.0.0"

MY_HOSTNAME = "0.0.0.0"  # or
# MY_HOSTNAME = gethostname()  # or
# MY_HOSTNAME = "192.168.X.X"

MY_PROMPT = ''
#MY_PROMPT = 'key> '

# Makes ANSI escape character sequences (for producing colored terminal
# text and cursor positioning) work under MS Windows.
USE_COLORAMA = True

################################################

if USE_COLORAMA:
    from colorama import init, Fore, Back, Style
    init()
    ColorOut = Fore.BLUE
    ColorWarn = Fore.RED
    ColorReset = Style.RESET_ALL
else:
    ColorOut = ""
    ColorWarn = ""
    ColorReset = ""


class KeykitShell(cmd.Cmd):
    intro = '''
    Welcome to the Keykit shell. Type help or ? to list commands.\n
    Connect to local keykit server with 'connect port'
    '''
    # prompt = MY_PROMPT
    prompt = ''
    file = None

    remote_server_adr = (PY_CONSOLE_HOSTNAME, PY_CONSOLE_PORT)
    local_server_adr = (MY_HOSTNAME, PY_CONSOLE_PORT + 1)

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
            warn("Connectiong failed. Invalid port?")

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
            warn("Sending of /target message failed.")

    def emptyline(self):
        """Do nothing on empty input line"""
        pass

    # ----- internal shell commands -----
    def do_connect(self, arg):
        '''Connect to OSC-Server:                       connect [PORT] [HOSTNAME]
        Default PORT: %i
        Default HOSTNAME: %s
        '''
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
        '''Set verbose level variable of pyconsole.k:    verbose [0|1]'''
        try:
            self.client.send(
                OSCMessage("/keykit/pyconsole/verbose", [int(arg)]))
        except OSCClientError:
            warn("Sending failed")

    # Dummy method for entry in help list
    def do_KEYKIT_CMD(self, arg):
        '''Any other cmd will be send to Keykit.        [cmd]'''

    def do_bye(self, arg):
        '''Close keykit shell window and exit:          bye
        It mutes the output of keykit, too.'''
        warn('Quitting keykit shell.')
        # self.send("stopp()")
        self.send("alloff()")
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

    loopVarIdx = 0

    def do_loop(self, arg):
        '''Start test loop to check asynchron beheaviour.'''

        # It is important to use different loop variable names for each call!
        i = chr(65+self.loopVarIdx)
        self.loopVarIdx = (self.loopVarIdx + 1) % 50
        s = '''for ( i%s=0; i%s<20; i%s++) { printf("l");
        for(j%s=0;j%s<i%s;j%s++){printf("o")}; print("p");
        sleeptill(Now+%s) }''' % (i,
                                  i,
                                  i,
                                  i,
                                  i,
                                  i,
                                  i,
                                  "2b")
        s = s.replace("\t", "")
        self.default(s)

    def do_test(self, arg):
        '''Send test commands to keykit backend.'''
        # self.do_loop("")
        self.default("print(\"Send irregular line\")")
        self.default("i = 0/0")

    # ----- Input for osc message -----

    def default(self, line):
        self.send(line)
        # Restore prompt
        sys.stdout.write("%s" % (MY_PROMPT))
        # return False

    def do_help(self, args):
        '''%s'''
        if args == "":
            cmd.Cmd.do_help(self, args)
            # Apend commands with irregular python function names
            print("Further commands")
            print("========================================")
            print("! !! !log ![num]")
        elif args == "!":
            print("List history of Keykit commands.")
        elif args == "!!":
            print("Repeat last Keykit command.")
        elif args == "!log":
            print(
                "Write history of commands into logfile.\n" +
                "The variable Pyconsole_logfile controls the name," +
                "but should ends with .log or .txt.")
        elif args[0] == "!":
            print("![num] Repeat num-th command of history.")
        else:
            cmd.Cmd.do_help(self, args)

    do_help.__doc__ %= (cmd.Cmd.do_help.__doc__)

    def close(self):
        if self.file:
            self.file.close()
            self.file = None
        if(self.client is not None):
            self.client.close()
        if self.server is not None:
            self.server.stop()
            # self.server_thread.join()

    def send(self, s):
        try:
            self.client.send(OSCMessage("/keykit/pyconsole/in", [s]))
        except OSCClientError:
            warn("Sending of '%s' failed" % (s,))

    # methodes for completions:
    def xcomplete(self, text, line, begidx, endidx):
        print("Hey")
        return [i for i in _AVAILABLE_KEYKIT_FUNCTIONS if i.startswith(text)]


# -----------------------------------------
# Server for return of Keykits output.
# (Adaption of Osc server example.)

class Server():

    def __init__(self, server_adr):
        self.server = OSCServer(server_adr)
        self.server.socket.settimeout(3)
        self.run = True
        self.timed_out = False

        # funny python's way to add a method to an instance of a class
        # import types
        # self.server.handle_timeout = types.MethodType(self.handle_timeout, self.server)
        # or
        self.server.handle_timeout = self.handle_timeout

        # Handler
        self.server.addMsgHandler("/quit", self.quit_callback)
        self.server.addMsgHandler("/keykit/pyconsole/out", self.print_callback)
        self.server.addMsgHandler("/keykit/pyconsole/start", self.print_callback)

    def handle_timeout(self, server = None):
        self.timed_out = True

    def each_frame(self):
        # clear timed_out flag
        self.timed_out = False
        # handle all pending requests then return
        while not self.timed_out and self.run:
            self.server.handle_request()
            # Line reached after each socket read
            sleep(.1)

    def start(self):
        # print("Wait on client input...")
        sys.stdout.write("%s" % (MY_PROMPT))
        sys.stdout.flush()
        while self.run:
            self.each_frame()
            # Line reached after each socket timeout
            sleep(1)


    def stop(self):
        self.run = False
        # Invoke shutdown. Socket still wait on timeout...
        try:
            #from socket import Error, SHUT_RDWR
            import socket
            self.server.socket.shutdown(socket.SHUT_RDWR)
        except socket.error:
            pass

        self.server.close()

    # Callbacks
    def quit_callback(self, path, tags, args, source):
        self.run = False

    def print_callback(self, path, tags, args, source):
        current_input = readline.get_line_buffer()

        # Add Tab at every input line
        out = args[0].replace("\n", "\n\t")

        # Delete current input, insert output and add input again.
        # \r : Carriage return, \033[K : Delete everything after the cursor.
        sys.stdout.write("\r\033[K")
        sys.stdout.write(
            "\t%s%s%s\n%s%s" %
            (ColorOut,
             out,
             ColorReset,
             MY_PROMPT,
             current_input))
        sys.stdout.flush()


def warn(s):
    print(ColorWarn+s+ColorReset)

# Setup tab completion
def complete(text, state):
    l = [i for i in KEYKIT_FUNCTIONS if i.startswith(text)]
    l.extend([i for i in KEYKIT_STATEMENTS if i.startswith(text)])
    l.extend([i for i in PYCONSOLE_CONSTANTS if i.startswith(text)])
    if(state < len(l)):
        return l[state]
    return None

readline.parse_and_bind('tab: complete')
readline.set_completer(complete)


if __name__ == '__main__':
    shell = KeykitShell()
    try:
        shell.cmdloop()
    except KeyboardInterrupt:
        warn("Ctrl+C pressed. Quitting keykit shell.")
        shell.close()
    except TypeError:
        warn("Type error. Quitting keykit shell.")
        shell.close()
    finally:
        shell.close()
