class Api::V1::TranslatorsController < ApplicationController
	skip_before_action :verify_authenticity_token
  
  def show
    respond_to do |format|
      format.html
      format.json
      format.xml
    end
  end
end