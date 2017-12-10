json.extract! user, :id, :email, :login_token, :token_generated_at, :admin, :created_at, :updated_at
json.url user_url(user, format: :json)
