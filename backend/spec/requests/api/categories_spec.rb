require 'rails_helper'

RSpec.describe "Api::Categories", type: :request do
  let!(:api_url) { "http://localhost:3000/api/categories" }

  describe "GET /api/categories" do
    let!(:food) { Category.find_or_create_by!(name: "Food") }
    let!(:transport) { Category.find_or_create_by!(name: "Transport") }
    let!(:supplies) { Category.find_or_create_by!(name: "Supplies") }

    it "returns all categories" do
      get api_url

      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json.map { |c| c["name"] }).to include("Food", "Transport", "Supplies")
    end

    it "returns categories in alphabetical order" do
      get api_url

      json = JSON.parse(response.body)
      names = json.map { |c| c["name"] }
      expect(names).to eq(names.sort)
    end
  end
end
