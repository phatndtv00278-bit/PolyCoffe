package servlet;

import dao.OrderDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.Order;
import model.OrderDetail;
import util.AuthUtil;
import util.ParamUtil;

import java.io.IOException;
import java.util.List;

@WebServlet("/admin/orders")
public class OrderListServlet extends HttpServlet {

    private final OrderDAO orderDAO = new OrderDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (!AuthUtil.isLogin(req)) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        if (!AuthUtil.isAdmin(req)) {
            resp.sendRedirect(req.getContextPath() + "/access-denied.jsp");
            return;
        }

        List<Order> orders = orderDAO.findAll();
        req.setAttribute("orders", orders);

        int orderId = ParamUtil.getInt(req, "orderId", -1);
        if (orderId > 0) {
            List<OrderDetail> details = orderDAO.findDetailsByOrderId(orderId);
            req.setAttribute("details", details);
            req.setAttribute("selectedOrderId", orderId);
        }

        req.getRequestDispatcher("/admin-orders.jsp").forward(req, resp);
    }
}