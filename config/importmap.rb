# frozen_string_literal: true

pin "sweetalert2", to: "sweetalert2.esm.all.js"
pin "swal_rails", to: "swal_rails/index.js"
pin "swal_rails/confirm", to: "swal_rails/confirm.js"
pin "swal_rails/flash", to: "swal_rails/flash.js"
pin "swal_rails/chain", to: "swal_rails/chain.js"
pin_all_from SwalRails::Engine.root.join("app/assets/javascripts/swal_rails/controllers"),
             under: "controllers", to: "swal_rails/controllers"
