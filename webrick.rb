 # webrick.rb
require 'webrick'

server = WEBrick::HTTPServer.new({ 
  :DocumentRoot => './',
  :BindAddress => '127.0.0.1',
  :Port => 8000
})

class UsersServlet < WEBrick::HTTPServlet::AbstractServlet
  def do_GET(request, response)
    response.status = 200
    response['Content-Type'] = 'text/plain'

    response.body = <<<EOF
    <ul>
      <li>太郎</li>
      <li>次郎</li>
      <li>三郎</li>
    </ul>
    EOF;
  end
end

server.mount('./users', UsersServlet)

trap(:INT){
    server.shutdown
}

server.start
