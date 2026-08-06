class StatusController < ApplicationController
  def healthcheck
    render json: { status: "ok" }
  end
end
