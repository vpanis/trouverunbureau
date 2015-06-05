module Payments
  module Mangopay
    class DestroyInvalidCreditCardWorker
      include Sidekiq::Worker
      include Sidetiq::Schedulable

      recurrence { hourly }

      def perform
        MangopayCreditCard.not_activated.where('registration_expiration_date <= :t',
                                               t: Time.current).destroy_all
      end
    end
  end
end
