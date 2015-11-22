require 'faraday'

module SamsonSlack
  class Engine < Rails::Engine
  end
end
Samson::Hooks.view :stage_form, "samson_slack/fields"

Samson::Hooks.callback :stage_clone do |old_stage, new_stage|
  new_stage.slack_channels.build(old_stage.slack_channels.map { |s| s.attributes.except("id", "created_at", "updated_at") })
end

Samson::Hooks.callback :stage_permitted_params do
  { slack_webhooks_attributes: [:id, :name, :webhook_url, :_destroy] }
end

notify = -> (deploy, _buddy) do
  if deploy.stage.send_slack_notifications?
    SlackNotification.new(deploy).deliver
  end
end

Samson::Hooks.callback :before_deploy, &notify
Samson::Hooks.callback :after_deploy, &notify
