class ApplicationController < ActionController::Base
  private

  def append_info_to_payload(payload)
    super
    payload[:host] = request.host
    payload[:remote_ip] = request.remote_ip
    payload[:referer] = request.referer
    payload[:user_agent] = request.user_agent
  end
end
