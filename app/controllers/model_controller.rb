class ModelController < ApplicationController
  inherit_resources
  include RepresentedHelper
  before_action :authenticate_user!, only: [:edit, :update]

  def do_update(entity, context, authorize_m, update_m)
    instance_variable_set "@#{entity}".to_sym, entity.find_by(id: params[:id])
    return render nothing: true, status: 404 unless entity_object(entity).present?
    object_context = context.new(entity_object(entity), current_represented)
    return render nothing: true, status: 403 unless object_context.send(authorize_m)
    return render nothing: true, status: 412 unless object_context.send(update_m, object_params)
    redirect_to action: 'edit'
  end

  private

  def entity_object(entity)
    instance_variable_get("@#{entity}")
  end
end
