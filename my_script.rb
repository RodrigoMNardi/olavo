require 'yaml'

x = YAML.load_file('./actions.yml')
puts x.inspect
file = "class Action\n"
x.each_pair do |method, code|
  file += "def #{method}\n"
  file += code
  file += "end\n"
end
file += "end\n"

#puts file

File.open('lib/actions.rb', 'w'){|f| f.write(file)}

require 'lib/actions.rb'
Action.new