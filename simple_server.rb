require 'socket'
require 'json'

METHODS = ['GET',
           'HEAD',
           'POST',
           'PUT',
           'DELETE',
           'CONNECT',
           'OPTIONS',
           'TRACE']

BAD_REQUEST = "HTTP/1.0 400 Bad Request\r\n\r\n"
NOT_ALLOWED = "HTTP/1.0 405 Method Not Allowed\r\n\r\n"
NOT_FOUND = "HTTP/1.0 404 Not Found\r\n\r\n"
OK = "HTTP/1.0 200 OK\r\n\r\n"

def get request
  #search for file after GET
  resource_indicator = request.scan(/\/.+ /).first.chomp(' ')
  resource_indicator = resource_indicator[1..-1]#strip slash
  if File.exist?(resource_indicator)
    resource = File.read(resource_indicator)
  else
    return NOT_FOUND
  end
  OK+"Date: #{Time.new}\r\n" + "Content-Type: text/html\r\n\r\n" + resource
end

def post request
  in_json = request.scan(/{.+$/).first
  params = JSON.parse(in_json)['viking']
  yield_replacement = ''
  params.each do |k, v|
    yield_replacement << "<li>#{k}: #{v}</li>\n"
  end

  thanks = File.read('thanks.html')
  thanks.sub("<%= yield %>", yield_replacement)
end

def process request
  method = request[0...request.index(' ')]
  return BAD_REQUEST unless METHODS.include?(method)
  return NOT_ALLOWED unless ["GET", "POST"].include?(method)
  case method
  when "GET" then return (get request)
  when "POST" then return (post request)
  else return 'else in case error'
  end
end

server = TCPServer.open(2000)

loop do
  $/ = "END"
  client = server.accept
  request = client.gets.chomp("END")
  response = process request
  client.puts response
  #client.puts "Closing..."
  client.close
end
