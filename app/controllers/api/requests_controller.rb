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

      result = result.all.order("case
        when status = 'sent' then '1'
        when status = 'pending' then '2'
        when status = 'successful' then '3'
        else status end asc,
        created_at desc"
      )

      render :json => include_associations(result)
    end

    def create
      params["requestee_emails"] ||= []
      params["requestee_ids"] ||= []

      render plain: "Requestee list should be an array", status: 400 and return unless
      params["requestee_ids"].is_a?(Array) and params["requestee_emails"].is_a?(Array)

      render plain: "Invalid item type", status: 400 and return unless
      ["Movie", "AndroidApp"].include?(params["item_type"])

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
      render :json => include_associations(request)
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

    private
    def include_associations(request)
      return request.to_json(include: {
        :requester => {
          :only => [:id, :name, :avatar_url]
        },
        :requestee => {
          :only => [:id, :name, :avatar_url]
        }
      })
    end

  end
end