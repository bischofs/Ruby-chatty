require 'socket'      # Sockets are in standard library
require 'thread'

host = 'localhost'
port = 1233

s = TCPSocket.open(host, port)


Thread.start() do |clientsock|
  
  while read = s.gets   # Read lines from the socket
    
    puts read.chop      # And print with platform line terminator
  
    
  end

end

  
while line = gets
  s.puts("#{line}")
end

s.close      
