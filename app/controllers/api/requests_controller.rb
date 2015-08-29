module Api
  class RequestsController < ApplicationController
    before_action :require_auth

    def index
      result = Request

      if params[:requestee_id]
        result = result.where(:requestee_id => params[:requestee_id])
      end

      if params[:requester_id]
        result = result.where(:requester_id => params[:requester_id])
      end

      result = result.all

      render :json => result
    end

    def create
      params["requestee_emails"] ||= []
      params["requestee_ids"] ||= []

      render plain: "Requestee list should be an array", status: 400 and return unless
      params["requestee_ids"].is_a?(Array) and params["requestee_emails"].is_a?(Array)

      render plain: "Invalid item type", status: 400 and return unless
      [nil, "Movie", "AndroidApp"].include?(params["item_type"])

      new_requests = Request.create_by_id_and_email(
        @api_user,
        params["item_type"],
        params["requestee_ids"],
        params["requestee_emails"]
      )

      render json: new_requests.to_json
    end

    def show
      request = Request.find(params[:id])
      render :json => request.to_json(include: ["requester", "requestee"])
    end

    def update
      request = Request.find(params[:id])

      request_params = params.permit(
        :status
      )
      if request.update(request_params)
        render :json => request
      else
        render :json => { errors: request.errors }, status: 409 and return
      end
    end

  end
end