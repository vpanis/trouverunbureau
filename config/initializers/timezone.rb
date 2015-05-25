Timezone::Configure.begin do |c|
  c.username = AppConfiguration.for(:timezone).geonames_username
end
