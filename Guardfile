coffeescript_options = {
  input: 'js',
  output: 'js',
  patterns: [%r{^js/(.+\.(?:coffee|coffee\.md|litcoffee))$}]
}

guard 'coffeescript', coffeescript_options do
  coffeescript_options[:patterns].each { |pattern| watch(pattern) }
end
