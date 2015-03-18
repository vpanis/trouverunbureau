module Users
  class RegistrationsController < Devise::RegistrationsController
    after_action :create_mangopay_user_account

    protected

    def create_mangopay_user_account
      binding.pry
      return unless resource.persisted? # user is created successfuly
      MangopayPaymentAccount.create(buyer: resource,
                                    status: MangopayPaymentAccount.statuses[:processing])
      MangopayPaymentAccountWorker.perform_async(resource.id)
    end
  end
end
