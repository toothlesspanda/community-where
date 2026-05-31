Recaptcha.configure do |config|
  if Rails.env.development? || Rails.env.test?
    config.site_key   = "6LeIxAcTAAAAAJcZVRqyHh71UMIEGNQ_MXjiZKhI"
    config.secret_key = "6LeIxAcTAAAAAGG-vFI1TnRWxMZNFuojJ4WifJWe"
  else
    config.site_key   = Rails.application.credentials.dig(:recaptcha, :site_key)
    config.secret_key = Rails.application.credentials.dig(:recaptcha, :secret_key)
  end
end