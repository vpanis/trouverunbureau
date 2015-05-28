ActiveAdmin.register Venue do

  actions :index, :show
  filter :name
  filter :status, collection: Venue.statuses, as: :select

  member_action :close, method: :post do
    resource.update_attributes(status: Venue.statuses[:closed])
    redirect_to resource_path, notice: 'The venue has been closed'
  end

  member_action :activate, method: :post do
    resource.update_attributes(status: Venue.statuses[:active])
    redirect_to resource_path, notice: 'The venue has been activated'
  end

  index do
    id_column
    column :name
    column :status
    column :town
    column :phone
    column :email
    column :currency
    column :v_type
    column 'Actions', class: 'actions-col' do |v|
      span { link_to 'View', admin_venue_path(v) }
      span { link_to 'View in application', venue_path(v) } unless v.status == 'creating'
      if v.status == 'reported'
        span { '|' }
        span { link_to 'Close Venue', close_admin_venue_path(v), method: 'post' }
      end
      if v.status == 'reported'
        span { '|' }
        span { link_to 'Dismiss Report', activate_admin_venue_path(v), method: 'post' }
      end
    end
  end

end
