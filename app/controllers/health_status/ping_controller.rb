module HealthStatus
  class PingController < ApplicationController
    def show
      render json: HealthStatus::Deployment.new
    end
  end
end
