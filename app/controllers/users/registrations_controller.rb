module Users
  class RegistrationsController < Devise::RegistrationsController
    def create
      super
      return unless resource.persisted? # user is created successfuly
      mpa = MangopayPaymentAccount.create(buyer: resource,
                                          status: MangopayPaymentAccount.statuses[:processing])
      Payments::Mangopay::PaymentAccountWorker.perform_async(resource.id, mpa.id)
    end
  end
end
