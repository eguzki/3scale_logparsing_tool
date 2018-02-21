require 'pp'

# Write results to stdout
def ui(result)
  computable_logs = result[:lines] - result[:failed_lines] - result[:filtered_head]
  failed_parsing = '%.2f' % (result[:failed_lines].to_f/result[:lines]*100)
  filtered_head = '%.2f' % (result[:filtered_head].to_f/result[:lines]*100)
  code_200 = '%.2f' % (result[:status_code_200].to_f/computable_logs*100)
  code_202 = '%.2f' % (result[:status_code_202].to_f/computable_logs*100)
  code_400 = '%.2f' % (result[:status_code_400].to_f/computable_logs*100)
  code_404 = '%.2f' % (result[:status_code_404].to_f/computable_logs*100)
  code_409 = '%.2f' % (result[:status_code_409].to_f/computable_logs*100)
  code_other = '%.2f' % (result[:status_code_other].to_f/computable_logs*100)

  puts '=============== Generic Stats ==================='
  puts "Total lines:\t\t\t #{result[:lines]}"
  puts "Failed parsing:\t\t\t #{failed_parsing}% (#{result[:failed_lines]})"
  puts "Filtered by HEAD method:\t #{filtered_head}% (#{result[:filtered_head]})"
  puts
  puts '=============== HTTP status code Stats =========='
  puts "200 (success):\t\t\t #{code_200}%"
  puts "202 (success):\t\t\t #{code_202}%"
  puts "400:\t\t\t\t #{code_400}%"
  puts "404:\t\t\t\t #{code_404}%"
  puts "409 (unauthorized):\t\t #{code_409}%"
  puts "others:\t\t\t\t #{code_other}%"
  puts
  puts '=============== RAW ============================='
  pp result
end
