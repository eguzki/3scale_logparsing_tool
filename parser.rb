#
APACHE_REGEX = /"(GET|POST|PUT|DELETE|OPTIONS|HEAD) ([^\s]+?) HTTP\/1\.\d{0,1}.+" (\d+)/

# Parse logline
# returns [bool, result]
#
# If could not be parsed:
# [false, nil]
#
# If could be parsed
# [true,
#       {
#       }
def parse(logline)
  parser = logline.scan(APACHE_REGEX)[0]

  if parser.nil?
    # write to stderr not parsed lines
    $stderr.puts logline
    return false, nil
  end

  res = {
    :method     => parser[0],
    :uri_path   => parser[1],
    :code       => parser[2]
  }
  return true, res
end

# Logstats format
# {
#    lines: #num lines
#    failed_lines: #num lines failed
# }
def partial_acc(logstats, parsed, res)
  logstats[:lines] += 1
  if !parsed
    logstats[:failed_lines] += 1
  end
end

def parse_logfile(f)
  init_stats = {
    lines: 0,
    failed_lines: 0
  }

  File.open(f).each_with_object(init_stats) do |line, acc|
    parsed, res = parse line
    partial_acc(acc, parsed, res)
  end
end
