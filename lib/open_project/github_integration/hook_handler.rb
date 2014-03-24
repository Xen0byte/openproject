module OpenProject::GithubIntegration
  class HookHandler
    # List of the github events we can handle.
    KNOWN_EVENTS = %w{ ping pull_request issue_comment }

    # A github webhook happened.
    # We need to check validity of the data and send a Notification
    # which we process in our NotificationHandler.
    def process(hook, environment, params, user)
      event_type = environment['HTTP_X_GITHUB_EVENT']
      event_delivery = environment['HTTP_X_GITHUB_DELIVERY']

      Rails.logger.debug "Received github webhook #{event_type} (#{event_delivery})"

      return 404 unless KNOWN_EVENTS.include?(event_type) && event_delivery
      return 403 unless user.present?

      payload = Hash.new
      payload.merge! params.require('webhook')
      payload.merge! 'user_id' => user.id,
                     'github_event' => event_type,
                     'github_delivery' => event_delivery

      OpenProject::Notifications.send(event_name(event_type), payload)

      return 200
    end

    private def event_name(github_event_name)
      "github.#{github_event_name}"
    end
  end
end
