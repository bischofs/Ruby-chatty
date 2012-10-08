require 'socket'  # TCPServer
require 'thread'

class ChatServer
  
  def initialize(port)
  
    @clientlist = Array.new
    @desc = Array.new
    @server = TCPServer.new( "", port )
    @server.setsockopt( Socket::SOL_SOCKET, Socket::SO_REUSEADDR, 1)
    printf("Chatserver started on port %d\n", port)
    @desc.push(@server)
 
  end#init
  
  
  def run  

    while true # main run loop 

      Thread.start(@server.accept) do |clientsock| # create a new thread for each new server.accept where clientsock is the local thread socket variable
        
        clientsock.puts("Type list to view the connected clients and then the handle you want to chat with")
        clientsock.puts("Enter Handle")
        
        handle = clientsock.gets.chomp 
        
        client = Client.new(handle,clientsock)
        @clientlist.push(client)
        
        while line = clientsock.gets.chomp 
          
          if line == "list"
            
            @clientlist.each_with_index do |n,i| 
              
              temp =  @clientlist[i]
              
              clientsock.puts temp.getHandle 
              clientsock.puts temp.getSockAddr
              
            end
          
          elsif line == "quit"
            
            break;
          
          else

            @clientlist.each_with_index do |n,i| 
              
              temp = @clientlist[i]
              
              if line == temp.getHandle

                chat_session(client,temp)

              end
              
            end
            
          end
          
        end
        
      end
    
    end
  
  end#run
  
    
  private
  
  def chat_session( client1,client2 ) #client 1 is intiating 
    
    clientsock1 = client1.getSock
    clientsock2 = client2.getSock
    
    clientsock2.puts("Entering chat session with #{client1.getHandle}") 

    while clientsock1.gets.chomp != "quit" || clientsock2.gets.chomp != "quit" 
      
      clientsock2.puts(clientsock1.gets.chomp)
      clientsock1.puts(clientsock2.gets.chomp)
      
    end
    
    
  end
  
  def broadcast # broadcast to all clients
    
    #    @clientlist.each_with_index do |n,i| 
    
    
    #   end
    
  end
  

end# end server

class Client

  def initialize(handle, sock)
    
    @sock = sock 
    @handle = handle 

  end

  def getHandle()

    return @handle

  end
  
  def getSock()

    return @sock
  end
  
  def getSockAddr()

    return @sock.peeraddr[2]

  end

end
  

def main
  
  serv = ChatServer.new(1233).run #init and run with 1233 as port
  
end 
main
    # Get list of all clients
    # Broadcast to all clients
    # connect to one client
    # begin chat
    # quit chat
    
