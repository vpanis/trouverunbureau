class SessionController < ApplicationController
  inherit_resources

  def login
    render layout: 'session'
  end

  def signup
    render layout: 'session'
  end
end
