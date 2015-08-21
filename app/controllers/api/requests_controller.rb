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
      requestee = User.find(params["requestee_id"])
      request = Request.new(
        :requester => @api_user,
        :requestee => requestee,
        :item_type => params["item_type"]
      )
      if request.save
        render :json => request
      else
        render json: { errors: request.errors }, status: 409 and return
      end
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