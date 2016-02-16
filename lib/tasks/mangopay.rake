namespace :mangopay do
  desc 'Creates the hooks where mangopay will notify for especific events'
  task deploy_hooks: :environment do
    current_endpoints = MangoPay::Hook.fetch

    base_url = AppConfiguration.for(:deskspotting).base_url
    base_endpoints = [
      { event_type: "PAYIN_NORMAL_SUCCEEDED", endpoint_url: "payin_succeeded" },
      { event_type: "PAYIN_NORMAL_FAILED", endpoint_url: "payin_failed" },
      { event_type: "PAYOUT_NORMAL_SUCCEEDED", endpoint_url: "payout_succeeded" },
      { event_type: "PAYOUT_NORMAL_FAILED", endpoint_url: "payout_failed" },
      { event_type: "PAYOUT_REFUND_SUCCEEDED", endpoint_url: "refund_succeeded" },
      { event_type: "PAYOUT_REFUND_FAILED", endpoint_url: "refund_failed" }
    ].freeze

    base_endpoints.each do |ss|
      hook = current_endpoints.select { |s| s["EventType"] == ss[:event_type] }.first
      url = "#{base_url}/api/v1/mangopay/#{ss[:endpoint_url]}"

      if !hook
        MangoPay::Hook.create(Url: url, EventType: ss[:event_type])
        puts "#{ss[:event_type]} created with url: #{url}"
      elsif url != hook["Url"]
        MangoPay::Hook.update(hook["Id"], Url: url)
        puts "#{ss[:event_type]} updated with url: #{url} (was #{hook['Url']})"
      else
        puts "#{ss[:event_type]} already up-to-date with url: #{url}"
      end
    end
  end
end
