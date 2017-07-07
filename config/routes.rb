Rails.application.routes.draw do
resources :users
root :"users#index"
#root :to => 'home#index'

#  devise_for :users,
 #   :skip       => [:registrations],
  #  :path       => '/user',
   # :path_names => {
    #  sign_in:  '/login',
     # sign_out: '/logout'
   # } do
 # end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
