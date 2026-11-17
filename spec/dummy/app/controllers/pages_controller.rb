# frozen_string_literal: true

class PagesController < ApplicationController
  # Visible proof of execution: a red banner at the top of the page.
  XSS_PAYLOAD = <<~HTML.delete("\n")
    <img src="x" onerror="document.body.insertAdjacentHTML('afterbegin',
    '<p id=pwned style=background:#c00;color:#fff;padding:1em;font-size:2em>XSS exécuté</p>')">
  HTML

  def index; end
  def plain; end

  def show_notice
    flash[:notice] = "Profile updated"
    redirect_to root_path
  end

  def show_alert
    flash[:alert] = "Could not save"
    redirect_to root_path
  end

  def show_custom
    # Per-request override: Hash value carries full SA2 options, bypassing
    # the default flash_map mapping.
    flash[:notice] = { text: "Custom bam", icon: "question", toast: false, timer: nil }
    redirect_to root_path
  end

  def show_stacked
    swal_flash :alert, ["First", "Second", "Third"], mode: :stacked, delay: 50
    redirect_to root_path
  end

  def show_sequential
    swal_flash :alert, ["First", "Second", "Third"], mode: :sequential
    redirect_to root_path
  end

  def confirm_page
    render :confirm
  end

  def chain_page
    render :chain
  end

  def security_page
    render :security
  end

  # Deliberate anti-pattern: a request parameter copied into the flash.
  # `msg[html]=…` arrives as a nested Hash after the session round-trip.
  def reflect_flash
    redirect_to root_path, notice: params[:msg]
  end

  def destroy
    flash[:notice] = "Deleted item ##{params[:id]}"
    redirect_to root_path
  end

  def destroy_chain
    flash[:notice] = "Chained delete ##{params[:id]}"
    redirect_to root_path
  end
end
