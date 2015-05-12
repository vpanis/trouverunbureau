namespace :mangopay do
  desc 'Creates the hooks where mangopay will notify for especific events'
  task create_hooks: :environment do
    base_url = AppConfiguration.for(:deskspotting).base_url

    begin
      MangoPay::Hook.create(Url: "#{base_url}/api/v1/payin_succeeded",
                            EventType: "PAYIN_NORMAL_SUCCEEDED")
      puts "Payin Succeeded hook created"
    rescue MangoPay::ResponseError => e
      previous_url = MangoPay::Hook.fetch.select do |h|
        h["EventType"] == "PAYIN_NORMAL_SUCCEEDED"
      end.first["Url"]
      puts "Succeeded hook already exists for url: #{previous_url} and yours is: #{base_url}/api/v1/payin_succeeded"
    end

    begin
      MangoPay::Hook.create(Url: "#{base_url}/api/v1/payin_failed",
                            EventType: "PAYIN_NORMAL_FAILED")
      puts "Payin Failed hook created"
    rescue MangoPay::ResponseError => e
      previous_url = MangoPay::Hook.fetch.select do |h|
        h["EventType"] == "PAYIN_NORMAL_FAILED"
      end.first["Url"]
      puts "Failed hook already exists for url: #{previous_url} and yours is: #{base_url}/api/v1/payin_failed"
    end

    begin
      MangoPay::Hook.create(Url: "#{base_url}/api/v1/payout_succeeded",
                            EventType: "PAYOUT_NORMAL_SUCCEEDED")
      puts "Payout Succeeded hook created"
    rescue MangoPay::ResponseError => e
      previous_url = MangoPay::Hook.fetch.select do |h|
        h["EventType"] == "PAYOUT_NORMAL_SUCCEEDED"
      end.first["Url"]
      puts "Succeeded hook already exists for url: #{previous_url} and yours is: #{base_url}/api/v1/payout_succeeded"
    end

    begin
      MangoPay::Hook.create(Url: "#{base_url}/api/v1/payout_failed",
                            EventType: "PAYOUT_NORMAL_FAILED")
      puts "Payout Failed hook created"
    rescue MangoPay::ResponseError => e
      previous_url = MangoPay::Hook.fetch.select do |h|
        h["EventType"] == "PAYOUT_NORMAL_FAILED"
      end.first["Url"]
      puts "Failed hook already exists for url: #{previous_url} and yours is: #{base_url}/api/v1/payout_failed"
    end

    begin
      MangoPay::Hook.create(Url: "#{base_url}/api/v1/refund_succeeded",
                            EventType: "PAYOUT_REFUND_SUCCEEDED")
      puts "Refund Succeeded hook created"
    rescue MangoPay::ResponseError => e
      previous_url = MangoPay::Hook.fetch.select do |h|
        h["EventType"] == "PAYOUT_REFUND_SUCCEEDED"
      end.first["Url"]
      puts "Succeeded hook already exists for url: #{previous_url} and yours is: #{base_url}/api/v1/refund_succeeded"
    end

    begin
      MangoPay::Hook.create(Url: "#{base_url}/api/v1/refund_failed",
                            EventType: "PAYOUT_REFUND_FAILED")
      puts "Refund Failed hook created"
    rescue MangoPay::ResponseError => e
      previous_url = MangoPay::Hook.fetch.select do |h|
        h["EventType"] == "PAYOUT_REFUND_FAILED"
      end.first["Url"]
      puts "Failed hook already exists for url: #{previous_url} and yours is: #{base_url}/api/v1/refund_failed"
    end
  end
end
