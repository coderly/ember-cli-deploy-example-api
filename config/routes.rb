Rails.application.routes.draw do
  get "/(*path)" => "ember_index#index", as: :root, format: :html
end
