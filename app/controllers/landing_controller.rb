class LandingController < ApplicationController
  inherit_resources
  include RepresentedHelper
  include SelectOptionsHelper

  def index
    @space_types_options = space_types_options
  end

end
