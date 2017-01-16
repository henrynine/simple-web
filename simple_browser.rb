require 'socket'
require 'json'

def get
  request = "GET /index.html HTTP/1.0\r\n\r\nEND"
  puts (send request)
end

def post
  request = "POST /thanks.html HTTP/1.0\r\n"

  puts "What's the viking's name?"
  name = gets.chomp
  puts "What's the viking's email?"
  email = gets.chomp

  include_in_json = Hash.new
  include_in_json[:viking] = {name: name, email: email}
  json_viking = include_in_json.to_json
  json_size = json_viking.size

  request += "Content-Length: #{json_size}\r\n\r\n"

  request += include_in_json.to_json + "END"
  puts (send request)
end


def send request
  socket = TCPSocket.open('localhost', 2000)
  socket.print(request)
  socket.read
end
