namespace :mangopay do
  desc 'Creates the hooks where mangopay will notify for especific events'
  task create_hooks: :environment do
    base_url = AppConfiguration.for(:deskspotting).base_url

    begin
      MangoPay::Hook.create(Url: "#{base_url}/api/v1/payin_succeeded",
                            EventType: "PAYIN_NORMAL_SUCCEEDED")
      puts "Succeeded hook created"
    rescue MangoPay::ResponseError => e
      previous_url = MangoPay::Hook.fetch.select do |h|
        h["EventType"] == "PAYIN_NORMAL_SUCCEEDED"
      end.first["Url"]
      puts "Succeeded hook already exists for url: #{previous_url} and yours is: #{base_url}/api/v1/payin_succeeded"
    end

    begin
      MangoPay::Hook.create(Url: "#{base_url}/api/v1/payin_failed",
                            EventType: "PAYIN_NORMAL_FAILED")
      puts "Failed hook created"
    rescue MangoPay::ResponseError => e
      previous_url = MangoPay::Hook.fetch.select do |h|
        h["EventType"] == "PAYIN_NORMAL_FAILED"
      end.first["Url"]
      puts "Failed hook already exists for url: #{previous_url} and yours is: #{base_url}/api/v1/payin_failed"
    end
  end
end
