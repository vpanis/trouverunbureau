module Users
  class RegistrationsController < Devise::RegistrationsController
    def create
      super
      return unless resource.persisted? # user is created successfuly
      create_mangopay_account
      NotificationsMailer.delay.welcome_email(resource.id)
    end

    private

    def create_mangopay_account
      status = MangopayPaymentAccount.statuses[:processing]
      mpa = MangopayPaymentAccount.create(buyer: resource, status: status)
      Payments::Mangopay::PaymentAccountWorker.perform_async(resource.id, mpa.id)
    end
  end
end
