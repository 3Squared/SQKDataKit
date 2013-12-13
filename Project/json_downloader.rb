require 'open-uri'
require 'json'
require 'pp'

all_commits = []

url = "https://api.github.com/repos/torvalds/linux/commits"
token = "62ace8411c371516ebb3f237cfec017312a2bc2a"

500.times do |n|
	puts n+1
	open(url, "Authorization" => "token #{token}") do |f| 
		link_str = f.meta['link']
		url = link_str.match(/<(.*)>; rel=\"next\", <(.*)>; rel=\"first\"/i).captures[0]
		# pp link_value
		commits = JSON.parse(f.read)
		all_commits = all_commits + commits

	end
end

File.open("data.json","w") do |f|
  f.write(all_commits.to_json)
end