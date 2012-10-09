require 'socket'      # Sockets are in standard library
require 'thread'

host = 'localhost'
port = 1233

s = TCPSocket.open(host, port)

while line = s.gets   # Read lines from the socket
  puts line.chop      # And print with platform line terminator
  
  Thread.start(s.accept) do |clientsock|
    while line = gets
      clientsock.puts("#{line}")
    end
  end

end
s.close      
