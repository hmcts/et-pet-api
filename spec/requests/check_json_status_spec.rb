require 'rails_helper'

RSpec.describe "Check JSON Status" do
  describe "/health" do
    it "responds with status" do
      get '/health'

      expect(JSON.parse(response.body, symbolize_names: true)).to eq(status: "ok")
    end

    it "responds with status ok when solid_queue param is present and process record exists" do
      SolidQueue::Process.create!(name: 'Test Supervisor', pid: 12345, hostname: Socket.gethostname, kind: 'Supervisor', last_heartbeat_at: 1.second.ago)
      get '/health?solid_queue=true
'
      expect(JSON.parse(response.body, symbolize_names: true)).to eq(status: "ok", worker: "solid_queue")
    end

    it "responds with status unhealthy when solid_queue param is present and process record does not exist" do
      SolidQueue::Process.delete_all
      get '/health?solid_queue=true
'
      expect(JSON.parse(response.body, symbolize_names: true)).to eq(status: "unhealthy", worker: "solid_queue")
    end
  end

  describe "/health/readiness" do
    it "responds with status" do
      get '/health/readiness'

      expect(JSON.parse(response.body, symbolize_names: true)).to eq(status: "ok")
    end
  end

  describe "/health/liveness" do
    it "responds with status" do
      get '/health/liveness'

      expect(JSON.parse(response.body, symbolize_names: true)).to eq(status: "ok")
    end
  end

end
