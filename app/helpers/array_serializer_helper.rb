module ArraySerializerHelper
  include ParametersHelper

  def serialized_array(result, serializer, options = {})
    options[:each_serializer] = serializer
    ActiveModel::ArraySerializer.new(result, options)
  end

  def serialized_paginated_array(result, array_name, serializer, options = {})
    options[:each_serializer] = serializer
    ActiveModel::ArraySerializer.new(result, options)
    pagination = pagination_params
    result = result.paginate(pagination_params)
    json = { count: result.size,
             current_page: pagination[:page],
             items_per_page: pagination[:per_page] }
    json[array_name] = result
    json
  end
end