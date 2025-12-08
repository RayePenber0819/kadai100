 # webrick.rb
require 'webrick'

server = WEBrick::HTTPServer.new({ 
  :DocumentRoot => './',
  :BindAddress => '127.0.0.1',
  :Port => 8000
})

server.mount_proc("/time") do |req, res|
  # レスポンス内容を出力
  time = Time.now
  jst = Time.at(time, in: "+09:00")
  body = "<html><body>" + jst.to_s + "</body></html>"
  res.status = 200
  res['Content-Type'] = 'text/html'
  res.body = body
end

trap(:INT){
    server.shutdown
}

server.start
