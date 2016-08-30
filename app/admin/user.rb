ActiveAdmin.register User do

  config.sort_order = 'last_name_asc'

  member_action :confirm_identity, method: :post do
    resource.update_attributes!(identity_confirmed: true)
    redirect_to admin_users_path, notice: "#{resource.name} identity was confirmed"
  end

  actions :index, :show

  index do
    id_column
    column :last_name
    column :first_name
    column :email
    column :identity_confirmed
    column :identity_picture do |user|
      unless user.identity_picture.file.nil?
        link_to(image_tag(user.identity_picture.thumb.url, :alt => "user verification image", :width => 60, :height => 60, :title => "Click here to see the picture in full size"), user.identity_picture.url, :target => '_blank')
      end
    end
    column 'Actions', class: 'actions-col' do |v|
      unless v.identity_confirmed?
        span { link_to 'Verify Identity', confirm_identity_admin_user_path(v), method: 'post', :data => {:confirm => "Are you sure to confirm #{v.name} identity?"} }
      end
    end
  end

end
