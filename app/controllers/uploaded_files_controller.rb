class UploadedFilesController < ApplicationController

  # GET /uploaded_files
  def index
    render json: UploadedFile.all, status: :ok
  end

  # POST /uploaded_files
  def create
    UploadedFile.create(uploaded_file_params)
    render json: {}, status: :ok
  end

  private

  # Only allow a trusted parameter "white list" through.
  def uploaded_file_params
    params.require(:uploaded_file).permit(:source)
  end
end
