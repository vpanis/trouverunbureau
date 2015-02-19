module ArraySerializerHelper
  def serialized_array(result, serializer, options)
    ActiveModel::ArraySerializer.new(result, { each_serializer: serializer }, options)
  end

  def serialized_paginated_array(result, array_name, serializer, options)
    ActiveModel::ArraySerializer.new(result, { each_serializer: serializer }, options)
    pagination = pagination_params
    result = result.paginate(pagination_params)
    json = { count: result.size,
             current_page: pagination.page,
             items_per_page: pagination.amount }
    json[array_name] = result
    json
  end
end