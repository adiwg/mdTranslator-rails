Rails.application.config.content_security_policy do |policy|
  policy.default_src :self
  policy.script_src  :self, :https
  policy.style_src   :self, "unpkg.com"
  policy.connect_src :self
end

Rails.application.config.content_security_policy_nonce_generator = -> request { SecureRandom.base64(16) }
