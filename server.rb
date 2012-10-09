#TCP SERVER
#Steve Bischoff
#Candace Gordon
#Jason Terpstra

require 'socket'  # TCPServer
require 'thread'

class ChatServer
  

  def initialize(port)
  
    @clientlist = Array.new
    @grouplist = Array.new
   
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
        clientsock.puts("Type $end to end a private chat session")
        clientsock.puts("Type $quit to leave the server")
        clientsock.puts("Type $add to add a group, $groups to list")
        clientsock.puts("Type a group name to join a group")
        clientsock.puts("Default is broadcasting to all available clients")
        clientsock.puts("Type your Handle")
        
        handle = clientsock.gets.chomp 
        
        client = Client.new(handle,clientsock)

        @clientlist.push(client)
        
        
        clientsock.puts("...Handle saved, Welcome to the server!")

        

        while line = clientsock.gets.chomp # get from the current client
        

          if client.getChatFlag == 0
            
                      
            if line == "-list"
              
              
              @clientlist.each_with_index do |n,i| 
                
                temp =  @clientlist[i]
                
                clientsock.puts temp.getHandle 
                clientsock.puts temp.getSockAddr
                
              end #end each loop
                  
            elsif line == "-quit"
              
              clientsock.puts("Leaving the server...")

              @clientlist.each_with_index do |n,k|
                
                if @clientlist[k].getHandle == client.getHandle
                  
                  @clientlist.delete_at(k)
                  

                end
                
              end

              break
              
            elsif line == "-add"
              
              clientsock.puts("What is the name of the new group?")
              
              gname = clientsock.gets.chomp 
              
              @grouplist.push(Group.new(gname))

              clientsock.puts("Group #{gname} added")

            elsif line == "-join"              

              clientsock.puts("Which group would you like to join?")
              
              gname = clientsock.gets.chomp 
              
              @grouplist.each_with_index do |n,p| #check for group name 
                
                group = @grouplist[p]
                
                if gname == group.getName
                  
                  group.add(client)
                  
                  client.setGroup(gname)

                  clientsock.puts("#{client.getHandle} joined group #{group.getName}")
                  
                end
             
              end

            elsif line == "-msg"
 
              if client.getGflag == 0
                
                  clientsock.puts("You are not in a group")

              else
                
                @grouplist.each_with_index do |n,r| #check for group name 
                  
                  clientsock.printf("Group Broadcast: ")
              
                  line = clientsock.gets.chomp                   

                  if client.getGroup == @grouplist[r].getName
                    
                    @grouplist[r].broadcast(line,client.getHandle)
                    
                  end

                end
                    
              end

            elsif line == "-groups"
              
              @grouplist.each_with_index do |n,m| 
              
                group = @grouplist[m]
                
                clientsock.puts  group.getName
                group.printClients(clientsock)
                
              end
              
            else
              
              @clientlist.each_with_index do |n,i| #check for client name
                
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
            
            
            if line == "-end"
              
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
  
  
  
  

end# end server

class Group
  
  def initialize(name)
    @name = name
    @clist = Array.new
     
  end
  
  def add(client)

    @clist.push(client)

  end
  def getName
    
    return @name
    
  end
  def printClients(csock)

    @clist.each_with_index do |n,o|
      
      csock.puts @clist[o].getHandle 
    
    end

  end
  def broadcast(line,handle)
    
    @clist.each_with_index do |n,q|
      
      csock =  @clist[q].getSock
     
      csock.puts("#{handle}: #{line}")
      
    end
    
  end


end


class Client

  def initialize(handle, sock)
    
    @sock = sock 
    @handle = handle 
    @chatflag = 0
    @chatsock = sock 
    @gflag=0
 
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

 
  def setGroup(name)
    @gflag = 1
    @group = name
    
  end
  
  def getGroup()
    
    return @group
    
  end

  def getGflag()

    return @gflag
    
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
    
