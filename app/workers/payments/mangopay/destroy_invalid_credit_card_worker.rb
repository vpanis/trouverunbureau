module Payments
  module Mangopay
    class DestroyInvalidCreditCardWorker
      include Sidekiq::Worker

      def perform
        MangopayCreditCard.not_activated.where('registration_expiration_date <= :t', t: Time.new)
          .destroy_all
      end
    end
  end
end