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
    SolidQueue::Process.
      exists?(hostname: Socket.gethostname,
              kind: %w[Supervisor(fork) Supervisor(async)],
              last_heartbeat_at: SolidQueue.process_alive_threshold.ago..)
  end
end
