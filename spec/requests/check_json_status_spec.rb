require 'rails_helper'

RSpec.describe "Check JSON Status" do
  describe "/health" do
    it "responds with status" do
      get '/health'

      expect(JSON.parse(response.body, symbolize_names: true)).to eq(status: "ok")
    end

    it "responds with status when solid_queue param is present" do
      get '/health?solid_queue=true
'
      expect(JSON.parse(response.body, symbolize_names: true)).to eq(status: "ok", worker: "solid_queue")
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
