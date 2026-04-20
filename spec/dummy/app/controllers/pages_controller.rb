# frozen_string_literal: true

class PagesController < ApplicationController
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

  def confirm_page
    render :confirm
  end

  def destroy
    flash[:notice] = "Deleted item ##{params[:id]}"
    redirect_to root_path
  end
end
