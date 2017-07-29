defmodule Core.PageControllerTest do
  use Core.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 302) =~ "You are being <a href=\"https://brandnewcongress.org\">redirected</a>."  end
end
