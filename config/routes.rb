Rails.application.routes.draw do

  root to: 'public#search'

  post '/', to: 'public#search'
  get '/t/:trade_request_id', to: 'public#trade_request', as: :public_trade_request

  devise_for :users

  ## User Restricted Area
  scope :u, module: :users do
    resources :trade_requests
  end

end
