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

  api_auth= '%.2f' % (result[:api_transactions_authorize].to_f/computable_logs*100)
  api_oauth_auth = '%.2f' % (result[:api_transactions_oauth_authorize].to_f/computable_logs*100)
  api_authrep = '%.2f' % (result[:api_transactions_authrep].to_f/computable_logs*100)
  api_oauth_authrep = '%.2f' % (result[:api_transactions_oauth_authrep].to_f/computable_logs*100)
  api_transactions = '%.2f' % (result[:api_transactions].to_f/computable_logs*100)
  api_other = '%.2f' % (result[:api_other].to_f/computable_logs*100)

  auth_provider_key = '%.2f' % (result[:authentication_provider_key].to_f/computable_logs*100)
  auth_service_token = '%.2f' % (result[:authentication_service_token].to_f/computable_logs*100)

  puts '=============== Generic Stats ==================='
  puts "Total lines:\t\t\t\t #{result[:lines]}"
  puts "Failed parsing:\t\t\t\t #{failed_parsing}% (#{result[:failed_lines]})"
  puts "Filtered by HEAD method:\t\t #{filtered_head}% (#{result[:filtered_head]})"
  puts
  puts '=============== HTTP status code Stats =========='
  puts "200 (success):\t\t\t\t #{code_200}%"
  puts "202 (success):\t\t\t\t #{code_202}%"
  puts "400:\t\t\t\t\t #{code_400}%"
  puts "404:\t\t\t\t\t #{code_404}%"
  puts "409 (unauthorized):\t\t\t #{code_409}%"
  puts "others:\t\t\t\t\t #{code_other}%"
  puts
  puts '=============== Authentication mode Stats ======='
  puts "provider_key:\t\t\t\t #{auth_provider_key}%"
  puts "service_token:\t\t\t\t #{auth_service_token}%"
  puts
  puts '=============== Endpoint Stats =================='
  puts "/transactions/authorize.xml:\t\t #{api_auth}%"
  puts "/transactions/oauth_authorize.xml:\t #{api_oauth_auth}%"
  puts "/transactions/authrep.xml:\t\t #{api_authrep}%"
  puts "/transactions/oauth_authrep.xml:\t #{api_oauth_authrep}%"
  puts "/transactions.xml:\t\t\t #{api_transactions}%"
  puts "others:\t\t\t\t\t #{api_other}%"
  puts
  puts '=============== RAW ============================='
  pp result
end
