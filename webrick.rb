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

server.mount_proc("/form_get") do |req, res|
  template = ERB.new( File.read('form_get.erb') )
  @params = req.query
  @username = req.query["username"]
  @age = req.query["age"]
  res.body = template.result( binding )
end

server.mount_proc("/form_post") do |req, res|
  template = ERB.new( File.read('form_post.erb') )
  @params = req.query
  @username = req.query["username"]
  @age = req.query["age"]
  res.body = template.result( binding )
end

# server.mount_proc("/foods") do |req, res|
#   foods = req.query["foods"]
#   if foods == "fruits"
#     template = ERB.new( File.read('foods_fruits.erb') )
#   elsif foods == "vegetables"
#     template = ERB.new( File.read('foods_vegetables.erb') )
#   else
#     template = ERB.new( File.read('foods_all.erb') )
#   end
#   res.body = template.result( binding )
# end

foods = [
  { id: 1, name: "りんご", category: "fruits", price: "100" },
  { id: 2, name: "バナナ", category: "fruits", price: "100" },
  { id: 3, name: "いちご", category: "fruits", price: "120" },
  { id: 4, name: "トマト", category: "vegetables", price: "120" },
  { id: 5, name: "キャベツ", category: "vegetables", price: "150" },
  { id: 6, name: "レタス", category: "vegetables", price: "150" },
]

server.mount_proc("/foods") do |req, res|
  template = ERB.new( File.read('foods/index.erb') )
  category = req.query["category_selected"]
  pricemin = req.query["pricemin_selected"]
  pricemax = req.query["pricemax_selected"]
  @foods = foods
  if category && category != "all"
    @foods = @foods.select { |food| food[:category] == category }
  end

  if pricemin && pricemin != "all"
    @foods = @foods.select { |food| food[:price] >= pricemin }
  end

  if pricemax && pricemax != "all"
    @foods = @foods.select { |food| food[:price] <= pricemax }
  end
  res.body = template.result( binding )
end

trap(:INT){
    server.shutdown
}

server.start
