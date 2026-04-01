package servlet;

import dao.OrderDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.Order;
import model.OrderDetail;
import model.User;
import util.AuthUtil;
import util.ParamUtil;

import java.io.IOException;
import java.util.List;

@WebServlet("/purchase-history")
public class PurchaseHistoryServlet extends HttpServlet {

    private final OrderDAO orderDAO = new OrderDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (!AuthUtil.isLogin(req)) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        HttpSession session = req.getSession();
        User user = (User) session.getAttribute("loggedInUser");

        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        List<Order> orders = orderDAO.findByUserId(user.getId());
        req.setAttribute("orders", orders);

        int orderId = ParamUtil.getInt(req, "orderId", -1);
        if (orderId > 0) {
            Order selectedOrder = orderDAO.findByIdAndUserId(orderId, user.getId());
            if (selectedOrder != null) {
                List<OrderDetail> details = orderDAO.findDetailsByOrderIdAndUserId(orderId, user.getId());
                req.setAttribute("selectedOrder", selectedOrder);
                req.setAttribute("details", details);
                req.setAttribute("selectedOrderId", orderId);
            }
        }

        req.getRequestDispatcher("/purchase-history.jsp").forward(req, resp);
    }
}