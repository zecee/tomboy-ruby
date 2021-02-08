module Backend
  class BooksController < BackendController
    before_action :set_book, only: %I[edit update destroy]

    def index
      @global_book_notes_count = global_book_notes_count
      @books = Book.by_user(current_user.id)
    end

    def new
      @book = Book.new
    end

    def create
      result = BookServices::BookCreator.call(book_params, current_user)
      if result.success?
        redirect_to backend_books_path
      else
        @book = result.object
        render :new
      end
    end

    def show
      @book = if params[:id] == 'nil'
                OpenStruct.new(
                  name: '-',
                  notes: OpenStruct.new(count: global_book_notes_count)
                )
              else
                Book.by_user(current_user.id).find(params[:id])
              end
    end

    def edit; end

    def update
      result = BookServices::BookUpdater.call(book_params, @book)
      if result.success?
        redirect_to backend_books_path
      else
        @book = result.object
        render :new
      end
    end

    def destroy
      result = BookServices::BookDestroyer.call(@book)
      if result.success?
        redirect_to backend_books_path
      else
        @book = result.object
        render :new
      end
    end

    private

    def book_params
      params.require(:book).permit(:name)
    end

    def global_book_notes_count
      Note.by_user(current_user.id).where(book_id: nil).count
    end

    def set_book
      @book = Book.by_user(current_user.id).find(params[:id])
    end
  end
end