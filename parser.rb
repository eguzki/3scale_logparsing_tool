require 'uri'
require 'cgi'

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
#         method: HTTP method
#         uri_path: HTTP uri path and querystring
#         code: HTTP status code
#       }
def parse(logline)
  parser = logline.scan(APACHE_REGEX)[0]

  if parser.nil?
    # write to stderr not parsed lines
    $stderr.puts logline
    return false, nil
  end

  res = {
    method: parser[0],
    uri_path: parser[1],
    code: parser[2].to_i
  }
  [true, res]
end

# Pre-reduce phase
def partial_acc(logstats, res)
  # filter HEAD reqs from stats
  if res[:method] == 'HEAD'.freeze
    logstats[:filtered_head] += 1
    return
  end

  uri = URI.parse res[:uri_path]
  if uri.path.include? '/transactions/authorize.xml'
    logstats[:api_transactions_authorize] += 1
  elsif uri.path.include? '/transactions/oauth_authorize.xml'
    logstats[:api_transactions_oauth_authorize] += 1
  elsif uri.path.include? '/transactions/authrep.xml'
    logstats[:api_transactions_authrep] += 1
  elsif uri.path.include? '/transactions/oauth_authrep.xml'
    logstats[:api_transactions_oauth_authrep] += 1
  elsif uri.path.include? '/transactions.xml'
    logstats[:api_transactions] += 1
  else
    logstats[:api_other] += 1
  end

  if res[:code] == 200
    logstats[:status_code_200] += 1
  elsif res[:code] == 202
    logstats[:status_code_202] += 1
  elsif res[:code] == 400
    logstats[:status_code_400] += 1
  elsif res[:code] == 404
    logstats[:status_code_404] += 1
  elsif res[:code] == 409
    logstats[:status_code_409] += 1
  else
    logstats[:status_code_other] += 1
  end

  return if uri.query.nil?

  params = CGI.parse(uri.query)
  if params.key? 'provider_key'
    logstats[:authentication_provider_key] += 1

    # provider_key distribution data
    # Assuming provider_key is used in 90% of the requests,
    # compute counter for each provider_key as client distribution
    provider_key = params['provider_key']
    provider_key.is_a?(Array) && provider_key = provider_key[0]
    logstats[:providers].key?(provider_key) || logstats[:providers][provider_key] = 0
    logstats[:providers][provider_key] += 1

    # service_id distribution by provider_key
    logstats[:service_by_provider].key?(provider_key) || logstats[:service_by_provider][provider_key] = {}
    if params.key? 'service_id'
      service_id = params['service_id']
      service_id.is_a?(Array) && service_id = service_id[0]
      logstats[:service_by_provider][provider_key][service_id] = nil
    else
      # default service_id, unknown without checking from DB.
      logstats[:service_by_provider][provider_key]['default'] = nil
    end

    # metric distribution by provider_key
    if uri.path.include? '/transactions/authrep.xml'
      num_metrics = params.keys.count { |x| x.start_with?('usage') }
      logstats[:metrics].key?(num_metrics) || logstats[:metrics][num_metrics] = 0
      logstats[:metrics][num_metrics] += 1
    end

    # app_id/user_key distribution by provider_key
    # Let's assume user_key and app_id are the same
    logstats[:app_by_provider].key?(provider_key) || logstats[:app_by_provider][provider_key] = {}
    if params.key? 'user_key'
      logstats[:app_by_provider][provider_key][params['user_key']] = nil
    elsif params.key? 'app_id'
      logstats[:app_by_provider][provider_key][params['app_id']] = nil
    end
  end

  if params.key? 'service_id'
    logstats[:service_id_as_param] += 1
  else
    logstats[:service_id_default] += 1
  end

  params.key?('service_token') && logstats[:authentication_service_token] += 1

  # app identification
  if params.key? 'user_key'
    logstats[:app_by_user_key] += 1
  elsif params.key? 'app_id'
    logstats[:app_by_app_id] += 1
  end

  params.key?('app_key') && logstats[:app_with_app_key] += 1
  params.key?('log[code]') && logstats[:code_reported] += 1
end

def parse_logfile(f)
  # Logstats format
  init_stats = {
    lines: 0,
    failed_lines: 0,
    status_code_200: 0,
    status_code_202: 0,
    status_code_400: 0,
    status_code_404: 0,
    status_code_409: 0,
    status_code_other: 0,
    filtered_head: 0,
    api_transactions_authorize: 0,
    api_transactions_oauth_authorize: 0,
    api_transactions_authrep: 0,
    api_transactions_oauth_authrep: 0,
    api_transactions: 0,
    api_other: 0,
    app_by_user_key: 0,
    app_by_app_id: 0,
    app_with_app_key: 0,
    authentication_provider_key: 0,
    authentication_service_token: 0,
    service_id_default: 0,
    service_id_as_param: 0,
    code_reported: 0,
    providers: {},
    service_by_provider: {},
    app_by_provider: {},
    metrics: {}
  }

  File.open(f).each_with_object(init_stats) do |line, acc|
    parsed, res = parse line
    acc[:lines] += 1
    if !parsed
      acc[:failed_lines] += 1
    else
      partial_acc(acc, res)
    end
  end
end
