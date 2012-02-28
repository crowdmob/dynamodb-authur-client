require 'active_support/core_ext/object/with_options'

Dynamodb::Authur::Client.with_options :model => true do |d|
  # Strategies first
  d.with_options :strategy => true do |s|
    routes = [nil, :new, :destroy]
    s.add_module :dynamodb_authenticatable, :controller => :sessions, :route => { :session => routes }, :no_input => true
  end
end