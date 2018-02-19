
def reduce_logstats(logstats)
  init_stats = {
    lines: 0,
    failed_lines: 0
  }
  reduced_stats = logstats.each_with_object(init_stats) do |new_res, acc|
    acc[:lines] += new_res[:lines]
    acc[:failed_lines] += new_res[:failed_lines]
  end
  puts reduced_stats
end
