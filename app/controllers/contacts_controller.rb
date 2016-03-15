class ContactsController < ApplicationController
  def new
    set_meta_tags title: t("meta.contacts.new.title"),
                  description: t("meta.contacts.new.description")
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
