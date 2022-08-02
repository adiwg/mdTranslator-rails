class StatusController < ApplicationController
    def show
        render json: { status: 0 }
    end
end
