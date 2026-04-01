package servlet;

import dao.OrderDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.CartItem;
import model.User;
import util.AuthUtil;
import util.CartUtil;

import java.io.IOException;
import java.util.List;

@WebServlet("/checkout")
public class CheckoutServlet extends HttpServlet {

    private final OrderDAO orderDAO = new OrderDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (!AuthUtil.isLogin(req)) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        HttpSession session = req.getSession();
        User user = (User) session.getAttribute("loggedInUser");
        List<CartItem> cart = CartUtil.getCart(session);

        if (cart == null || cart.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/home");
            return;
        }

        double totalAmount = CartUtil.getTotalAmount(session);
        int orderId = orderDAO.createCashOrder(user.getId(), totalAmount, cart);

        if (orderId > 0) {
            CartUtil.clear(session);
            session.setAttribute("successMessage", "Thanh toán tiền mặt thành công. Mã hóa đơn: #" + orderId);
        } else {
            session.setAttribute("successMessage", "Thanh toán thất bại. Vui lòng thử lại.");
        }

        resp.sendRedirect(req.getContextPath() + "/home");
    }
}