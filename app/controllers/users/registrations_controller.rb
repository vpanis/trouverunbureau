module Users
  class RegistrationsController < Devise::RegistrationsController
    def create
      super
      return unless resource.persisted? # user is created successfuly
      create_mangopay_account
    end

    private

    def create_mangopay_account
      status = MangopayPaymentAccount.statuses[:processing]
      mpa = MangopayPaymentAccount.create(buyer: self, status: status)
      Payments::Mangopay::PaymentAccountWorker.perform_async(self.id, mpa.id)
    end
  end
end
