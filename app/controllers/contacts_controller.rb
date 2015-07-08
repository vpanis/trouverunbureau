class ContactsController < ApplicationController
  def new
    @contact = Contact.new
  end

  def create
    @contact = Contact.new(params[:contact])
    ContactWorker.perform_async params[:contact]
    flash.now[:notice] = I18n.t('contact.success')
    @contact = Contact.new
    render :new
  end
end
