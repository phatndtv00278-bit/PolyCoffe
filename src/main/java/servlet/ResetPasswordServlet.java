package servlet;

import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.mindrot.jbcrypt.BCrypt;
import util.ParamUtil;

import java.io.IOException;

@WebServlet("/reset-password")
public class ResetPasswordServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.getRequestDispatcher("/reset-password.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String email = ParamUtil.getString(req, "email", "").trim();
        String otp = ParamUtil.getString(req, "otp", "").trim();
        String newPassword = ParamUtil.getString(req, "newPassword", "");
        String confirmPassword = ParamUtil.getString(req, "confirmPassword", "");

        HttpSession session = req.getSession();
        String sessionEmail = (String) session.getAttribute("resetEmail");
        String sessionOtp = (String) session.getAttribute("resetOtp");

        if (email.isBlank() || otp.isBlank() || newPassword.isBlank() || confirmPassword.isBlank()) {
            req.setAttribute("error", "Vui lòng nhập đầy đủ thông tin.");
            req.getRequestDispatcher("/reset-password.jsp").forward(req, resp);
            return;
        }

        if (!newPassword.equals(confirmPassword)) {
            req.setAttribute("error", "Mật khẩu xác nhận không khớp.");
            req.getRequestDispatcher("/reset-password.jsp").forward(req, resp);
            return;
        }

        if (sessionEmail == null || sessionOtp == null) {
            req.setAttribute("error", "Phiên đặt lại mật khẩu đã hết hạn. Vui lòng thử lại.");
            req.getRequestDispatcher("/forgot-password.jsp").forward(req, resp);
            return;
        }

        if (!email.equalsIgnoreCase(sessionEmail) || !otp.equals(sessionOtp)) {
            req.setAttribute("error", "Email hoặc mã xác nhận không đúng.");
            req.getRequestDispatcher("/reset-password.jsp").forward(req, resp);
            return;
        }

        String hashedPassword = BCrypt.hashpw(newPassword, BCrypt.gensalt());
        boolean updated = userDAO.updatePasswordByEmail(email, hashedPassword);

        if (updated) {
            session.removeAttribute("resetEmail");
            session.removeAttribute("resetOtp");
            resp.sendRedirect(req.getContextPath() + "/login?resetSuccess=true");
        } else {
            req.setAttribute("error", "Đổi mật khẩu thất bại.");
            req.getRequestDispatcher("/reset-password.jsp").forward(req, resp);
        }
    }
}