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
end
