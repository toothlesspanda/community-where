Rails.application.config.after_initialize do
  MissionControl::Jobs.base_controller_class = "Studio::BaseController"
  MissionControl::Jobs.http_basic_auth_enabled = false
end
