require "action_view/rendering"
require "active_support/core_ext/module/remove_method"

module ActionView
  # Layouts reverse the common pattern of including shared headers and footers in many templates to isolate changes in
  # repeated setups. The inclusion pattern has pages that look like this:
  #
  #   <%= render "shared/header" %>
  #   Hello World
  #   <%= render "shared/footer" %>
  #
  # This approach is a decent way of keeping common structures isolated from the changing content, but it's verbose
  # and if you ever want to change the structure of these two includes, you'll have to change all the templates.
  #
  # With layouts, you can flip it around and have the common structure know where to insert changing content. This means
  # that the header and footer are only mentioned in one place, like this:
  #
  #   // The header part of this layout
  #   <%= yield %>
  #   // The footer part of this layout
  #
  # And then you have content pages that look like this:
  #
  #    hello world
  #
  # At rendering time, the content page is computed and then inserted in the layout, like this:
  #
  #   // The header part of this layout
  #   hello world
  #   // The footer part of this layout
  #
  # == Accessing shared variables
  #
  # Layouts have access to variables specified in the content pages and vice versa. This allows you to have layouts with
  # references that won't materialize before rendering time:
  #
  #   <h1><%= @page_title %></h1>
  #   <%= yield %>
  #
  # ...and content pages that fulfill these references _at_ rendering time:
  #
  #    <% @page_title = "Welcome" %>
  #    Off-world colonies offers you a chance to start a new life
  #
  # The result after rendering is:
  #
  #   <h1>Welcome</h1>
  #   Off-world colonies offers you a chance to start a new life
  #
  # == Layout assignment
  #
  # You can either specify a layout declaratively (using the #layout class method) or give
  # it the same name as your controller, and place it in <tt>app/views/layouts</tt>.
  # If a subclass does not have a layout specified, it inherits its layout using normal Ruby inheritance.
  #
  # For instance, if you have PostsController and a template named <tt>app/views/layouts/posts.html.erb</tt>,
  # that template will be used for all actions in PostsController and controllers inheriting
  # from PostsController.
  #
  # If you use a module, for instance Weblog::PostsController, you will need a template named
  # <tt>app/views/layouts/weblog/posts.html.erb</tt>.
  #
  # Since all your controllers inherit from ApplicationController, they will use
  # <tt>app/views/layouts/application.html.erb</tt> if no other layout is specified
  # or provided.
  #
  # == Inheritance Examples
  #
  #   class BankController < ActionController::Base
  #     # bank.html.erb exists
  #
  #   class ExchangeController < BankController
  #     # exchange.html.erb exists
  #
  #   class CurrencyController < BankController
  #
  #   class InformationController < BankController
  #     layout "information"
  #
  #   class TellerController < InformationController
  #     # teller.html.erb exists
  #
  #   class EmployeeController < InformationController
  #     # employee.html.erb exists
  #     layout nil
  #
  #   class VaultController < BankController
  #     layout :access_level_layout
  #
  #   class TillController < BankController
  #     layout false
  #
  # In these examples, we have three implicit lookup scenarios:
  # * The +BankController+ uses the "bank" layout.
  # * The +ExchangeController+ uses the "exchange" layout.
  # * The +CurrencyController+ inherits the layout from BankController.
  #
  # However, when a layout is explicitly set, the explicitly set layout wins:
  # * The +InformationController+ uses the "information" layout, explicitly set.
  # * The +TellerController+ also uses the "information" layout, because the parent explicitly set it.
  # * The +EmployeeController+ uses the "employee" layout, because it set the layout to +nil+, resetting the parent configuration.
  # * The +VaultController+ chooses a layout dynamically by calling the <tt>access_level_layout</tt> method.
  # * The +TillController+ does not use a layout at all.
  #
  # == Types of layouts
  #
  # Layouts are basically just regular templates, but the name of this template needs not be specified statically. Sometimes
  # you want to alternate layouts depending on runtime information, such as whether someone is logged in or not. This can
  # be done either by specifying a method reference as a symbol or using an inline method (as a proc).
  #
  # The method reference is the preferred approach to variable layouts and is used like this:
  #
  #   class WeblogController < ActionController::Base
  #     layout :writers_and_readers
  #
  #     def index
  #       # fetching posts
  #     end
  #
  #     private
  #       def writers_and_readers
  #         logged_in? ? "writer_layout" : "reader_layout"
  #       end
  #   end
  #
  # Now when a new request for the index action is processed, the layout will vary depending on whether the person accessing
  # is logged in or not.
  #
  # If you want to use an inline method, such as a proc, do something like this:
  #
  #   class WeblogController < ActionController::Base
  #     layout proc { |controller| controller.logged_in? ? "writer_layout" : "reader_layout" }
  #   end
  #
  # If an argument isn't given to the proc, it's evaluated in the context of
  # the current controller anyway.
  #
  #   class WeblogController < ActionController::Base
  #     layout proc { logged_in? ? "writer_layout" : "reader_layout" }
  #   end
  #
  # Of course, the most common way of specifying a layout is still just as a plain template name:
  #
  #   class WeblogController < ActionController::Base
  #     layout "weblog_standard"
  #   end
  #
  # The template will be looked always in <tt>app/views/layouts/</tt> folder. But you can point
  # <tt>layouts</tt> folder direct also. <tt>layout "layouts/demo"</tt> is the same as <tt>layout "demo"</tt>.
  #
  # Setting the layout to +nil+ forces it to be looked up in the filesystem and fallbacks to the parent behavior if none exists.
  # Setting it to +nil+ is useful to re-enable template lookup overriding a previous configuration set in the parent:
  #
  #     class ApplicationController < ActionController::Base
  #       layout "application"
  #     end
  #
  #     class PostsController < ApplicationController
  #       # Will use "application" layout
  #     end
  #
  #     class CommentsController < ApplicationController
  #       # Will search for "comments" layout and fallback "application" layout
  #       layout nil
  #     end
  #
  # == Conditional layouts
  #
  # If you have a layout that by default is applied to all the actions of a controller, you still have the option of rendering
  # a given action or set of actions without a layout, or restricting a layout to only a single action or a set of actions. The
  # <tt>:only</tt> and <tt>:except</tt> options can be passed to the layout call. For example:
  #
  #   class WeblogController < ActionController::Base
  #     layout "weblog_standard", except: :rss
  #
  #     # ...
  #
  #   end
  #
  # This will assign "weblog_standard" as the WeblogController's layout for all actions except for the +rss+ action, which will
  # be rendered directly, without wrapping a layout around the rendered view.
  #
  # Both the <tt>:only</tt> and <tt>:except</tt> condition can accept an arbitrary number of method references, so
  # #<tt>except: [ :rss, :text_only ]</tt> is valid, as is <tt>except: :rss</tt>.
  #
  # == Using a different layout in the action render call
  #
  # If most of your actions use the same layout, it makes perfect sense to define a controller-wide layout as described above.
  # Sometimes you'll have exceptions where one action wants to use a different layout than the rest of the controller.
  # You can do this by passing a <tt>:layout</tt> option to the <tt>render</tt> call. For example:
  #
  #   class WeblogController < ActionController::Base
  #     layout "weblog_standard"
  #
  #     def help
  #       render action: "help", layout: "help"
  #     end
  #   end
  #
  # This will override the controller-wide "weblog_standard" layout, and will render the help action with the "help" layout instead.
  module Layouts
    extend ActiveSupport::Concern

    include ActionView::Rendering

    included do
      class_attribute :_layout, :_layout_conditions, instance_accessor: false
      self._layout = nil
      self._layout_conditions = {}
      _write_layout_method
    end

    delegate :_layout_conditions, to: :class

    module ClassMethods
      def inherited(klass) # :nodoc:
        super
        klass._write_layout_method
      end

      # This module is mixed in if layout conditions are provided. This means
      # that if no layout conditions are used, this method is not used
      module LayoutConditions # :nodoc:
        private

          # Determines whether the current action has a layout definition by
          # checking the action name against the :only and :except conditions
          # set by the <tt>layout</tt> method.
          #
          # ==== Returns
          # * <tt>Boolean</tt> - True if the action has a layout definition, false otherwise.
          def _conditional_layout?
            return unless super

            conditions = _layout_conditions

            if only = conditions[:only]
              only.include?(action_name)
            elsif except = conditions[:except]
              !except.include?(action_name)
            else
              true
            end
          end
      end

      # Specify the layout to use for this class.
      #
      # If the specified layout is a:
      # String:: the String is the template name
      # Symbol:: call the method specified by the symbol
      # Proc::   call the passed Proc
      # false::  There is no layout
      # true::   raise an ArgumentError
      # nil::    Force default layout behavior with inheritance
      #
      # Return value of +Proc+ and +Symbol+ arguments should be +String+, +false+, +true+ or +nil+
      # with the same meaning as described above.
      # ==== Parameters
      # * <tt>layout</tt> - The layout to use.
      #
      # ==== Options (conditions)
      # * :only   - A list of actions to apply this layout to.
      # * :except - Apply this layout to all actions but this one.
      def layout(layout, conditions = {})
        include LayoutConditions unless conditions.empty?

        conditions.each { |k, v| conditions[k] = Array(v).map(&:to_s) }
        self._layout_conditions = conditions

        self._layout = layout
        _write_layout_method
      end

      # Creates a _layout method to be called by _default_layout .
      #
      # If a layout is not explicitly mentioned then look for a layout with the controller's name.
      # if nothing is found then try same procedure to find super class's layout.
      def _write_layout_method # :nodoc:
        remove_possible_method(:_layout)

        prefixes = /\blayouts/.match?(_implied_layout_name) ? [] : ["layouts"]
        default_behavior = "lookup_context.find_all('#{_implied_layout_name}', #{prefixes.inspect}, false, [], { formats: formats }).first || super"
        name_clause = if name
          default_behavior
        else
          <<-RUBY
            super
          RUBY
        end

        layout_definition = \
          case _layout
          when String
            _layout.inspect
          when Symbol
            <<-RUBY
              #{_layout}.tap do |layout|
                return #{default_behavior} if layout.nil?
                unless layout.is_a?(String) || !layout
                  raise ArgumentError, "Your layout method :#{_layout} returned \#{layout}. It " \
                    "should have returned a String, false, or nil"
                end
              end
            RUBY
          when Proc
            define_method :_layout_from_proc, &_layout
            protected :_layout_from_proc
            <<-RUBY
              result = _layout_from_proc(#{_layout.arity == 0 ? '' : 'self'})
              return #{default_behavior} if result.nil?
              result