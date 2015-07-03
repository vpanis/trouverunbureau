class ContactsController < ApplicationController
  def new
    @contact = Contact.new
  end

  def create
    @contact = Contact.new(params[:contact])
    # @contact.request = request
    ContactWorker.perform_async params[:contact]
    flash.now[:notice] = I18n.t('contact.success')
    render :new
  end
end
