class ContactWorker
  include Sidekiq::Worker

  def perform(attributes)
    contact = Contact.new attributes
    contact.deliver
  end
end
