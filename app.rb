require 'webrick'

server = WEBrick::HTTPServer.new(Port: 9876)
server.mount('/', WEBrick::HTTPServlet::FileHandler, 'book/')

trap("INT") { server.stop } # Stop the server with Ctrl+C
server.start
