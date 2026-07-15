class StatusController < ApplicationController
  def healthcheck
    if params[:solid_queue]
      check_solid_queue
    else
      render json: { status: "ok" }
    end
  end

  private

  def check_solid_queue
    if solid_queue_healthy?
      render json: { status: "ok", worker: "solid_queue" }
    else
      render json: { status: "unhealthy", worker: "solid_queue" }, status: :service_unavailable
    end
  rescue StandardError => e
    render json: { status: "error", message: e.message }, status: :internal_server_error
  end

  def solid_queue_healthy?
    ActiveRecord::Base.connection.select_value(<<-SQL.squish, "Check Solid Queue Health", [Socket.gethostname, 60.seconds.ago])
      SELECT EXISTS (
        SELECT 1
        FROM solid_queue_processes
        WHERE hostname = $1
        AND kind = 'Supervisor'
        AND last_heartbeat_at > $2
      )
    SQL
  end
end
