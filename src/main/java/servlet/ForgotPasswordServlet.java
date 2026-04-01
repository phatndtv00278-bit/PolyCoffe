package servlet;

import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;
import util.MailUtil;
import util.ParamUtil;

import java.io.IOException;
import java.util.Random;

@WebServlet("/forgot-password")
public class ForgotPasswordServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.getRequestDispatcher("/forgot-password.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String email = ParamUtil.getString(req, "email", "").trim();

        if (email.isBlank()) {
            req.setAttribute("error", "Vui lòng nhập email.");
            req.getRequestDispatcher("/forgot-password.jsp").forward(req, resp);
            return;
        }

        User user = userDAO.findByEmail(email);
        if (user == null) {
            req.setAttribute("error", "Email này chưa được đăng ký.");
            req.getRequestDispatcher("/forgot-password.jsp").forward(req, resp);
            return;
        }

        String otp = generateOtp();

        HttpSession session = req.getSession();
        session.setAttribute("resetEmail", email);
        session.setAttribute("resetOtp", otp);

        boolean mailSent = MailUtil.sendForgotPasswordOtp(email, otp);

        if (mailSent) {
            req.setAttribute("success", "Mã xác nhận đã được gửi về email của bạn.");
            req.getRequestDispatcher("/reset-password.jsp").forward(req, resp);
        } else {
            req.setAttribute("error", "Gửi email thất bại. Vui lòng thử lại.");
            req.getRequestDispatcher("/forgot-password.jsp").forward(req, resp);
        }
    }

    private String generateOtp() {
        Random random = new Random();
        int code = 100000 + random.nextInt(900000);
        return String.valueOf(code);
    }
}