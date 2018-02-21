#
COUNTER_STATS = [
  :lines,
  :failed_lines,
  :status_code_200,
  :status_code_202,
  :status_code_400,
  :status_code_404,
  :status_code_409,
  :status_code_other,
  :filtered_head,
  :api_transactions_authorize,
  :api_transactions_oauth_authorize,
  :api_transactions_authrep,
  :api_transactions_oauth_authrep,
  :api_transactions,
  :api_other,
  :app_by_user_key,
  :app_by_app_id,
  :app_with_app_key,
  :authentication_provider_key,
  :authentication_service_token,
]
# Reduce phase
def reduce_logstats(logstats)
  # Add all counters
  result = {providers: {}}
  logstats.each_with_object(result) do |new_res, acc|
    acc.merge!(new_res.select{ |key,_| COUNTER_STATS.include? key }) { |key, v1, v2| v1 + v2 }
    acc[:providers].merge!(new_res[:providers]) { |key, v1, v2| v1 + v2 }
  end
end
