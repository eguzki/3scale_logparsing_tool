#
def percentile(values, percentile)
  values_sorted = values.sort
  k = (percentile * (values_sorted.length - 1) + 1).floor - 1
  f = (percentile * (values_sorted.length - 1) + 1).modulo(1)
  values_sorted[k] + (f * (values_sorted[k + 1] - values_sorted[k]))
end
#
def post_process(res)
  # Compute providers distribution indicators
  providers = res.delete :providers
  providers_pdf = providers.values
  # Sort reverse order. The first providers, the highest hit count
  providers_pdf.sort!.reverse!
  # Compute cumulative distribution function
  providers_cdf = Array.new(providers_pdf.size)
  providers_cdf[0] = providers_pdf[0]
  (providers_pdf.size - 1).times do |i|
    providers_cdf[i + 1] = providers_cdf[i] + providers_pdf[i + 1]
  end
  res[:providers_cdf] = {}
  total_hits = providers_cdf[-1]
  total_num_providers = providers_pdf.size
  [0.5, 0.7, 0.8, 0.9, 0.99].each do |perc|
    perc_index = providers_cdf.index { |val| val.to_f / total_hits > perc }
    # store number of providers, as percentage and total
    res[:providers_cdf][perc] = [perc_index.to_f / total_num_providers, perc_index]
  end

  # Compute service_id per provider distribution indicators
  services_by_providers = res.delete :service_by_provider
  num_serv_by_provider_list = services_by_providers.values.map { |provider| provider.keys.size }
  res[:service_by_provider_cdf] = {}
  [0.5, 0.7, 0.8, 0.9, 0.99].each do |perc|
    res[:service_by_provider_cdf][perc] = percentile(num_serv_by_provider_list, perc)
  end

  # compute num unique service_id's
  res[:unique_services] = num_serv_by_provider_list.inject(:+)

  # compute num app per provider
  app_by_providers = res.delete :app_by_provider
  num_app_by_provider_list = app_by_providers.values.map { |provider| provider.keys.size }
  res[:app_by_provider_cdf] = {}
  [0.5, 0.7, 0.8, 0.9, 0.99].each do |perc|
    res[:app_by_provider_cdf][perc] = percentile(num_app_by_provider_list, perc)
  end

  # compute num unique app_id's
  res[:unique_apps] = num_app_by_provider_list.inject(:+)

  # Compute metric per request distribution indicators
  metrics_by_request = res.delete :metrics
  res[:metrics_by_request_cdf] = {}
  total_reqs = metrics_by_request.values.inject(0, :+)
  [0, 1, 2, 3, 4].each do |n|
    res[:metrics_by_request_cdf][n] = metrics_by_request[n].to_f / total_reqs
  end
end
