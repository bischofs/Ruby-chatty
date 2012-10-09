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
    @x = 0

 
  end#init
  
  
  def run  

    while true # main run loop 

      Thread.start(@server.accept) do |clientsock| # create a new thread for each new server.accept where clientsock is the local thread socket variable
        
        clientsock.puts("Type $list to view the connected clients")
        clientsock.puts("Type a handle for a private chat session")
        clientsock.puts("Type #end to end a private chat session")
        clientsock.puts("Default is broadcasting to all available clients")
        clientsock.puts("Type your Handle")
        
        handle = clientsock.gets.chomp 
        
        client = Client.new(handle,clientsock)

        @clientlist.push(client)
        
        clientsock.puts("...Handle saved, Welcome to the server!")
        

        while line = clientsock.gets.chomp # get from the current client
        

          if client.getChatFlag == 0
            
                      
            if line == "$list"
              
              printf("\n")
              
              @clientlist.each_with_index do |n,i| 
                
                temp =  @clientlist[i]
                
                clientsock.puts temp.getHandle 
                clientsock.puts temp.getSockAddr
                
              end #end each loop
                  
            elsif line == "$quit"
              
              clientsock.puts("Leaving the server...")

              
              
              break;


              
            else
              
              @clientlist.each_with_index do |n,i| 
                
                temp = @clientlist[i]
                
                if line == temp.getHandle 
                  
                  @x = i

                  clientsock.puts("Entered chat with #{temp.getHandle}")
                  
                  client.setChatPart(temp.getSock)
                  temp.setChatPart(client.getSock)

                  temp.setChatFlag(1)
                  client.setChatFlag(1)

                end
              end #end each loop
              
              @clientlist.each_with_index do |n,j|

                @clientlist[j].getSock.puts("#{client.getHandle}: #{line}")
 
              end

            end
            
            
          else#in chat session
            
            if line == "$end"
              
              client.setChatFlag(0)
              @clientlist[@x].setChatFlag(0)
              

            else
              chatsock = client.getChatPart
                          
              chatsock.puts("#{client.getHandle}: #{line}")
            end
          
          end
          
          #somewhere close the worker socket

          
        end
        
      end
      
    end


    
  end#run
  
  
  private
  
  
  def broadcast # broadcast to all clients
    
    #    @clientlist.each_with_index do |n,i| 
    
    
    #   end
    
  end
  

end# end server




class Client

  def initialize(handle, sock)
    
    @sock = sock 
    @handle = handle 
    @chatflag = 0
    @chatsock = sock 
 
  end

  def getChatPart

    return @chatsock

  end
  def setChatPart(chatsocket)

    @chatsock = chatsocket

  end
  def getHandle()

    return @handle

  end

  def setChatFlag(num)
    
    @chatflag = num
    
  end
  
  def getChatFlag()
    
    return @chatflag
    
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
    
