class AlbumsController < ApplicationController
  before_action :authenticate_user
  before_action :admin_user, except: :show
  before_action :correct_user, only: :show
  before_action :set_album, only: [:edit, :upload, :update, :destroy]

  # GET /albums
  # GET /albums.json
  def index
    @albums = Album.paginate(:page => params[:page], :per_page => 50).order(:name)
  end

  # GET /albums/1
  # GET /albums/1.json
  def show
    @album = Album.find(params[:id])
    @photos = @album.photos.paginate(:page => params[:page], :per_page => 20).order(created_at: :asc)
  end

  # GET /albums/new
  def new
    @album = Album.new
  end

  # GET /albums/1/edit
  def edit
    session[:upload] = ""
  end
  
  # GET /albums/1/upload
  def upload
    session[:upload] = "true"
  end

  # POST /albums
  # POST /albums.json
  def create
    @album = Album.new(album_params)

    respond_to do |format|
      if @album.save
        format.html { redirect_to @album, notice: 'Album was successfully created.' }
        format.json { render :show, status: :created, location: @album }
      else
        format.html { render :new }
        format.json { render json: @album.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /albums/1
  # PATCH/PUT /albums/1.json
  def update
    respond_to do |format|
      if @album.update(album_params)
        if session[:upload] == "true" # don't re-upload unless the update is from the upload action
          session[:upload] = ""       # reset
          @photos = @album.photos.all
          @photos.each do |photo|
            photo.change_filename
            photo.process_image
          end
          ZipJob.perform_in(300, @album.id)
        end
        format.html { redirect_to albums_path, notice: 'Album was successfully updated.' }
        format.json { render :show, status: :ok, location: @album }
      else
        format.html { render :edit }
        format.json { render json: @album.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /albums/1
  # DELETE /albums/1.json
  def destroy
    @album.destroy
    respond_to do |format|
      format.html { redirect_to albums_url, notice: 'Album was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def correct_user
      album = Album.find(params[:id])
      unless current_user.admin? || current_user.id == album.user_id
        redirect_to root_url, :alert => "Sorry, that is not permitted."
      end
    end
    
    # Use callbacks to share common setup or constraints between actions.
    def set_album
      @album = Album.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def album_params
      params.require(:album).permit(:name, :expiry_date, :user_id, :paid, photos_files: [])
    end
end
