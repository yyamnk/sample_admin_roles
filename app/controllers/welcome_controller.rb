class WelcomeController < ApplicationController
  authorize_resource :class => false # for cancancan

  def index
  end
end
