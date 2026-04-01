package servlet;

import dao.UserDAO;
import model.User;
import org.mindrot.jbcrypt.BCrypt;
import util.MailUtil;
import util.ParamUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.getRequestDispatcher("register.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String fullName = ParamUtil.getString(req, "fullName", "");
        String email = ParamUtil.getString(req, "email", "");
        String username = ParamUtil.getString(req, "username", "");
        String password = ParamUtil.getString(req, "password", "");
        String confirmPassword = ParamUtil.getString(req, "confirmPassword", "");

        if (fullName.isBlank() || email.isBlank() || username.isBlank() || password.isBlank() || confirmPassword.isBlank()) {
            req.setAttribute("error", "Vui lòng nhập đầy đủ thông tin.");
            req.getRequestDispatcher("register.jsp").forward(req, resp);
            return;
        }

        if (!password.equals(confirmPassword)) {
            req.setAttribute("error", "Mật khẩu xác nhận không khớp.");
            req.getRequestDispatcher("register.jsp").forward(req, resp);
            return;
        }

        if (userDAO.existsByUsernameOrEmail(username, email)) {
            req.setAttribute("error", "Username hoặc email đã tồn tại.");
            req.getRequestDispatcher("register.jsp").forward(req, resp);
            return;
        }

        String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());

        User user = new User();
        user.setFullName(fullName);
        user.setEmail(email);
        user.setUsername(username);
        user.setPassword(hashedPassword);
        user.setRole("user");

        boolean success = userDAO.register(user);

        if (success) {
            // Gửi mail sau khi đăng ký thành công
            MailUtil.sendRegisterSuccessMail(email, fullName, username);

            // Chuyển về login và báo đăng ký thành công
            resp.sendRedirect(req.getContextPath() + "/login?registered=true");
        } else {
            req.setAttribute("error", "Đăng ký thất bại.");
            req.getRequestDispatcher("register.jsp").forward(req, resp);
        }
    }
}