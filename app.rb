require 'webrick'

server = WEBrick::HTTPServer.new(Port: 80)
server.mount('/', WEBrick::HTTPServlet::FileHandler, 'book/')

trap("INT") { server.stop } # Stop the server with Ctrl+C
server.start
