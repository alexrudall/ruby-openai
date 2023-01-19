# frozen_string_literal: true

StimulusReflex.configure do |config|
  config.on_failed_sanity_checks = :warn

  # Override the parent class that the StimulusReflex ActionCable channel inherits from

  # config.parent_channel = "ApplicationCable::Channel"

  # Customize server-side Reflex logging format, with optional colorization:
  # Available tokens: session_id, session_id_full, reflex_info, operation, reflex_id, reflex_id_full, mode, selector, operation_counter, connection_id, connection_id_full, timestamp
  # Available colors: red, green, yellow, blue, magenta, cyan, white
  # You can also use attributes from your ActionCable Connection's identifiers that resolve to valid ActiveRecord models
  # eg. if your connection is `identified_by :current_user` and your User model has an email attribute, you can access r.email (it will display `-` if the user isn't logged in)
  # Learn more at: https://docs.stimulusreflex.com/troubleshooting#stimulusreflex-logging

  # config.logging = proc { "[#{session_id}] #{operation_counter.magenta} #{reflex_info.green} -> #{selector.cyan} via #{mode} Morph (#{operation.yellow})" }

  # Optimized for speed, StimulusReflex doesn't enable Rack middleware by default.
  # If you are using Page Morphs and your app uses Rack middleware to rewrite part of the request path, you must enable those middleware modules in StimulusReflex.
  #
  # Learn more about registering Rack middleware in Rails here: https://guides.rubyonrails.org/rails_on_rack.html#configuring-middleware-stack

  # config.middleware.use FirstRackMiddleware
  # config.middleware.use SecondRackMiddleware
end
