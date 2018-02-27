#
COUNTER_STATS = %i[
  lines
  failed_lines
  status_code_200
  status_code_202
  status_code_400
  status_code_404
  status_code_409
  status_code_other
  filtered_head
  api_transactions_authorize
  api_transactions_oauth_authorize
  api_transactions_authrep
  api_transactions_oauth_authrep
  api_transactions
  api_other
  app_by_user_key
  app_by_app_id
  app_with_app_key
  authentication_provider_key
  authentication_service_token
  service_id_default
  service_id_as_param
  code_reported
].freeze
# Reduce phase
def reduce_logstats(logstats)
  # Add all counters
  result = {
    providers: {},
    service_by_provider: {},
    metrics: {}
  }
  logstats.each_with_object(result) do |new_res, acc|
    acc.merge!(new_res.select { |key, _| COUNTER_STATS.include? key }) { |_, v1, v2| v1 + v2 }
    acc[:providers].merge!(new_res[:providers]) { |_, v1, v2| v1 + v2 }
    acc[:service_by_provider].merge!(new_res[:service_by_provider]) { |_, v1, v2| v1.merge(v2) }
    acc[:metrics].merge!(new_res[:metrics]) { |_, v1, v2| v1 + v2 }
  end
end
