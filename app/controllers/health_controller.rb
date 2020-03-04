class HealthController < ActionController::API
  def health
    render json: { api: 'OK' }, status: :ok
  end
end