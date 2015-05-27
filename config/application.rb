require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module Deskspotting
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true
    config.assets.precompile += %w[admin/active_admin.js admin/active_admin.css]
    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    # config.active_record.schema_format = :sql

    # Enforce whitelist mode for mass assignment.
    # This will create an empty whitelist of attributes available for mass-assignment for all models
    # in your app. As such, your models will need to explicitly whitelist or blacklist accessible
    # parameters by using an attr_accessible or attr_protected declaration.
    # config.active_record.whitelist_attributes = true

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    # For Heroku deployments
    config.assets.initialize_on_precompile = true

    config.autoload_paths += %W(#{config.root}/lib)
    config.to_prepare do
      Devise::SessionsController.layout "session"
      Devise::RegistrationsController.layout "session"
      Devise::PasswordsController.layout "session"
    end

    # Mailer configuration
    mail = AppConfiguration.for :mail
    config.action_mailer.default_url_options = { host: mail.host, only_path: false }
    config.action_mailer.asset_host = mail.host
    # ActionMailer Config
    # Setup for production - deliveries, no errors raised
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.perform_deliveries = mail.perform_deliveries == 'true'
    config.action_mailer.raise_delivery_errors =  mail.raise_delivery_errors == 'true'
    config.action_mailer.default :charset => "utf-8"
    config.action_mailer.smtp_settings = {
      enable_starttls_auto: true,
      address: mail.address,
      port: mail.port.to_i,
      domain: mail.domain,
      user_name: mail.user_name,
      password: mail.password,
      authentication: mail.authentication
    }

    #config.middleware.use ExceptionNotification::Rack, email: {
    #  email_prefix: "[DESKSPOTTING - #{Rails.env}] ",
    #  sender_address: mail.user_name,
    #  exception_recipients: mail.notifications_account
    #}
  end
end
