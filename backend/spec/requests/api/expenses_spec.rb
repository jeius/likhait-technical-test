require 'rails_helper'

RSpec.describe "Api::Expenses", type: :request do
  let!(:food_category) { Category.find_or_create_by!(name: "Food") }
  let!(:transport_category) { Category.find_or_create_by!(name: "Transport") }
  let!(:api_url) { "http://localhost:3000/api/expenses" }

  describe "GET /api/expenses" do
    let!(:expense1) { Expense.create!(description: "Lunch", amount: 100.00, category: food_category, date: Date.today - 1, payer_name: "Julius Pahama") }
    let!(:expense2) { Expense.create!(description: "Taxi", amount: 50.00, category: transport_category, date: Date.today, payer_name: "Julius Pahama") }

    it "returns all expenses with category information" do
      get api_url

      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json.map { |e| e["id"] }).to include(expense1.id, expense2.id)
    end
  end

  describe "POST /api/expenses" do
    context "with valid parameters" do
      let(:valid_params) do
        {
          expense: {
            description: "Team Lunch",
            amount: 150.50,
            category_id: food_category.id,
            date: Date.today,
            payer_name: "Julius Pahama"
          }
        }
      end

      it "creates a new expense" do
        expect {
          post api_url, params: valid_params, as: :json
        }.to change(Expense, :count).by(1)

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json["description"]).to eq("Team Lunch")
        expect(json["amount"]).to eq(150.5)
      end
    end

    context "with invalid parameters" do
      it "with negative amounts" do
        invalid_params = {
          expense: {
            description: "Invalid expense",
            amount: -100.00,
            category_id: food_category.id,
            date: Date.today,
            payer_name: "Julius Pahama"
          }
        }

        expect {
          post api_url, params: invalid_params, as: :json
        }.to change(Expense, :count).by(1)

        expect(response).to have_http_status(:created)
      end

      it "with empty descriptions" do
        invalid_params = {
          expense: {
            description: "",
            amount: 100.00,
            category_id: food_category.id,
            date: Date.today,
            payer_name: "Julius Pahama"
          }
        }

        expect {
          post api_url, params: invalid_params, as: :json
        }.to change(Expense, :count).by(1)

        expect(response).to have_http_status(:created)
      end

      it "rejects a future date" do
        future_params = {
          expense: {
            description: "Future expense",
            amount: 100.00,
            category_id: food_category.id,
            date: Date.today + 1,
            payer_name: "Julius Pahama"
          }
        }

        expect {
          post api_url, params: future_params, as: :json
        }.not_to change(Expense, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json["errors"]).to be_present
      end
    end
  end
end
