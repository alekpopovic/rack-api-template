# frozen_string_literal: true

# @license
#
# © CODEPOP 2015. All rights reserved.
#
# This copyright notice and any related information provided is “copyright
# management information” under the Digital Millennium Copyright Act.
# Such notices and language are used to deter, detect, and police copyright
# infringement, and their maintenance on copies of the source code is one
# of the conditions for lawful use of the source code. As such, any removal
# or alteration of such copyright management information without the express
# written permission CODEPOP will result in copyright
# infringement, and is prohibited.
#
# Confidential

require_relative "config/initializer"

router = ActionDispatch::Routing::RouteSet.new

router.draw do
  root to: "application#error_404"
  scope "v1" do
    post "sign_in", to: "sign_in#handler"
  end
  match "*unmatched", to: "application#error_404", via: :all
end

app = Rack::Builder.new do
  use(Rack::Cors) do
    allow do
      origins("*")
      resource(
        "*",
        credentials: true,
        headers: :any,
        methods: %(get post put patch delete options head),
      )
    end
  end
  use(Rackup::Handler::Puma.run(router, Port: Application.config.port))
end

run app
