[ 'version', 'record', 'common', 'company', 'ci' ].each do |file|
  require "rs_service_now/#{file}"
end

module RsServiceNow

end
