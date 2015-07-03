class ContactsController < ApplicationController
	def new
    @contact = Contact.new
  end

  def create
    @contact = Contact.new(params[:contact])
    @contact.request = request
    if @contact.deliver
      flash.now[:error] = nil
      flash.now[:notice] = I18n.t('contact.success')
      render :new
    else
      flash.now[:error] = I18n.t('contact.error')
      render :new
    end
  end
end
