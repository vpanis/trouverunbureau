module ArraySerializerHelper
  include ParametersHelper

  def serialized_array(result, serializer, options = {})
    options[:each_serializer] = serializer
    ActiveModel::ArraySerializer.new(result, options)
  end

  def serialized_paginated_array(result, array_name, serializer, options = {})
    options[:each_serializer] = serializer
    result = result.paginate(pagination_params)
    serializer_result = ActiveModel::ArraySerializer.new(result, options)
    json = { count: result.total_entries,
             current_page: result.current_page,
             items_per_page: result.per_page }
    json[array_name] = serializer_result.as_json
    json
  end
end
