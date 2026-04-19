# frozen_string_literal: true

pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin "sweetalert2", to: "sweetalert2.esm.all.js", preload: true
pin "swal_rails", to: "swal_rails/index.js", preload: true
pin "swal_rails/confirm", to: "swal_rails/confirm.js"
pin "swal_rails/flash", to: "swal_rails/flash.js"
