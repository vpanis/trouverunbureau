class PaginationSerializer < ActiveModel::ArraySerializer

  def initialize(object, options = {})
    meta_key = options[:meta_key] || :meta
    options[meta_key] ||= {}

    options[meta_key][:total_count] = object.total_entries.try(:to_i)
    options[meta_key][:pagination] = { previous:     object.previous_page.try(:to_i),
                                       next:         object.next_page.try(:to_i),
                                       current:      object.current_page.try(:to_i),
                                       per_page:     object.per_page.try(:to_i),
                                       pages:        object.total_pages.try(:to_i)
    }
    # need to do this hack to make sure it works for STI subclasses as well.
    options[:each_serializer] = get_serializer_for(object)

    super(object, options)
  end

  private

  def get_serializer_for(klass)
    serializer_class_name = "#{klass.name}Serializer"
    serializer_class = serializer_class_name.safe_constantize

    if serializer_class
      serializer_class
    elsif klass.superclass
      get_serializer_for(klass.superclass)
    end
  end
end
