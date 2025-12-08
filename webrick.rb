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

require "erb" # erbをrequireする記述が必要
# erb を使うにはこういった記述が必要。理解する必要はありません。このまま使いましょう。
WEBrick::HTTPServlet::FileHandler.add_handler("erb", WEBrick::HTTPServlet::ERBHandler)
server.config[:MimeTypes]["erb"] = "text/html"
server.mount_proc("/hello") do |req, res|
  template = ERB.new( File.read('hello.erb') )
  # 現在時刻についてはインスタンス変数をここで定義してみるといいかも？
  @now = Time.new
  res.body << template.result( binding )
end

trap(:INT){
    server.shutdown
}

server.start
