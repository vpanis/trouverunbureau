def devise_requests_login(email, password)
  post_via_redirect user_session_path, user: {
    email: email,
    password: password
  }
end

def devise_requests_logout
  delete_via_redirect destroy_user_session_path
end
