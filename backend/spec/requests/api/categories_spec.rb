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

  describe "POST /api/categories" do
    context "with valid parameters" do
      it "creates a new category" do
        expect {
          post api_url, params: { category: { name: "Groceries" } }, as: :json
        }.to change(Category, :count).by(1)

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json["name"]).to eq("Groceries")
      end
    end

    context "with invalid parameters" do
      it "returns 422 when name is blank" do
        expect {
          post api_url, params: { category: { name: "" } }, as: :json
        }.not_to change(Category, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json["errors"]).to be_present
      end

      it "returns 422 when name is already taken" do
        Category.find_or_create_by!(name: "Food")

        expect {
          post api_url, params: { category: { name: "Food" } }, as: :json
        }.not_to change(Category, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json["errors"]).to be_present
      end

      it "returns 422 when name is taken with different casing" do
        Category.find_or_create_by!(name: "Food")

        expect {
          post api_url, params: { category: { name: "food" } }, as: :json
        }.not_to change(Category, :count)

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
