class PhotosController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:postback]
  before_action :authenticate_user, except: :postback
  before_action :admin_user, except: :postback
  before_action :set_photo, only: [:postback, :show, :destroy]
  
  # POST /photos/1/postback
  def postback
    results = JSON.parse(params["results"]) if params["results"].is_a?(String)
    unless results =~ /error/
      @photo.move_for_delete(@photo.file_id)
    end
    respond_to do |format|
      format.json { head :ok }
    end
  end
  
  # GET /photos/1
  # GET /photos/1.json
  def show
  end
  
  # DELETE /photos/1
  # DELETE /photos/1.json
  def destroy
    @photo.destroy
    respond_to do |format|
      format.html { redirect_to photos_url, notice: 'Photo was successfully destroyed.' }
    end
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_photo
      @photo = Photo.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def photo_params
      params.require(:photo).permit()
    end
end
