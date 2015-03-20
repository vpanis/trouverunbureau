module Users
  class RegistrationsController < Devise::RegistrationsController
    after_action :create_mangopay_user_account

    protected

    def create_mangopay_user_account
      return unless resource.persisted? # user is created successfuly
      mpa = MangopayPaymentAccount.create(buyer: resource,
                                          status: MangopayPaymentAccount.statuses[:processing])
      MangopayPaymentAccountWorker.perform_async(resource.id, mpa.id)
    end
  end
end
