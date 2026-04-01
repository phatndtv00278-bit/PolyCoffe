package servlet;

import dao.UserDAO;
import model.User;
import org.mindrot.jbcrypt.BCrypt;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.getRequestDispatcher("login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        String username = req.getParameter("username");
        String password = req.getParameter("password");

        if (username == null || password == null || username.isBlank() || password.isBlank()) {
            req.setAttribute("error", "Vui lòng nhập username và password.");
            req.getRequestDispatcher("login.jsp").forward(req, resp);
            return;
        }

        User user = userDAO.findByUsername(username);

        if (user != null && BCrypt.checkpw(password, user.getPassword())) {
            HttpSession session = req.getSession();
           session.setAttribute("loggedInUser", user);
            resp.sendRedirect(req.getContextPath() + "/home");
        } else {
            req.setAttribute("error", "Sai tài khoản hoặc mật khẩu.");
            req.getRequestDispatcher("login.jsp").forward(req, resp);
        }
    }
}