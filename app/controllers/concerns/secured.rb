module Secured
  def authenticate_user!
    # Bearer xxxxxxxx
    token_regex = /Bearer (\w+)/
    # Read Header auth
    headers = request.headers
    # Check it's valid
    if headers['Authorization'].present? && headers['Authorization'].match(token_regex)
      token = headers['Authorization'].match(token_regex)[1]
      # Check token is a User's token
      if (Current.user = User.find_by_auth_token(token))
        return
      end
    end
    render json: { error: 'Unauthorized' }, status: :unauthorized
  end
end
