module ApplicationHelper
  def current_class?(test_path)
    return 'active' if test_path == '/' and request.path == '/'
    unless test_path == '/' then
      return 'active' if request.path.include? test_path
    end
    ''
  end
end
