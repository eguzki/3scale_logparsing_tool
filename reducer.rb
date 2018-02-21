# Reduce phase
def reduce_logstats(logstats)
  logstats.each_with_object({}) do |new_res, acc|
    acc.merge!(new_res) { |key, v1, v2| v1 + v2 }
  end
end
