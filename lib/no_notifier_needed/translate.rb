module NoNotifierNeeded
  module Translate
    def url_for(destination)
      unless destination.is_a?(Hash) || destination.match(/_path/i)
        raise ArgumentError.new(" must pass something that ends with a _path. #{destination} sent.")
      end
      to_send = "Rails.application.routes.url_helpers.#{destination}"
      instance_eval to_send
    end

    def email_link_to(title, link)
      return title if link.blank?
      if link.match(/http:\/\/[\w*\.]*\//i)
        root_link = link
      else
        splitter = NoNotifierNeeded.send(:host).split('/').last

        link_broken = link.split(splitter).last
        link_broken = link_broken.split('/').reject{|e| e.blank?}.join('/')
        if NoNotifierNeeded.send(:host).last == "/"
          root_link = NoNotifierNeeded.send(:host) + link_broken
        else
          root_link = NoNotifierNeeded.send(:host) + "/" + link_broken
        end
      end
      "<a href='#{root_link}'>#{title}</a>"
    end

    def get_send_hash(template)
      send_hash = base_send_hash(template)
      send_hash[:subject] = render_template_subject_type(@template)
      send_hash[:to] = @to.nil? ? @user.email : @to
      send_hash[:from] = @from unless @from.nil?
      send_hash[:reply_to] = @reply_to unless @reply_to.nil?
      send_hash
    end

    def base_send_hash(template)
      base = {}
      NoNotifierNeeded::Config::VALID_OPTIONS_KEYS.each do |k|
        base[k] = NoNotifierNeeded.send(k)
      end
      base[:from] = "#{base.delete(:from_name)} <#{base.delete(:from_email)}>"
      base[:from] = "#{template.from_name} <#{template.from_email}>" if template.from_name && template.from_email
      base[:reply_to] = "#{template.reply_to}" if template.reply_to
      base
    end

    def args_to_instance_vars(args)
      #take each key, if a model, make it an @#{model} = model.find(value)
      #else make it a @#{name}=#{value}
      args.each do |k,v|
        if Object.const_defined?(k.classify) && known_models.include?(k.classify.constantize)
          self.instance_eval("@#{k}= #{k.classify}.find(#{v})")
        else
          if v.is_a?(String)
            self.instance_eval("@#{k} = \"#{v}\"")
          else
            self.instance_eval("@#{k}=#{v}")
          end
        end
      end
    end

    def known_models
      @known_models || @known_models = ActiveRecord::Base.send( :subclasses )
    end
  end
end
